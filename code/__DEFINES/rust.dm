// DM API for Rust extension modules

// Default automatic library detection.
// Look for it in the build location first, then in `.`, then in standard places.

/* This comment bypasses grep checks */ /var/__rustlib

// This works by allowing rust to compile with modern x86 instructionns, instead of compiling for a pentium 4
// This has the potential for significant speed upgrades with SIMD and similar

#ifdef PARADISE_PRODUCTION_HARDWARE
#define RUSTLIBS_SUFFIX "_prod"
#else
#define RUSTLIBS_SUFFIX ""
#endif

/proc/__detect_rustlib()
	if(world.system_type == UNIX)
#ifdef CIBUILDING
		// CI override, use librustlibs_ci.so if possible.
		if(fexists("./tools/ci/librustlibs_ci.so"))
			return __rustlib = "tools/ci/librustlibs_ci.so"
#endif
		// First check if it's built in the usual place.
		// Linx doesnt get the version suffix because if youre using linux you can figure out what server version youre running for
		if(fexists("./rust/target/i686-unknown-linux-gnu/release/librustlibs[RUSTLIBS_SUFFIX].so"))
			return __rustlib = "./rust/target/i686-unknown-linux-gnu/release/librustlibs[RUSTLIBS_SUFFIX].so"
		// Then check in the current directory.
		if(fexists("./librustlibs[RUSTLIBS_SUFFIX].so"))
			return __rustlib = "./librustlibs[RUSTLIBS_SUFFIX].so"
		// And elsewhere.
		return __rustlib = "librustlibs[RUSTLIBS_SUFFIX].so"
	else
		// First check if it's built in the usual place.
		if(fexists("./rust/target/i686-pc-windows-msvc/debug/rustlibs.dll"))
			return __rustlib = "./rust/target/i686-pc-windows-msvc/debug/rustlibs.dll"
		if(fexists("./rust/target/i686-pc-windows-msvc/release/rustlibs.dll"))
			return __rustlib = "./rust/target/i686-pc-windows-msvc/release/rustlibs.dll"

		if(fexists("./rust/target/i686-pc-windows-gnu/release/rustlibs.dll"))
			return __rustlib = "./rust/target/i686-pc-windows-gnu/release/rustlibs.dll"
		// Then check in the current directory.
		if(fexists("./rustlibs[RUSTLIBS_SUFFIX].dll"))
			return __rustlib = "./rustlibs[RUSTLIBS_SUFFIX].dll"

		// And elsewhere.
		var/assignment_confirmed = (__rustlib = "rustlibs[RUSTLIBS_SUFFIX].dll")
		// This being spanned over multiple lines is kinda scuffed, but its needed because of https://www.byond.com/forum/post/2072419
		return assignment_confirmed

#define RUSTLIB (__rustlib || __detect_rustlib())
#define RUSTLIB_CALL(func, args...) call_ext(RUSTLIB, "byond:[#func]_ffi")(args)

/// Exists by default in 516, but needs to be defined for 515 or byondapi-rs doesn't like it.
/proc/byondapi_stack_trace(err)
	CRASH(err)
