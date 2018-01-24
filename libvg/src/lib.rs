// Disallow warnings when testing.
#![cfg_attr(test, deny(warnings))]

#[macro_use]
extern crate byond;
extern crate encoding;
extern crate libc;

pub mod utf8;
