//A barebones antagonist team.
/datum/objective_team
	var/list/datum/mind/members = list()
	var/name = "team"
	var/member_name = "member"

/datum/objective_team/New(starting_members)
	. = ..()
	if(starting_members)
		members += starting_members

/datum/objective_team/proc/is_solo()
	return members.len == 1
