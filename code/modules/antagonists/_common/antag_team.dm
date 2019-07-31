GLOBAL_LIST_EMPTY(antagonist_teams)

//A barebones antagonist team.
/datum/team
	var/list/datum/mind/members = list()
	var/name = "team"
	var/member_name = "member"
	var/list/objectives = list() //common objectives, these won't be added or removed automatically, subtypes handle this, this is here for bookkeeping purposes.
	var/show_roundend_report = TRUE
	var/has_hud = FALSE /// Does the team have its own HUD?
	var/hud_icon_state = "traitor" /// Default icon
	var/datum/atom_hud/antag/team/team_hud = new /// HUD datum

/datum/team/New(starting_members)
	. = ..()
	GLOB.antagonist_teams += src

	if (has_hud)
		team_hud.self_visible = TRUE
		GLOB.huds += team_hud

	if(starting_members)
		if(islist(starting_members))
			for(var/datum/mind/M in starting_members)
				add_member(M)
		else
			add_member(starting_members)

/datum/team/Destroy(force, ...)
	GLOB.antagonist_teams -= src
	. = ..()

/datum/team/proc/is_solo()
	return members.len == 1

/datum/team/proc/add_member(datum/mind/new_member)
	if (has_hud)
		team_hud.join_hud(new_member.current)
		set_antag_hud(new_member.current, hud_icon_state, TRUE)

	members |= new_member

/datum/team/proc/remove_member(datum/mind/member)
	if (has_hud)
		team_hud.leave_hud(member.current)
		set_antag_hud(member.current, null, TRUE)

	members -= member

//Display members/victory/failure/objectives for the team
/datum/team/proc/roundend_report()
	if(!show_roundend_report)
		return

	var/list/report = list()

	report += "<span class='header'>[name]:</span>"
	report += "The [member_name]s were:"
	report += printplayerlist(members)

	if(objectives.len)
		report += "<span class='header'>Team had following objectives:</span>"
		var/win = TRUE
		var/objective_count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				report += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				report += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				win = FALSE
			objective_count++
		if(win)
			report += "<span class='greentext'>The [name] was successful!</span>"
		else
			report += "<span class='redtext'>The [name] have failed!</span>"


	return "<div class='panel redborder'>[report.Join("<br>")]</div>"
