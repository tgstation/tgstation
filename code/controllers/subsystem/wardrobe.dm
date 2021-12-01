///This subsystem strives to make loading outfits as smooth at execution as possible
///It preloads a set of marked outfit datum's equipment, and caches them until requested
///Doesn't catch everything mind, but it's close enough for government work
///Fuck you goonstation
SUBSYSTEM_DEF(wardrobe)
	name = "Wardrobe"
	wait = 10 //This is more like a queue then anything else
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT //We're going to fill up our cache while players sit in the lobby
	///How much to cache outfit items
	///Multiplier, 2 would mean cache enough items to stock 1 of each preloaded order twice, etc
	var/cache_intensity = 2
	///How many more then the template of a type are we allowed to have before we delete applicants?
	var/overflow_lienency = 2
	///Canonical list of types required to fill all preloaded stocks once.
	///Type -> count
	var/list/outfit_minimum = list()
	///List of types to load. Type -> count //(I'd do a list of lists but this needs to be refillable)
	var/list/order_list = list()
	///List of lists. Contains our preloaded atoms. Type -> list(last inspect time, list(instances))
	var/list/preloaded_stock = list()
	///The last time we inspected our stock
	var/last_inspect_time = 0
	///How often to inspect our stock, in deciseconds
	var/inspect_delay = 30 SECONDS
	///What we're currently doing
	var/current_task = SSWARDROBE_STOCK
	///How many times we've had to generate a stock item on request
	var/stock_miss = 0
	///How many times we've successfully returned a cached item
	var/stock_hit = 0

/datum/controller/subsystem/wardrobe/Initialize(start_timeofday)
	. = ..()
	load_outfits()
	hard_refresh_queue()

/datum/controller/subsystem/wardrobe/proc/load_outfits()
	for(var/datum/outfit/outfit_to_stock as anything in typesof(/datum/outfit))
		if(!initial(outfit_to_stock.preload)) //Clearly not interested
			continue
		store_outfit(new outfit_to_stock)
		CHECK_TICK

///Resets the load queue to the master template, accounting for the existing stock
/datum/controller/subsystem/wardrobe/proc/hard_refresh_queue()
	for(var/datum/type_to_queue as anything in outfit_minimum)
		var/amount_to_load = outfit_minimum[type_to_queue] * cache_intensity
		var/list/stock_info = preloaded_stock[type_to_queue]
		if(stock_info) //If we already have stuff, reduce the amount we load
			amount_to_load -= length(stock_info[2])
		set_queue_item(type_to_queue, amount_to_load)

/datum/controller/subsystem/wardrobe/stat_entry(msg)
	var/total_provided = max(stock_hit + stock_miss, 1)
	msg += " P:[length(outfit_minimum)] Q:[length(order_list)] S:[length(preloaded_stock)] I:[cache_intensity] O:[overflow_lienency]"
	msg += " H:[stock_hit] M:[stock_miss] T:[total_provided] H/T:[stock_hit / total_provided] M/T:[stock_miss / total_provided]"
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

///Turns the order list into actual loaded items, this is where most work is done
/datum/controller/subsystem/wardrobe/proc/stock_wardrobe()
	for(var/datum/type_to_stock as anything in order_list)
		var/amount_to_stock = order_list[type_to_stock]
		for(var/i in 1 to amount_to_stock)
			if(MC_TICK_CHECK)
				order_list[type_to_stock] = (amount_to_stock - (i - 1)) //Account for types we've already created
				return
			var/datum/new_suit = new type_to_stock()
			stash_object(new_suit)

		order_list -= type_to_stock
		if(MC_TICK_CHECK)
			return

///If we have a spare moment, go through the current stock and make sure we don't have too much of one thing
///Or that we're not too low on some other stock
///This exists as a failsafe, so the wardrobe doesn't just end up generating too many items
/datum/controller/subsystem/wardrobe/proc/run_inspection()
	for(var/datum/loaded_type as anything in preloaded_stock)
		var/list/stock_info = preloaded_stock[loaded_type]
		var/last_looked_at = stock_info[WARDROBE_STOCK_LAST_INSPECT]
		if(last_looked_at == last_inspect_time)
			continue

		var/list/held_objects = stock_info[WARDROBE_STOCK_CONTENTS]
		var/amount_held = length(held_objects)
		var/target_stock = outfit_minimum[loaded_type] * cache_intensity
		var/target_delta = amount_held - target_stock
		//If we've got too much
		if(target_delta > overflow_lienency)
			unload_stock(loaded_type, target_delta - overflow_lienency)
			if(state != SS_RUNNING)
				return

		//If we have more then we target, just continue
		target_delta = min(target_delta, 0) //I only want negative numbers to matter here

		//If we don't have enough, queue enough to make up the remainder
		//If we have too much in the queue, cull to 0. We do this so time isn't wasted creating and destroying entries
		set_queue_item(loaded_type, abs(target_delta))

		stock_info[WARDROBE_STOCK_LAST_INSPECT] = last_inspect_time

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/wardrobe/proc/canonize_type(type_to_stock)
	if(!type_to_stock)
		return
	if(!ispath(type_to_stock))
		stack_trace("Non path [type_to_stock] attempted to canonize itself. Something's fucky")
	if(!outfit_minimum[type_to_stock])
		outfit_minimum[type_to_stock] = 0
	outfit_minimum[type_to_stock] += 1

/datum/controller/subsystem/wardrobe/proc/add_queue_item(queued_type, amount)
	if(amount <= 0)
		return
	if(!order_list[queued_type])
		order_list[queued_type] = 0
	order_list[queued_type] += amount

/datum/controller/subsystem/wardrobe/proc/remove_queue_item(queued_type, amount)
	if(amount <= 0)
		return
	var/current_amount = order_list[queued_type]
	if(!current_amount)
		return
	if(current_amount - amount <= 0)
		order_list -= queued_type
		return

	order_list[queued_type] = current_amount - amount

/datum/controller/subsystem/wardrobe/proc/set_queue_item(queued_type, amount)
	if(amount <= 0)
		order_list -= queued_type
		return
	order_list[queued_type] = amount

///Take an existing object, and insert it into our storage
///If we can't or won't take it, it's deleted. You do not own this object after passing it in
/datum/controller/subsystem/wardrobe/proc/stash_object(datum/object)
	var/object_type = object.type
	var/stock_target = outfit_minimum[object_type] * cache_intensity
	var/amount_held = 0
	var/list/stock_info = preloaded_stock[object_type]
	if(stock_info)
		amount_held = length(stock_info[WARDROBE_STOCK_CONTENTS])

	//I will not permit objects you didn't reserve ahead of time
	//Doublely so for things we already have too much of
	if(!stock_target || amount_held - stock_target > overflow_lienency)
		qdel(object)
		return

	if(!stock_info)
		preloaded_stock[object_type] = new /list(WARDROBE_STOCK_CONTENTS)
		stock_info = preloaded_stock[object_type]
		stock_info[WARDROBE_STOCK_LAST_INSPECT] = 0
		stock_info[WARDROBE_STOCK_CONTENTS] = list()

	stock_info[WARDROBE_STOCK_CONTENTS] += object

/datum/controller/subsystem/wardrobe/proc/provide_type(datum/requested_type, atom/movable/location)
	var/atom/movable/requested_object
	var/list/stock_info = preloaded_stock[requested_type]
	if(!stock_info)
		stock_miss++
		requested_object = new requested_type()
	else
		var/list/contents = stock_info[WARDROBE_STOCK_CONTENTS]
		requested_object = contents[contents.len]
		contents.len--
		stock_hit++
		add_queue_item(requested_type, 1) //Requeue the item, under the assumption we'll never see it again
		if(!length(contents))
			preloaded_stock -= requested_type

	if(location)
		requested_object.forceMove(location)

	return requested_object

///Unloads an amount of some type we have in stock
///Private function, for internal use only
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

/datum/controller/subsystem/wardrobe/proc/store_outfit(datum/outfit/hang_up)
	///You should do this dynamically. List on the outfit of things to cache, use initial to read it, and take a copy of initial vars
	///Iterate that, rather then doing this ridged method
	///As a bonus, we can force people who touch outfits to care about this
	var/list/types_to_store = hang_up.get_types_to_preload()
	for(var/datum/outfit_item_type as anything in types_to_store)
		canonize_type(outfit_item_type)
