/// Accepts visible food that has no kitten (other than the pawn) nearby.
/// Pair with a food typecache source (e.g. oview_typed/from_bb_key/basic_foods).
/datum/targeting_strategy/cat_food

/datum/targeting_strategy/cat_food/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/nearby_kitten = locate(/mob/living/basic/pet/cat/kitten) in oview(2, target)
	if(nearby_kitten && nearby_kitten != living_mob)
		return FALSE
	return can_see(living_mob, target, vision_range)
