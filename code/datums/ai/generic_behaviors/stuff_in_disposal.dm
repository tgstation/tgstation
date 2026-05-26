/// Grabs a downed target mob and stuffs them into a nearby disposal unit.
/datum/bt_node/ai_behavior/stuff_in_disposal
	action_cooldown = 2 SECONDS

/datum/bt_node/ai_behavior/stuff_in_disposal/perform(seconds_per_tick, datum/ai_controller/controller, attack_target_key, disposal_target_key)
	var/mob/living/target = controller.blackboard[attack_target_key]
	var/obj/machinery/disposal/disposal = controller.blackboard[disposal_target_key]
	var/mob/living/living_pawn = controller.pawn
	if(QDELETED(target) || QDELETED(disposal))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!living_pawn.Adjacent(disposal))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(disposal.stuff_mob_in(target, living_pawn))
		disposal.flush()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/stuff_in_disposal/finish_action(datum/ai_controller/controller, succeeded, attack_target_key, disposal_target_key)
	. = ..()
	controller.clear_blackboard_key(attack_target_key)
	controller.clear_blackboard_key(disposal_target_key)
