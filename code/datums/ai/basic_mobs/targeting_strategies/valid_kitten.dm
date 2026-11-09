/// Accepts living kittens that don't already have huntable food sitting next to them.
/// Reads the prey typecache from BB_HUNTABLE_PREY on the searching controller.
/datum/targeting_strategy/valid_kitten

/datum/targeting_strategy/valid_kitten/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/kitten = target
	if(!isliving(kitten) || kitten.stat == DEAD)
		return FALSE
	var/list/prey = controller?.blackboard[BB_HUNTABLE_PREY]
	if(prey && length(typecache_filter_list(oview(2, kitten), prey)))
		return FALSE
	return TRUE
