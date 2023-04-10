/**
 * Heal
 *
 * During the night, Healing will prevent a player from dying.
 */
/datum/mafia_ability/heal
	name = "Heal"
	ability_action = "heal"

/datum/mafia_ability/heal/set_target(datum/mafia_controller/game, datum/mafia_role/new_target)
	if(new_target.role_flags & ROLE_VULNERABLE)
		to_chat(host_role.body, span_notice("[new_target] can't be protected."))
		return FALSE
	if(target_role)
		UnregisterSignal(target_role, COMSIG_MAFIA_ON_KILL)
		UnregisterSignal(game, COMSIG_MAFIA_NIGHT_POST_KILL_PHASE)
	. = ..()
	if(target_role)
		RegisterSignal(target_role, COMSIG_MAFIA_ON_KILL, PROC_REF(prevent_kill))
		RegisterSignal(game, COMSIG_MAFIA_NIGHT_POST_KILL_PHASE, PROC_REF(end_protection))

/datum/mafia_ability/heal/perform_action(datum/mafia_controller/game)
	if(!validate_action_target(game))
		host_role.add_note("N[game.turn] - [target_role.body.real_name] - Unable to protect")
		return ..()

	host_role.add_note("N[game.turn] - Protected [target_role.body.real_name]")
	return ..()

/datum/mafia_ability/heal/proc/prevent_kill(datum/source, datum/mafia_controller/game, datum/mafia_role/attacker, lynch)
	SIGNAL_HANDLER
	if(!validate_action_target(game, silent = TRUE))
		return FALSE

	to_chat(host_role.body, span_warning("The person you protected tonight was attacked!"))
	to_chat(target_role.body, span_greentext("You were attacked last night, but someone nursed you back to life!"))
	return MAFIA_PREVENT_KILL

/datum/mafia_ability/heal/proc/end_protection(datum/mafia_controller/game)
	SIGNAL_HANDLER

	UnregisterSignal(target_role, COMSIG_MAFIA_ON_KILL)

/**
 * Defend subtype
 * Kills both players when successfully defending.
 */
/datum/mafia_ability/heal/defend
	name = "Defend"
	ability_action = "defend"

/datum/mafia_ability/heal/defend/prevent_kill(datum/source, datum/mafia_controller/game, datum/mafia_role/attacker, lynch)
	if(!validate_action_target(game, silent = TRUE))
		return FALSE

	to_chat(host_role.body, span_userdanger("The person you defended tonight was attacked!"))
	to_chat(target_role.body,span_userdanger("You were attacked last night, but security fought off the attacker!"))
	if(attacker.kill(game, src, FALSE)) //you attack the attacker
		to_chat(attacker.body, span_userdanger("You have been ambushed by Security!"))
	host_role.kill(game, attacker, FALSE) //the attacker attacks you, they were able to attack the target so they can attack you.
	return MAFIA_PREVENT_KILL
