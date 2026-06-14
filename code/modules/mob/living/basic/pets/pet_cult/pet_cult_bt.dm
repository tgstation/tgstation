
/**
 * Finds a nearby cultist that isn't already befriended and sets BB_FRIENDLY_CULTIST.
 * Uses a cooldown via time_between_perform.
 */
/datum/bt_node/ai_behavior/find_friendly_cultist
	time_between_perform = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/find_friendly_cultist/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	for(var/mob/living/carbon/possible_cultist in oview(9, living_pawn))
		if(!IS_CULTIST(possible_cultist) || living_pawn.has_ally(possible_cultist))
			continue
		controller.set_blackboard_key(BB_FRIENDLY_CULTIST, possible_cultist)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED


/**
 * Checks whether the cult has enough souls to revive and finds a raise_dead rune
 * with a dead cultist on it. Sets BB_OCCUPIED_RUNE.
 */
/datum/bt_node/ai_behavior/find_occupied_rune
	time_between_perform = 3 SECONDS

/datum/bt_node/ai_behavior/find_occupied_rune/perform(seconds_per_tick, datum/ai_controller/controller)
	if((LAZYLEN(GLOB.sacrificed) - SOULS_TO_REVIVE - GLOB.sacrifices_used) < 0)
		controller.clear_blackboard_key(BB_OCCUPIED_RUNE)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/team/cult/cult_team = controller.blackboard[BB_CULT_TEAM]
	if(isnull(cult_team))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	for(var/obj/effect/rune/raise_dead/target_rune in oview(9, controller.pawn))
		controller.set_blackboard_key(BB_NEARBY_RUNE, target_rune)
		var/mob/living/occupant = locate(/mob/living/carbon/human) in get_turf(target_rune)
		if(isnull(occupant) || occupant.stat != DEAD || !IS_CULTIST(occupant))
			continue
		controller.set_blackboard_key(BB_OCCUPIED_RUNE, target_rune)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED


/**
 * Activates a raise_dead rune at BB_OCCUPIED_RUNE, reviving the dead cultist on it.
 * Must be adjacent. Clears BB_OCCUPIED_RUNE on finish.
 */
/datum/bt_node/ai_behavior/activate_rune
	time_between_perform = 3 SECONDS

/datum/bt_node/ai_behavior/activate_rune/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[BB_OCCUPIED_RUNE]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!controller.pawn.Adjacent(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/datum/team/cult/cult_team = controller.blackboard[BB_CULT_TEAM]
	var/mob/living/revive_mob = locate(/mob/living) in get_turf(target)
	if(isnull(revive_mob) || revive_mob.stat != DEAD || !(revive_mob.mind in cult_team.members))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.ai_interact(target = target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/activate_rune/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_OCCUPIED_RUNE)


/**
 * Finds a dead cultist that can be dragged to a rune for revival. Sets BB_DEAD_CULTIST.
 * Skips cultists that are already on a raise_dead rune or being pulled by someone else.
 */
/datum/bt_node/ai_behavior/find_dead_cultist

/datum/bt_node/ai_behavior/find_dead_cultist/perform(seconds_per_tick, datum/ai_controller/controller)
	if((LAZYLEN(GLOB.sacrificed) - SOULS_TO_REVIVE - GLOB.sacrifices_used) < 0)
		controller.clear_blackboard_key(BB_DEAD_CULTIST)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/our_pawn = controller.pawn
	if(!isnull(our_pawn.pulling))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/team/cult/cult_team = controller.blackboard[BB_CULT_TEAM]
	if(isnull(cult_team))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	for(var/mob/living/carbon/human/target in oview(9, our_pawn))
		if(target.stat != DEAD || !IS_CULTIST(target))
			continue
		if(target.buckled || target.move_resist > our_pawn.move_force || target.pulledby)
			continue
		if(locate(/obj/effect/rune/raise_dead) in target.loc)
			continue
		controller.set_blackboard_key(BB_DEAD_CULTIST, target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
