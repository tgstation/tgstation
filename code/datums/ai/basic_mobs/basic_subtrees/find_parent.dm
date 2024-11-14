/datum/ai_planning_subtree/look_for_adult
	///how far we must be from the mom
	var/minimum_distance = 1

/datum/ai_planning_subtree/look_for_adult/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/target = controller.blackboard[BB_FOUND_MOM]
	var/mob/baby = controller.pawn

	if(QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/find_mom, BB_FIND_MOM_TYPES, BB_IGNORE_MOM_TYPES, BB_FOUND_MOM)
		return

	if(get_dist(target, baby) > minimum_distance)
		controller.queue_behavior(/datum/ai_behavior/travel_towards/stop_on_arrival, BB_FOUND_MOM)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!SPT_PROB(15, seconds_per_tick))
		return

	if(target.stat == DEAD)
		controller.queue_behavior(/datum/ai_behavior/perform_emote, "cries for their parent!")
	else
		controller.queue_behavior(/datum/ai_behavior/perform_emote, "dances around their parent!")

	return SUBTREE_RETURN_FINISH_PLANNING
