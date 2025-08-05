/**
 * Alert
 *
 * During the night, goes on watch, killing all players who visit.
 */
/datum/mafia_ability/attack_visitors
	name = "Alert"
	ability_action = "send any visitors home with buckshot tonight"
	use_flags = CAN_USE_ON_SELF

/datum/mafia_ability/attack_visitors/set_target(datum/mafia_role/new_target)
	. = ..()
	if(!.)
		return FALSE
	if(using_ability)
		RegisterSignal(host_role, COMSIG_MAFIA_ON_VISIT, PROC_REF(self_defense))
	else
		UnregisterSignal(host_role, COMSIG_MAFIA_ON_VISIT)
	return TRUE

/datum/mafia_ability/attack_visitors/proc/self_defense(datum/source, datum/mafia_controller/game, datum/mafia_role/attacker)
	SIGNAL_HANDLER
	if(attacker == host_role)
		return
	host_role.send_message_to_player(span_userdanger("You have shot a visitor!"))
	attacker.send_message_to_player(span_userdanger("You have visited the warden!"))
	attacker.kill(game, host_role, lynch = FALSE)
	return MAFIA_VISIT_INTERRUPTED

/datum/mafia_ability/attack_visitors/clean_action_refs(datum/mafia_controller/game)
	if(using_ability)
		host_role.role_unique_actions -= src
		qdel(src)
	return ..()
