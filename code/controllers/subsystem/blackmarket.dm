SUBSYSTEM_DEF(blackmarket)
	name		 = "Blackmarket"
	flags		 = SS_BACKGROUND
	init_order	 = INIT_ORDER_DEFAULT

	// I don't know why you would need this but it can be fun.
	var/supplypod_type = /obj/structure/closet/supplypod
	var/shipping_method_descriptions = list(
		SHIPPING_METHOD_DROPPOD="Launches a supply pod in the general area of the uplink.",
		SHIPPING_METHOD_LAUNCH="Launches the item at the station from space, cheap but you might not recieve your item at all.",
		SHIPPING_METHOD_LTSRBT="Long-To-Short-Range-Bluespace-Transceiver, a machine that recieves items outside the station and then teleports them to the location of the uplink.",
		SHIPPING_METHOD_TELEPORT="Teleports the item in a random area in the station, you get 60 seconds to get there first though."
	)

	var/list/datum/blackmarket_market/markets		= list()
	var/list/obj/machinery/ltsrbt/telepads			= list()
	var/list/queued_purchases 						= list()

/datum/controller/subsystem/blackmarket/Initialize(timeofday)
	for(var/market in subtypesof(/datum/blackmarket_market))
		markets[market] += new market
		for(var/cat in markets[market].categories)
			markets[market].available_items[cat] = list()
	
	for(var/item in subtypesof(/datum/blackmarket_item))
		var/datum/blackmarket_item/I = new item
		if(!I.item)
			qdel(I)
			continue
		if(!prob(I.availability_prob))
			qdel(I)
			continue
		for(var/M in I.markets)
			if(!markets[M])
				CRASH("SSblackmarket: Item [I.name] available in market that does not exist.")
			var/datum/blackmarket_market/market = markets[M]
			market.available_items[I.category] += I
	. = ..()

/datum/controller/subsystem/blackmarket/fire(resumed)
	// This whole system will break if the uplink gets removed before the order is processed.
	for(var/datum/blackmarket_purchase/purchase in queued_purchases)
		switch(purchase.method)
			// Find a ltsrbt pad and make it handle the shipping.
			if(SHIPPING_METHOD_LTSRBT)
				if(!telepads.len)
					continue
				// Prioritize pads that don't have a cooldown active.
				var/free_pad_found = FALSE
				for(var/obj/machinery/ltsrbt/pad in telepads)
					if(pad.recharge_cooldown)
						continue
					pad.add_to_queue(purchase)
					queued_purchases -= purchase
					free_pad_found = TRUE
					break
				
				if(free_pad_found)
					continue
				
				var/obj/machinery/ltsrbt/pad = pick(telepads)
				purchase.uplink.visible_message("<span class='notice'>[purchase.uplink] flashes a message noting that the order is being processed by [pad].</span>")
				queued_purchases -= purchase
				pad.add_to_queue(purchase)
			// Get random area, throw it somewhere there.
			if(SHIPPING_METHOD_TELEPORT)
				var/turf/targetturf = get_safe_random_station_turf()
				// This shouldn't happen.
				if (!targetturf)
					continue
				
				purchase.uplink.visible_message("<span class='notice'>[purchase.uplink] flashes a message noting that the order is being teleported to [get_area(targetturf)] in 60 seconds.</span>")
				addtimer(CALLBACK(GLOBAL_PROC, /proc/do_teleport, purchase.entry.spawn_item(), targetturf), 60 SECONDS)
				queued_purchases -= purchase
				qdel(purchase)
				
			// Get the current area of the uplink if it exists, drop the item there.
			if(SHIPPING_METHOD_DROPPOD)
				var/area/A = get_area(purchase.uplink)
				var/LZ
				if(A.valid_territory)
					var/list/empty_turfs
					for(var/turf/open/floor/T in A.contents)
						if(is_blocked_turf(T))
							continue
						LAZYADD(empty_turfs, T)
						CHECK_TICK
					if(empty_turfs && empty_turfs.len)
						LZ = pick(empty_turfs)
				// Alright, bad area. cancel would happen here but I am too lazy to do that. Anyways just drop it on the uplink
				else
					LZ = get_turf(purchase.uplink)
				
				if(LZ)
					new /obj/effect/DPtarget(LZ, supplypod_type, purchase.entry.spawn_item())

					purchase.uplink.visible_message("<span class='notice'>[purchase.uplink] flashes a message noting that the order is being dropped to [get_area(LZ)].</span>")
					queued_purchases -= purchase
					qdel(purchase)

					continue
				
				// Guessing the uplink got sent to the void realm. This will refund at some point
				queued_purchases -= purchase
				qdel(purchase)
			// Get the current location of the uplink if it exists, then throws the item from space at the station from a random direction.
			if(SHIPPING_METHOD_LAUNCH)
				var/startSide = pick(GLOB.cardinals)
				var/pickedloc = spaceDebrisStartLoc(startSide, purchase.uplink.z)

				var/atom/movable/item = purchase.entry.spawn_item(pickedloc)
				item.throw_at(purchase.uplink, 3, 3)

				purchase.uplink.visible_message("<span class='notice'>[purchase.uplink] flashes a message noting the order is being launched from [dir2text(startSide)].</span>")
				queued_purchases -= purchase
				qdel(purchase)
		
		if(MC_TICK_CHECK)
			return

// Add to queued_purchases after checking if shipping method is available.
/datum/controller/subsystem/blackmarket/proc/queue_item(datum/blackmarket_purchase/P)
	// Should never have the same purchase in the list anyways.
	queued_purchases += P
	return TRUE
