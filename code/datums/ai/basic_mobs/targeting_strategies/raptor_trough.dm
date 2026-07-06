/// Looks for filled troughs raptors can eat from
/datum/targeting_strategy/raptor_trough

/datum/targeting_strategy/raptor_trough/is_valid_target(mob/living/living_mob, obj/structure/ore_container/food_trough/raptor_trough/trough, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!can_see(living_mob, trough, vision_range))
		return FALSE
	return !!(locate(/obj/item/stack/ore) in trough.contents)
