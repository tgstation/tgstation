/// Gates child on pawn being emagged. Use invert = TRUE for the opposite. Checked each tick.
/datum/bt_node/decorator/bot_is_emagged

/datum/bt_node/decorator/bot_is_emagged/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	return !!(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED)

/// Gates child on pawn having the specified bot_mode_flag. Observes COMSIG_BOT_MODE_FLAGS_SET.
/datum/bt_node/decorator/bot_mode_flag
	var/flag

/datum/bt_node/decorator/bot_mode_flag/register_observe_signals(atom/pawn)
	RegisterSignal(pawn, COMSIG_BOT_MODE_FLAGS_SET, PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/bot_mode_flag/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, COMSIG_BOT_MODE_FLAGS_SET)

/datum/bt_node/decorator/bot_mode_flag/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	return !!(bot_pawn.bot_mode_flags & flag)

/// Gates child on the pawn's current mode matching `mode` (e.g. BOT_DELIVER). Use invert = TRUE for the opposite. Checked each tick.
/datum/bt_node/decorator/bot_mode
	var/mode

/datum/bt_node/decorator/bot_mode/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	return bot_pawn.mode == mode

/// Gates child on the pawn's `wire` being cut. Use invert = TRUE to gate on the wire being intact. Checked each tick.
/datum/bt_node/decorator/bot_wire_cut
	var/wire

/datum/bt_node/decorator/bot_wire_cut/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	return !!(bot_pawn.wires?.is_cut(wire))

/// Gates child when pawn has the specified medical mode flag. Use invert = TRUE for the opposite. Checked each tick.
/datum/bt_node/decorator/bot_medical_flag
	var/flag

/datum/bt_node/decorator/bot_medical_flag/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	return !!(bot_pawn.medical_mode_flags & flag)
