//this file has procs that help ais think good. used by behaviors mostly


/// Returns either the best weapon from the given choices or null if held weapons are better
/proc/GetBestWeapon(datum/ai_controller/controller, list/choices, list/held_weapons)
	var/gun_neurons_activated = controller.blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED]
	var/top_force = 0
	var/obj/item/top_force_item
	for(var/obj/item/item in held_weapons)
		if(HAS_TRAIT(item, TRAIT_NEEDS_TWO_HANDS) || controller.blackboard[BB_MONKEY_BLACKLISTITEMS][item])
			continue
		if(gun_neurons_activated && isgun(item))
			// We have a gun, why bother looking for something inferior
			// Also yes it is intentional that pawns dont know how to pick the best gun
			return item
		if(item.force > top_force)
			top_force = item.force
			top_force_item = item

	for(var/obj/item/item in choices)
		if(HAS_TRAIT(item, TRAIT_NEEDS_TWO_HANDS) || controller.blackboard[BB_MONKEY_BLACKLISTITEMS][item])
			continue
		if(gun_neurons_activated && isgun(item))
			return item
		if(item.force <= top_force)
			continue
		top_force_item = item
		top_force = item.force

	return top_force_item


/// Gets the ability from the blackboard given the key, else null
/atom/proc/get_ability_from_blackboard(key)
	var/datum/ai_controller/controller = ai_controller
	if(isnull(controller))
		return null
	var/datum/action/action_ability = controller.blackboard[key]
	return action_ability
