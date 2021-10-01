// Interfaces for the SpacemanDMM linter, define'd to nothing when the linter
// is not in use.

// The SPACEMAN_DMM define is set by the linter and other tooling when it runs.
#ifdef SPACEMAN_DMM
	#define RETURN_TYPE(X) set SpacemanDMM_return_type = X
	#define SHOULD_CALL_PARENT(X) set SpacemanDMM_should_call_parent = X
	#define UNLINT(X) SpacemanDMM_unlint(X)
	#define SHOULD_NOT_OVERRIDE(X) set SpacemanDMM_should_not_override = X
	#define SHOULD_NOT_SLEEP(X) set SpacemanDMM_should_not_sleep = X
	#define SHOULD_BE_PURE(X) set SpacemanDMM_should_be_pure = X
	#define PRIVATE_PROC(X) set SpacemanDMM_private_proc = X
	#define PROTECTED_PROC(X) set SpacemanDMM_protected_proc = X
	#define VAR_FINAL var/SpacemanDMM_final
	#define VAR_PRIVATE var/SpacemanDMM_private
	#define VAR_PROTECTED var/SpacemanDMM_protected
#else
	#define RETURN_TYPE(X)
	#define SHOULD_CALL_PARENT(X)
	#define UNLINT(X) X
	#define SHOULD_NOT_OVERRIDE(X)
	#define SHOULD_NOT_SLEEP(X)
	#define SHOULD_BE_PURE(X)
	#define PRIVATE_PROC(X)
	#define PROTECTED_PROC(X)
	#define VAR_FINAL var
	#define VAR_PRIVATE var
	#define VAR_PROTECTED var
#endif

/proc/auxtools_stack_trace(msg)
	CRASH(msg)

/proc/auxtools_expr_stub()
	CRASH("auxtools not loaded")

/proc/enable_debugging(mode, port)
	CRASH("auxtools not loaded")

/world/proc/enable_debugger()
	var/dll = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if (dll)
		call(dll, "auxtools_init")()
		enable_debugging()

/world/Del()
	var/debug_server = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if (debug_server)
		call(debug_server, "auxtools_shutdown")()
	. = ..()
