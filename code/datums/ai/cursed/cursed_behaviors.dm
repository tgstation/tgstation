/datum/ai_behavior/item_move_close_and_attack/ghostly/cursed

/datum/ai_behavior/item_move_close_and_attack/ghostly/cursed/reset_blackboard(datum/ai_controller/controller, succeeded, target_key, throw_count_key)
	var/atom/throw_target = controller.blackboard[target_key]
	//dropping our target from the blackboard if they are no longer a valid target after the attack behavior
	if(get_dist(throw_target, controller.pawn) > CURSED_VIEW_RANGE)
		controller.clear_blackboard_key(target_key)
