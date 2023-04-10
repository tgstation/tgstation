/**
 * Vest
 *
 * During the night, Vesting will prevent the user from dying.
 */
/datum/mafia_ability/vest
	name = "Vest"
	ability_action = "vest"
	///Amount of vests that can be used until the power deletes itself.
	var/charges = 2

/datum/mafia_ability/vest/set_target(datum/mafia_controller/game, datum/mafia_role/new_target)
	using_ability = !using_ability
	if(using_ability)
		RegisterSignal(host_role, COMSIG_MAFIA_ON_KILL, PROC_REF(self_defense))
		to_chat(host_role.body, span_danger("You have decided to use a vest tonight."))
	else
		UnregisterSignal(host_role, COMSIG_MAFIA_ON_KILL)
		to_chat(host_role.body, span_warning("You are no longer using a vest tonight."))

/datum/mafia_ability/vest/perform_action(datum/mafia_controller/game)
	if(!validate_action_target(game))
		host_role.add_note("N[game.turn] - Unable to vest")
		return ..()

	host_role.add_note("N[game.turn] - Vested")
	charges--
	if(!charges)
		host_role.role_unique_actions -= src
		qdel(src)
	return ..()

/datum/mafia_ability/vest/proc/self_defense(datum/source, datum/mafia_controller/game, datum/mafia_role/attacker, lynch)
	SIGNAL_HANDLER
	if(!validate_action_target(game, silent = TRUE))
		return FALSE

	to_chat(host_role.body, span_warning("Your vest saved you!"))
	return MAFIA_PREVENT_KILL

/datum/mafia_ability/vest/proc/end_protection(datum/mafia_controller/game)
	SIGNAL_HANDLER

	UnregisterSignal(host_role, COMSIG_MAFIA_ON_KILL)
