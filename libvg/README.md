# What's this?
This is a [Rust](https://www.rust-lang.org)-based library that is invoked throughout the /vg/station13 code.

# Uses:
* UTF-8 handling.

# Building
First of all, you're gonna need to install **nightly** Rust. The website (linked above) has the Rustup installer which you can use to easily install the Rust toolchain. If you are on a 64-bit system it'll probably install `x86_64` for you, though because BYOND is stuck in the stone age you need to compile for `i686` instead. To install the `i686` version of the toolchain, simply run:
```powershell
rustup default nightly-i686
```

Easiest way to build on both Windows and Linux is to run `build.ps1` with Powershell.
If you do not have Powershell installed on Linux, a basic makefile is also available.

If either of those don't work, do not fear! Building Rust code is extremely simple. To build manually, simply run the following command:

```powershell
cargo build --release --target $target
```

Where `$target` is `i686-pc-windows-msvc` on Windows or `i686-unknown-linux-gnu` on Linux.

The binary will then be placed in `target/$target/release/`, which you can copy next to the root project. On Linux it's incorrectly named as `liblibvg.so`, so make sure to rename it to `libvg.so` when you do!
