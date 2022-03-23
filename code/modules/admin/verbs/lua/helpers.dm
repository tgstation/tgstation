#define PROMISE_PENDING 0
#define PROMISE_RESOLVED 1
#define PROMISE_REJECTED 2

/**
 * Auxtools hooks act as "set waitfor = 0" procs. This means that whenever
 * a proc directly called from auxtools sleeps, the hook returns with whatever
 * the called proc had as its return value at the moment it slept. This may not
 * be desired behavior, so this datum exists to wrap these procs.
 */
/datum/promise
	var/datum/callback/callback
	var/return_value
	var/runtime_message
	var/status = PROMISE_PENDING

/datum/promise/New(...)
	callback = CALLBACK(arglist(args))
	perform()

/datum/promise/proc/perform()
	set waitfor = 0
	try
		return_value = callback.Invoke()
		status = PROMISE_RESOLVED
	catch(var/exception/e)
		runtime_message = e.name
		status = PROMISE_REJECTED
