/* Framework for creating action sequences without sleeps

Usage:

Override /datum/action_sequence. Make sure it's uniquely named and don't call the parent/New()

Optionally set delay to delay the first action, client_based_delay, and required steps. See below

Override /datum/action_sequence/var/next_step with the path to the proc on src that is your first action

In /Run(), and every action step that follows do the following to continue the sequence

Set next_step to a proc path on src to delegate that as the next action (reset to null before every action) having it as null will stop the sequence
Optionally set delay to add a non-blocking delay to it (reset to 0 before every action)
Optionally set client_based_delay to TRUE to enable TIMER_CLIENT_TIME (reset to FALSE before every action)
Optionally set step_requires to a list of datums you want passed to the next step (reset to null before every action)
Optionally set step_requires_weak, which is the same as step_requires but should be preferred wherever possible because it doesn't prevent GCing of the datums inside it (reset to null before every action)

step_requires and step_requires_weak will be combined to form the arguments of the next action

If, at any point, the action sequence or anything in step_requires* is deleted the sequence stops with Destroy() being called

BeforeStep() is called before every step and if it returns FALSE the sequence is deleted
AfterStep() is called after every step and if it returns FALSE the sequence is deleted

Note that if you need to use step_requires_weak in Destroy, call ResolveWeakRequires first

When you're ready to start call Initiate()
*/

/datum/action_sequence
	var/next_step	//path to proc on src to run next
	var/delay = 0	//delay until next_step
	var/client_based_delay = FALSE
	var/list/step_requires	//list of dependencies, will be passed to the next step proc
	var/list/step_requires_weak	//list of dependencies that will be converted to weakrefs during the delay, will be passed to the next step proc

	var/steps_invoked = 0
	var/datum/callback/callback

/datum/action_sequence/New()
	CRASH("[/datum/action_sequence]/New() called!")

/datum/action_sequence/Destroy()
	QDEL_NULL(callback)
	LAZYCLEARLIST(step_requires)
	LAZYCLEARLIST(step_requires_weak)
	return ..()

/datum/action_sequence/proc/Initiate()
	callback = CALLBACK(src, null)
	INVOKE_ASYNC(src, .proc/NextStep)

/datum/action_sequence/proc/NextStep()
	if(QDELING(src))
		return

	if(!next_step)
		if(steps_invoked <= 1)
			WARNING("[type] ran out of steps after 1 or 0 runs. Consider demoting it from an action_sequence")
		qdel(src)
		return

	if(delay)
		for(var/I in 1 to LAZYLEN(step_requires_weak))
			step_requires_weak[I] = WEAKREF(step_requires_weak[I])

		var/datum/callback/cb = callback
		cb.delegate = .proc/AfterSleepStep
		addtimer(cb, delay, client_based_delay ? TIMER_CLIENT_TIME : NONE)
	else
		CallStep()

/datum/action_sequence/proc/AfterSleepStep()
	if(ResolveWeakRequires(TRUE))
		return

	if(!next_step)	//timer will check QDELETED for us
		qdel(src)
		return

	for(var/I in step_requires)
		var/datum/D = I
		if(QDELETED(D))
			qdel(src)
			return

	CallStep()

/datum/action_sequence/proc/ResolveWeakRequires(allow_qdel = FALSE)
	var/qdel_after = FALSE
	var/check_first_invoke = TRUE
	for(var/I in 1 to LAZYLEN(step_requires_weak))
		var/datum/weakref/W = step_requires_weak[I]
		if(check_first_invoke)
			if(!istype(W))
				return
			check_first_invoke = FALSE
		var/datum/D = W.resolve()
		if(!D)
			qdel_after = allow_qdel
		step_requires_weak[I] = D
	if(qdel_after)
		qdel(src)
		return TRUE
	return FALSE

/datum/action_sequence/proc/CallStep()
	callback.delegate = next_step
	var/list/arguments = (step_requires || list()) + (step_requires_weak || list())
	next_step = null
	delay = 0
	client_based_delay = FALSE
	step_requires = null
	step_requires_weak = null
	if(!BeforeStep(arglist(arguments)))
		qdel(src)
		return
	callback.Invoke(arglist(arguments))
	++steps_invoked
	if(!AfterStep(arglist(arguments)))
		qdel(src)
		return
	NextStep()

/datum/action_sequence/proc/BeforeStep()
	return TRUE

/datum/action_sequence/proc/AfterStep()
	return TRUE