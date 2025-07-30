/**
 * Changeling kill
 *
 * During the night, changelings vote for who to kill.
 * The attacker will always be the first person in the list, killing them will go to the next.
 */
/datum/mafia_ability/changeling_kill
	name = "Kill Vote"
	ability_action = "attempt to absorb"
	action_priority = COMSIG_MAFIA_NIGHT_KILL_PHASE
	///Boolean on whether a Changeling has been sent to attack someone yet.
	var/static/ling_sent = FALSE

/datum/mafia_ability/changeling_kill/clean_action_refs(datum/mafia_controller/game)
	ling_sent = FALSE
	game.reset_votes("Mafia")
	return ..()

/datum/mafia_ability/changeling_kill/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	var/datum/mafia_role/victim = game.get_vote_winner("Mafia")
	if(!victim)
		return FALSE
	target_role = victim

	. = ..()
	if(!.)
		return FALSE
	if(ling_sent)
		return FALSE

	ling_sent = TRUE
	if(target_role.kill(game, host_role, FALSE))
		target_role.send_message_to_player(span_userdanger("You have been killed by a Changeling!"))
	game.send_message(span_danger("[host_role.body.real_name] was selected to attack [target_role.body.real_name] tonight!"), MAFIA_TEAM_MAFIA)
	return TRUE

/datum/mafia_ability/changeling_kill/set_target(datum/mafia_role/new_target)
	if(new_target.team & MAFIA_TEAM_MAFIA)
		return FALSE
	if(!validate_action_target(new_target))
		return FALSE
	using_ability = TRUE
	host_role.mafia_game_controller.vote_for(host_role, new_target, "Mafia", MAFIA_TEAM_MAFIA)

/**
 * handle_speech
 *
 * During the night, Changelings talking will instead redirect it to Changeling chat.
 */
/datum/mafia_ability/changeling_kill/handle_speech(datum/source, list/speech_args)
	. = ..()
	if (host_role.mafia_game_controller.phase != MAFIA_PHASE_NIGHT)
		return FALSE

	var/message = span_changeling("<b>\[CHANGELING CHAT\] [source]</b>: [html_decode(speech_args[SPEECH_MESSAGE])]")
	host_role.mafia_game_controller.send_message(message, MAFIA_TEAM_MAFIA)
	speech_args[SPEECH_MESSAGE] = ""
	return TRUE
