/**
 * Changeling kill
 *
 * During the night, changelings vote for who to kill.
 */
/datum/mafia_ability/changeling_kill
	name = "Kill Vote"
	ability_action = "attempt to absorb"
	action_priority = COMSIG_MAFIA_NIGHT_KILL_PHASE

/datum/mafia_ability/changeling_kill/set_target(datum/mafia_controller/game, datum/mafia_role/new_target)
	if(!validate_action_target(game))
		return ..()
	game.vote_for(host_role, new_target, "Mafia", MAFIA_TEAM_MAFIA)
	return ..()
