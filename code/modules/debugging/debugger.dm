/// The debugger instance.
/// This is a GLOBAL_REAL because it initializes before the MC or GLOB.
/// Really only used to check to see if the debugger is enabled or not,
/// and to separate debugger-related code into its own thing.
GLOBAL_REAL(Debugger, /datum/debugger)

/datum/debugger
	/// Is the debugger enabled?
	VAR_FINAL/enabled = FALSE
	/// The error text, if initializing the debugger errored.
	VAR_FINAL/error
	/// The path to the auxtools debug DLL, if it sets.
	/// Defaults to the environmental variable AUXTOOLS_DEBUG_DLL.
	VAR_FINAL/dll_path

/datum/debugger/New(dll_path)
	if(!isnull(Debugger))
		CRASH("Attempted to initialize /datum/debugger when global.Debugger is already set!")
	Debugger = src
#ifndef OPENDREAM_REAL
	src.dll_path = dll_path || world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	enable()
#endif

/datum/debugger/Destroy()
#ifndef OPENDREAM_REAL
	if(enabled)
		call_ext(dll_path, "auxtools_shutdown")()
#endif
	return ..()

/// Attempt to enable the debugger.
/datum/debugger/proc/enable()
#ifndef OPENDREAM_REAL
	if(enabled)
		CRASH("Attempted to enable debugger while its already enabled, somehow.")
	if(!dll_path)
		return FALSE
	var/result = call_ext(dll_path, "auxtools_init")()
	if(result != "SUCCESS")
		error = result
		return FALSE
	enable_debugging()
	enabled = TRUE
	return TRUE
#else
	return FALSE
#endif

/datum/debugger/vv_edit_var(var_name, var_value)
	return FALSE // no.

/datum/debugger/CanProcCall(procname)
	return FALSE // double no.
