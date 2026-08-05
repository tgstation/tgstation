/// Accepts beehives that contain at least one honeycomb and are visible to the pawn.
/datum/targeting_strategy/stocked_beehive

/datum/targeting_strategy/stocked_beehive/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/structure/beebox/candidate = target
	if(!istype(candidate) || !length(candidate.honeycombs))
		return FALSE
	return can_see(living_mob, candidate, vision_range)
