//
/// The minimum amount of time necessary to
#define FLUID_SPREAD_OVERRUN_EFFECT_SKIP_MIN (1 SECONDS)
/// The probability that the subsystem will skip a fluid effect tick to instead process fluid spreading each second it overruns past [FLUID_SPREAD_OVERRUN_EFFECT_SKIP_MIN].
#define FLUID_SPREAD_OVERRUN_EFFECT_SKIP_PROB (80)


#define HEAPIFY(__HEAP, __START_INDEX, __CMP) \
	do { \
		var/__HEAP_SIZE = length(__HEAP); \
		if(!length(__HEAP)) { \
			break; \
		} \
		var/__CURRENT_INDEX = __START_INDEX; \
		for () { \
			var/__LEFT_INDEX = __CURRENT_INDEX << 1; \
			var/__NEXT_INDEX = ((__LEFT_INDEX <= __HEAP_SIZE) && __CMP(__HEAP[__LEFT_INDEX], __HEAP[__CURRENT_INDEX])) ? __LEFT_INDEX : __CURRENT_INDEX; \
			var/__RIGHT_INDEX = __LEFT_INDEX + 1; \
			if((__RIGHT_INDEX <= __HEAP_SIZE) && __CMP(__HEAP[__RIGHT_INDEX], __HEAP[__NEXT_INDEX])) { \
				__NEXT_INDEX = __RIGHT_INDEX; \
			} \
			if (__NEXT_INDEX == __CURRENT_INDEX) { \
				break; \
			} \
			__HEAP.Swap(__CURRENT_INDEX, __NEXT_INDEX); \
			__CURRENT_INDEX = __NEXT_INDEX; \
		} \
	} while(FALSE);

#define __CMP_SPREAD_HEAP_QUEUES(QUEUE_TRUE, QUEUE_FALSE) (QUEUE_TRUE < QUEUE_FALSE)


/**
 *
 */
SUBSYSTEM_DEF(fluids)
	name = "Fluids"
	priority = FIRE_PRIORITY_FLUIDS
	wait = 0.1 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	// General fluid processing:
	/// The set of fluid nodes that are currently processing.
	var/list/obj/effect/particle_effect/fluid/currentrun
	/// Whether we are trying to catch up on spreading.
	var/catching_up_on_spreading = FALSE

	// Fluid effect processing:
	/// The set of fluid nodes that are currently processing effects.
	var/list/obj/effect/particle_effect/fluid/processing
	/// The last tick fluids were processed on.
	COOLDOWN_DECLARE(effect_processing_cooldown)
	/// How frequently the effects of fluids are processed.
	var/effect_processing_wait = 2 SECONDS

	// Fluid spread processing:
	/// A max heap of times when spreads are queued.
	var/list/spread_heap
	/// An assoc list associating times when spreads are queued with sets of fluid nodes that want to spread on that time.
	var/list/spread_queues
	/// The time that we are currently trying to spread fluids for.
	var/current_spread_tick

/datum/controller/subsystem/fluids/Initialize(start_timeofday)
	processing = list()
	spread_heap = list()
	spread_queues = list()
	current_spread_tick = world.time
	COOLDOWN_START(src, effect_processing_cooldown, round(rand() * effect_processing_wait, 0.1 SECONDS)) // Fuzz effect processing a bit so fluids don't process perfectly on beat.
	return ..()



/datum/controller/subsystem/fluids/fire(resumed)
	var/now = world.time
	var/list/obj/effect/particle_effect/fluid/currentrun
	var/list/cached_heap = spread_heap

	if (src.effect_processing_cooldown <= now && !(catching_up_on_spreading || (cached_heap.len && now > (cached_heap[1] + FLUID_SPREAD_OVERRUN_EFFECT_SKIP_MIN) && DT_PROB(FLUID_SPREAD_OVERRUN_EFFECT_SKIP_PROB, ((now - (cached_heap[1] + FLUID_SPREAD_OVERRUN_EFFECT_SKIP_MIN)) / (1 SECONDS))))))
		if(!resumed)
			src.currentrun = processing.Copy()

		currentrun = src.currentrun
		while(currentrun.len)
			var/obj/effect/particle_effect/fluid/processing_node = currentrun[currentrun.len]
			currentrun.len--

			if (QDELETED(processing_node))
				STOP_PROCESSING(src, processing_node)
				if (MC_TICK_CHECK)
					return

			if (processing_node.process((now - processing_node.last_process) / (1 SECONDS)) == PROCESS_KILL)
				STOP_PROCESSING(src, processing_node)

			processing_node.last_process = now
			if (MC_TICK_CHECK)
				return

		COOLDOWN_START(src, effect_processing_cooldown, effect_processing_wait)
		resumed = FALSE

	var/list/cached_queues = spread_queues
	while ( resumed || cached_heap.len)
		var/current_spread_tick
		if(!resumed)
			current_spread_tick = cached_heap[1]

			if (current_spread_tick > now)
				break // We have caught up to where we want to be.

			cached_heap.Swap(1, cached_heap.len)
			if (--cached_heap.len)
				HEAPIFY(cached_heap, 1, __CMP_SPREAD_HEAP_QUEUES)

			currentrun = cached_queues["[current_spread_tick]"]
			cached_queues -= "[current_spread_tick]"

			if (current_spread_tick < src.current_spread_tick)
				stack_trace("We have advanced the fluid spread tick and have somehow gone backwards ([src.current_spread_tick] -> [current_spread_tick]). This has the potential to lock up the [name] subsystem indefinitely so we are skipping [currentrun.len] spreads.")
				continue

			src.current_spread_tick = current_spread_tick
			src.currentrun = currentrun
		else
			current_spread_tick = src.current_spread_tick
			currentrun = src.currentrun

		currentrun = src.currentrun
		while(currentrun.len)
			var/obj/effect/particle_effect/fluid/spreading_node = currentrun[currentrun.len]
			currentrun.len--

			if (QDELETED(spreading_node) && MC_TICK_CHECK)
				return

			spreading_node.next_spread = null
			spreading_node.spread((now - spreading_node.last_spread) / (1 SECONDS))
			spreading_node.last_spread = now
			if (MC_TICK_CHECK)
				return

		resumed = FALSE

	catching_up_on_spreading = FALSE


/**
 *
 */
/datum/controller/subsystem/fluids/proc/queue_spread(obj/effect/particle_effect/fluid/node, spread_time)
	if(!isnull(node.next_spread))
		cancel_spread(node, node.next_spread)

	node.next_spread = spread_time
	var/list/cached_queue = spread_queues["[spread_time]"]
	if (cached_queue)
		cached_queue += node
		return

	cached_queue = list(node)
	spread_queues["[spread_time]"] = cached_queue

	var/list/cached_heap = spread_heap
	cached_heap += spread_time

	var/index = cached_heap.len
	var/parent
	while((parent = (index - 1) >> 1) > 0 && cached_heap[parent] > spread_time)
		cached_heap.Swap(index, parent)
		index = parent

/**
 *
 */
/datum/controller/subsystem/fluids/proc/cancel_spread(obj/effect/particle_effect/fluid/node, spread_time)
	var/list/cached_queue = spread_queues["[spread_time]"]
	if (cached_queue)
		cached_queue -= node
