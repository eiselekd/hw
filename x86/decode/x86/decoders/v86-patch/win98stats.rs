// Win98 boot instruction census for v86.
//
// v86 already has `opstats` (feature = "profiler"), but it only counts
// instructions executed from *JIT-compiled* blocks and has no 16/32-bit code
// segment bit.  For the Win98 ISA census we need the opposite bias: we care
// about instructions that execute *once* (LGDT, MOV CRn, real-mode BIOS code) —
// exactly the ones that never get hot enough to be compiled.
//
// This module therefore counts both paths:
//   - interpreted: called from cpu::jit_run_interpreted
//   - compiled:    an inline i64 increment emitted into the generated block
//
// Index layout (16384 entries):
//     is_32 << 13 | is_0f << 12 | opcode << 4 | is_mem << 3 | fixed_g
//
// Enabled by `--features win98stats` (see Cargo.toml).

use crate::opstats;
#[cfg(feature = "win98stats")]
use crate::wasmgen::wasm_builder::WasmBuilder;

/// Opcodes whose modrm reg field is an opcode extension ("group" opcodes).
///
/// v86's own `opstats::decode` uses a narrower list which omits 0F 00, 0F 01,
/// 0F 18, 8F, C6 and C7 -- and 0F 01 is exactly where LGDT/LIDT/LMSW/INVLPG
/// live, i.e. the instructions that matter most for a boot census.
/// This list is derived from ref.x86asm.net (`<opcd_ext>` entries).
fn has_fixed_g(is_0f: bool, opcode: u8) -> bool {
    if is_0f {
        matches!(opcode,
            0x00 | 0x01 | 0x18 | 0x1F |
            0x71 | 0x72 | 0x73 |
            0x90..=0x9F |
            0xAE | 0xBA | 0xC7)
    }
    else {
        matches!(opcode,
            0x80..=0x83 | 0x8F |
            0xC0 | 0xC1 | 0xC6 | 0xC7 |
            0xD0..=0xD3 | 0xD8..=0xDF |
            0xF6 | 0xF7 | 0xFE | 0xFF)
    }
}

/// Re-decode with the wider group-opcode list.  Everything except `fixed_g`
/// comes from v86's own decoder so the two stay consistent.
fn decode(instruction: u32) -> opstats::Instruction {
    let mut op = opstats::decode(instruction);
    if !has_fixed_g(op.is_0f, op.opcode) {
        op.fixed_g = 0;
        return op;
    }
    // Skip prefixes + (0F) + opcode to find the modrm byte.
    let skip = op.prefixes.len() + if op.is_0f { 2 } else { 1 };
    if skip < 4 {
        let modrm = (instruction >> (8 * skip)) as u8;
        op.fixed_g = modrm >> 3 & 7;
        op.is_mem = modrm < 0xC0;
    }
    op
}

pub const WIN98_STATS_SIZE: usize = if cfg!(feature = "win98stats") { 16384 } else { 0 };

#[allow(non_upper_case_globals)]
pub static mut win98_buffer: [u64; WIN98_STATS_SIZE] = [0; WIN98_STATS_SIZE];
/// Separate prefix histogram: prefix byte -> count.
#[allow(non_upper_case_globals)]
pub static mut win98_prefix_buffer: [u64; 256] = [0; 256];
/// Total instructions counted (sanity / coverage denominator).
#[allow(non_upper_case_globals)]
pub static mut win98_total: u64 = 0;

#[inline]
pub fn index_of(op: &opstats::Instruction, is_32: bool) -> usize {
    (is_32 as usize) << 13
        | (op.is_0f as usize) << 12
        | (op.opcode as usize) << 4
        | (op.is_mem as usize) << 3
        | op.fixed_g as usize
}

/// Called for every instruction executed by the interpreter.
/// `instruction` is the little-endian dword at the start of the instruction.
#[cfg(feature = "win98stats")]
pub unsafe fn record_interpreted(instruction: u32, is_32: bool) {
    let op = decode(instruction);
    for prefix in &op.prefixes {
        win98_prefix_buffer[*prefix as usize] += 1;
    }
    win98_buffer[index_of(&op, is_32)] += 1;
    win98_total += 1;
}

#[cfg(not(feature = "win98stats"))]
pub unsafe fn record_interpreted(_instruction: u32, _is_32: bool) {}

/// Emits an inline increment into the JIT-generated wasm for one instruction.
#[cfg(feature = "win98stats")]
pub fn gen_record_compiled(builder: &mut WasmBuilder, instruction: u32, is_32: bool) {
    let op = decode(instruction);

    for prefix in &op.prefixes {
        builder.increment_fixed_i64(
            unsafe { &mut win98_prefix_buffer[*prefix as usize] as *mut _ } as u32,
            1,
        );
    }

    builder.increment_fixed_i64(
        unsafe { &mut win98_buffer[index_of(&op, is_32)] as *mut _ } as u32,
        1,
    );
    builder.increment_fixed_i64((&raw mut win98_total) as u32, 1);
}

#[cfg(not(feature = "win98stats"))]
pub fn gen_record_compiled(_builder: &mut crate::wasmgen::wasm_builder::WasmBuilder, _i: u32, _b: bool) {
}

// ---------------------------------------------------------------- JS exports

#[no_mangle]
#[cfg(feature = "win98stats")]
pub unsafe fn win98_get_stat(index: u32) -> f64 {
    if (index as usize) < WIN98_STATS_SIZE { win98_buffer[index as usize] as f64 } else { 0.0 }
}

#[no_mangle]
#[cfg(feature = "win98stats")]
pub unsafe fn win98_get_prefix_stat(prefix: u32) -> f64 {
    if (prefix as usize) < 256 { win98_prefix_buffer[prefix as usize] as f64 } else { 0.0 }
}

#[no_mangle]
#[cfg(feature = "win98stats")]
pub unsafe fn win98_get_total() -> f64 { win98_total as f64 }

#[no_mangle]
#[cfg(feature = "win98stats")]
pub unsafe fn win98_clear_stats() {
    #[allow(static_mut_refs)]
    for v in win98_buffer.iter_mut() {
        *v = 0
    }
    #[allow(static_mut_refs)]
    for v in win98_prefix_buffer.iter_mut() {
        *v = 0
    }
    win98_total = 0;
}

#[no_mangle]
#[cfg(not(feature = "win98stats"))]
pub unsafe fn win98_get_stat(_index: u32) -> f64 { 0.0 }
#[no_mangle]
#[cfg(not(feature = "win98stats"))]
pub unsafe fn win98_get_prefix_stat(_p: u32) -> f64 { 0.0 }
#[no_mangle]
#[cfg(not(feature = "win98stats"))]
pub unsafe fn win98_get_total() -> f64 { 0.0 }
#[no_mangle]
#[cfg(not(feature = "win98stats"))]
pub unsafe fn win98_clear_stats() {}
