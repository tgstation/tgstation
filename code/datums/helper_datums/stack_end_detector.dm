/**
	Stack End Detector.
	Can detect if a given code stack has exited, used by the mc for stack overflow detection.

 **/
/datum/stack_end_detector
	var/datum/weakref/_WF
	var/datum/stack_canary/_canary

/datum/stack_end_detector/New()
	_canary = new()
	_WF = WEAKREF(_canary)

/** Prime the stack overflow detector.
	Store the return value of this proc call in a proc level var.
	Can only be called once.
**/
/datum/stack_end_detector/proc/prime_canary()
	if (!_canary)
		CRASH("Prime_canary called twice")
	. = _canary
	_canary = null

/// Returns true if the stack is still going. Calling before the canary has been primed also returns true
/datum/stack_end_detector/proc/check()
	return !!_WF.resolve()

/// Stack canary. Will go away if the stack it was primed by is ended by byond for return or stack overflow reasons.
/datum/stack_canary

/// empty proc to avoid warnings about unused variables. Call this proc on your canary in the stack it's watching.
/datum/stack_canary/proc/use_variable()
