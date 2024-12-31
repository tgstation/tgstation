#define DEFAULT_TIME_SWIMMER 30 SECONDS

///subtree to go and swim!
/datum/ai_planning_subtree/go_for_swim

/datum/ai_planning_subtree/go_for_swim/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_SWIM_ALTERNATE_TURF))
		controller.queue_behavior(/datum/ai_behavior/travel_towards/swimming, BB_SWIM_ALTERNATE_TURF)

	if(isnull(controller.blackboard[BB_KEY_SWIM_TIME]))
		controller.set_blackboard_key(BB_KEY_SWIM_TIME, DEFAULT_TIME_SWIMMER)

	var/mob/living/living_pawn = controller.pawn
	var/turf/our_turf = get_turf(living_pawn)

	// we have been taken out of water!
	controller.set_blackboard_key(BB_CURRENTLY_SWIMMING, iswaterturf(our_turf))

	if(controller.blackboard[BB_KEY_SWIM_TIME] < world.time)
		controller.queue_behavior(/datum/ai_behavior/find_and_set/swim_alternate, BB_SWIM_ALTERNATE_TURF, /turf/open)
		return

	// have some fun in the water
	if(controller.blackboard[BB_CURRENTLY_SWIMMING] && SPT_PROB(5, seconds_per_tick))
		controller.queue_behavior(/datum/ai_behavior/perform_emote, "splashes water all around!")


///find land if its time to get out of water, otherwise find water
/datum/ai_behavior/find_and_set/swim_alternate

/datum/ai_behavior/find_and_set/swim_alternate/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn
	if(QDELETED(living_pawn))
		return null
	var/look_for_land = controller.blackboard[BB_CURRENTLY_SWIMMING]
	var/list/possible_turfs = list()
	for(var/turf/possible_turf in oview(search_range, living_pawn))
		if(isclosedturf(possible_turf) || is_space_or_openspace(possible_turf))
			continue
		if(possible_turf.is_blocked_turf())
			continue
		if(look_for_land == iswaterturf(possible_turf))
			continue
		possible_turfs += possible_turf

	if(!length(possible_turfs))
		return null

	return(pick(possible_turfs))

/datum/ai_behavior/travel_towards/swimming
	clear_target = TRUE

/datum/ai_behavior/travel_towards/swimming/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	var/time_to_add = controller.blackboard[BB_KEY_SWIMMER_COOLDOWN] ? controller.blackboard[BB_KEY_SWIMMER_COOLDOWN] : DEFAULT_TIME_SWIMMER
	controller.set_blackboard_key(BB_KEY_SWIM_TIME, world.time + time_to_add )

#undef DEFAULT_TIME_SWIMMER
