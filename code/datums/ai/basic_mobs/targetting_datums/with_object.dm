/**
 * Find mobs who are holding the configurable object type
 *
 * This is an extension of basic targeting behaviour, that allows you to
 * only target the mob if they have a specific item in their hand.
 *
 */
/datum/targetting_datum/basic/holding_object
	// We will find mobs who are holding this object in their hands
	var/object_type_path = null

/**
 * Create an instance of the holding object targeting datum
 *
 * * object_type_path Pass an object type path, this will be compared to the items
 *   in targets hands to filter the target list.
 */
/datum/targetting_datum/basic/holding_object/New(object_type_path)
	if (!ispath(object_type_path))
		stack_trace("trying to create an item targeting datum with no valid typepath")
		// Leaving object type as null will make this basically a noop
		return
	src.object_type_path = object_type_path

///Returns true or false depending on if the target can be attacked by the mob
/datum/targetting_datum/basic/holding_object/can_attack(mob/living/living_mob, atom/target, vision_range)
	if (object_type_path == null)
		return FALSE // no op
	if(!ismob(target))
		return FALSE // no hands no problems

	// Look at me, type casting like a grown up
	var/mob/targetmob = target
	// Check if our parent behaviour agrees we can attack this target (we ignore faction by default)
	var/can_attack = ..()
	if(can_attack && targetmob.is_holding_item_of_type(object_type_path))
		return TRUE // they have the item
	// No valid target
	return FALSE
