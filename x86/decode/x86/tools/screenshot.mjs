#!/usr/bin/env node
// Capture the emulated screen from a headless v86 run and write a PNG.
//
//   ./screenshot.mjs --target win98 --state --out /tmp/desktop.png
//   ./screenshot.mjs --target winnt --seconds 300 --out /tmp/nt4.png
//   ./screenshot.mjs --target winnt --shots        (-> ../winnt/shots/*.png)
//
// v86 renders graphical modes into an RGBA buffer inside the wasm memory at
// `vga.dest_buffet_offset` (sic) and then calls screen.update_buffer(), which is
// a no-op under the DummyScreenAdapter used headlessly.  So we can just call
// screen_fill_buffer() ourselves and read the pixels straight out of wasm
// memory.  Text modes are rasterised from VGA memory + the plane-2 font.
//
// PNGs are written with node's built-in zlib, so there are no dependencies.

import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";
import { V86_DIR, resolveTarget, v86Options, argsOf, scheduleLogin } from "./targets.mjs";

// ------------------------------------------------------------------ args
const argv = process.argv.slice(2);
const { get: arg, all, flag } = argsOf(argv);

const log = console.error.bind(console);
if(!flag("verbose")) console.log = () => {};

let target;
try { target = resolveTarget(arg("target", "win98")); }
catch(e) { log(e.message); process.exit(1); }

// --shot N (repeatable) overrides the target's default shot schedule;
// --shots uses the schedule from targets.json;
// --shot-every N samples every N seconds up to --seconds.
let shots = all("shot").map(Number);
if(!shots.length && flag("shots")) shots = (target.shots || []).slice();

const every = Number(arg("shot-every", 0));
const seconds = Number(arg("seconds",
    shots.length ? Math.max(...shots) + 5 : (target.boot_seconds || 30)));

if(every > 0)
{
    for(let t = every; t <= seconds; t += every) shots.push(t);
}
shots = [...new Set(shots)].sort((a, b) => a - b);

const out = arg("out", path.join(target.dir, "shots", `${target.id}.png`));
const ascii = flag("ascii");

// ------------------------------------------------------------------ PNG
function crc32(buf)
{
    let c, table = crc32.table;
    if(!table)
    {
        table = crc32.table = new Int32Array(256);
        for(let n = 0; n < 256; n++)
        {
            c = n;
            for(let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
            table[n] = c;
        }
    }
    c = -1;
    for(let i = 0; i < buf.length; i++) c = table[(c ^ buf[i]) & 0xFF] ^ (c >>> 8);
    return (c ^ -1) >>> 0;
}

function chunk(type, data)
{
    const len = Buffer.alloc(4);
    len.writeUInt32BE(data.length);
    const body = Buffer.concat([Buffer.from(type, "ascii"), data]);
    const crc = Buffer.alloc(4);
    crc.writeUInt32BE(crc32(body));
    return Buffer.concat([len, body, crc]);
}

/** @param {Uint8Array} rgba  width*height*4 */
function png(rgba, width, height)
{
    // add the per-scanline filter byte (0 = none)
    const raw = Buffer.alloc(height * (1 + width * 4));
    for(let y = 0; y < height; y++)
    {
        raw[y * (1 + width * 4)] = 0;
        Buffer.from(rgba.buffer, rgba.byteOffset + y * width * 4, width * 4)
            .copy(raw, y * (1 + width * 4) + 1);
    }
    const ihdr = Buffer.alloc(13);
    ihdr.writeUInt32BE(width, 0);
    ihdr.writeUInt32BE(height, 4);
    ihdr[8] = 8;    // bit depth
    ihdr[9] = 6;    // colour type RGBA
    return Buffer.concat([
        Buffer.from([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
        chunk("IHDR", ihdr),
        chunk("IDAT", zlib.deflateSync(raw, { level: 9 })),
        chunk("IEND", Buffer.alloc(0)),
    ]);
}

// ------------------------------------------------------------------ capture
function captureGraphical(cpu, vga)
{
    vga.screen_fill_buffer();

    const width = vga.svga_enabled ? vga.svga_width : vga.screen_width;
    const height = vga.svga_enabled ? vga.svga_height : vga.screen_height;
    const stride = vga.svga_enabled ? width : vga.virtual_width;
    if(!width || !height) return null;

    const src = new Uint8Array(cpu.wasm_memory.buffer,
                               vga.dest_buffet_offset, stride * height * 4);
    // v86 stores BGRA-ish words; normalise to RGBA
    const dst = new Uint8Array(width * height * 4);
    for(let y = 0; y < height; y++)
    {
        for(let x = 0; x < width; x++)
        {
            const s = (y * stride + x) * 4;
            const d = (y * width + x) * 4;
            dst[d + 0] = src[s + 0];
            dst[d + 1] = src[s + 1];
            dst[d + 2] = src[s + 2];
            dst[d + 3] = 255;
        }
    }
    return { rgba: dst, width, height };
}

// Text mode: read characters + attributes straight out of VGA plane 0/1 and
// rasterise them with the character generator the BIOS loaded into plane 2.
function captureText(cpu, vga)
{
    const cols = vga.max_cols || 80;
    const rows = vga.max_rows || 25;
    const cw = 8, ch = 16;
    const width = cols * cw, height = rows * ch;
    const rgba = new Uint8Array(width * height * 4);

    const mem = vga.vga_memory;
    const font = vga.plane2;
    const row_offset = Math.max(0, (vga.offset_register * 2 - cols) * 2);
    const blink = vga.attribute_mode & 1 << 3;
    const fg_mask = vga.font_page_ab_enabled ? 7 : 0xF;
    const bg_mask = blink ? 7 : 0xF;
    const pal = i => vga.vga256_palette[vga.dac_mask & vga.dac_map[i]] >>> 0;

    let addr = vga.start_address << 1;
    for(let r = 0; r < rows; r++, addr += row_offset)
    for(let c = 0; c < cols; c++, addr += 2)
    {
        const chr = mem[addr];
        const color = mem[addr | 1];
        const fg = pal(color & fg_mask);
        const bg = pal(color >> 4 & bg_mask);
        for(let y = 0; y < ch; y++)
        {
            const bits = font ? font[chr * 32 + y] : 0;
            for(let x = 0; x < cw; x++)
            {
                const col = (bits >> (7 - x)) & 1 ? fg : bg;
                const d = ((r * ch + y) * width + c * cw + x) * 4;
                rgba[d + 0] = (col >> 16) & 0xFF;
                rgba[d + 1] = (col >> 8) & 0xFF;
                rgba[d + 2] = col & 0xFF;
                rgba[d + 3] = 255;
            }
        }
    }
    return { rgba, width, height };
}

// ------------------------------------------------------------------ run
// vga.js only allocates the RGBA destination buffer when `ImageData` exists
// (`else { // TODO: nodejs }`).  Provide the two fields it uses so the headless
// run actually renders graphical modes.
if(typeof globalThis.ImageData === "undefined")
{
    globalThis.ImageData = class ImageData {
        constructor(data, width, height) {
            this.data = data;
            this.width = width;
            this.height = height;
        }
    };
}

const { V86 } = await import(path.join(V86_DIR, "build/libv86-debug.mjs"));

let opts;
try
{
    opts = v86Options(target, {
        useState: flag("state") && !arg("state", null),
        memory: arg("memory", null) ? Number(arg("memory")) : null,
    });
}
catch(e) { log(e.message); process.exit(1); }

const explicitState = arg("state", null);
if(explicitState) opts.initial_state = { url: path.resolve(explicitState) };

fs.mkdirSync(path.dirname(path.resolve(out)), { recursive: true });

log(`booting ${target.id} (${target.name})${flag("state") ? " from state" : ""}, ` +
    `capturing at ${shots.length ? shots.join("s, ") + "s" : seconds + "s"}`);

const emulator = new V86(opts);
const t0 = Date.now();

const elapsed = () => ((Date.now() - t0) / 1000).toFixed(0);

emulator.add_listener("screen-set-size", ([w, h, bpp]) => {
    log(`[screen] ${w}x${h} ${bpp ? bpp + "bpp graphical" : "text"} @ ${elapsed()}s`);
});

// --cad <sec>            send Ctrl+Alt+Del (NT's Secure Attention Sequence)
// --type <sec>:<text>    type text, "\n" = Enter
// --scan <sec>:<name>    send a raw key by name (esc, enter, space, tab, ...)
// --login                run the target's scripted logon from targets.json
const steps = [];
for(const t of all("cad").map(Number)) steps.push({ at: t, cad: true });
for(const spec of all("type"))
{
    const i = spec.indexOf(":");
    steps.push({ at: Number(spec.slice(0, i)), type: spec.slice(i + 1) });
}
for(const spec of all("scan"))
{
    const i = spec.indexOf(":");
    steps.push({ at: Number(spec.slice(0, i)), key: spec.slice(i + 1) });
}
if(flag("login")) steps.push(...(target.login || []));

scheduleLogin(emulator, steps, m => log(`${m} @ ${elapsed()}s`));

/** Coarse ASCII rendering so a boot can be watched from the terminal. */
function asciiPreview(img, cols = 78, rows = 22)
{
    const ramp = " .:-=+*#%@";
    const lines = [];
    for(let r = 0; r < rows; r++)
    {
        const y = Math.floor(r * img.height / rows);
        let s = "";
        for(let c = 0; c < cols; c++)
        {
            const x = Math.floor(c * img.width / cols);
            const o = (y * img.width + x) * 4;
            const lum = (img.rgba[o] * 30 + img.rgba[o + 1] * 59 + img.rgba[o + 2] * 11) / 100;
            s += ramp[Math.min(9, Math.floor(lum * 10 / 256))];
        }
        lines.push(s);
    }
    return lines.join("\n");
}

function capture(label)
{
    const cpu = emulator.v86 && emulator.v86.cpu;
    const vga = cpu && cpu.devices && cpu.devices.vga;
    if(!vga) { log("no vga yet"); return; }

    const img = vga.graphical_mode
        ? captureGraphical(cpu, vga)
        : captureText(cpu, vga);

    if(!img) { log("nothing to capture"); return; }

    const file = label
        ? out.replace(/\.png$/, "") + `.${label}.png`
        : (out.endsWith(".png") ? out : out + ".png");
    fs.writeFileSync(file, png(img.rgba, img.width, img.height));
    const mode = vga.graphical_mode
        ? (vga.svga_enabled ? "svga " + vga.svga_bpp + "bpp" : "vga")
        : "text";
    log(`[+] ${path.basename(file)}  ${img.width}x${img.height} ${mode}  t=${elapsed()}s`);
    if(ascii) log(asciiPreview(img) + "\n");
}

for(const t of shots) setTimeout(() => capture(`t${t}s`), t * 1000);
setTimeout(() => { if(!shots.length) capture(null); process.exit(0); }, seconds * 1000);
process.on("SIGINT", () => { capture(null); process.exit(0); });
