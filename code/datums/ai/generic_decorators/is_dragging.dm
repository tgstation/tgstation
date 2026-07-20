/// Gates child on pawn currently pulling something. Use invert = TRUE for the opposite. Checked each tick.
/datum/bt_node/decorator/is_dragging

/datum/bt_node/decorator/is_dragging/check_condition(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	return !!living_pawn.pulling
