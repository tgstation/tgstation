/// Picks a random visible, non-abstract atom within range 2 and stores it in a blackboard key.
/datum/bt_node/ai_behavior/find_nearby
	/// Blackboard key to store the found atom in.
	var/target_key

/datum/bt_node/ai_behavior/find_nearby/perform(seconds_per_tick, datum/ai_controller/controller)
	var/list/possible_targets = list()
	for(var/atom/thing in view(2, controller.pawn))
		if(!thing.mouse_opacity)
			continue
		if(thing.IsObscured())
			continue
		if(isitem(thing))
			var/obj/item/item = thing
			if(item.item_flags & ABSTRACT)
				continue
		possible_targets += thing
	if(!possible_targets.len)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(target_key, pick(possible_targets))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
