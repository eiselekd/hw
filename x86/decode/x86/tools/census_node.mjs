#!/usr/bin/env node
// Headless instruction census driver for the instrumented v86 build
// (see ../decoders/v86-patch and ./README.md).
//
//   make -C ../decoders/v86 with-win98stats build/libv86-debug.mjs
//   ./fetch_image.sh win98
//   ./census_node.mjs --target win98 --seconds 600 --phase-every 120 \
//       --out ../win98/traces/win98.boot.tsv
//
// Targets come from x86/targets.json and reproduce the configuration used by
// the hosted demo at copy.sh/v86 (memory size, image, cpuid level), so the
// census matches what the browser demo actually executes.
//
// Options:
//   --target <id>         see ./fetch_image.sh --list
//   --hda/--hdb/--cdrom/--fda   explicit images (override the target)
//   --state               resume from the demo's boot-to-desktop state
//   --state <file>        resume from an explicit saved state
//   --bios/--vgabios      default: v86's seabios
//   --memory <MB>         default: the target's
//   --seconds <n>         wall-clock run time (default: target boot_seconds)
//   --login               replay the target's scripted logon (targets.json).
//                         Required for NT/2000: without it the census only
//                         covers the pre-logon kernel, never the shell.
//   --phase-every <n>     also snapshot every n seconds
//   --out <file>          output TSV (default: <target>/traces/<id>.boot.tsv)
//   --l8trace <file>      also dump the deduplicated *encoding* corpus (JSONL:
//                         instruction bytes per encoding shape).  Needs a build
//                         with `make -C ../decoders/v86 with-l8trace`.
//   --screen              dump the text-mode screen with each snapshot
//   --serial              echo serial output to stderr
//   --verbose             don't suppress v86's debug log
//
// Produces aggregate.py "form 1" TSV.  SIGINT dumps and exits.

import fs from "node:fs";
import path from "node:path";
import { TOOLS_DIR, V86_DIR, resolveTarget, v86Options, listTargets, argsOf, scheduleLogin }
    from "./targets.mjs";

// ------------------------------------------------------------------ args
const argv = process.argv.slice(2);
const { get: arg, flag } = argsOf(argv);

const log = console.error.bind(console);
if(!flag("verbose")) console.log = () => {};   // libv86-debug is very chatty

let target;
try { target = resolveTarget(arg("target", "win98")); }
catch(e) { log(e.message); process.exit(1); }

const seconds = Number(arg("seconds", target.boot_seconds || 60));
const phaseEvery = Number(arg("phase-every", target.phase_every || 0));
const out = arg("out", path.join(target.traces, `${target.id}.boot.tsv`));

const { V86 } = await import(path.join(V86_DIR, "build/libv86-debug.mjs"));

// v86_census.js is a plain script, not a module; evaluate it into scope.
const { Win98Census } = (() => {
    const src = fs.readFileSync(path.join(TOOLS_DIR, "v86_census.js"), "utf8");
    const mod = { exports: {} };
    new Function("module", "exports", "globalThis", src)(mod, mod.exports, globalThis);
    return mod.exports;
})();

const { L8Corpus } = (() => {
    const src = fs.readFileSync(path.join(TOOLS_DIR, "l8_corpus.js"), "utf8");
    const mod = { exports: {} };
    new Function("module", "exports", "globalThis", src)(mod, mod.exports, globalThis);
    return mod.exports;
})();

// ------------------------------------------------------------------ config
let opts;
try
{
    opts = v86Options(target, {
        useState: flag("state") && !arg("state", null),
        memory: arg("memory", null) ? Number(arg("memory")) : null,
    });
}
catch(e) { log(e.message); process.exit(1); }

if(arg("bios", null)) opts.bios = { url: path.resolve(arg("bios")) };
if(arg("vgabios", null)) opts.vga_bios = { url: path.resolve(arg("vgabios")) };

for(const d of ["hda", "hdb", "cdrom", "fda", "fdb"])
{
    const v = arg(d, null);
    if(v) opts[d] = { url: path.resolve(v), async: true };
}

const explicitState = arg("state", null);
if(explicitState) opts.initial_state = { url: path.resolve(explicitState) };

for(const k of ["hda", "hdb", "cdrom", "fda", "initial_state"])
{
    if(opts[k] && !fs.existsSync(opts[k].url))
    {
        log(`missing ${k}: ${opts[k].url}\n` +
            `fetch it with:  ./fetch_image.sh ${target.id}` +
            (k === "initial_state" ? " state" : ""));
        process.exit(1);
    }
}

fs.mkdirSync(path.dirname(out), { recursive: true });

const t0 = Date.now();
log(`booting ${target.id} (${target.name}): ` +
    Object.entries(opts).filter(([, v]) => v && v.url)
        .map(([k, v]) => `${k}=${path.basename(v.url)}`).join(" ") +
    ` mem=${opts.memory_size / 1048576}M`);

// ------------------------------------------------------------------ run
const emulator = new V86(opts);

if(flag("serial"))
{
    emulator.add_listener("serial0-output-byte", b =>
        process.stderr.write(String.fromCharCode(b)));
}

// NT-family guests sit at a "press Ctrl+Alt+Del" prompt forever; without the
// scripted logon the census would only ever see the pre-logon kernel.
if(flag("login"))
{
    const last = scheduleLogin(emulator, target.login,
        m => log(`${m} @ ${((Date.now() - t0) / 1000).toFixed(0)}s`));
    if(!target.login?.length) log(`note: target '${target.id}' defines no login steps`);
    else if(last >= seconds)
        log(`warning: last login step at ${last}s but --seconds is ${seconds}`);
}

// Cheap progress indicator: track the VGA mode and text-mode screen, so the log
// shows the boot moving real-mode text -> 640x480 -> the GUI.
const screen = { w: 80, h: 25, bpp: 0, chars: new Map() };
emulator.add_listener("screen-set-size", ([w, h, bpp]) => {
    screen.w = w; screen.h = h; screen.bpp = bpp;
    screen.chars.clear();
    log(`[screen] ${w}x${h} ${bpp ? bpp + "bpp graphical" : "text"}` +
        ` @ ${((Date.now() - t0) / 1000).toFixed(0)}s`);
});
emulator.add_listener("screen-put-char", ([row, col, chr]) =>
    screen.chars.set(row * 256 + col, chr));

function screenText()
{
    if(screen.bpp) return `(graphical ${screen.w}x${screen.h}x${screen.bpp})`;
    const lines = [];
    for(let r = 0; r < screen.h; r++)
    {
        let s = "";
        for(let c = 0; c < screen.w; c++)
            s += String.fromCharCode(screen.chars.get(r * 256 + c) || 32);
        if(s.trim()) lines.push(s.replace(/\s+$/, ""));
    }
    return lines.join("\n") || "(blank)";
}

let census = null;
let corpus = null;
const l8out = arg("l8trace", null);
const attach = setInterval(() => {
    const cpu = emulator.v86 && emulator.v86.cpu;
    if(!cpu || !cpu.wm || !cpu.wm.exports) return;
    census = new Win98Census(cpu);
    census.clear();
    log("census attached, counters cleared");
    if(l8out)
    {
        // Shapes are cumulative across the whole run on purpose: clearing them
        // per phase would lose every real-mode encoding once the boot leaves
        // real mode.  Only the counts are per-phase.
        corpus = new L8Corpus(cpu);
        corpus.clearAll();
        log("l8trace corpus attached");
    }
    clearInterval(attach);
}, 100);

if(phaseEvery > 0)
{
    let n = 0;
    setInterval(() => {
        if(!census) return;
        n++;
        const base = out.replace(/\.tsv$/, "");
        fs.writeFileSync(`${base}.phase${n}.tsv`, census.toTSV());
        log(`[phase ${n}] t=${((Date.now() - t0) / 1000).toFixed(0)}s` +
            ` -> ${base}.phase${n}.tsv`);
        if(corpus)
        {
            const f = l8out.replace(/\.jsonl$/, "") + `.phase${n}.jsonl`;
            fs.mkdirSync(path.dirname(f), { recursive: true });
            fs.writeFileSync(f, corpus.toJSONL({ phase: n }));
            log(`[phase ${n}] ${corpus.summary()} -> ${f}`);
            // Counts are NOT cleared: each phase file is cumulative-so-far, so
            // the final file is the whole boot and "new in phase n" is a diff
            // against phase n-1.  Clearing would make the last file useless.
        }
        if(flag("screen")) log(screenText());
    }, phaseEvery * 1000);
}

let finished = false;
function finish()
{
    if(finished) return;
    finished = true;
    if(!census)
    {
        log("census never attached -- was v86 built with --features win98stats?");
        process.exit(1);
    }
    const tsv = census.toTSV();
    fs.writeFileSync(out, tsv);
    log("[+] wrote " + out);
    log(census.summary());
    if(corpus)
    {
        fs.mkdirSync(path.dirname(l8out), { recursive: true });
        fs.writeFileSync(l8out, corpus.toJSONL());
        log("[+] wrote " + l8out);
        log(corpus.summary());
    }
    if(flag("screen")) log("--- screen ---\n" + screenText());
    log(`elapsed ${((Date.now() - t0) / 1000).toFixed(1)}s`);
    process.exit(0);
}

process.on("SIGINT", finish);
setTimeout(finish, seconds * 1000);
