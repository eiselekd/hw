// Win98 ISA census -- browser-side reader for the v86 `win98stats` build.
//
// Requires v86 built with:   make with-win98stats
// (see x86/win98/tools/README.md and the patch applied to x86/decoders/v86)
//
// Usage in the v86 page (or the browser console on copy.sh/v86):
//
//     const c = new Win98Census(emulator.v86.cpu);
//     c.clear();                       // start of a phase
//     ... let it boot ...
//     c.download("win98.phase3.pmode.tsv");
//     console.log(c.summary());
//
// Output is aggregate.py "form 1" TSV:
//     <count>\t<mode>\t<opcode>\t<ext>\t<mnemonic>

"use strict";

const PREFIX_BYTES = [0x26, 0x2E, 0x36, 0x3E, 0x64, 0x65, 0x66, 0x67, 0xF0, 0xF2, 0xF3];

const PREFIX_NAMES = {
    0x26: "es", 0x2E: "cs", 0x36: "ss", 0x3E: "ds", 0x64: "fs", 0x65: "gs",
    0x66: "opsize", 0x67: "addrsize", 0xF0: "lock", 0xF2: "repnz", 0xF3: "rep",
};

class Win98Census
{
    /** @param {Object} cpu  emulator.v86.cpu */
    constructor(cpu)
    {
        this.cpu = cpu;
        const e = cpu.wm.exports;
        if(!e["win98_get_stat"])
        {
            throw new Error("v86 was not built with --features win98stats (make with-win98stats)");
        }
        this.get = e["win98_get_stat"];
        this.getPrefix = e["win98_get_prefix_stat"];
        this.getTotal = e["win98_get_total"];
        this.clearFn = e["win98_clear_stats"];
    }

    clear() { this.clearFn(); }

    /** index = is_32<<13 | is_0f<<12 | opcode<<4 | is_mem<<3 | fixed_g */
    static index(is32, is0f, opcode, isMem, fixedG)
    {
        return (is32 ? 1 : 0) << 13 | (is0f ? 1 : 0) << 12 |
               (opcode & 0xFF) << 4 | (isMem ? 1 : 0) << 3 | (fixedG & 7);
    }

    /** @returns {Array<{mode:number,is0f:boolean,opcode:number,isMem:boolean,fixedG:number,count:number}>} */
    entries()
    {
        const out = [];
        for(let is32 = 0; is32 < 2; is32++)
        for(let is0f = 0; is0f < 2; is0f++)
        for(let opcode = 0; opcode < 0x100; opcode++)
        for(let isMem = 0; isMem < 2; isMem++)
        for(let fixedG = 0; fixedG < 8; fixedG++)
        {
            const idx = Win98Census.index(is32, is0f, opcode, isMem, fixedG);
            const count = this.get(idx);
            if(count > 0)
            {
                out.push({
                    mode: is32 ? 32 : 16,
                    is0f: !!is0f,
                    opcode,
                    isMem: !!isMem,
                    fixedG,
                    count,
                });
            }
        }
        out.sort((a, b) => b.count - a.count);
        return out;
    }

    prefixes()
    {
        const out = [];
        for(const b of PREFIX_BYTES)
        {
            const count = this.getPrefix(b);
            if(count > 0) out.push({ byte: b, name: PREFIX_NAMES[b], count });
        }
        return out.sort((a, b) => b.count - a.count);
    }

    /**
     * Opcodes whose modrm reg field is an opcode extension.  Must stay in sync
     * with `has_fixed_g` in src/rust/win98stats.rs (derived from
     * ref.x86asm.net `<opcd_ext>` entries).  For all other opcodes `fixedG`
     * is 0 and must be ignored.  `isMem` says whether mod != 3.
     */
    static hasFixedG(is0f, opcode)
    {
        if(is0f)
        {
            return opcode === 0x00 || opcode === 0x01 || opcode === 0x18 ||
                   opcode === 0x1F ||
                   (opcode >= 0x71 && opcode <= 0x73) ||
                   (opcode >= 0x90 && opcode <= 0x9F) ||
                   opcode === 0xAE || opcode === 0xBA || opcode === 0xC7;
        }
        return (opcode >= 0x80 && opcode <= 0x83) || opcode === 0x8F ||
               opcode === 0xC0 || opcode === 0xC1 ||
               opcode === 0xC6 || opcode === 0xC7 ||
               (opcode >= 0xD0 && opcode <= 0xD3) ||
               (opcode >= 0xD8 && opcode <= 0xDF) ||
               opcode === 0xF6 || opcode === 0xF7 ||
               opcode === 0xFE || opcode === 0xFF;
    }

    static hex(is0f, opcode)
    {
        const b = opcode.toString(16).toUpperCase().padStart(2, "0");
        return is0f ? "0F " + b : b;
    }

    toTSV()
    {
        let out = "#count\tmode\topcode\text\tmnemonic\n";
        out += "#total-instructions\t" + this.getTotal() + "\n";
        for(const p of this.prefixes())
        {
            out += `#prefix\t${p.byte.toString(16).toUpperCase().padStart(2, "0")}\t${p.name}\t${p.count}\n`;
        }
        for(const e of this.entries())
        {
            const ext = Win98Census.hasFixedG(e.is0f, e.opcode) ? "/" + e.fixedG : "-";
            const mem = e.isMem ? "m" : "r";
            out += `${e.count}\t${e.mode}\t${Win98Census.hex(e.is0f, e.opcode)}\t${ext}\t?\t${mem}\n`;
        }
        return out;
    }

    summary()
    {
        const e = this.entries();
        const total = e.reduce((a, x) => a + x.count, 0);
        let acc = 0, n50 = 0, n90 = 0, n99 = 0, n999 = 0;
        e.forEach((x, i) => {
            acc += x.count;
            const p = acc / total;
            if(!n50 && p >= 0.50) n50 = i + 1;
            if(!n90 && p >= 0.90) n90 = i + 1;
            if(!n99 && p >= 0.99) n99 = i + 1;
            if(!n999 && p >= 0.999) n999 = i + 1;
        });
        return [
            `total instructions: ${total.toLocaleString()}`,
            `distinct encodings: ${e.length}`,
            `50%: ${n50}  90%: ${n90}  99%: ${n99}  99.9%: ${n999} encodings`,
            "top 20:",
            ...e.slice(0, 20).map(x =>
                `  ${String(x.count).padStart(14)}  ${x.mode}b ${Win98Census.hex(x.is0f, x.opcode)}` +
                (Win98Census.hasFixedG(x.is0f, x.opcode) ? " /" + x.fixedG : "") +
                (x.isMem ? " [mem]" : " [reg]")),
        ].join("\n");
    }

    download(name = "win98.trace.tsv")
    {
        const blob = new Blob([this.toTSV()], { type: "text/tab-separated-values" });
        const a = document.createElement("a");
        a.href = URL.createObjectURL(blob);
        a.download = name;
        document.body.appendChild(a);
        a.click();
        a.remove();
    }

    /** Convenience: snapshot a phase and reset for the next one. */
    phase(name)
    {
        this.download(`win98.${name}.tsv`);
        console.log(`[${name}]\n` + this.summary());
        this.clear();
    }
}

if(typeof globalThis !== "undefined") globalThis.Win98Census = Win98Census;
if(typeof module !== "undefined") module.exports = { Win98Census };
