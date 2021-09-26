
/datum/ai_behavior/find_and_set/cursed
	//optional, don't use if you're changing search_tactic()
	locate_path = /mob/living/carbon
	bb_key_to_set = BB_CURSE_TARGET

/datum/ai_behavior/item_move_close_and_attack/cursed
	attack_sound = 'sound/items/haunted/ghostitemattack.ogg'
	max_attempts = 4

/datum/ai_behavior/item_move_close_and_attack/cursed/reset_blackboard(datum/ai_controller/controller, succeeded, target_key, throw_count_key)
	var/atom/throw_target = controller.blackboard[target_key]
	//dropping our target from the blackboard if they are no longer a valid target after the attack behavior
	if(get_dist(throw_target, controller.pawn) > CURSED_VIEW_RANGE)
		controller.blackboard[target_key] = null
