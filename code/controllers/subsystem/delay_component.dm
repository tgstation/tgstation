SUBSYSTEM_DEF(circuit_component)
	name = "Circuit Components"
	wait = 0.1 SECONDS
	priority = FIRE_PRIORITY_DEFAULT

	var/list/callbacks_to_invoke = list()
	var/list/currentrun = list()

/datum/controller/subsystem/circuit_component/fire(resumed)
	if(!resumed)
		currentrun = callbacks_to_invoke.Copy()
		callbacks_to_invoke.Cut()

	while(length(currentrun))
		var/datum/callback/to_call = currentrun[1]
		currentrun.Cut(1,2)

		if(QDELETED(to_call))
			continue

		to_call.InvokeAsync()
		qdel(to_call)

		if(MC_TICK_CHECK)
			return

/**
 * Adds a callback to be invoked when the next fire() is done. Used by the integrated circuit system.
 *
 * Prevents race conditions as it acts like a queue system.
 * Those that registered first will be executed first and those registered last will be executed last.
 */
/datum/controller/subsystem/circuit_component/proc/add_callback(datum/callback/to_call)
	callbacks_to_invoke += to_call
