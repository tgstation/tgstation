/datum/mind
	var/datum/team/voidcrew/ship_team

/datum/team/voidcrew
	show_roundend_report = TRUE
	var/obj/structure/overmap/ship/ship
	var/faction_prefix

/datum/team/voidcrew/add_member(datum/mind/new_member)
	if(!new_member.ship_team)
		. = ..()
		new_member.ship_team = src
		new_member.add_antag_datum(/datum/antagonist/crew)

/datum/team/voidcrew/remove_member(datum/mind/member)
	. = ..()
	member.ship_team = null
	member.remove_antag_datum(/datum/antagonist/crew)

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



