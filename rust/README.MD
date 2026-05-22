# Paradise Rust Libraries

## Info

These libraries allow rust code for things that are incredibly slow or outright impossible in DM.
Think of it like a ParadiseSS13 specifiy version of [rust-g](https://github.com/tgstation/rust-g).

It currently handles:

- Atmospherics (`milla`)
- DMM manipulation stuff (`mapmanip`)

## Building

BYOND 516.1651 introduced breaking changes to ByondAPI, the interop system to get data other than strings in and out of DLLs.
Because of this, you need to specify the `--no-default-features --features byond-516` to build the 516 compliant lib. Not specifying a feature will build for versions `515.1621` to `516.1650`. Specifying `byond-516` will build for `516.1651` and up.
