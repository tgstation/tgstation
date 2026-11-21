/// Accepts trees that are not stumps and are visible to the pawn.
/datum/targetingUI_strategy/non_stump_tree

/datum/targeting_strategy/non_stump_tree/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(istype(target, /obj/structure/flora/tree/stump))
		return FALSE
	return can_see(living_mob, target, vision_range)
