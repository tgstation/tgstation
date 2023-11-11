SUBSYSTEM_DEF(circuit_component)
	name = "Circuit Components"
	wait = 0.1 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	flags = SS_NO_INIT

	var/list/callbacks_to_invoke = list()
	var/list/currentrun = list()

	var/list/instant_run_stack = list()

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

/// Queues any callbacks to be executed instantly instead of using the subsystem.
/datum/controller/subsystem/circuit_component/proc/queue_instant_run(start_cpu_time)
	if(instant_run_tick)
		instant_run_stack += list(instant_run_callbacks_to_run)
		// If we're already instantly executing, don't change the start_cpu_time.
		start_cpu_time = instant_run_start_cpu_usage

	if(!start_cpu_time)
		start_cpu_time = TICK_USAGE

	instant_run_tick = world.time
	instant_run_start_cpu_usage = start_cpu_time
	instant_run_callbacks_to_run = list()

/**
 * Instantly executes the stored callbacks and does this in a loop until there are no stored callbacks or it hits tick limit.
 *
 * Returns a list containing any values added by any input port.
 */
/datum/controller/subsystem/circuit_component/proc/execute_instant_run()
	var/list/received_inputs = list()
	while(length(instant_run_callbacks_to_run))
		var/list/instant_run_currentrun = instant_run_callbacks_to_run
		instant_run_callbacks_to_run = list()
		while(length(instant_run_currentrun))
			var/datum/callback/to_call = instant_run_currentrun[1]
			instant_run_currentrun.Cut(1,2)
			to_call.user = null
			to_call.InvokeAsync(received_inputs)

	if(length(instant_run_stack))
		instant_run_callbacks_to_run = pop(instant_run_stack)
	else
		instant_run_tick = 0

	if((TICK_USAGE - instant_run_start_cpu_usage) < instant_run_max_cpu_usage)
		return received_inputs
	else
		return null
