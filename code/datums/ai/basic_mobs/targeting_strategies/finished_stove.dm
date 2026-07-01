/// Accepts closed ovens whose tray holds finished (no longer bakeable) goods.
/datum/targeting_strategy/finished_stove

/datum/targeting_strategy/finished_stove/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/machinery/oven/range/candidate = target
	if(!istype(candidate) || candidate.open || !length(candidate.used_tray?.contents))
		return FALSE
	for(var/atom/baking as anything in candidate.used_tray)
		if(HAS_TRAIT(baking, TRAIT_BAKEABLE))
			return FALSE
	return TRUE
