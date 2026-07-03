/**
 * Investigate
 *
 * During the night, Investigating will reveal the person's faction.
 */
/datum/mafia_ability/investigate
	name = "Расследование"
	ability_action = "расследовать"

/datum/mafia_ability/investigate/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	var/fluff = "член станции, или отлично умеет обманывать."
	if(!(target_role.role_flags & ROLE_UNDETECTABLE))
		switch(target_role.team)
			if(MAFIA_TEAM_MAFIA)
				fluff = "бесчувственный, отвратительный генокрад!"
			if(MAFIA_TEAM_SOLO)
				fluff = "изгой, преследующий свои собственные цели..."

	host_role.send_message_to_player(span_warning("Ваше расследование показало, что [target_role.body.real_name] это [fluff]"))
	return TRUE
