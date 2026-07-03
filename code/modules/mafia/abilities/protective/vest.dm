///The amount of vests that you get by default to use, lowers as you use them.
#define STARTING_VEST_AMOUNT 2

/**
 * Vest
 *
 * During the night, Vesting will prevent the user from dying.
 */
/datum/mafia_ability/vest
	name = "Жилет"
	ability_action = "защитить себя жилетом"
	use_flags = CAN_USE_ON_SELF
	///Amount of vests that can be used until the power deletes itself.
	var/charges = STARTING_VEST_AMOUNT

/datum/mafia_ability/vest/set_target(datum/mafia_role/new_target)
	. = ..()
	if(!.)
		return FALSE
	if(using_ability)
		RegisterSignal(host_role, COMSIG_MAFIA_ON_KILL, PROC_REF(self_defense))
	else
		UnregisterSignal(host_role, COMSIG_MAFIA_ON_KILL)
	return TRUE

/datum/mafia_ability/vest/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	charges--
	return TRUE

/datum/mafia_ability/vest/proc/self_defense(datum/source, datum/mafia_controller/game, datum/mafia_role/attacker, lynch)
	SIGNAL_HANDLER
	host_role.send_message_to_player(span_greentext("Ваш жилет спас вас!"))
	return MAFIA_PREVENT_KILL

/datum/mafia_ability/vest/proc/end_protection(datum/mafia_controller/game)
	SIGNAL_HANDLER

	UnregisterSignal(host_role, COMSIG_MAFIA_ON_KILL)

/datum/mafia_ability/vest/clean_action_refs(datum/mafia_controller/game)
	if(!charges)
		host_role.role_unique_actions -= src
		qdel(src)
	return ..()

#undef STARTING_VEST_AMOUNT
