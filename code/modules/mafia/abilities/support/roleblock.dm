/**
 * Roleblock
 *
 * During the night, prevents a player from using their role abilities.
 * This is done before anything else.
 */
/datum/mafia_ability/roleblock
	name = "Advise"
	ability_action = "give legal counsel to"
	action_priority = COMSIG_MAFIA_NIGHT_PRE_ACTION_PHASE

/datum/mafia_ability/roleblock/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return .

	target_role.role_flags |= ROLE_ROLEBLOCKED
	RegisterSignal(game, COMSIG_MAFIA_NIGHT_POST_KILL_PHASE, PROC_REF(end_block))

/**
 * Ends the roleblock on the player.
 */
/datum/mafia_ability/roleblock/proc/end_block(datum/mafia_controller/game)
	target_role.role_flags &= ~ROLE_ROLEBLOCKED
	UnregisterSignal(game, COMSIG_MAFIA_NIGHT_POST_KILL_PHASE)
