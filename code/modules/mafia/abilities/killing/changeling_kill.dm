/**
 * Changeling kill
 *
 * During the night, changelings vote for who to kill.
 */
/datum/mafia_ability/changeling_kill
	name = "Kill Vote"
	ability_action = "attempt to absorb"
	action_priority = COMSIG_MAFIA_NIGHT_KILL_PHASE
	///Boolean on whether changelings attempted to attack their target or not.
	var/static/attacked_target = FALSE
	var/static/datum/mafia_role/changeling_attacker

/datum/mafia_ability/changeling_kill/set_target(datum/mafia_controller/game, datum/mafia_role/new_target)
	if(target_role)
		game.votes["Mafia"] += target_role
	. = ..()
	if(target_role)
		game.votes["Mafia"] += target_role

/**
 * Attempt to attack a player.
 * First we will check if this changeling player is able to attack
 * If so, they will select a random Changeling to attack.
 *
 * This makes it impossible for the Lawyer to meta hold up a game by repeatedly roleblocking one Changeling.
 */
/datum/mafia_ability/changeling_kill/perform_action(datum/mafia_controller/game)
	if(!validate_action_target(game))
		return ..()
	if(attacked_target)
		return

	changeling_attacker = game.get_random_voter("Mafia")
	var/datum/mafia_role/victim = game.get_vote_winner("Mafia")
	if(!victim)
		return ..()
	if(!victim.kill(game, changeling_attacker, FALSE))
		game.send_message(span_danger("[changeling_attacker.body.real_name] was unable to attack [victim.body.real_name] tonight!"), MAFIA_TEAM_MAFIA)
	else
		game.send_message(span_danger("[changeling_attacker.body.real_name] has attacked [victim.body.real_name]!"), MAFIA_TEAM_MAFIA)
		to_chat(victim.body, span_userdanger("You have been killed by a Changeling!"))
	changeling_attacker = null
	return ..()
