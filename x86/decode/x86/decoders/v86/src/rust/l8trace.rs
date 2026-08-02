// l8trace — deduplicated *encoding* corpus for decoder verification.
//
// `win98stats` answers "which opcodes execute, how often". That is a histogram
// over 16384 buckets and says nothing about the bytes: no modrm, no SIB, no
// displacement, no immediate. To verify a decoder's operand extraction we need
// the actual instruction bytes.
//
// A full boot is ~10^10 instructions, so the bytes must be deduplicated inside
// the emulator; a text trace is not viable (it would be terabytes).
//
// DEDUPLICATION KEY = the ENCODING SHAPE:
//
//     mode(16/32) + prefixes + [0F] + opcode + modrm + sib
//
// i.e. everything up to and including the last byte that *steers* the decode,
// and nothing that is merely a value. That is at most 4 + 2 + 1 + 1 = 8 bytes,
// so the key fits in a u64. Displacements and immediates are deliberately NOT
// in the key: they are exactly the fields a decoder can get wrong, so instead
// of multiplying the key space we keep up to `VARIANTS` distinct full byte
// strings per key, which gives the consumer several disp/imm values per shape
// at bounded cost.
//
// This is the right axis: it is the same partition the decode tables use, so
// "every key seen" == "every decode path exercised".
//
// SIZE: 131072 slots x (8 key + 4 meta + 8 count + 2*16 bytes + 2 len) = ~6.8 MB
// of zero-initialised bss (no wasm file size cost), and the dump is a few
// hundred KB of JSONL.
//
// Enabled by `--features l8trace`.

pub const L8_SLOTS: usize = if cfg!(feature = "l8trace") { 131072 } else { 0 };
/// Distinct full byte strings kept per encoding shape.
pub const L8_VARIANTS: usize = 2;
/// Bytes captured per sample. x86 instructions are at most 15 bytes.
pub const L8_BYTES_PER: usize = 16;
/// Give up (and count a drop) after this many probes.
const MAX_PROBE: usize = 64;

#[allow(non_upper_case_globals)]
pub static mut l8_key: [u64; L8_SLOTS] = [0; L8_SLOTS];
/// bit 0..7 header length in bytes, bit 8 is_32, bit 16..17 variant count,
/// bit 24 slot used, bit 25 truncated (page boundary cut the sample short)
#[allow(non_upper_case_globals)]
pub static mut l8_meta: [u32; L8_SLOTS] = [0; L8_SLOTS];
/// Dynamic execution count for this shape.
#[allow(non_upper_case_globals)]
pub static mut l8_count: [u64; L8_SLOTS] = [0; L8_SLOTS];
#[allow(non_upper_case_globals)]
pub static mut l8_bytes: [u8; L8_SLOTS * L8_VARIANTS * L8_BYTES_PER] =
    [0; L8_SLOTS * L8_VARIANTS * L8_BYTES_PER];
#[allow(non_upper_case_globals)]
pub static mut l8_nbytes: [u8; L8_SLOTS * L8_VARIANTS] = [0; L8_SLOTS * L8_VARIANTS];

#[allow(non_upper_case_globals)]
pub static mut l8_total: u64 = 0;
#[allow(non_upper_case_globals)]
pub static mut l8_distinct: u32 = 0;
/// Samples lost because the table was full (should stay 0).
#[allow(non_upper_case_globals)]
pub static mut l8_dropped: u64 = 0;

/// Does this opcode have a modrm byte?
///
/// Same information as `opstats::decode`'s internal table, restated here
/// because we need it for the *length of the key*, not just for `is_mem`, and
/// because the 0F list below is the wider one from win98stats (0F 00/01/18
/// are missing from v86's, and 0F 01 is where LGDT/LIDT/INVLPG live).
fn has_modrm(is_0f: bool, op: u8) -> bool {
    if is_0f {
        matches!(op,
            0x00..=0x03 | 0x0D | 0x0F | 0x10..=0x17 | 0x18..=0x1F |
            0x20..=0x23 | 0x28..=0x2F | 0x40..=0x4F | 0x50..=0x77 |
            0x7C..=0x7F | 0x90..=0x9F | 0xA3..=0xA5 | 0xAB..=0xAF |
            0xB0..=0xB7 | 0xB8 | 0xBA..=0xBF | 0xC0..=0xC7 | 0xD0..=0xFE)
    }
    else {
        matches!(op,
            0x00..=0x03 | 0x08..=0x0B | 0x10..=0x13 | 0x18..=0x1B |
            0x20..=0x23 | 0x28..=0x2B | 0x30..=0x33 | 0x38..=0x3B |
            0x62 | 0x63 | 0x69 | 0x6B |
            0x80..=0x8F | 0xC0 | 0xC1 | 0xC4..=0xC7 | 0xD0..=0xD3 |
            0xD8..=0xDF | 0xF6 | 0xF7 | 0xFE | 0xFF)
    }
}

/// Number of leading bytes that steer the decode: prefixes, 0F escape, opcode,
/// modrm, sib. Returns `(header_len, ok)`; `ok` is false when the captured
/// sample was too short to see the whole header.
pub fn header_len(bytes: &[u8], is_32: bool) -> (usize, bool) {
    let mut i = 0;
    let mut has67 = false;
    // At most four prefix bytes, one per group. Scan defensively: a run longer
    // than four is architecturally undefined, and we must not run off the end.
    while i < 4 && i < bytes.len() {
        match bytes[i] {
            0x67 => has67 = true,
            0x26 | 0x2E | 0x36 | 0x3E | 0x64 | 0x65 | 0x66 | 0xF0 | 0xF2 | 0xF3 => {},
            _ => break,
        }
        i += 1;
    }
    if i >= bytes.len() {
        return (i, false);
    }
    let is_0f = bytes[i] == 0x0F;
    if is_0f {
        i += 1;
        if i >= bytes.len() {
            return (i, false);
        }
    }
    let op = bytes[i];
    i += 1;

    if !has_modrm(is_0f, op) {
        return (i, true);
    }
    if i >= bytes.len() {
        return (i, false);
    }
    let modrm = bytes[i];
    i += 1;

    // SIB exists only in 32-bit addressing. The address size is the segment's
    // D bit flipped by a 0x67 prefix -- which is precisely why `has67` above is
    // tracked separately from the other prefixes.
    let addr32 = is_32 != has67;
    let md = modrm >> 6;
    let rm = modrm & 7;
    if addr32 && md != 3 && rm == 4 {
        if i >= bytes.len() {
            return (i, false);
        }
        i += 1; // sib
    }
    (i, true)
}

#[inline]
fn key_of(bytes: &[u8], hdr: usize) -> u64 {
    let mut k = 0u64;
    for j in 0..hdr.min(8) {
        k |= (bytes[j] as u64) << (8 * j);
    }
    k
}

#[inline]
fn hash(key: u64, is_32: bool, hdr: usize) -> usize {
    // 64->32 mix (splitmix-ish). Cheap: this runs on every instruction.
    let mut h = key ^ ((is_32 as u64) << 60) ^ ((hdr as u64) << 56);
    h ^= h >> 33;
    h = h.wrapping_mul(0xff51_afd7_ed55_8ccd);
    h ^= h >> 29;
    (h as usize) & (L8_SLOTS - 1)
}

/// Record one executed instruction. `bytes` is what could be read without
/// crossing the page boundary (1..=16 bytes).
#[cfg(feature = "l8trace")]
pub unsafe fn record(bytes: &[u8], is_32: bool) {
    l8_total += 1;
    if bytes.is_empty() {
        return;
    }

    let (hdr, complete) = header_len(bytes, is_32);
    let key = key_of(bytes, hdr);

    let mut slot = hash(key, is_32, hdr);
    // Linear probing. The table is sized far above the expected distinct-key
    // count, so this is almost always a single load and no probe at all.
    for _ in 0..MAX_PROBE {
        let meta = l8_meta[slot];
        if meta & (1 << 24) == 0 {
            // free slot: claim it, and store this byte string as variant 0
            l8_key[slot] = key;
            l8_count[slot] = 1;
            l8_distinct += 1;
            store_variant(slot, bytes, 0);
            l8_meta[slot] = (hdr as u32 & 0xFF)
                | (is_32 as u32) << 8
                | 1 << 16
                | 1 << 24
                | ((!complete as u32) << 25);
            return;
        }
        if l8_key[slot] == key
            && (meta & 0xFF) == hdr as u32
            && ((meta >> 8) & 1) == is_32 as u32
        {
            // known shape: maybe keep this byte string as another variant, so
            // the corpus carries more than one displacement/immediate value
            let nvar = ((meta >> 16) & 3) as usize;
            if nvar < L8_VARIANTS && !have_variant(slot, bytes, nvar) {
                store_variant(slot, bytes, nvar);
                l8_meta[slot] = (meta & !(3 << 16)) | ((nvar as u32 + 1) << 16);
            }
            l8_count[slot] += 1;
            return;
        }
        slot = (slot + 1) & (L8_SLOTS - 1);
    }
    l8_dropped += 1;
}

#[cfg(feature = "l8trace")]
unsafe fn have_variant(slot: usize, bytes: &[u8], nvar: usize) -> bool {
    for v in 0..nvar {
        let base = (slot * L8_VARIANTS + v) * L8_BYTES_PER;
        let n = l8_nbytes[slot * L8_VARIANTS + v] as usize;
        if n == bytes.len() && l8_bytes[base..base + n] == *bytes {
            return true;
        }
    }
    false
}

#[cfg(feature = "l8trace")]
unsafe fn store_variant(slot: usize, bytes: &[u8], v: usize) {
    let n = bytes.len().min(L8_BYTES_PER);
    let base = (slot * L8_VARIANTS + v) * L8_BYTES_PER;
    l8_bytes[base..base + n].copy_from_slice(&bytes[..n]);
    l8_nbytes[slot * L8_VARIANTS + v] = n as u8;
}

#[cfg(not(feature = "l8trace"))]
pub unsafe fn record(_bytes: &[u8], _is_32: bool) {}

// ---------------------------------------------------------------- JS exports
//
// Read out with per-field getters rather than by handing JS a pointer: v86's
// wasm memory layout is not something this module should depend on, and a dump
// happens a handful of times per boot.

#[no_mangle]
#[cfg(feature = "l8trace")]
pub unsafe fn l8_get_slots() -> u32 { L8_SLOTS as u32 }
#[no_mangle]
#[cfg(feature = "l8trace")]
pub unsafe fn l8_get_meta(slot: u32) -> u32 {
    if (slot as usize) < L8_SLOTS { l8_meta[slot as usize] } else { 0 }
}
#[no_mangle]
#[cfg(feature = "l8trace")]
pub unsafe fn l8_get_count(slot: u32) -> f64 {
    if (slot as usize) < L8_SLOTS { l8_count[slot as usize] as f64 } else { 0.0 }
}
#[no_mangle]
#[cfg(feature = "l8trace")]
pub unsafe fn l8_get_nbytes(slot: u32, v: u32) -> u32 {
    let i = slot as usize * L8_VARIANTS + v as usize;
    if i < L8_SLOTS * L8_VARIANTS { l8_nbytes[i] as u32 } else { 0 }
}
#[no_mangle]
#[cfg(feature = "l8trace")]
pub unsafe fn l8_get_byte(slot: u32, v: u32, k: u32) -> u32 {
    let i = (slot as usize * L8_VARIANTS + v as usize) * L8_BYTES_PER + k as usize;
    if i < L8_SLOTS * L8_VARIANTS * L8_BYTES_PER { l8_bytes[i] as u32 } else { 0 }
}
#[no_mangle]
#[cfg(feature = "l8trace")]
pub unsafe fn l8_get_total() -> f64 { l8_total as f64 }
#[no_mangle]
#[cfg(feature = "l8trace")]
pub unsafe fn l8_get_distinct() -> u32 { l8_distinct }
#[no_mangle]
#[cfg(feature = "l8trace")]
pub unsafe fn l8_get_dropped() -> f64 { l8_dropped as f64 }

/// Clear counts only. The *shapes* are cumulative across phases on purpose:
/// clearing them would lose real-mode encodings once the boot leaves real mode,
/// and the per-phase question ("what is new in this phase") is answered by the
/// count being zero at the phase boundary.
#[no_mangle]
#[cfg(feature = "l8trace")]
pub unsafe fn l8_clear_counts() {
    #[allow(static_mut_refs)]
    for v in l8_count.iter_mut() {
        *v = 0
    }
    l8_total = 0;
}

#[no_mangle]
#[cfg(feature = "l8trace")]
pub unsafe fn l8_clear_all() {
    #[allow(static_mut_refs)]
    for v in l8_meta.iter_mut() {
        *v = 0
    }
    l8_clear_counts();
    l8_distinct = 0;
    l8_dropped = 0;
}

#[no_mangle]
#[cfg(not(feature = "l8trace"))]
pub unsafe fn l8_get_slots() -> u32 { 0 }
#[no_mangle]
#[cfg(not(feature = "l8trace"))]
pub unsafe fn l8_get_meta(_s: u32) -> u32 { 0 }
#[no_mangle]
#[cfg(not(feature = "l8trace"))]
pub unsafe fn l8_get_count(_s: u32) -> f64 { 0.0 }
#[no_mangle]
#[cfg(not(feature = "l8trace"))]
pub unsafe fn l8_get_nbytes(_s: u32, _v: u32) -> u32 { 0 }
#[no_mangle]
#[cfg(not(feature = "l8trace"))]
pub unsafe fn l8_get_byte(_s: u32, _v: u32, _k: u32) -> u32 { 0 }
#[no_mangle]
#[cfg(not(feature = "l8trace"))]
pub unsafe fn l8_get_total() -> f64 { 0.0 }
#[no_mangle]
#[cfg(not(feature = "l8trace"))]
pub unsafe fn l8_get_distinct() -> u32 { 0 }
#[no_mangle]
#[cfg(not(feature = "l8trace"))]
pub unsafe fn l8_get_dropped() -> f64 { 0.0 }
#[no_mangle]
#[cfg(not(feature = "l8trace"))]
pub unsafe fn l8_clear_counts() {}
#[no_mangle]
#[cfg(not(feature = "l8trace"))]
pub unsafe fn l8_clear_all() {}
