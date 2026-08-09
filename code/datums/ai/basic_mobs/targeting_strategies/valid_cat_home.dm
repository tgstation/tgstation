/// Accepts cat houses that don't already have a resident cat.
/datum/targeting_strategy/valid_cat_home

/datum/targeting_strategy/valid_cat_home/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/structure/cat_house/home = target
	if(!istype(home) || home.resident_cat)
		return FALSE
	return TRUE
