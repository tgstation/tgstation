//! I have no idea WHY this is but to bench these you need to disable dylib in cargo.

#![feature(test)]
extern crate test;
extern crate libvg;

use libvg::utf8::{to_utf8, utf8_sanitize};
use std::ffi::CString;
use test::Bencher;

#[bench]
fn bench_utf8(b: &mut Bencher) {
    let encoding = CString::new("1252".as_bytes()).unwrap();
    let message = CString::new(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras elementum \
                      mauris eu odio bibendum, ut porttitor libero vulputate. Vivamus et augue \
                      justo. Quisque ut auctor lectus. Vestibulum ante ipsum primis in faucibus \
                      orci luctus et ultrices posuere cubilia Curae; Maecenas non scelerisque \
                      nisl. Suspendisse egestas, diam et aliquam ultrices, mi est condimentum \
                      neque, eu fermentum dolor justo at lectus. Nam consequat dolor sit amet \
                      massa convallis volutpat eget eget nibh. Nullam a ultricies elit. Etiam eu \
                      quam interdum, ornare enim vitae, placerat dolor. Curabitur a tempor ex. \
                      Curabitur metus elit, pharetra nec faucibus a, consectetur nec ex. \
                      Pellentesque venenatis dapibus mi et vulputate. Nullam laoreet, tortor at \
                      rutrum sagittis, nibh purus ultrices est, ut efficitur nulla dui vel \
                      felis. Etiam malesuada nec orci in rutrum. Ut consectetur ante vitae arcu \
                      ultricies hendrerit. Etiam a tempor enim."
            .as_bytes(),
    ).unwrap();

    let both = [encoding.as_ptr(), message.as_ptr()];

    b.iter(|| to_utf8(2, both.as_ptr()))
}

#[bench]
fn bench_sanitize(b: &mut Bencher) {
    let encoding = CString::new("1252".as_bytes()).unwrap();
    let message = CString::new(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras elementum \
                      mauris eu odio bibendum, ut porttitor libero vulputate. Vivamus et augue \
                      justo. Quisque ut auctor lectus. Vestibulum ante ipsum primis in faucibus \
                      orci luctus et ultrices posuere cubilia Curae; Maecenas non scelerisque \
                      nisl. Suspendisse egestas, diam et aliquam ultrices, mi est condimentum \
                      neque, eu fermentum dolor justo at lectus. Nam consequat dolor sit amet \
                      massa convallis volutpat eget eget nibh. Nullam a ultricies elit. Etiam eu \
                      quam interdum, ornare enim vitae, placerat dolor. Curabitur a tempor ex. \
                      Curabitur metus elit, pharetra nec faucibus a, consectetur nec ex. \
                      Pellentesque venenatis dapibus mi et vulputate. Nullam laoreet, tortor at \
                      rutrum sagittis, nibh purus ultrices est, ut efficitur nulla dui vel \
                      felis. Etiam malesuada nec orci in rutrum. Ut consectetur ante vitae arcu \
                      ultricies hendrerit. Etiam a tempor enim."
            .as_bytes(),
    ).unwrap();
    let cap = CString::new("1024".as_bytes()).unwrap();

    let both = [encoding.as_ptr(), message.as_ptr(), cap.as_ptr()];

    b.iter(|| utf8_sanitize(3, both.as_ptr()))
}
