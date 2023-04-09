//this file has procs that help ais think good. used by behaviors mostly


/// Returns either the best weapon from the given choices or null if held weapons are better
/proc/GetBestWeapon(datum/ai_controller/controller, list/choices, list/held_weapons)
	var/gun_neurons_activated = controller.blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED]
	var/top_force = 0
	var/obj/item/top_force_item
	for(var/obj/item/item as anything in held_weapons)
		if(!item)
			continue
		if(HAS_TRAIT(item, TRAIT_NEEDS_TWO_HANDS) || controller.blackboard[BB_MONKEY_BLACKLISTITEMS][item])
			continue
		if(gun_neurons_activated && isgun(item))
			// We have a gun, why bother looking for something inferior
			// Also yes it is intentional that pawns dont know how to pick the best gun
			return item
		if(item.force > top_force)
			top_force = item.force
			top_force_item = item

	for(var/obj/item/item as anything in choices)
		if(!item)
			continue
		if(HAS_TRAIT(item, TRAIT_NEEDS_TWO_HANDS) || controller.blackboard[BB_MONKEY_BLACKLISTITEMS][item])
			continue
		if(gun_neurons_activated && isgun(item))
			return item
		if(item.force <= top_force)
			continue
		top_force_item = item
		top_force = item.force

	return top_force_item

///returns if something can be consumed, drink or food
/proc/IsEdible(obj/item/thing)
	if(!istype(thing))
		return FALSE
	if(IS_EDIBLE(thing))
		return TRUE
	if(istype(thing, /obj/item/reagent_containers/cup/glass/drinkingglass))
		var/obj/item/reagent_containers/cup/glass/drinkingglass/glass = thing
		if(glass.reagents.total_volume) // The glass has something in it, time to drink the mystery liquid!
			return TRUE
	return FALSE
