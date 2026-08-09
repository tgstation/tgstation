///yeet yourself at a thing
/datum/bt_node/ai_behavior/throw_attack
	/// Sound played on each throw.
	var/attack_sound = 'sound/items/haunted/ghostitemattack.ogg'
	/// Maximum throws before the attack is exhausted.
	var/max_attempts = 4
	/// Blackboard key holding the throw target.
	var/target_key
	/// Blackboard key tracking how many throws have happened.
	var/throw_count_key

/datum/bt_node/ai_behavior/throw_attack/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/item/item_pawn = controller.pawn
	var/atom/throw_target = controller.blackboard[target_key]
	if(QDELETED(throw_target))
		controller.clear_blackboard_key(target_key)
		controller.set_blackboard_key(throw_count_key, 0)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	item_pawn.visible_message(span_warning("[item_pawn] hurls towards [throw_target]!"))
	item_pawn.throw_at(throw_target, rand(4, 5), 9)
	playsound(item_pawn.loc, attack_sound, 100, TRUE)
	controller.add_blackboard_key(throw_count_key, 1)
	if(controller.blackboard[throw_count_key] >= max_attempts)
		return on_throws_exhausted(controller, throw_target, target_key, throw_count_key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Clears target and resets throw count. Override to add extra on-exhaust logic.
/datum/bt_node/ai_behavior/throw_attack/proc/on_throws_exhausted(datum/ai_controller/controller, atom/throw_target, target_key, throw_count_key)
	controller.clear_blackboard_key(target_key)
	controller.set_blackboard_key(throw_count_key, 0)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
