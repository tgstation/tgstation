#define PROMISE_PENDING 0
#define PROMISE_RESOLVED 1
#define PROMISE_REJECTED 2

/**
 * Auxtools hooks act as "set waitfor = 0" procs. This means that whenever
 * a proc directly called from auxtools sleeps, the hook returns with whatever
 * the called proc had as its return value at the moment it slept. This may not
 * be desired behavior, so this datum exists to wrap these procs.
 */
/datum/auxtools_promise
	var/datum/callback/callback
	var/return_value
	var/runtime_message
	var/status = PROMISE_PENDING

/datum/auxtools_promise/New(...)
	callback = CALLBACK(arglist(args))
	perform()

/datum/auxtools_promise/proc/perform()
	set waitfor = 0
	try
		return_value = callback.Invoke()
		status = PROMISE_RESOLVED
	catch(var/exception/e)
		runtime_message = e.name
		status = PROMISE_REJECTED

#undef PROMISE_PENDING
#undef PROMISE_RESOLVED
#undef PROMISE_REJECTED

/**
 * When a datum is created from lua, it gets held in `SSlua.gc_guard`, and later,
 * in the calling state datum's `var/list/references`, just in case it would be garbage
 * collected due to there not being any references that BYOND recognizes. To avoid harddels,
 * we register this proc as a signal handler any time a DM function called from lua returns
 * a datum.
 */
/datum/proc/lua_reference_cleanup()
	SIGNAL_HANDLER
	if(SSlua.gc_guard == src)
		SSlua.gc_guard = null
	for(var/datum/lua_state/state in SSlua.states)
		state.references -= src
