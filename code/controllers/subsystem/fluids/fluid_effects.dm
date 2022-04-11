/**
 *
 */
SUBSYSTEM_DEF(fluid_effect)
	name = "Fluid Effect"
	wait = 1
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING

	//
	/// The amount of time
	var/effect_wait = 1 SECONDS
	///
	var/list/list/obj/effect/particle_effect/fluid/processing
	///
	var/tmp/list/obj/effect/particle_effect/fluid/currentrun
	///
	var/tmp/num_buckets
	///
	var/tmp/processing_bucket_index

/datum/controller/subsystem/fluid_effect/Initialize(start_timeofday)
	if (effect_wait < wait)
		if (effect_wait > 0)
			wait = effect_wait
		else
			effect_wait = wait

	num_buckets = round(effect_wait / wait)
	effect_wait = wait * num_buckets

	processing = list()
	processing.len = num_buckets
	for(var/i in 1 to num_buckets)
		processing[i] = list()

	processing_bucket_index = rand(1, effect_wait)
	return ..()

/datum/controller/subsystem/fluid_effect/fire(resumed)
	if(!resumed)
		processing_bucket_index = (processing_bucket_index % effect_wait) + 1
		src.currentrun = processing[processing_bucket_index].Copy()

	var/delta_time = effect_wait / (1 SECONDS)
	var/list/obj/effect/particle_effect/fluid/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/effect/particle_effect/fluid/processing_node = currentrun[currentrun.len]
		currentrun.len--

		if(QDELETED(processing_node) || processing_node.process(delta_time) == PROCESS_KILL)
			processing[processing_bucket_index] -= processing_node
			processing_node.datum_flags &= ~DF_ISPROCESSING
			processing_node.process_bucket = null

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/fluid_effect/proc/start_processing(obj/effect/particle_effect/fluid/node)
	if (node.process_bucket)
		return

	var/bucket = processing_bucket_index
	processing[bucket] += node
	node.process_bucket = bucket

/datum/controller/subsystem/fluid_effect/proc/stop_processing(obj/effect/particle_effect/fluid/node)
	if(!node.process_bucket)
		return

	var/bucket = node.process_bucket
	processing[bucket] -= node
	if (bucket == processing_bucket_index && currentrun.len)
		currentrun -= node

	node.process_bucket = null

FLUID_EFFECT_SUBSYSTEM_DEF(smoke_effect)
	name = "Smoke Effect"
	effect_wait = 2 SECONDS

FLUID_EFFECT_SUBSYSTEM_DEF(foam_effect)
	name = "Foam Effect"
	effect_wait = 0.2 SECONDS
