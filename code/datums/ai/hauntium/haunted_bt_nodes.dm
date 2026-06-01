/// Gates on whether the haunted item pawn is currently inside a mob's inventory.
/datum/bt_node/decorator/item_being_held

/datum/bt_node/decorator/item_being_held/check_condition(datum/ai_controller/controller)
	return ismob(controller.pawn.loc)

/**
 * Attempts to slip out of the holder's hands with a per-tick probability.
 * Returns RUNNING while waiting for the chance to fire; SUCCEEDED after escaping.
 */
/datum/bt_node/ai_behavior/item_escape_grasp

/datum/bt_node/ai_behavior/item_escape_grasp/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!SPT_PROB(HAUNTED_ITEM_ESCAPE_GRASP_CHANCE, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT
	var/obj/item/item_pawn = controller.pawn
	var/mob/item_holder = item_pawn.loc
	if(!ismob(item_holder))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	item_pawn.visible_message(span_warning("[item_pawn] slips out of the hands of [item_holder]!"))
	item_holder.dropItemToGround(item_pawn, TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/**
 * Scans BB_TO_HAUNT_LIST for a valid nearby target and sets the target key.
 * Includes the per-tick attack chance roll — fails immediately if the roll doesn't fire.
 * Prunes depleted and out-of-range entries on the way through.
 */
/datum/bt_node/ai_behavior/pick_haunt_target

/datum/bt_node/ai_behavior/pick_haunt_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, haunt_list_key)
	if(!SPT_PROB(HAUNTED_ITEM_ATTACK_HAUNT_CHANCE, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/obj/item/item_pawn = controller.pawn
	var/list/to_haunt = controller.blackboard[haunt_list_key]
	for(var/mob/living/candidate as anything in to_haunt)
		if(QDELETED(candidate) || to_haunt[candidate] <= 0)
			controller.remove_thing_from_blackboard_key(haunt_list_key, candidate)
			continue
		if(get_dist(candidate, item_pawn) <= CURSED_VIEW_RANGE)
			controller.set_blackboard_key(target_key, candidate)
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/**
 * Throws the haunted item at its current target once per call.
 * Returns SUCCEEDED while more throws remain (drives subplan loop).
 * Returns FAILED when max throws are exhausted — clears the target and decrements haunt list aggro.
 */
/datum/bt_node/ai_behavior/haunted_throw_attack

/datum/bt_node/ai_behavior/haunted_throw_attack/perform(seconds_per_tick, datum/ai_controller/controller, target_key, haunt_list_key, throw_count_key)
	var/obj/item/item_pawn = controller.pawn
	var/mob/throw_target = controller.blackboard[target_key]
	if(QDELETED(throw_target))
		controller.clear_blackboard_key(target_key)
		controller.set_blackboard_key(throw_count_key, 0)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	item_pawn.visible_message(span_warning("[item_pawn] hurls towards [throw_target]!"))
	item_pawn.throw_at(throw_target, rand(4, 5), 9)
	playsound(item_pawn.loc, 'sound/items/haunted/ghostitemattack.ogg', 100, TRUE)
	controller.add_blackboard_key(throw_count_key, 1)
	if(controller.blackboard[throw_count_key] >= HAUNTED_MAX_THROW_ATTEMPTS)
		controller.add_blackboard_key_assoc(haunt_list_key, throw_target, -1)
		controller.clear_blackboard_key(target_key)
		controller.set_blackboard_key(throw_count_key, 0)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED


///Teleport every now and then
/datum/bt_node/ai_behavior/idle_ghost_item
	///Chance for item to teleport somewhere else
	var/teleport_chance = 4
	action_cooldown = 1 SECONDS

/datum/bt_node/ai_behavior/idle_ghost_item/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/obj/item/item_pawn = controller.pawn
	if(ismob(item_pawn.loc)) //Being held. dont teleport
		return AI_BEHAVIOR_INSTANT
	if(SPT_PROB(teleport_chance, seconds_per_tick))
		playsound(item_pawn.loc, 'sound/items/haunted/ghostitemattack.ogg', 100, TRUE)
		#ifndef UNIT_TESTS // hauntium teleports can cause mapping nearstation tests to fail if it teleports outside an area
		do_teleport(item_pawn, get_turf(item_pawn), 4, channel = TELEPORT_CHANNEL_MAGIC)
		#endif
	return AI_BEHAVIOR_INSTANT
