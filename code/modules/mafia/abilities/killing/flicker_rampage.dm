/**
 * Flicker/Rampage
 *
 * During the night, turns the lights off in a player's house.
 * If they visit someone with the lights off again, they will kill all players they previously visited.
 */
/datum/mafia_ability/flicker_rampage
	name = "Flicker/Rampage"
	ability_action = "attempt to attack or darken"
	action_priority = COMSIG_MAFIA_NIGHT_KILL_PHASE

	///List of all players in the dark, which we can rampage.
	var/list/datum/mafia_role/darkened_players = list()

/datum/mafia_ability/flicker_rampage/New(datum/mafia_role/host_role)
	. = ..()
	RegisterSignal(host_role, COMSIG_MAFIA_ON_KILL, PROC_REF(flickering_immunity))

/datum/mafia_ability/flicker_rampage/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	if(!(target_role in darkened_players))
		target_role.send_message_to_player(span_userdanger("The lights begin to flicker and dim. You're in danger."))
		darkened_players += target_role
	else
		for(var/datum/mafia_role/dead_players as anything in darkened_players)
			dead_players.send_message_to_player(span_userdanger("A shadowy figure appears out of the darkness!"))
			dead_players.kill(game, host_role, FALSE)
			darkened_players -= dead_players
	return TRUE

/datum/mafia_ability/flicker_rampage/proc/flickering_immunity(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER
	if(!attacker)
		return //no chance man, that's a town lynch

	if(attacker in darkened_players)
		host_role.send_message_to_player(span_userdanger("You were attacked by someone in a flickering room. You have danced in the shadows, evading them."))
		return MAFIA_PREVENT_KILL

