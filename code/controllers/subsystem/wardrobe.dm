/// This subsystem strives to make loading large amounts of select objects as smooth at execution as possible
/// It preloads a set of types to store, and caches them until requested
/// Doesn't catch everything mind, this is intentional. There's many types that expect to either
/// A: Not sit in a list for 2 hours, or B: have extra context passed into them, or for their parent to be their location
/// You should absolutely not spam this system, it will break things in new and wonderful ways
/// S close enough for government work though.
/// Fuck you goonstation

	name = "Wardrobe"
	wait = 10 // This is more like a queue then anything else
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT // We're going to fill up our cache while players sit in the lobby
	/// How much to cache outfit items
	/// Multiplier, 2 would mean cache enough items to stock 1 of each preloaded order twice, etc
	var/cache_intensity = 2
	/// How many more then the template of a type are we allowed to have before we delete applicants?
	var/overflow_lienency = 2
	/// List of type -> list(insertion callback, removal callback) callbacks for insertion/removal to use.
	/// Set in setup_callbacks, used in canonization.
	var/list/initial_callbacks = list()
	/// List of key -> /datum/callbacks for optional invokation. See code/__DEFINES/wardrobe.dm
	/// Allows callers to request something particular happen to their object, along with arguments
	var/list/keyed_callbacks = list()
	/// Canonical list of types required to fill all preloaded stocks once.
	/// Type -> list(count, last inspection timestamp, call on insert, call on removal)
	var/list/canon_minimum = list()
	/// List of types to load. Type -> count //(I'd do a list of lists but this needs to be refillable)
	var/list/order_list = list()
	/// List of lists. Contains our preloaded atoms. Type -> list(last inspect time, list(instances))
	var/list/preloaded_stock = list()
	/// The last time we inspected our stock
	var/last_inspect_time = 0
	/// How often to inspect our stock, in deciseconds
	var/inspect_delay = 30 SECONDS
	/// What we're currently doing
	var/current_task = SSWARDROBE_STOCK
	/// How many times we've had to generate a stock item on request
	var/stock_miss = 0
	/// How many times we've successfully returned a cached item
	var/stock_hit = 0
	/// How many items would we make just by loading the master list once?
	var/one_go_master = 0
	// Hit/Miss Tracking
	var/list/hit_map = list()
	var/list/miss_map = list()

/datum/controller/subsystem/wardrobe/Initialize()
	setup_callbacks()
	load_outfits()
	load_species()
	load_storage_contents()
	load_stacks()
	load_shards()
	load_abstract()
	hard_refresh_queue()
	stock_hit = 0
	stock_miss = 0
	return SS_INIT_SUCCESS

/// Resets the load queue to the master template, accounting for the existing stock
/datum/controller/subsystem/wardrobe/proc/hard_refresh_queue()
	for(var/datum/type_to_queue as anything in canon_minimum)
		var/list/master_info = canon_minimum[type_to_queue]
		var/amount_to_load = master_info[WARDROBE_CACHE_COUNT] * cache_intensity

		var/list/stock_info = preloaded_stock[type_to_queue]
		if(stock_info) // If we already have stuff, reduce the amount we load
			amount_to_load -= length(stock_info[WARDROBE_STOCK_CONTENTS])
		set_queue_item(type_to_queue, amount_to_load)

/datum/controller/subsystem/wardrobe/stat_entry(msg)
	var/total_provided = max(stock_hit + stock_miss, 1)
	var/current_max_store = (one_go_master * cache_intensity) + (overflow_lienency * length(canon_minimum))
	msg += " P:[length(canon_minimum)] Q:[length(order_list)] S:[length(preloaded_stock)] I:[cache_intensity] O:[overflow_lienency]"
	msg += " H:[stock_hit] M:[stock_miss] T:[total_provided] H/T:[PERCENT(stock_hit / total_provided)]% M/T:[PERCENT(stock_miss / total_provided)]%"
	msg += " MAX:[current_max_store]"
	msg += " ID:[inspect_delay] NI:[last_inspect_time + inspect_delay]"
	return ..()

/datum/controller/subsystem/wardrobe/fire(resumed=FALSE)
	if(current_task != SSWARDROBE_INSPECT && world.time - last_inspect_time >= inspect_delay)
		current_task = SSWARDROBE_INSPECT

	switch(current_task)
		if(SSWARDROBE_STOCK)
			stock_wardrobe()
		if(SSWARDROBE_INSPECT)
			run_inspection()
			if(state != SS_RUNNING)
				return
			current_task = SSWARDROBE_STOCK
			last_inspect_time = world.time

/// Turns the order list into actual loaded items, this is where most work is done
/datum/controller/subsystem/wardrobe/proc/stock_wardrobe()
	for(var/atom/movable/type_to_stock as anything in order_list)
		var/amount_to_stock = order_list[type_to_stock]
		for(var/i in 1 to amount_to_stock)
			if(MC_TICK_CHECK)
				order_list[type_to_stock] = (amount_to_stock - (i - 1)) // Account for types we've already created
				return
			var/atom/movable/new_member = new type_to_stock()
			yield_object(new_member)

		order_list -= type_to_stock
		if(MC_TICK_CHECK)
			return

/// Once every medium while, go through the current stock and make sure we don't have too much of one thing
/// Or that we're not too low on some other stock
/// This exists as a failsafe, so the wardrobe doesn't just end up generating too many items or accidentially running out somehow
/datum/controller/subsystem/wardrobe/proc/run_inspection()
	for(var/datum/loaded_type as anything in canon_minimum)
		var/list/master_info = canon_minimum[loaded_type]
		var/last_looked_at = master_info[WARDROBE_CACHE_LAST_INSPECT]
		if(last_looked_at == last_inspect_time)
			continue

		var/list/stock_info = preloaded_stock[loaded_type]
		var/amount_held = 0
		if(stock_info)
			var/list/held_objects = stock_info[WARDROBE_STOCK_CONTENTS]
			amount_held = length(held_objects)

		var/target_stock = master_info[WARDROBE_CACHE_COUNT] * cache_intensity
		var/target_delta = amount_held - target_stock
		// If we've got too much
		if(target_delta > overflow_lienency)
			unload_stock(loaded_type, target_delta - overflow_lienency)
			if(state != SS_RUNNING)
				return

		// If we have more then we target, just don't you feel me?
		target_delta = min(target_delta, 0) //I only want negative numbers to matter here

		// If we don't have enough, queue enough to make up the remainder
		// If we have too much in the queue, cull to 0. We do this so time isn't wasted creating and destroying entries
		set_queue_item(loaded_type, abs(target_delta))

		master_info[WARDROBE_CACHE_LAST_INSPECT] = last_inspect_time

		if(MC_TICK_CHECK)
			return

/// Takes a path to get the callback owner for
/// Returns the deepest path in our callback store that matches the input
/// The hope is this will prevent dumb conflicts, since the furthest down is always going to be the most relevant
/datum/controller/subsystem/wardrobe/proc/get_callback_type(datum/to_check)
	var/longest_path
	var/longest_path_length = 0
	for(var/datum/path as anything in initial_callbacks)
		if(ispath(to_check, path))
			var/stringpath = "[path]"
			var/pathlength = length(splittext(stringpath, "/")) // We get the "depth" of the path
			if(pathlength < longest_path_length)
				continue
			longest_path = path
			longest_path_length = pathlength
	return longest_path

/**
 * Canonizes the type, which means it's now managed by the subsystem, and will be created deleted and passed out to comsumers
 *
 * Arguments:
 * * type to stock - What type exactly do you want us to remember?
 * * amount - Optional, how many of this type would you like to store
 *
*/
/datum/controller/subsystem/wardrobe/proc/canonize_type(type_to_stock, amount = 1)
	if(!type_to_stock)
		return
	if(!ispath(type_to_stock))
		stack_trace("Non path [type_to_stock] attempted to canonize itself. Something's fucky")
	var/list/master_info = canon_minimum[type_to_stock]
	if(!master_info)
		master_info = new /list(WARDROBE_CACHE_CALL_REMOVAL)
		master_info[WARDROBE_CACHE_COUNT] = 0
		//Decide on the appropriate callbacks to use
		var/callback_type = get_callback_type(type_to_stock)
		var/list/callback_info = initial_callbacks[callback_type]
		if(callback_info)
			master_info[WARDROBE_CACHE_CALL_INSERT] = callback_info[WARDROBE_CALLBACK_INSERT]
			master_info[WARDROBE_CACHE_CALL_REMOVAL] = callback_info[WARDROBE_CALLBACK_REMOVE]
		canon_minimum[type_to_stock] = master_info
	master_info[WARDROBE_CACHE_COUNT] += amount
	one_go_master++

/// Canonizes a typepath if and only if initial(typepath.to_read) is truthy
#define CANNONIZE_IF_VAR_TYPEPATH(typepath, type_to_make, amount, to_read) \
	do { \
		var##typepath/remembered = type_to_make; \
		if(initial(remembered.##to_read)) { \
			canonize_type(type_to_make, amount); \
		} \
	} while(FALSE)

#define CANNONIZE_IF_VAR(typepath, amount, to_read) CANNONIZE_IF_VAR_TYPEPATH(typepath, typepath, amount, to_read)

/datum/controller/subsystem/wardrobe/proc/add_queue_item(queued_type, amount)
	var/amount_held = order_list[queued_type] || 0
	set_queue_item(queued_type, amount_held + amount)

/datum/controller/subsystem/wardrobe/proc/remove_queue_item(queued_type, amount)
	var/amount_held = order_list[queued_type]
	if(!amount_held)
		return
	set_queue_item(queued_type, amount_held - amount)

/datum/controller/subsystem/wardrobe/proc/set_queue_item(queued_type, amount)
	var/list/master_info = canon_minimum[queued_type]
	if(!master_info)
		stack_trace("We just tried to queue a type \[[queued_type]\] that's not stored in the master canon")
		return

	var/target_amount = master_info[WARDROBE_CACHE_COUNT] * cache_intensity
	var/list/stock_info = preloaded_stock[queued_type]
	if(stock_info)
		target_amount -= length(stock_info[WARDROBE_STOCK_CONTENTS])

	amount = min(amount, target_amount) // If we're trying to set more then we need, don't!

	if(amount <= 0) // If we already have all we need, end it
		order_list -= queued_type
		return

	order_list[queued_type] = amount

/// Take an existing object, and insert it into our storage or failing that delete it
/// You no longer own this object after passing it in
/datum/controller/subsystem/wardrobe/proc/yield_object(atom/movable/object)
	if(!stash_object(object))
		qdel(object)

/// Take an existing object, and insert it into our storage
/// If we can't or won't take it, we return FALSE. TRUE otherwise
/// You only continue to own this object if TRUE is returned
/datum/controller/subsystem/wardrobe/proc/stash_object(atom/movable/object)
	var/object_type = object.type
	var/list/master_info = canon_minimum[object_type]
	// I will not permit objects you didn't reserve ahead of time
	if(!master_info)
		return FALSE

	// Fuck off
	if(QDELETED(object))
		stack_trace("We tried to stash a qdeleted object, what did you do")
		return FALSE

	var/stock_target = master_info[WARDROBE_CACHE_COUNT] * cache_intensity
	var/amount_held = 0
	var/list/stock_info = preloaded_stock[object_type]
	if(stock_info)
		amount_held = length(stock_info[WARDROBE_STOCK_CONTENTS])

	// Doublely so for things we already have too much of
	if(amount_held - stock_target >= overflow_lienency)
		return FALSE

	if(!stock_info)
		stock_info = new /list(WARDROBE_STOCK_CALL_REMOVAL)
		stock_info[WARDROBE_STOCK_CONTENTS] = list()
		stock_info[WARDROBE_STOCK_CALL_INSERT] = master_info[WARDROBE_CACHE_CALL_INSERT]
		stock_info[WARDROBE_STOCK_CALL_REMOVAL] = master_info[WARDROBE_CACHE_CALL_REMOVAL]
		preloaded_stock[object_type] = stock_info

	if(object.loc != null)
		object.moveToNullspace()
	var/datum/callback/do_on_insert = stock_info[WARDROBE_STOCK_CALL_INSERT]
	if(do_on_insert)
		do_on_insert.FleetingInvoke(object)

	stock_info[WARDROBE_STOCK_CONTENTS] += object
	return TRUE

/// Returns an object of requested_type at location, alongside a set of of lists of a defined key and arguments to call on the new object
/datum/controller/subsystem/wardrobe/proc/provide(datum/requested_type, atom/movable/location, ...)
	var/atom/movable/requested_object
	if(!canon_minimum[requested_type])
		return new requested_type(location)

	var/list/misc_callbacks
	if(length(args) >= 3) // If we got callbacks passed in throw them all in one list for ease of processing
		misc_callbacks = args.Copy(3)

	var/list/stock_info = preloaded_stock[requested_type]
	if(!stock_info)
		stock_miss++
		miss_map[requested_type]++
		requested_object = new requested_type()
		if(length(misc_callbacks))
			apply_misc_callbacks(requested_object, misc_callbacks)
		if(location)
			requested_object.forceMove(location)
		return requested_object

	var/list/contents = stock_info[WARDROBE_STOCK_CONTENTS]
	var/contents_length = length(contents)
	requested_object = contents[contents_length]
	contents.len--

	if(QDELETED(requested_object))
		stack_trace("We somehow ended up with a qdeleted or null object in SSwardrobe's stock. Something's weird, likely to do with reinsertion. Typepath of [requested_type]")
		stock_miss++
		miss_map[requested_type]++
		requested_object = new requested_type()
		if(length(misc_callbacks))
			apply_misc_callbacks(requested_object, misc_callbacks)
		if(location)
			requested_object.forceMove(location)
		return requested_object

	if(length(misc_callbacks))
		apply_misc_callbacks(requested_object, misc_callbacks)

	if(location)
		requested_object.forceMove(location)

	var/datum/callback/do_on_removal = stock_info[WARDROBE_STOCK_CALL_REMOVAL]
	if(do_on_removal)
		do_on_removal.FleetingInvoke(requested_object)

	stock_hit++
	hit_map[requested_type]++
	add_queue_item(requested_type, 1) // Requeue the item, under the assumption we'll never see it again
	if(!(contents_length - 1))
		preloaded_stock -= requested_type

	return requested_object

/// Applies a list of lists of callbacks in the form list(list(define key, arg, ...), ...)
/datum/controller/subsystem/wardrobe/proc/apply_misc_callbacks(datum/apply_to, list/callbacks)
	for(var/list/callback as anything in callbacks)
		var/key = callback[1]
		var/datum/callback/invoke = keyed_callbacks[key]
		invoke.FleetingInvoke(apply_to, callback - key)

/// Unloads an amount of some type we have in stock
/// Private function, for internal use only
/datum/controller/subsystem/wardrobe/proc/unload_stock(datum/unload_type, amount, force = FALSE)
	var/list/stock_info = preloaded_stock[unload_type]
	if(!stock_info)
		return

	var/list/unload_from = stock_info[WARDROBE_STOCK_CONTENTS]
	for(var/i in 1 to min(amount, length(unload_from)))
		var/datum/nuke = unload_from[unload_from.len]
		unload_from.len--
		qdel(nuke)
		if(!force && MC_TICK_CHECK && length(unload_from))
			return

	if(!length(stock_info[WARDROBE_STOCK_CONTENTS]))
		preloaded_stock -= unload_type

/// Sets up insertion and removal callbacks by typepath, alongside our bespoke requestable callbacks
/// We will always use the deepest path. So /obj/item/blade/knife superceeds the entries of /obj/item and /obj/item/blade
/// Mind this
/datum/controller/subsystem/wardrobe/proc/setup_callbacks()
	var/list/play_with = new /list(WARDROBE_CALLBACK_REMOVE) // Don't want organs rotting on the job
	play_with[WARDROBE_CALLBACK_INSERT] = CALLBACK(null, TYPE_PROC_REF(/obj/item/organ, enter_wardrobe))
	play_with[WARDROBE_CALLBACK_REMOVE] = CALLBACK(null, TYPE_PROC_REF(/obj/item/organ, exit_wardrobe))
	initial_callbacks[/obj/item/organ] = play_with

	play_with = new /list(WARDROBE_CALLBACK_REMOVE)
	play_with[WARDROBE_CALLBACK_REMOVE] = CALLBACK(null, TYPE_PROC_REF(/obj/item/storage/box/survival, wardrobe_removal))
	initial_callbacks[/obj/item/storage/box/survival] = play_with

	play_with = new /list(WARDROBE_CALLBACK_REMOVE)
	play_with[WARDROBE_CALLBACK_INSERT] = CALLBACK(null, TYPE_PROC_REF(/obj/item/stack, on_wardrobe_insertion))
	initial_callbacks[/obj/item/stack] = play_with

	play_with = new /list(WARDROBE_CALLBACK_REMOVE)
	play_with[WARDROBE_CALLBACK_INSERT] = CALLBACK(null, TYPE_PROC_REF(/obj/effect/abstract/z_holder, clear))
	initial_callbacks[/obj/effect/abstract/z_holder] = play_with

	// Ok now onto the bespoke ones
	// Gives stacks a way to set their amount before the stack moves and is potentially given up again
	keyed_callbacks[WARDROBE_STACK_AMOUNT] = CALLBACK(null, TYPE_PROC_REF(/obj/item/stack, set_amount))
	keyed_callbacks[WARDROBE_STACK_MATS] = CALLBACK(null, TYPE_PROC_REF(/obj/item/stack, set_mats_per_unit))
	keyed_callbacks[WARDROBE_CONVEYOR_ID] = CALLBACK(null, TYPE_PROC_REF(/obj/item/stack/conveyor, set_id))

/datum/controller/subsystem/wardrobe/proc/load_outfits()
	for(var/datum/outfit/to_stock as anything in subtypesof(/datum/outfit))
		if(!initial(to_stock.preload)) // Clearly not interested
			continue
		var/datum/outfit/hang_up = new to_stock()
		for(var/datum/outfit_item as anything in hang_up.get_types_to_preload())
			canonize_type(outfit_item)
		CHECK_TICK

/datum/controller/subsystem/wardrobe/proc/load_species()
	for(var/datum/species/to_record as anything in subtypesof(/datum/species))
		if(!initial(to_record.preload))
			continue
		var/datum/species/fossil_record = new to_record()
		for(var/obj/item/species_request as anything in fossil_record.get_types_to_preload())
			// Store 5 of each species, since that seems on par with 1 of each outfit
			canonize_type(species_request, 5)
		CHECK_TICK

/datum/controller/subsystem/wardrobe/proc/load_storage_contents()
	for(var/obj/item/storage/crate as anything in subtypesof(/obj/item/storage))
		if(!initial(crate.preload))
			continue
		var/obj/item/storage/another_crate = new crate()
		//Unlike other uses, I really don't want people being lazy with this one.
		var/list/somehow_more_boxes = another_crate.get_types_to_preload()
		if(!length(somehow_more_boxes))
			stack_trace("You appear to have set preload to true on [crate] without defining get_types_to_preload. Please be more strict about your scope, this stuff is spooky")
		for(var/datum/a_really_small_box as anything in somehow_more_boxes)
			canonize_type(a_really_small_box)
		qdel(another_crate)
		CHECK_TICK

/datum/controller/subsystem/wardrobe/proc/load_stacks()
	for(var/obj/item/stack/stackable as anything in subtypesof(/obj/item/stack))
		if(!initial(stackable.preload))
			continue
		// 5 of each type, just to provide a decent baseline
		canonize_type(stackable, 5)
		CHECK_TICK
	// I want to be prepared for explosions
	var/turf/closed/wall/read_from = /turf/closed/wall
	CANNONIZE_IF_VAR_TYPEPATH(/obj/item/stack, initial(read_from.sheet_type), 800, preload)
	read_from = /turf/closed/wall/r_wall
	CANNONIZE_IF_VAR_TYPEPATH(/obj/item/stack, initial(read_from.sheet_type), 200, preload)
	CANNONIZE_IF_VAR(/obj/item/stack/cable_coil, 450, preload)
	CANNONIZE_IF_VAR(/obj/item/stack/rods, 700, preload)

/datum/controller/subsystem/wardrobe/proc/load_shards()
	for(var/obj/item/shard/secret_sauce as anything in subtypesof(/obj/item/shard))
		if(!initial(secret_sauce.preload))
			continue
		// 5 of each type, just to provide a decent buffer for explosions in engi and stuff
		canonize_type(secret_sauce, 5)
		CHECK_TICK
	// I want to be ready for exploisions and massive window shattering
	CANNONIZE_IF_VAR_TYPEPATH(/obj/item/shard, /obj/item/shard, 350, preload)

/datum/controller/subsystem/wardrobe/proc/load_abstract()
	// We make and delete a LOT of these all at once (explosions, shuttles, etc)
	// It's worth caching them, and they have low side effects so it's safe too
	canonize_type(/obj/effect/abstract/z_holder, 300)

/datum/controller/subsystem/wardrobe/proc/display_consumption_info()
	var/list/tracked_deets = list()
	for(var/print in hit_map|miss_map)
		var/hit_count = hit_map[print] || 0
		var/miss_count = miss_map[print] || 0
		tracked_deets += list(list(print, hit_count, miss_count, miss_count ? hit_count / miss_count : 0))

	sortTim(tracked_deets, cmp=/proc/cmp_wardrobe_cache)
	var/list/trackin_info = list("<B>Cache information</B><BR><BR><ol>")
	for(var/list/deets in tracked_deets)
		trackin_info += "<li><u>"
		trackin_info += deets[1]
		trackin_info += "</u></li>"

		trackin_info += "<li>Hit: "
		trackin_info += deets[2]
		trackin_info += "</li>"

		trackin_info += "<li>Miss: "
		trackin_info += deets[3]
		trackin_info += "</li>"

		trackin_info += "<li>Ratio: "
		trackin_info += deets[4]
		trackin_info += "%</li>"
	trackin_info += "</ol>"
	usr << browse(trackin_info.Join(), "window=wardrobe_perf")

/// Sorts the worst entries up to the top, based off the ratio between hit and miss
/proc/cmp_wardrobe_cache(list/A, list/B)
	if(A[4] < B[4])
		return 1
	return -1

/// Debug proc, should not use
/datum/controller/subsystem/wardrobe/proc/clear_consumption_info()
	hit_map = list()
	miss_map = list()

/// Runs a speed test for all our various types
/// Measures the average cost of providing vs spawning, and deletion vs stashing
/// This will take for fucking ever (20 min on my machine). I'm sorry for that
/datum/controller/subsystem/wardrobe/proc/speed_test(turf/spawn_on, attempt_count = 200)
	var/old_overflow_lienency = overflow_lienency
	overflow_lienency = INFINITY

	// Stock everything I want IMMEDIATELY
	force_stock_wardrobe(attempt_count)

	// List of lists in the form list(type, new_cost, provide_cost, qdel_cost, stash_cost)
	// I am writing this dumb because it's very hot (lots of shit) and I don't want to add any extra time
	var/list/type_info = list()
	var/atom/hh
	var/stopwatch_start
	var/new_cost = 0
	var/provide_cost = 0
	var/qdel_cost = 0
	var/stash_cost = 0
	for(var/atom/movable/type_to_test as anything in preloaded_stock)
		new_cost = 0
		provide_cost = 0
		qdel_cost = 0
		stash_cost = 0
		for(var/i in 1 to attempt_count)
			// Stopwatches are one per proc, so lets give them their own scope
			do {
				stopwatch_start = TICK_USAGE
				hh = new type_to_test(spawn_on)
				new_cost += TICK_USAGE_TO_MS(stopwatch_start)
				QDEL_NULL(hh)
			} while(FALSE)
			// In case subobjects are also tracked, this avoids any mistakes
			force_stock_wardrobe(attempt_count)
			// Now provide()
			do {
				stopwatch_start = TICK_USAGE
				hh = SSwardrobe.provide(type_to_test, spawn_on)
				provide_cost += TICK_USAGE_TO_MS(stopwatch_start)
				QDEL_NULL(hh)
			} while(FALSE)
			force_stock_wardrobe(attempt_count)
			// qdel()
			do {
				hh = SSwardrobe.provide(type_to_test, spawn_on)
				stopwatch_start = TICK_USAGE
				qdel(hh)
				qdel_cost += TICK_USAGE_TO_MS(stopwatch_start)
				hh = null
			} while(FALSE)
			force_stock_wardrobe(attempt_count)
			// stash_object()
			do {
				hh = SSwardrobe.provide(type_to_test, spawn_on)
				stopwatch_start = TICK_USAGE
				SSwardrobe.stash_object(hh)
				stash_cost += TICK_USAGE_TO_MS(stopwatch_start)
				hh = null
			} while(FALSE)
			force_stock_wardrobe(attempt_count)
		type_info += list(list(type_to_test, new_cost, provide_cost, qdel_cost, stash_cost))

	overflow_lienency = old_overflow_lienency
	// Ok now we have our data, time to print it
	var/list/wardrobe_info = list("<B>Performance information ([attempt_count] runs)</B><BR><BR><ol>")
	sortTim(type_info, cmp=/proc/cmp_wardrobe_performance)
	for(var/list/deets in type_info)
		wardrobe_info += "<li><u>"
		wardrobe_info += deets[1]
		wardrobe_info += "</u></li>"

		wardrobe_info += "<li>New: "
		wardrobe_info += deets[2]
		wardrobe_info += "ms</li>"

		wardrobe_info += "<li>Provide: "
		wardrobe_info += deets[3]
		wardrobe_info += "ms</li>"

		wardrobe_info += "<li>Qdel: "
		wardrobe_info += deets[4]
		wardrobe_info += "ms</li>"

		wardrobe_info += "<li>Stash: "
		wardrobe_info += deets[5]
		wardrobe_info += "ms</li>"
		wardrobe_info += "</ul></li>"
	wardrobe_info += "</ol>"

	usr << browse(wardrobe_info.Join(), "window=wardrobe_perf")

/// Sorts the fastest entries up to the top, based off how long the wardrobe version takes vs the normal sort
/proc/cmp_wardrobe_performance(list/A, list/B)
	var/create_delta_a = A[3] - A[2]
	var/create_delta_b = B[3] - B[2]
	var/del_delta_a = A[5] - A[4]
	var/del_delta_b = B[5] - B[4]
	if(create_delta_a + del_delta_a > create_delta_b + del_delta_b)
		return 1
	return -1

/// Stocks the wardrobe to stock_to items, no more no less
/// Only usable for testing, will not work well in production as it'll likely just get run over by other code
/datum/controller/subsystem/wardrobe/proc/force_stock_wardrobe(stock_to)
	var/list/canon_minimum = src.canon_minimum
	var/list/preloaded_stock = src.preloaded_stock
	for(var/datum/loaded_type as anything in canon_minimum)
		var/list/stock_info = preloaded_stock[loaded_type]
		var/amount_held = 0
		if(stock_info)
			amount_held = length(stock_info[WARDROBE_STOCK_CONTENTS])

		var/target_delta = amount_held - stock_to

		// If we've got anything over the line, cut it back down
		if(target_delta > 0)
			unload_stock(loaded_type, target_delta, force = TRUE)
			continue
		// If we have more then we target, just don't you feel me?
		else if (target_delta == 0)
			continue

		// If we don't have enough, queue enough to make up the remainder
		for(var/i in 1 to abs(target_delta))
			yield_object(new loaded_type())
