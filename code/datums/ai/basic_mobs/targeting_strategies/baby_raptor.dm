/// Accepts visible, living baby raptors. ONLY USE ON BABY RAPTORS WE ASSUME IT IS ONE
/datum/targeting_strategy/healthy_raptor_baby

/datum/targeting_strategy/healthy_raptor_baby/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/raptor/candidate = target
	if(candidate.stat == DEAD || candidate.growth_stage != RAPTOR_BABY)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
