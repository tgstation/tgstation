/// This subsystem strives to make loading large amounts of select objects as smooth at execution as possible
/// It preloads a set of types to store, and caches them until requested
/// Doesn't catch everything mind, this is intentional. There's many types that expect to either
/// A: Not sit in a list for 2 hours, or B: have extra context passed into them, or for their parent to be their location
/// You should absolutely not spam this system, it will break things in new and wonderful ways
/// S close enough for government work though.
/// Fuck you goonstation
SUBSYSTEM_DEF(wardrobe)
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

/datum/controller/subsystem/wardrobe/Initialize(start_timeofday)
	. = ..()
	setup_callbacks()
	load_outfits()
	load_species()
	load_pda_nicknacks()
	load_storage_contents()
	hard_refresh_queue()
	stock_hit = 0
	stock_miss = 0

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
			stash_object(new_member)

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
 *
*/
/datum/controller/subsystem/wardrobe/proc/canonize_type(type_to_stock)
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
	master_info[WARDROBE_CACHE_COUNT] += 1
	one_go_master++

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

/// Take an existing object, and insert it into our storage
/// If we can't or won't take it, it's deleted. You do not own this object after passing it in
/datum/controller/subsystem/wardrobe/proc/stash_object(atom/movable/object)
	var/object_type = object.type
	var/list/master_info = canon_minimum[object_type]
	// I will not permit objects you didn't reserve ahead of time
	if(!master_info)
		qdel(object)
		return

	var/stock_target = master_info[WARDROBE_CACHE_COUNT] * cache_intensity
	var/amount_held = 0
	var/list/stock_info = preloaded_stock[object_type]
	if(stock_info)
		amount_held = length(stock_info[WARDROBE_STOCK_CONTENTS])

	// Doublely so for things we already have too much of
	if(amount_held - stock_target >= overflow_lienency)
		qdel(object)
		return
	// Fuck off
	if(QDELETED(object))
		stack_trace("We tried to stash a qdeleted object, what did you do")
		return

	if(!stock_info)
		stock_info = new /list(WARDROBE_STOCK_CALL_REMOVAL)
		stock_info[WARDROBE_STOCK_CONTENTS] = list()
		stock_info[WARDROBE_STOCK_CALL_INSERT] = master_info[WARDROBE_CACHE_CALL_INSERT]
		stock_info[WARDROBE_STOCK_CALL_REMOVAL] = master_info[WARDROBE_CACHE_CALL_REMOVAL]
		preloaded_stock[object_type] = stock_info

	var/datum/callback/do_on_insert = stock_info[WARDROBE_STOCK_CALL_INSERT]
	if(do_on_insert)
		do_on_insert.object = object
		do_on_insert.Invoke()
		do_on_insert.object = null

	object.moveToNullspace()
	stock_info[WARDROBE_STOCK_CONTENTS] += object

/datum/controller/subsystem/wardrobe/proc/provide_type(datum/requested_type, atom/movable/location)
	var/atom/movable/requested_object
	var/list/stock_info = preloaded_stock[requested_type]
	if(!stock_info)
		stock_miss++
		requested_object = new requested_type(location)
		return requested_object

	var/list/contents = stock_info[WARDROBE_STOCK_CONTENTS]
	var/contents_length = length(contents)
	requested_object = contents[contents_length]
	contents.len--

	if(QDELETED(requested_object))
		stack_trace("We somehow ended up with a qdeleted or null object in SSwardrobe's stock. Something's weird, likely to do with reinsertion. Typepath of [requested_type]")
		stock_miss++
		requested_object = new requested_type(location)
		return requested_object

	if(location)
		requested_object.forceMove(location)

	var/datum/callback/do_on_removal = stock_info[WARDROBE_STOCK_CALL_REMOVAL]
	if(do_on_removal)
		do_on_removal.object = requested_object
		do_on_removal.Invoke()
		do_on_removal.object = null

	stock_hit++
	add_queue_item(requested_type, 1) // Requeue the item, under the assumption we'll never see it again
	if(!(contents_length - 1))
		preloaded_stock -= requested_type

	return requested_object

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

/// Sets up insertion and removal callbacks by typepath
/// We will always use the deepest path. So /obj/item/blade/knife superceeds the entries of /obj/item and /obj/item/blade
/// Mind this
/datum/controller/subsystem/wardrobe/proc/setup_callbacks()
	var/list/play_with = new /list(WARDROBE_CALLBACK_REMOVE) // Turns out there's a global list of pdas. Let's work around that yeah?
	play_with[WARDROBE_CALLBACK_INSERT] = CALLBACK(null, /obj/item/pda/proc/display_pda)
	play_with[WARDROBE_CALLBACK_REMOVE] = CALLBACK(null, /obj/item/pda/proc/cloak_pda)
	initial_callbacks[/obj/item/pda] = play_with

	play_with = new /list(WARDROBE_CALLBACK_REMOVE) // Don't want organs rotting on the job
	play_with[WARDROBE_CALLBACK_INSERT] = CALLBACK(null, /obj/item/organ/proc/enter_wardrobe)
	play_with[WARDROBE_CALLBACK_REMOVE] = CALLBACK(null, /obj/item/organ/proc/exit_wardrobe)
	initial_callbacks[/obj/item/organ] = play_with

	play_with = new /list(WARDROBE_CALLBACK_REMOVE)
	play_with[WARDROBE_CALLBACK_REMOVE] = CALLBACK(null, /obj/item/storage/box/survival/proc/wardrobe_removal)
	initial_callbacks[/obj/item/storage/box/survival] = play_with

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
			for(var/i in 1 to 5) // Store 5 of each species, since that seems on par with 1 of each outfit
				canonize_type(species_request)
		CHECK_TICK

/datum/controller/subsystem/wardrobe/proc/load_pda_nicknacks()
	for(var/obj/item/pda/pager as anything in typesof(/obj/item/pda))
		var/obj/item/pda/flip_phone = new pager()
		for(var/datum/outfit_item_type as anything in flip_phone.get_types_to_preload())
			canonize_type(outfit_item_type)
		qdel(flip_phone)
		CHECK_TICK

/datum/controller/subsystem/wardrobe/proc/load_storage_contents()
	for(var/obj/item/storage/crate as anything in subtypesof(/obj/item/storage))
		if(!initial(crate.preload))
			continue
		var/obj/item/pda/another_crate = new crate()
		//Unlike other uses, I really don't want people being lazy with this one.
		var/list/somehow_more_boxes = another_crate.get_types_to_preload()
		if(!length(somehow_more_boxes))
			stack_trace("You appear to have set preload to true on [crate] without defining get_types_to_preload. Please be more strict about your scope, this stuff is spooky")
		for(var/datum/a_really_small_box as anything in somehow_more_boxes)
			canonize_type(a_really_small_box)
		qdel(another_crate)
