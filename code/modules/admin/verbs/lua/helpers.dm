#ifndef DISABLE_DREAMLUAU
#define PROMISE_PENDING 0
#define PROMISE_RESOLVED 1
#define PROMISE_REJECTED 2

/**
 * Byondapi hooks act as "set waitfor = 0" procs. This means that whenever
 * a proc directly called from an external library sleeps, the hook returns with whatever
 * the called proc had as its return value at the moment it slept. This may not
 * be desired behavior, so this datum exists to wrap these procs.
 *
 * Some procs that don't sleep could take longer than the execution limit would
 * allow for. We can wrap these in a promise as well.
 */
/datum/promise
	var/datum/callback/callback
	var/return_value
	var/runtime_message
	var/status = PROMISE_PENDING

/datum/promise/New(...)
	if(!usr)
		usr = GLOB.lua_usr
	callback = CALLBACK(arglist(args))
	INVOKE_ASYNC(src, PROC_REF(perform))

/datum/promise/proc/perform()
	try
		return_value = callback.Invoke()
		status = PROMISE_RESOLVED
	catch(var/exception/e)
		runtime_message = e.name
		status = PROMISE_REJECTED

#undef PROMISE_PENDING
#undef PROMISE_RESOLVED
#undef PROMISE_REJECTED
#endif
