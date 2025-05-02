/**
 * Reveal
 *
 * During the night, revealing someone will announce their role when day comes.
 * This is one time use, we'll delete ourselves once done.
 */
/datum/mafia_ability/reveal_role
	name = "Reveal"
	ability_action = "psychologically evaluate"

/datum/mafia_ability/reveal_role/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	host_role.send_message_to_player(span_warning("You have revealed the true nature of the [target_role]!"))
	target_role.reveal_role(game, verbose = TRUE)
	return TRUE

/datum/mafia_ability/reveal_role/clean_action_refs(datum/mafia_controller/game)
	if(using_ability)
		host_role.role_unique_actions -= src
		qdel(src)
	return ..()
