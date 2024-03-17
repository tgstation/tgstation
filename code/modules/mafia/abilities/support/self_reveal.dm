/**
 * Self reveal
 *
 * During the day, reveals your role to everyone and gives you a voting power boost,
 * however it will additionally make you unable to be protected.
 */
/datum/mafia_ability/self_reveal
	name = "Reveal"
	ability_action = "reveal your role"
	action_priority = null
	valid_use_period = MAFIA_PHASE_DAY
	use_flags = CAN_USE_ON_SELF

/datum/mafia_ability/self_reveal/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE
	host_role.reveal_role(game, TRUE)
	host_role.role_flags |= ROLE_VULNERABLE
	host_role.vote_power *= 3
	host_role.role_unique_actions -= src
	qdel(src)
