/// Gates on whether the haunted item pawn is currently inside a mob's inventory.
/datum/bt_node/decaorator/item_being_held

/datum/bt_node/decorator/item_being_held/check_condition(datum/ai_controller/controller)
	return ismob(controller.pawn.loc)

/datum/bt_node/decorator/item_being_held/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(COMSIG_ITEM_ENTERED_HANDS, COMSIG_ITEM_DROPPED), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/item_being_held/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(COMSIG_ITEM_ENTERED_HANDS, COMSIG_ITEM_DROPPED))

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

///Find someone to haunt
/datum/bt_node/ai_behavior/pick_haunt_target
	var/target_key
	var/haunt_list_key

/datum/bt_node/ai_behavior/pick_haunt_target/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!prob(HAUNTED_ITEM_ATTACK_HAUNT_CHANCE))
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

/// Haunted variant: decrements haunt list aggro when throws are exhausted.
/// BT args: target_key, throw_count_key, haunt_list_key
/datum/bt_node/ai_behavior/throw_attack/haunted
	var/haunt_list_key
	max_attempts = HAUNTED_MAX_THROW_ATTEMPTS
	/// Cached from perform args so on_throws_exhausted can access haunt_list_key.
	var/active_haunt_list_key

/datum/bt_node/ai_behavior/throw_attack/haunted/perform(seconds_per_tick, datum/ai_controller/controller)
	active_haunt_list_key = haunt_list_key
	return ..()

/datum/bt_node/ai_behavior/throw_attack/haunted/on_throws_exhausted(datum/ai_controller/controller, atom/throw_target, target_key, throw_count_key)
	controller.add_blackboard_key_assoc(active_haunt_list_key, throw_target, -1)
	return ..()


///Teleport every now and then
/datum/bt_node/ai_behavior/idle_ghost_item
	///Chance for item to teleport somewhere else
	var/teleport_chance = 4
	time_between_perform = 1 SECONDS

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
