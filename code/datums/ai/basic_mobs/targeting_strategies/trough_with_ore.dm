/// Accepts containers (e.g. troughs) that hold at least one ore item.
/datum/targeting_strategy/trough_with_ore

/datum/targeting_strategy/trough_with_ore/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!ismovable(target))
		return FALSE
	return !!(locate(/obj/item/stack/ore) in target.contents)
