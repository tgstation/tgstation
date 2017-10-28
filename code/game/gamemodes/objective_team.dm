//A barebones antagonist team.
/datum/objective_team
	var/list/datum/mind/members = list()
	var/name = "team"
	var/member_name = "member"

/datum/objective_team/New(starting_members)
	. = ..()
	if(starting_members)
		if(islist(starting_members))
			for(var/datum/mind/M in starting_members)
				add_member(M)
		else
			add_member(starting_members)
		members += starting_members

/datum/objective_team/proc/is_solo()
	return members.len == 1

/datum/objective_team/proc/add_member(datum/mind/new_member)
	members |= new_member

/datum/objective_team/proc/remove_member(datum/mind/member)
	members -= member