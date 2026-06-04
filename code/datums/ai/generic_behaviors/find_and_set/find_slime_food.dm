/datum/bt_node/ai_behavior/find_and_set/in_list/find_slime_food

/// Finds edible targets for slimes based on hunger level and faction
/datum/bt_node/ai_behavior/find_and_set/in_list/find_slime_food/valid_target(datum/ai_controller/controller, mob/living/candidate, search_range)
	var/mob/living/basic/slime/hunter = controller.pawn
	var/static/list/slime_faction
	if(isnull(slime_faction))
		slime_faction = string_list(list(FACTION_SLIME))

	if(FAST_FACTION_CHECK(slime_faction, candidate.get_faction(), hunter.allies, candidate.allies, FALSE))
		return FALSE

	if(!hunter.can_feed_on(candidate, check_adjacent = FALSE))
		return FALSE

	if(candidate == controller.blackboard[BB_CURRENT_TARGET])
		return can_see(hunter, candidate, search_range)

	if(controller.blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_STARVING && controller.blackboard[BB_SLIME_RABID])
		return can_see(hunter, candidate, search_range)

	if(islarva(candidate) || ismonkey(candidate) || ishuman(candidate) || isalienadult(candidate))
		return can_see(hunter, candidate, search_range)

	return FALSE
