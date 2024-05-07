/**
 * Investigate
 *
 * During the night, Investigating will reveal the person's faction.
 */
/datum/mafia_ability/investigate
	name = "Investigate"
	ability_action = "investigate"

/datum/mafia_ability/investigate/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	var/fluff = "a member of the station, or great at deception."
	if(!(target_role.role_flags & ROLE_UNDETECTABLE))
		switch(target_role.team)
			if(MAFIA_TEAM_MAFIA)
				fluff = "an unfeeling, hideous changeling!"
			if(MAFIA_TEAM_SOLO)
				fluff = "rogue, with their own objectives..."

	host_role.send_message_to_player(span_warning("Your investigations reveal that [target_role.body.real_name] is [fluff]"))
	return TRUE
