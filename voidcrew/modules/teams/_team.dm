/datum/team/voidcrew
	show_roundend_report = FALSE

/datum/team/voidcrew/Destroy(force, ...)
	for(var/datum/mind/team_minds as anything in members)
		to_chat(team_minds, span_notice("Your faction has been disbanded! You are now alone!"))
	return ..()

///Checks the team's members to see if anyone with a client is alive. returns TRUE if active.
/datum/team/voidcrew/proc/is_active_team(obj/structure/overmap/ship/owner_ship)
	for(var/datum/mind/team_minds as anything in members)
		if(owner_ship.shuttle.z != team_minds.current.z) // different z, they don't matter anymore
			continue
		if(!team_minds.current.client)
			continue
		if(team_minds.current.stat <= HARD_CRIT)
			return TRUE
	return FALSE
