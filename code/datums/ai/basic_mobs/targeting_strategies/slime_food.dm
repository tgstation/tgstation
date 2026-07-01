/// Accepts edible targets for slimes based on hunger level, faction, and species.
/// Requires the controller (reads slime hunger/rabid/current-target blackboard keys).
/datum/targeting_strategy/slime_food

/datum/targeting_strategy/slime_food/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!controller)
		return FALSE
	var/mob/living/basic/slime/hunter = living_mob
	var/mob/living/candidate = target
	if(!isliving(candidate))
		return FALSE

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
