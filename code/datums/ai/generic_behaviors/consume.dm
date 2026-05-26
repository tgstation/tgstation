/// Uses the pawn's held food/drink item on themselves until consumed.
/datum/bt_node/ai_behavior/consume
	action_cooldown = 2 SECONDS

/datum/bt_node/ai_behavior/consume/perform(seconds_per_tick, datum/ai_controller/controller, target_key, hunger_timer_key)
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target) || !living_pawn.is_holding(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.ai_interact(target = living_pawn, combat_mode = FALSE)

	return AI_BEHAVIOR_DELAY | (is_content(living_pawn, target) ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/datum/bt_node/ai_behavior/consume/finish_action(datum/ai_controller/controller, succeeded, target_key, hunger_timer_key)
	. = ..()
	if(!succeeded)
		return
	controller.set_blackboard_key(hunger_timer_key, world.time + rand(12 SECONDS, 60 SECONDS))

	var/mob/living/living_pawn = controller.pawn
	var/obj/item/target = controller.blackboard[target_key]
	if(!QDELETED(target) && !DOING_INTERACTION_WITH_TARGET(living_pawn, target))
		controller.clear_blackboard_key(target_key)
		living_pawn.dropItemToGround(target) // drops empty drink glasses
	for(var/obj/item/trash/trash in living_pawn.held_items)
		living_pawn.dropItemToGround(trash) // drops spawned trash items

/// Check if the target is fully consumed, or being actively consumed, or if we're just bored of eating it
/datum/bt_node/ai_behavior/consume/proc/is_content(mob/living/living_pawm, obj/item/target)
	if(QDELETED(target))
		return TRUE
	if(DOING_INTERACTION_WITH_TARGET(living_pawm, target))
		return TRUE
	if(target.reagents?.total_volume <= 0)
		return TRUE
	// Even if we don't finish it all we can randomly decide to be done
	return prob(10)

