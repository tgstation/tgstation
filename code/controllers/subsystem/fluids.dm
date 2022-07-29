// Flags indicating what parts of the fluid the subsystem processes.
/// Indicates that a fluid subsystem processes fluid spreading.
#define SS_PROCESSES_SPREADING (1<<0)
/// Indicates that a fluid subsystem processes fluid effects.
#define SS_PROCESSES_EFFECTS (1<<1)

/**
 * # Fluid Subsystem
 *
 * A subsystem that processes the propagation and effects of a particular fluid.
 *
 * Both fluid spread and effect processing are handled through a carousel system.
 * Fluids being spread and fluids being processed are organized into buckets.
 * Each fresh (non-resumed) fire one bucket of each is selected to be processed.
 * These selected buckets are then fully processed.
 * The next fresh fire selects the next bucket in each set for processing.
 * If this would walk off the end of a carousel list we wrap back to the first element.
 * This effectively makes each set a circular list, hence a carousel.
 */
SUBSYSTEM_DEF(fluids)
	name = "Fluid"
	wait = 0 // Will be autoset to whatever makes the most sense given the spread and effect waits.
	flags = SS_BACKGROUND|SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME

	// Fluid spread processing:
	/// The amount of time (in deciseconds) before a fluid node is created and when it spreads.
	var/spread_wait = 1 SECONDS
	/// The number of buckets in the spread carousel.
	var/num_spread_buckets
	/// The set of buckets containing fluid nodes to spread.
	var/list/spread_carousel
	/// The index of the spread carousel bucket currently being processed.
	var/spread_bucket_index
	/// The set of fluid nodes we are currently processing spreading for.
	var/list/currently_spreading
	/// Whether the subsystem has resumed spreading fluid.
	var/resumed_spreading

	// Fluid effect processing:
	/// The amount of time (in deciseconds) between effect processing ticks for each fluid node.
	var/effect_wait = 1 SECONDS
	/// The number of buckets in the effect carousel.
	var/num_effect_buckets
	/// The set of buckets containing fluid nodes to process effects for.
	var/list/effect_carousel
	/// The index of the currently processing bucket on the effect carousel.
	var/effect_bucket_index
	/// The set of fluid nodes we are currently processing effects for.
	var/list/currently_processing
	/// Whether the subsystem has resumed processing fluid effects.
	var/resumed_effect_processing

/datum/controller/subsystem/fluids/Initialize(start_timeofday)
	initialize_waits()
	initialize_spread_carousel()
	initialize_effect_carousel()
	return ..()

/**
 * Initializes the subsystem waits.
 *
 * Ensures that the subsystem's fire wait evenly splits the spread and effect waits.
 */
/datum/controller/subsystem/fluids/proc/initialize_waits()
	if (spread_wait <= 0)
		WARNING("[src] has the invalid spread wait [spread_wait].")
		spread_wait = 1 SECONDS
	if (effect_wait <= 0)
		WARNING("[src] has the invalid effect wait [effect_wait].")
		spread_wait = 1 SECONDS

	// Sets the overall wait of the subsystem to evenly divide both the effect and spread waits.
	var/max_wait = Gcd(spread_wait, effect_wait)
	if (max_wait < wait || wait <= 0)
		wait = max_wait
	else
		// If the wait of the subsystem overall is set to a valid value make the actual wait of the subsystem evenly divide that as well.
		// Makes effect bubbling possible with identical spread and effect waits.
		wait = Gcd(wait, max_wait)


/**
 * Initializes the carousel used to process fluid spreading.
 *
 * Synchronizes the spread delta time with the actual target spread tick rate.
 * Builds the carousel buckets used to queue spreads.
 */
/datum/controller/subsystem/fluids/proc/initialize_spread_carousel()
	// Make absolutely certain that the spread wait is in sync with the target spread tick rate.
	num_spread_buckets = round(spread_wait / wait)
	spread_wait = wait * num_spread_buckets

	spread_carousel = list()
	spread_carousel.len = num_spread_buckets
	for(var/i in 1 to num_spread_buckets)
		spread_carousel[i] = list()
	currently_spreading = list()
	spread_bucket_index = 1

/**
 * Initializes the carousel used to process fluid effects.
 *
 * Synchronizes the spread delta time with the actual target spread tick rate.
 * Builds the carousel buckets used to bubble processing.
 */
/datum/controller/subsystem/fluids/proc/initialize_effect_carousel()
	// Make absolutely certain that the effect wait is in sync with the target effect tick rate.
	num_effect_buckets = round(effect_wait / wait)
	effect_wait = wait * num_effect_buckets

	effect_carousel = list()
	effect_carousel.len = num_effect_buckets
	for(var/i in 1 to num_effect_buckets)
		effect_carousel[i] = list()
	currently_processing = list()
	effect_bucket_index = 1


/datum/controller/subsystem/fluids/fire(resumed)
	var/delta_time
	var/cached_bucket_index
	var/list/obj/effect/particle_effect/fluid/currentrun
	MC_SPLIT_TICK_INIT(2)

	MC_SPLIT_TICK // Start processing fluid spread:
	if(!resumed_spreading)
		spread_bucket_index = WRAP_UP(spread_bucket_index, num_spread_buckets)
		currently_spreading = spread_carousel[spread_bucket_index]
		spread_carousel[spread_bucket_index] = list() // Reset the bucket so we don't process an _entire station's worth of foam_ spreading every 2 ticks when the foam flood event happens.
		resumed_spreading = TRUE

	delta_time = spread_wait / (1 SECONDS)
	currentrun = currently_spreading
	while(currentrun.len)
		var/obj/effect/particle_effect/fluid/to_spread = currentrun[currentrun.len]
		currentrun.len--

		if(!QDELETED(to_spread))
			to_spread.spread(delta_time)
			to_spread.spread_bucket = null

		if (MC_TICK_CHECK)
			break

	if(!currentrun.len)
		resumed_spreading = FALSE

	MC_SPLIT_TICK // Start processing fluid effects:
	if(!resumed_effect_processing)
		effect_bucket_index = WRAP_UP(effect_bucket_index, num_effect_buckets)
		var/list/tmp_list = effect_carousel[effect_bucket_index]
		currently_processing = tmp_list.Copy()
		resumed_effect_processing = TRUE

	delta_time = effect_wait / (1 SECONDS)
	cached_bucket_index = effect_bucket_index
	currentrun = currently_processing
	while(currentrun.len)
		var/obj/effect/particle_effect/fluid/to_process = currentrun[currentrun.len]
		currentrun.len--

		if (QDELETED(to_process) || to_process.process(delta_time) == PROCESS_KILL)
			effect_carousel[cached_bucket_index] -= to_process
			to_process.effect_bucket = null
			to_process.datum_flags &= ~DF_ISPROCESSING

		if (MC_TICK_CHECK)
			break

	if(!currentrun.len)
		resumed_effect_processing = FALSE


/**
 * Queues a fluid node to spread later after one full carousel rotation.
 *
 * Arguments:
 * - [node][/obj/effect/particle_effect/fluid]: The node to queue to spread.
 */
/datum/controller/subsystem/fluids/proc/queue_spread(obj/effect/particle_effect/fluid/node)
	if (node.spread_bucket)
		return

	spread_carousel[spread_bucket_index] += node
	node.spread_bucket = spread_bucket_index

/**
 * Cancels a queued spread of a fluid node.
 *
 * Arguments:
 * - [node][/obj/effect/particle_effect/fluid]: The node to cancel the spread of.
 */
/datum/controller/subsystem/fluids/proc/cancel_spread(obj/effect/particle_effect/fluid/node)
	if(!node.spread_bucket)
		return

	var/bucket_index = node.spread_bucket
	spread_carousel[bucket_index] -= node
	if (bucket_index == spread_bucket_index)
		currently_spreading -= node

	node.spread_bucket = null

/**
 * Starts processing the effects of a fluid node.
 *
 * The fluid node will next process after one full bucket rotation.
 *
 * Arguments:
 * - [node][/obj/effect/particle_effect/fluid]: The node to start processing.
 */
/datum/controller/subsystem/fluids/proc/start_processing(obj/effect/particle_effect/fluid/node)
	if (node.datum_flags & DF_ISPROCESSING || node.effect_bucket)
		return

	// Edit this value to make all fluids process effects (at the same time|offset by when they started processing| -> offset by a random amount <- )
	var/bucket_index = rand(1, num_effect_buckets)
	effect_carousel[bucket_index] += node
	node.effect_bucket = bucket_index
	node.datum_flags |= DF_ISPROCESSING

/**
 * Stops processing the effects of a fluid node.
 *
 * Arguments:
 * - [node][/obj/effect/particle_effect/fluid]: The node to stop processing.
 */
/datum/controller/subsystem/fluids/proc/stop_processing(obj/effect/particle_effect/fluid/node)
	if(!(node.datum_flags & DF_ISPROCESSING))
		return

	var/bucket_index = node.effect_bucket
	if(!bucket_index)
		return

	effect_carousel[bucket_index] -= node
	if (bucket_index == effect_bucket_index)
		currently_processing -= node

	node.effect_bucket = null
	node.datum_flags &= ~DF_ISPROCESSING

#undef SS_PROCESSES_SPREADING
#undef SS_PROCESSES_EFFECTS


// Subtypes:

/// The subsystem responsible for processing smoke propagation and effects.
FLUID_SUBSYSTEM_DEF(smoke)
	name = "Smoke"
	spread_wait = 0.1 SECONDS
	effect_wait = 2.0 SECONDS

/// The subsystem responsible for processing foam propagation and effects.
FLUID_SUBSYSTEM_DEF(foam)
	name = "Foam"
	wait = 0.1 SECONDS // Makes effect bubbling work with foam.
	spread_wait = 0.2 SECONDS
	effect_wait = 0.2 SECONDS
