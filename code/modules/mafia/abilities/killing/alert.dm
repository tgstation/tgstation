/**
 * Alert
 *
 * During the night, goes on watch, killing all players who visit.
 */
/datum/mafia_ability/attack_visitors
	name = "Alert"
	ability_action = "will kill all visitors"

/datum/mafia_ability/attack_visitors/set_target(datum/mafia_controller/game, datum/mafia_role/new_target)
	using_ability = !using_ability
	if(using_ability)
		RegisterSignal(host_role, COMSIG_MAFIA_ON_VISIT, PROC_REF(self_defense))
		to_chat(host_role.body, span_danger("Any and all visitors are going to eat buckshot tonight."))
	else
		UnregisterSignal(host_role, COMSIG_MAFIA_ON_VISIT)
		to_chat(host_role.body, span_warning("You will now kill visitors."))

/datum/mafia_ability/attack_visitors/perform_action(datum/mafia_controller/game)
	. = ..()
	if(!validate_action_target(game))
		host_role.add_note("N[game.turn] - [target_role.body.real_name] - Unable to go on alert.")
		return ..()
	host_role.role_unique_actions -= src
	qdel(src)

/datum/mafia_ability/attack_visitors/proc/self_defense(datum/source, datum/mafia_controller/game, datum/mafia_role/attacker, lynch)
	SIGNAL_HANDLER
	if(!validate_action_target(game, silent = TRUE))
		return FALSE

	to_chat(host_role.body, span_userdanger("You have shot a visitor!"))
	to_chat(attacker, span_userdanger("You have visited the warden!"))
	attacker.kill(game, src, lynch = FALSE)
	return MAFIA_VISIT_INTERRUPTED
