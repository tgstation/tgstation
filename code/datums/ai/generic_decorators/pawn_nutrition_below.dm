/// Passes if the pawn's nutrition is below the given threshold.
/datum/bt_node/decorator/pawn_nutrition_below
	/// Nutrition threshold to check against.
	var/nutrition_threshold = NUTRITION_LEVEL_HUNGRY

/datum/bt_node/decorator/pawn_nutrition_below/check_condition(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(!isliving(pawn))
		return FALSE
	return pawn.nutrition < nutrition_threshold
