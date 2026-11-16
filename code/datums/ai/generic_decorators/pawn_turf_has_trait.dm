/// Gates child on the pawn's current turf having a given trait. Use invert = TRUE to gate on the trait being absent.
/datum/bt_node/decorator/pawn_turf_has_trait
	var/trait = null

/datum/bt_node/decorator/pawn_turf_has_trait/check_condition(datum/ai_controller/controller)
	var/turf/my_turf_in_the_middle_of_my_turf = get_turf(controller.pawn)
	return HAS_TRAIT(my_turf_in_the_middle_of_my_turf, trait)
