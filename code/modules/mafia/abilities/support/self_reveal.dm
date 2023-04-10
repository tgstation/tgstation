/**
 * Roleblock
 *
 * During the night, prevents a player from using their role abilities.
 */
/datum/mafia_ability/self_reveal
	name = "Reveal"
	ability_action = "reveal your role"
	action_priority = null
	valid_use_period = MAFIA_PHASE_DAY

/datum/mafia_ability/self_reveal/perform_action(datum/mafia_controller/game)
	. = ..()
	if(!validate_action_target(game))
		return ..()
	host_role.reveal_role(game, TRUE)
	host_role.role_flags |= ROLE_VULNERABLE
	host_role.vote_power *= 3
	host_role.role_unique_actions -= src
	qdel(src)
