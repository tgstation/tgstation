/// Accepts items that are edible or consumable from a bowl, or drinks when allowed by the controller blackboard.
/datum/targeting_strategy/food_or_drink

/datum/targeting_strategy/food_or_drink/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/find_drinks = controller?.blackboard[BB_IGNORE_DRINKS]
	return _is_food(target) || (find_drinks && _is_drink(target))

/datum/targeting_strategy/food_or_drink/proc/_is_food(obj/item/thing)
	if(IS_EDIBLE(thing))
		return TRUE
	if(istype(thing, /obj/item/reagent_containers/cup/bowl))
		return thing.reagents.total_volume > 0
	return FALSE

/datum/targeting_strategy/food_or_drink/proc/_is_drink(obj/item/thing)
	if(istype(thing, /obj/item/reagent_containers/cup/glass))
		return thing.reagents.total_volume > 0
	return FALSE

/// Like food_or_drink but always accepts drinks regardless of BB_IGNORE_DRINKS.
/datum/targeting_strategy/food_or_drink/include_drinks

/datum/targeting_strategy/food_or_drink/include_drinks/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	return _is_food(target) || _is_drink(target)
