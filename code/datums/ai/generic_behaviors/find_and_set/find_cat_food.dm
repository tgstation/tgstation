/datum/bt_node/ai_behavior/find_and_set/in_list/find_cat_food

/// Finds food items that are not already near a kitten
/datum/bt_node/ai_behavior/find_and_set/in_list/find_cat_food/valid_target(datum/ai_controller/controller, atom/candidate, search_range)
	var/mob/living/nearby_kitten = locate(/mob/living/basic/pet/cat/kitten) in oview(2, candidate)
	if(nearby_kitten && nearby_kitten != controller.pawn)
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
