/**
 *
 */
SUBSYSTEM_DEF(fluid_spread)
	name = "Fluid Spread"
	wait = 0.1 SECONDS
	flags = SS_KEEP_TIMING

	//
	/// The amount of time
	var/spread_wait = 1 SECONDS
	///
	var/list/list/obj/effect/particle_effect/fluid/processing
	///
	var/tmp/list/obj/effect/particle_effect/fluid/currentrun
	///
	var/tmp/num_buckets
	///
	var/tmp/processing_bucket_index



/datum/controller/subsystem/fluid_spread/Initialize(start_timeofday)
	if (spread_wait < wait)
		if (spread_wait > 0)
			wait = spread_wait
		else
			spread_wait = wait

	num_buckets = round(spread_wait / wait)
	spread_wait = wait * num_buckets

	processing = list()
	processing.len = num_buckets
	for(var/i in 1 to num_buckets)
		processing[i] = list()

	processing_bucket_index = rand(1, spread_wait)
	return ..()

/datum/controller/subsystem/fluid_spread/fire(resumed)
	if(!resumed)
		processing_bucket_index = (processing_bucket_index % spread_wait) + 1
		src.currentrun = processing[processing_bucket_index]
		processing[processing_bucket_index] = list()

	var/delta_time = spread_wait / (1 SECONDS)
	var/list/obj/effect/particle_effect/fluid/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/effect/particle_effect/fluid/processing_node = currentrun[currentrun.len]
		currentrun.len--

		if(QDELETED(processing_node) || processing_node.spread(delta_time) == PROCESS_KILL)
			processing[processing_bucket_index] -= processing_node
			processing_node.spread_bucket = null

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/fluid_spread/proc/queue_spread(obj/effect/particle_effect/fluid/node)
	processing[processing_bucket_index] += node

/datum/controller/subsystem/fluid_spread/proc/cancel_spread(obj/effect/particle_effect/fluid/node)
	var/index = node.spread_bucket
	if (index)
		processing[index] -= node
		if (index == processing_bucket_index && currentrun.len)
			currentrun -= node
		node.spread_bucket = null

FLUID_SPREAD_SUBSYSTEM_DEF(smoke_spread)
	name = "Smoke Spread"
	spread_wait = 0.1 SECONDS

FLUID_SPREAD_SUBSYSTEM_DEF(foam_spread)
	name = "Foam Spread"
	spread_wait = 0.2 SECONDS
