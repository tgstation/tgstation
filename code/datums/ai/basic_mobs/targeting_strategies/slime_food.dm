/// Accepts edible targets for slimes based on hunger level, faction, and species.
/// Requires the controller (reads slime hunger/rabid/current-target blackboard keys).
/datum/targeting_strategy/slime_food

/datum/targeting_strategy/slime_food/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!controller)
		return FALSE
	// Anything that attacked us is a valid target even if we can't eat it.
	if(target in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		var/datum/targeting_strategy/retaliate_strategy = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/not_friends)
		return retaliate_strategy.is_valid_target(living_mob, target, vision_range)

	var/mob/living/basic/slime/hunter = living_mob
	var/mob/living/candidate = target
	if(!isliving(candidate))
		return FALSE

	// We're already latched onto them and feeding; don't invalidate our own meal.
	if(hunter.buckled == candidate)
		return TRUE

	var/static/list/slime_faction
	if(isnull(slime_faction))
		slime_faction = string_list(list(FACTION_SLIME))

	if(FAST_FACTION_CHECK(slime_faction, candidate.get_faction(), hunter.allies, candidate.allies, FALSE))
		return FALSE

	if(!hunter.can_feed_on(candidate, check_adjacent = FALSE))
		return FALSE

	if(candidate == controller.blackboard[BB_CURRENT_TARGET])
		return can_see(hunter, candidate, vision_range)

	if(controller.blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_STARVING && controller.blackboard[BB_SLIME_RABID])
		return can_see(hunter, candidate, vision_range)

	if(islarva(candidate) || ismonkey(candidate) || ishuman(candidate) || isalienadult(candidate))
		return can_see(hunter, candidate, vision_range)

	return FALSE
