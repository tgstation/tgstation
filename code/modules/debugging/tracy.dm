/// The byond-tracy instance.
/// This is a GLOBAL_REAL because it is the VERY FIRST THING to initialize, even before the MC or GLOB.
GLOBAL_REAL(Tracy, /datum/tracy)

/datum/tracy
	/// Is byond-tracy enabled and running?
	VAR_FINAL/enabled = FALSE
	/// The error text, if initializing byond-tracy errored.
	VAR_FINAL/error
	/// A description of what / who enabled byond-tracy.
	VAR_FINAL/init_reason
	/// A path to the file containing the output trace, if any.
	VAR_FINAL/trace_path

/datum/tracy/New()
	if(!isnull(Tracy))
		CRASH("Attempted to initialize /datum/tracy when global.Tracy is already set!")
	Tracy = src

/datum/tracy/Destroy()
#ifndef OPENDREAM_REAL
	if(enabled)
		call_ext(TRACY_DLL_PATH, "destroy")()
#endif
	return ..()

/// Tries to initialize byond-tracy.
/datum/tracy/proc/enable(init_reason)
#ifndef OPENDREAM_REAL
	if(enabled)
		return TRUE
	src.init_reason = init_reason
	if(!fexists(TRACY_DLL_PATH))
		error = "[TRACY_DLL_PATH] not found"
		SEND_TEXT(world.log, "Error initializing byond-tracy: [error]")
		return FALSE

	var/init_result = call_ext(TRACY_DLL_PATH, "init")("block")
	if(length(init_result) != 0 && init_result[1] == ".") // if first character is ., then it returned the output filename
		SEND_TEXT(world.log, "byond-tracy initialized (logfile: [init_result])")
		enabled = TRUE
		trace_path = init_result
		return TRUE
	else if(init_result == "already initialized") // not gonna question it.
		enabled = TRUE
		SEND_TEXT(world.log, "byond-tracy already initialized ([trace_path ? "logfile: [trace_path]" : "no logfile"])")
		return TRUE
	else if(init_result != "0")
		error = init_result
		SEND_TEXT(world.log, "Error initializing byond-tracy: [init_result]")
		return FALSE
	else
		enabled = TRUE
		SEND_TEXT(world.log, "byond-tracy initialized (no logfile)")
		return TRUE
#else
	error = "OpenDream not supported"
	return FALSE
#endif

/datum/tracy/vv_edit_var(var_name, var_value)
	return FALSE // no.

/datum/tracy/CanProcCall(procname)
	return FALSE // double no.
