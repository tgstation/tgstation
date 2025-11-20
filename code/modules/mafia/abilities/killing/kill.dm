/**
 * Attack
 *
 * During the night, attacks a player in attempts to kill them.
 */
/datum/mafia_ability/attack_player
	name = "Attack"
	ability_action = "attempt to attack"
	action_priority = COMSIG_MAFIA_NIGHT_KILL_PHASE
	///The message told to the player when they are killed.
	var/attack_action = "killed by"
	///Whether the player will suicide if they hit a Town member.
	var/honorable = FALSE

/datum/mafia_ability/attack_player/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	if(!target_role.kill(game, host_role, FALSE))
		host_role.send_message_to_player(span_danger("Your attempt at killing [target_role.body.real_name] was prevented!"))
	else
		target_role.send_message_to_player(span_userdanger("You have been [attack_action] \a [host_role.name]!"))
		if(honorable && (target_role.team & MAFIA_TEAM_TOWN))
			host_role.send_message_to_player(span_userdanger("You have killed an innocent crewmember. You will die tomorrow night."))
			RegisterSignal(game, COMSIG_MAFIA_SUNDOWN, PROC_REF(internal_affairs))
	return TRUE

/datum/mafia_ability/attack_player/proc/internal_affairs(datum/mafia_controller/game)
	SIGNAL_HANDLER
	host_role.send_message_to_player(span_userdanger("You have been killed by Nanotrasen Internal Affairs!"))
	host_role.reveal_role(game, verbose = TRUE)
	host_role.kill(game, host_role, FALSE) //you technically kill yourself but that shouldn't matter

/datum/mafia_ability/attack_player/execution
	name = "Execute"
	ability_action = "attempt to execute"
	attack_action = "executed by"
	honorable = TRUE
