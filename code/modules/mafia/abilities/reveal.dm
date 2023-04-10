/**
 * Reveal
 *
 * During the night, revealing someone will announce their role when day comes.
 * This is one time use, we'll delete ourselves once done.
 */
/datum/mafia_ability/reaveal_role
	name = "Reveal"
	ability_action = "psychologically evaluate"

/datum/mafia_ability/reaveal_role/perform_action(datum/mafia_controller/game)
	if(!validate_action_target(game))
		host_role.add_note("N[game.turn] - [target_role.body.real_name] - Unable to reveal")
		return ..()

	host_role.add_note("N[game.turn] - [target_role.body.real_name] - Revealed true identity")
	to_chat(host_role.body, span_warning("You have revealed the true nature of the [target_role]!"))
	target_role.reveal_role(game, verbose = TRUE)
	. = ..()
	host_role.role_unique_actions -= src
	qdel(src)
