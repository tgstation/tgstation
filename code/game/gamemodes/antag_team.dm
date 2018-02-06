//A barebones antagonist team.
/datum/team
	var/list/datum/mind/members = list()
	var/name = "team"
	var/member_name = "member"
	var/list/objectives = list() //common objectives, these won't be added or removed automatically, subtypes handle this, this is here for bookkeeping purposes.

/datum/team/New(starting_members)
	. = ..()
	if(starting_members)
		if(islist(starting_members))
			for(var/datum/mind/M in starting_members)
				add_member(M)
		else
			add_member(starting_members)

/datum/team/proc/is_solo()
	return members.len == 1

/datum/team/proc/add_member(datum/mind/new_member)
	members |= new_member

/datum/team/proc/remove_member(datum/mind/member)
	members -= member

//Display members/victory/failure/objectives for the team
/datum/team/proc/roundend_report()
	var/list/report = list()

	report += "<b>[name]:</b>"
	report += "The [member_name]s were:"
	report += printplayerlist(members)

	return report.Join("<br>")

//Get all teams [of type team_type]
//TODO move these to some antag helpers file with get_antagonists
/proc/get_all_teams(team_type)
	. = list()
	for(var/V in GLOB.antagonists)
		var/datum/antagonist/A = V
		if(!A.owner)
			continue
		var/datum/team/T = A.get_team()
		if(!team_type || istype(T,team_type))
			. |= T
