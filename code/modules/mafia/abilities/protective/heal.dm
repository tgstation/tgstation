/**
 * Heal
 *
 * During the night, Healing will prevent a player from dying.
 * Can be used to protect yourself, but only once.
 */
/datum/mafia_ability/heal
	name = "Heal"
	ability_action = "heal"
	action_priority = COMSIG_MAFIA_NIGHT_ACTION_PHASE
	use_flags = CAN_USE_ON_OTHERS | CAN_USE_ON_SELF

	///The message sent when you've successfully saved someone.
	var/saving_message = "someone nursed you back to health"

/datum/mafia_ability/heal/set_target(datum/mafia_controller/game, datum/mafia_role/new_target)
	if(new_target.role_flags & ROLE_VULNERABLE)
		to_chat(host_role.body, span_notice("[new_target] can't be protected."))
		return FALSE
	return ..()

/datum/mafia_ability/heal/perform_action(datum/mafia_controller/game, datum/mafia_role/day_target)
	if(!using_ability)
		return
	if(!validate_action_target(game))
		host_role.add_note("N[game.turn] - [target_role.body.real_name] - Unable to protect")
		return ..()

	if(target_role == host_role)
		use_flags &= ~CAN_USE_ON_SELF
	host_role.add_note("N[game.turn] - Protected [target_role.body.real_name]")
	RegisterSignal(target_role, COMSIG_MAFIA_ON_KILL, PROC_REF(prevent_kill))
	RegisterSignal(game, COMSIG_MAFIA_NIGHT_POST_KILL_PHASE, PROC_REF(end_protection))
	return ..()

/datum/mafia_ability/heal/proc/prevent_kill(datum/source, datum/mafia_controller/game, datum/mafia_role/attacker, lynch)
	SIGNAL_HANDLER
	to_chat(host_role.body, span_warning("The person you protected tonight was attacked!"))
	to_chat(target_role.body, span_greentext("You were attacked last night, but [saving_message]!"))
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
	saving_message = "security fought off the attacker"

/datum/mafia_ability/heal/defend/prevent_kill(datum/source, datum/mafia_controller/game, datum/mafia_role/attacker, lynch)
	. = ..()
	if(attacker.kill(game, src, FALSE)) //you attack the attacker
		to_chat(attacker.body, span_userdanger("You have been ambushed by Security!"))
	host_role.kill(game, attacker, FALSE) //the attacker attacks you, they were able to attack the target so they can attack you.
	return .
