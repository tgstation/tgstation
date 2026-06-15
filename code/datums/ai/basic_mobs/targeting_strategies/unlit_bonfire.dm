/// Accepts bonfires that are not currently burning and are visible to the pawn.
/datum/targeting_strategy/unlit_bonfire

/datum/targeting_strategy/unlit_bonfire/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/obj/structure/bonfire/candidate = target
	if(!istype(candidate) || candidate.burning)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
