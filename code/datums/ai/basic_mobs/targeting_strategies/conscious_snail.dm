/// Accepts visible, conscious carbon mobs of the snail species.
/datum/targeting_strategy/conscious_snail

/datum/targeting_strategy/conscious_snail/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/candidate = target
	if(!istype(candidate) || candidate.stat != CONSCIOUS)
		return FALSE
	if(!is_species(candidate, /datum/species/snail))
		return FALSE
	return can_see(living_mob, candidate, vision_range)
