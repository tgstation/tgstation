/// Accepts carbon cultists that the pawn has not already befriended.
/datum/targeting_strategy/befriendable_cultist

/datum/targeting_strategy/befriendable_cultist/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/carbon_target = target
	if(!IS_CULTIST(carbon_target))
		return FALSE
	return !living_mob.has_ally(carbon_target)
