// Encoding-corpus reader for the v86 `l8trace` build.
//
// Requires:   make -C x86/decoders/v86 with-l8trace
//
// The wasm side keeps a hash table keyed by *encoding shape*
// (mode + prefixes + [0F] + opcode + modrm + sib) holding up to two distinct
// full instruction byte strings per shape plus a dynamic execution count.
// This reads it out. See src/rust/l8trace.rs for the layout and the reasoning.
//
//     const c = new L8Corpus(emulator.v86.cpu);
//     ... boot ...
//     fs.writeFileSync("corpus.jsonl", c.toJSONL());

"use strict";

class L8Corpus
{
    /** @param {Object} cpu  emulator.v86.cpu */
    constructor(cpu)
    {
        const e = cpu.wm.exports;
        if(!e["l8_get_slots"] || e["l8_get_slots"]() === 0)
        {
            throw new Error("v86 was not built with --features l8trace " +
                            "(make -C decoders/v86 with-l8trace)");
        }
        this.e = e;
        this.slots = e["l8_get_slots"]();
    }

    total()    { return this.e["l8_get_total"](); }
    distinct() { return this.e["l8_get_distinct"](); }
    dropped()  { return this.e["l8_get_dropped"](); }

    clearCounts() { this.e["l8_clear_counts"](); }
    clearAll()    { this.e["l8_clear_all"](); }

    /**
     * @returns {Array<{mode:number,hdr:number,count:number,truncated:boolean,
     *                  bytes:string[]}>}
     * `bytes` are the distinct full byte strings seen for this shape, hex.
     */
    entries()
    {
        const { l8_get_meta, l8_get_count, l8_get_nbytes, l8_get_byte } = this.e;
        const out = [];
        for(let s = 0; s < this.slots; s++)
        {
            const meta = l8_get_meta(s);
            if((meta & (1 << 24)) === 0) continue;       // slot unused

            const hdr = meta & 0xFF;
            const mode = ((meta >> 8) & 1) ? 32 : 16;
            const nvar = (meta >> 16) & 3;
            const truncated = !!(meta & (1 << 25));

            const bytes = [];
            for(let v = 0; v < nvar; v++)
            {
                const n = l8_get_nbytes(s, v);
                let hex = "";
                for(let k = 0; k < n; k++)
                    hex += l8_get_byte(s, v, k).toString(16).padStart(2, "0");
                if(hex) bytes.push(hex);
            }
            if(!bytes.length) continue;

            out.push({ mode, hdr, count: l8_get_count(s), truncated, bytes });
        }
        // Hottest first: the report weights mismatches by dynamic count, and a
        // truncated corpus should keep the instructions that matter.
        out.sort((a, b) => b.count - a.count);
        return out;
    }

    /**
     * One JSON object per encoding shape.  JSONL rather than one big array so
     * phases can simply be concatenated and the file can be streamed.
     */
    toJSONL(extra = {})
    {
        return this.entries().map(e => JSON.stringify(Object.assign({
            mode: e.mode,
            hdr: e.hdr,
            count: e.count,
            bytes: e.bytes,
            ...(e.truncated ? { truncated: true } : {}),
        }, extra))).join("\n") + "\n";
    }

    summary()
    {
        const e = this.entries();
        const nb = e.reduce((a, x) => a + x.bytes.length, 0);
        return `l8trace: ${e.length} encoding shapes, ${nb} byte strings, ` +
               `${this.total().toLocaleString()} instructions` +
               (this.dropped() ? `, ${this.dropped()} DROPPED (table full)` : "");
    }
}

if(typeof module !== "undefined") module.exports = { L8Corpus };
