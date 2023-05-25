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
		to_chat(target_role.body, span_userdanger("You have been killed by a Changeling!"))
	game.send_message(span_danger("[host_role.body.real_name] was selected to attack [target_role.body.real_name] tonight!"), MAFIA_TEAM_MAFIA)
	return TRUE

/datum/mafia_ability/changeling_kill/set_target(datum/mafia_controller/game, datum/mafia_role/new_target)
	if(!validate_action_target(game, new_target))
		return FALSE
	using_ability = TRUE
	game.vote_for(host_role, new_target, "Mafia", MAFIA_TEAM_MAFIA)
