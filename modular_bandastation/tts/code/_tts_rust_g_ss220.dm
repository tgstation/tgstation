// rust_g_ss220.dm - DM API for rust_g_ss220 extension library
//
// To configure, create a `rust_g_ss220.config.dm` and set what you care about from
// the following options:
//
// #define RUST_G_SS220 "path/to/rust_g_ss220"
// Override the .dll/.so detection logic with a fixed path or with detection
// logic of your own.
//
// #define RUSTG_OVERRIDE_BUILTINS
// Enable replacement rust-g functions for certain builtins. Off by default.

#ifndef RUST_G_SS220
// Default automatic RUST_G_SS220 detection.
// On Windows, looks in the standard places for `rust_g_ss220.dll`.
// On Linux, looks in `.`, `$LD_LIBRARY_PATH`, and `~/.byond/bin` for either of
// `librust_g_ss220.so` (preferred) or `rust_g_ss220` (old).

/* This comment bypasses grep checks */ /var/__rust_g_ss220

/proc/__detect_rust_g_ss220()
	if (world.system_type == UNIX)
		if (fexists("./librust_g_ss220.so"))
			// No need for LD_LIBRARY_PATH badness.
			return __rust_g_ss220 = "./librust_g_ss220.so"
		else if (fexists("./rust_g_ss220"))
			// Old dumb filename.
			return __rust_g_ss220 = "./rust_g_ss220"
		else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/rust_g_ss220"))
			// Old dumb filename in `~/.byond/bin`.
			return __rust_g_ss220 = "rust_g_ss220"
		else
			// It's not in the current directory, so try others
			return __rust_g_ss220 = "librust_g_ss220.so"
	else
		return __rust_g_ss220 = "rust_g_ss220"

#define RUST_G_SS220 (__rust_g_ss220 || __detect_rust_g_ss220())
#endif

/// Gets the version of rust_g
/proc/rustgss220_get_version() return RUSTG_CALL(RUST_G_SS220, "get_version")()

#define rustgss220_file_write_b64decode(text, fname) RUSTG_CALL(RUST_G_SS220, "file_write")(text, fname, "true")

// Hashing Operations //
#define rustgss220_hash_string(algorithm, text) RUSTG_CALL(RUST_G_SS220, "hash_string")(algorithm, text)
#define rustgss220_hash_file(algorithm, fname) RUSTG_CALL(RUST_G_SS220, "hash_file")(algorithm, fname)

#define RUSTG_HASH_MD5 "md5"

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define md5(thing) (isfile(thing) ? rustgss220_hash_file(RUSTG_HASH_MD5, "[thing]") : rustgss220_hash_string(RUSTG_HASH_MD5, thing))
#endif

// Text Operations //
#define rustgss220_cyrillic_to_latin(text) RUSTG_CALL(RUST_G_SS220, "cyrillic_to_latin")("[text]")
#define rustgss220_latin_to_cyrillic(text) RUSTG_CALL(RUST_G_SS220, "latin_to_cyrillic")("[text]")

/proc/rustgss220_create_async_http_client() return RUSTG_CALL(RUST_G_SS220, "start_http_client")()
/proc/rustgss220_close_async_http_client() return RUSTG_CALL(RUST_G_SS220, "shutdown_http_client")()
