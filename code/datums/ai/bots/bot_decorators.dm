/// Gates child on pawn being emagged. Use invert = TRUE for the opposite. Checked each tick.
/datum/bt_node/decorator/bot_is_emagged

/datum/bt_node/decorator/bot_is_emagged/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	return !!(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED)

/// Gates child on pawn having the specified bot_mode_flag. Observes COMSIG_BOT_MODE_FLAGS_SET.
/datum/bt_node/decorator/bot_mode_flag
	var/flag

/datum/bt_node/decorator/bot_mode_flag/get_pawn_observe_signals()
	return list(COMSIG_BOT_MODE_FLAGS_SET)

/datum/bt_node/decorator/bot_mode_flag/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	return !!(bot_pawn.bot_mode_flags & flag)

/datum/bt_node/decorator/bot_mode_flag/evaluate_for_observer(datum/ai_controller/controller)
	return check_condition(controller)

/// Gates child when a cooldown blackboard key is expired (null or <= world.time). Checked each tick.
/datum/bt_node/decorator/bb_key_cooldown
	var/cooldown_key

/datum/bt_node/decorator/bb_key_cooldown/check_condition(datum/ai_controller/controller)
	var/cooldown_time = controller.blackboard[cooldown_key]
	return isnull(cooldown_time) || cooldown_time <= world.time

/// Gates child when pawn has the specified medical mode flag. Use invert = TRUE for the opposite. Checked each tick.
/datum/bt_node/decorator/bot_medical_flag
	var/flag

/datum/bt_node/decorator/bot_medical_flag/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	return !!(bot_pawn.medical_mode_flags & flag)

/**
 * Validates the secbot's current target. Clears BB_BASIC_MOB_CURRENT_TARGET and returns BT_FAILURE
 * if the target is handcuffed, deleted, or paralyzed without handcuff mode. Otherwise ticks child.
 */
/datum/bt_node/decorator/secbot_target_valid

/datum/bt_node/decorator/secbot_target_valid/tick(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/carbon/my_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(my_target) || !istype(my_target) || my_target.handcuffed)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_DECISIONMAKING, "[controller.pawn] secbot_target_valid: clearing target [my_target] (deleted=[QDELETED(my_target)], handcuffed=[my_target?.handcuffed])")
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return BT_FAILURE
	var/mob/living/basic/bot/secbot/my_bot = controller.pawn
	if(my_target.IsParalyzed() && !(my_bot.security_mode_flags & SECBOT_HANDCUFF_TARGET))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_DECISIONMAKING, "[controller.pawn] secbot_target_valid: clearing [my_target] (paralyzed, no handcuff mode)")
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return BT_FAILURE
	return child.tick(controller, seconds_per_tick)
