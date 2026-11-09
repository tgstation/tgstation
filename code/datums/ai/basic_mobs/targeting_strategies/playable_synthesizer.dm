/// Accepts a visible piano synthesizer sitting on the floor (not a wearable headphones variant).
/datum/targeting_strategy/playable_synthesizer

/datum/targeting_strategy/playable_synthesizer/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(target.type != /obj/item/instrument/piano_synth)
		return FALSE
	if(!isturf(target.loc))
		return FALSE
	return can_see(living_mob, target, vision_range)
