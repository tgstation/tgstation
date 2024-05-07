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
	. = ..()
	if(!.)
		return FALSE
	if(new_target.role_flags & ROLE_VULNERABLE)
		host_role.send_message_to_player(span_notice("[new_target] can't be protected."))
		return FALSE

/datum/mafia_ability/heal/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	if(target_role == host_role)
		use_flags &= ~CAN_USE_ON_SELF
	RegisterSignal(target_role, COMSIG_MAFIA_ON_KILL, PROC_REF(prevent_kill))
	return TRUE

/datum/mafia_ability/heal/clean_action_refs(datum/mafia_controller/game)
	if(target_role)
		UnregisterSignal(target_role, COMSIG_MAFIA_ON_KILL)
	return ..()

/datum/mafia_ability/heal/proc/prevent_kill(datum/source, datum/mafia_controller/game, datum/mafia_role/attacker, lynch)
	SIGNAL_HANDLER
	if(host_role == target_role)
		host_role.send_message_to_player(span_warning("You were attacked last night!"))
		return MAFIA_PREVENT_KILL
	host_role.send_message_to_player(span_warning("The person you protected tonight was attacked!"))
	target_role.send_message_to_player(span_greentext("You were attacked last night, but [saving_message]!"))
	return MAFIA_PREVENT_KILL

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
	if(host_role == target_role)
		return FALSE

	if(attacker.kill(game, host_role, FALSE)) //you attack the attacker
		attacker.send_message_to_player(span_userdanger("You have been ambushed by Security!"))
	host_role.kill(game, attacker, FALSE) //the attacker attacks you, they were able to attack the target so they can attack you.
	return FALSE
