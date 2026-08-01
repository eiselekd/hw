# v86 `win98stats` patch

The v86 clone in `../v86/` is gitignored (it is a shallow upstream checkout).
This directory holds the delta so it can be reapplied:

```sh
cd x86/decoders
./fetch.sh v86
cp v86-patch/win98stats.rs v86/src/rust/win98stats.rs
git -C v86 apply ../v86-patch/win98stats.patch
cd v86 && make with-win98stats
```

`win98stats.patch` touches `Cargo.toml`, `Makefile`, `src/rust/lib.rs`,
`src/rust/cpu/cpu.rs` and `src/rust/jit.rs`; `win98stats.rs` is the new module.

Rationale and counter layout: [../../win98/tools/README.md](../../win98/tools/README.md).
