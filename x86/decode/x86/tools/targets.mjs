// Shared target resolution for the headless v86 drivers.
//
// Layout:
//   x86/targets.json      registry of guests
//   x86/tools/            these scripts (shared by all targets)
//   x86/<target>/images/  disk image + saved state   (gitignored)
//   x86/<target>/traces/  raw counter dumps          (gitignored)
//   x86/<target>/instructions/  final artifacts      (tracked)

import fs from "node:fs";
import path from "node:path";
import url from "node:url";

export const TOOLS_DIR = url.fileURLToPath(new URL(".", import.meta.url));
export const X86_DIR = path.resolve(TOOLS_DIR, "..");
export const V86_DIR = path.join(X86_DIR, "decoders/v86");

const registry = JSON.parse(fs.readFileSync(path.join(X86_DIR, "targets.json"), "utf8"));

export const TARGETS = registry.targets;

export function listTargets()
{
    return Object.keys(TARGETS);
}

/**
 * Resolve a target id into everything the drivers need.
 * @param {string} id
 */
export function resolveTarget(id)
{
    const t = TARGETS[id];
    if(!t)
    {
        throw new Error(`unknown target '${id}'; known: ${listTargets().join(", ")}`);
    }

    const dir = path.join(X86_DIR, id);
    const images = path.join(dir, "images");

    return {
        id,
        ...t,
        dir,
        images,
        traces: path.join(dir, "traces"),
        instructions: path.join(dir, "instructions"),
        hda: path.join(images, t.image.file),
        state: t.image.state ? path.join(images, t.image.state) : null,
    };
}

/** Common V86 constructor options for a target. */
export function v86Options(target, { useState = false, memory = null } = {})
{
    const opts = {
        wasm_path: path.join(V86_DIR, "build/v86.wasm"),
        bios: { url: path.join(V86_DIR, "bios/seabios.bin") },
        vga_bios: { url: path.join(V86_DIR, "bios/vgabios.bin") },
        memory_size: (memory || target.memory) * 1024 * 1024,
        vga_memory_size: 8 * 1024 * 1024,
        hda: { url: target.hda, async: true },
        autostart: true,
        disable_speaker: true,
    };

    if(target.cpuid_level) opts.cpuid_level = target.cpuid_level;

    if(useState)
    {
        if(!target.state)
        {
            throw new Error(`target '${target.id}' has no saved state upstream; cold boot it instead`);
        }
        if(!fs.existsSync(target.state))
        {
            throw new Error(`state not found: ${target.state}\n  run: ./fetch_image.sh ${target.id} state`);
        }
        opts.initial_state = { url: target.state };
    }

    if(!fs.existsSync(target.hda))
    {
        throw new Error(`disk image not found: ${target.hda}\n  run: ./fetch_image.sh ${target.id}`);
    }

    return opts;
}

/** Tiny argv helper shared by the drivers. */
export function argsOf(argv)
{
    return {
        get: (name, dflt) => {
            const i = argv.indexOf("--" + name);
            if(i === -1) return dflt;
            const v = argv[i + 1];
            return v === undefined || v.startsWith("--") ? dflt : v;
        },
        all: name => argv.reduce((a, v, i) =>
            (v === "--" + name && argv[i + 1] && !argv[i + 1].startsWith("--"))
                ? [...a, argv[i + 1]] : a, []),
        flag: name => argv.includes("--" + name),
    };
}

// ------------------------------------------------------------------ input
// Ctrl+Alt+Del: NT's Secure Attention Sequence cannot be produced by
// keyboard_send_text, so it goes in as raw make/break scancodes.
export const CAD_SCANCODES = [0x1D, 0x38, 0xE0, 0x53, 0xE0, 0xD3, 0xB8, 0x9D];

export const SCANCODES = {
    esc: 0x01, enter: 0x1C, space: 0x39, tab: 0x0F, backspace: 0x0E,
    up: 0xE048, down: 0xE050, left: 0xE04B, right: 0xE04D,
    f1: 0x3B, f8: 0x42, delete: 0xE053,
};

/**
 * Schedule the target's scripted logon (targets.json "login" array).
 * Steps: { at, cad } | { at, key } | { at, type }
 * @returns {number} seconds at which the last step fires
 */
export function scheduleLogin(emulator, steps, log = () => {})
{
    let last = 0;

    const sendKey = name => {
        const c = SCANCODES[name];
        if(c === undefined) { log(`unknown key '${name}'`); return; }
        const make = c > 0xFF ? [c >> 8, c & 0xFF] : [c];
        const brk = c > 0xFF ? [c >> 8, (c & 0xFF) | 0x80] : [c | 0x80];
        emulator.keyboard_send_scancodes([...make, ...brk]);
    };

    for(const step of steps || [])
    {
        last = Math.max(last, step.at);
        setTimeout(() => {
            if(step.cad)
            {
                log(`[key] ctrl+alt+del`);
                emulator.keyboard_send_scancodes(CAD_SCANCODES);
            }
            else if(step.key)
            {
                log(`[key] ${step.key}`);
                sendKey(step.key);
            }
            else if(step.type !== undefined)
            {
                log(`[key] type ${JSON.stringify(step.type)}`);
                emulator.keyboard_send_text(step.type.replace(/\\n/g, "\n"));
            }
        }, step.at * 1000);
    }
    return last;
}
