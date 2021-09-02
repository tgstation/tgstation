SUBSYSTEM_DEF(circuit_component)
	name = "Circuit Components"
	wait = 0.1 SECONDS
	priority = FIRE_PRIORITY_DEFAULT

	var/list/callbacks_to_invoke = list()
	var/list/currentrun = list()

	var/instant_run_tick = 0
	var/instant_run_start_cpu_usage = 0
	var/instant_run_max_cpu_usage = 10
	var/list/instant_run_callbacks_to_run = list()

/datum/controller/subsystem/circuit_component/fire(resumed)
	if(!resumed)
		currentrun = callbacks_to_invoke.Copy()
		callbacks_to_invoke.Cut()

	while(length(currentrun))
		var/datum/callback/to_call = currentrun[1]
		currentrun.Cut(1,2)

		if(QDELETED(to_call))
			continue

		to_call.user = null
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
/datum/controller/subsystem/circuit_component/proc/add_callback(datum/port/input, datum/callback/to_call)
	if(instant_run_tick == world.time && (TICK_USAGE - instant_run_start_cpu_usage) < instant_run_max_cpu_usage)
		instant_run_callbacks_to_run += to_call
		return

	callbacks_to_invoke += to_call

/datum/controller/subsystem/circuit_component/proc/queue_instant_run()
	instant_run_tick = world.time
	instant_run_start_cpu_usage = TICK_USAGE
	instant_run_callbacks_to_run = list()

/datum/controller/subsystem/circuit_component/proc/execute_instant_run()
	while(length(instant_run_callbacks_to_run))
		var/list/instant_run_currentrun = instant_run_callbacks_to_run
		instant_run_callbacks_to_run = list()
		while(length(instant_run_currentrun))
			var/datum/callback/to_call = instant_run_currentrun[1]
			instant_run_currentrun.Cut(1,2)

			to_call.user = null
			to_call.InvokeAsync()
			qdel(to_call)

	instant_run_tick = 0
	if((TICK_USAGE - instant_run_start_cpu_usage) < instant_run_max_cpu_usage)
		return TRUE
	else
		return FALSE
