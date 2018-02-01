all:
	cargo build --release --target i686-unknown-linux-gnu
	if [ -f ../libvg.so ]; then rm ../libvg.so; fi
	cp target/i686-unknown-linux-gnu/release/liblibvg.so ../libvg.so
