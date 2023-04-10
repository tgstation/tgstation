/**
 * Investigate
 *
 * During the night, Investigating will reveal the person's faction.
 */
/datum/mafia_ability/investigate
	name = "Investigate"
	ability_action = "investigate"

/datum/mafia_ability/investigate/perform_action(datum/mafia_controller/game)
	if(!validate_action_target(game))
		host_role.add_note("N[game.turn] - [target_role.body.real_name] - Unable to investigate")
		return ..()

	var/team_text = "Town"
	var/fluff = "a member of the station, or great at deception."
	if(!(target_role.role_flags & ROLE_UNDETECTABLE))
		switch(target_role.team)
			if(MAFIA_TEAM_MAFIA)
				team_text = "Mafia"
				fluff = "an unfeeling, hideous changeling!"
			if(MAFIA_TEAM_SOLO)
				team_text = "Solo"
				fluff = "rogue, with their own objectives..."

	to_chat(body,span_warning("Your investigations reveal that [target_role.body.real_name] is [fluff]"))
	host_role.add_note("N[game.turn] - [target_role.body.real_name] - [team_text]")
	return ..()

/**
 * Thoughtfeeding
 *
 * During the night, thoughtfeeding will reveal the person's exact role.
 */
/datum/mafia_ability/thoughtfeeder
	name = "Thoughtfeed"
	ability_action = "feast on the memories of"

/datum/mafia_ability/thoughtfeeder/perform_action(datum/mafia_controller/game)
	if(!validate_action_target(game))
		host_role.add_note("N[game.turn] - [target_role.body.real_name] - Unable to investigate")
		return ..()

	if((target_role.role_flags & ROLE_UNDETECTABLE))
		to_chat(body,span_warning("[target_role.body.real_name]'s memories reveal that they are the [pick(game.all_roles - target_role)]."))
		host_role.add_note("N[game.turn] - [target_role.body.real_name] - Assistant")
	else
		to_chat(body,span_warning("[target_role.body.real_name]'s memories reveal that they are the [target_role.name]."))
		host_role.add_note("N[game.turn] - [target_role.body.real_name] - [target_role.name]")
	return ..()
