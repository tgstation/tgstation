/// Accepts visible, living baby raptors.
/datum/targeting_strategy/baby_raptor

/datum/targeting_strategy/baby_raptor/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/raptor/candidate = target
	if(!istype(candidate) || candidate.stat == DEAD || candidate.growth_stage != RAPTOR_BABY)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
