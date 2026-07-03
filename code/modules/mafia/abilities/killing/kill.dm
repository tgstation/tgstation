/**
 * Attack
 *
 * During the night, attacks a player in attempts to kill them.
 */
/datum/mafia_ability/attack_player
	name = "Нападение"
	ability_action = "попробовать напасть"
	action_priority = COMSIG_MAFIA_NIGHT_KILL_PHASE
	///The message told to the player when they are killed.
	var/attack_action = "убит"
	///Whether the player will suicide if they hit a Town member.
	var/honorable = FALSE

/datum/mafia_ability/attack_player/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	if(!target_role.kill(game, host_role, FALSE))
		host_role.send_message_to_player(span_danger("Твоя попытка убить [target_role.body.real_name] был предотвращёна!"))
	else
		target_role.send_message_to_player(span_userdanger("Вы были [attack_action]ы [host_role.name]!"))
		if(honorable && (target_role.team & MAFIA_TEAM_TOWN))
			host_role.send_message_to_player(span_userdanger("Вы убили невинного члена экипажа. Вы умрете завтра ночью."))
			RegisterSignal(game, COMSIG_MAFIA_SUNDOWN, PROC_REF(internal_affairs))
	return TRUE

/datum/mafia_ability/attack_player/proc/internal_affairs(datum/mafia_controller/game)
	SIGNAL_HANDLER
	host_role.send_message_to_player(span_userdanger("Вы были убиты сотрудником внутренних дел Нанотрейзен!"))
	host_role.reveal_role(game, verbose = TRUE)
	host_role.kill(game, host_role, FALSE) //you technically kill yourself but that shouldn't matter

/datum/mafia_ability/attack_player/execution
	name = "Казнь"
	ability_action = "попробовать казнить"
	attack_action = "казнен"
	honorable = TRUE
