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
		return FALSE

	target_role.role_flags |= ROLE_ROLEBLOCKED
	return TRUE

/datum/mafia_ability/roleblock/clean_action_refs(datum/mafia_controller/game)
	if(target_role)
		target_role.role_flags &= ~ROLE_ROLEBLOCKED
	return ..()
