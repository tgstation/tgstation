/// Accepts conscious humans who have at least one leg and are visible to the pawn.
/datum/targeting_strategy/legged_conscious_human

/datum/targeting_strategy/legged_conscious_human/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/mob/living/carbon/human/candidate = target
	if(!istype(candidate) || candidate.stat != CONSCIOUS)
		return FALSE
	if(isnull(candidate.get_bodypart(BODY_ZONE_R_LEG)) && isnull(candidate.get_bodypart(BODY_ZONE_L_LEG)))
		return FALSE
	return can_see(living_mob, candidate, vision_range)
