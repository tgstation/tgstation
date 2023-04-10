/**
 * Pray
 *
 * During the night, revealing someone will announce their role when day comes.
 * This is one time use, we'll delete ourselves once done.
 */
/datum/mafia_ability/seance
	name = "Seance"
	ability_action = "commune with the spirit of"

/datum/mafia_ability/seance/perform_action(datum/mafia_controller/game)
	if(!validate_action_target(game))
		return ..()

	to_chat(host_role.body, span_warning("You invoke spirit of [target_role.body.real_name] and learn their role was <b>[target_role.name]<b>."))
	host_role.add_note("N[game.turn] - [target_role.body.real_name] - [target_role.name]")
	return ..()
