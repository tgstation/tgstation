/// Pick nearest instead of any, we should probably move this into a datum of some kind in the future?
/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/nearest

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/nearest/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/turf/our_position = get_turf(controller.pawn)
	return get_closest_atom(/atom/, filtered_targets, our_position)
