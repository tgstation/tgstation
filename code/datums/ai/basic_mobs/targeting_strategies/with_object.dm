/**
 * Find mobs who are holding the bb configurable object type
 *
 * This is an extension of basic targeting behaviour, that allows you to
 * only target the mob if they have a specific item in their hand.
 *
 */
/datum/targeting_strategy/basic/holding_object
	/// BB key that holds the target typepath to use
	var/target_item_key = BB_TARGET_HELD_ITEM

///Returns true or false depending on if the target can be attacked by the mob
/datum/targeting_strategy/basic/holding_object/can_attack(mob/living/living_mob, atom/target, vision_range)
	var/datum/ai_controller/controller = living_mob.ai_controller
	var/object_type_path = controller.blackboard[target_item_key]

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
