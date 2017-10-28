/datum/antagonist/brother
	name = "Brother"
	job_rank = ROLE_BROTHER
	var/special_role = "blood brother"
	var/datum/objective_team/brother_team/team

/datum/antagonist/brother/New(datum/mind/new_owner)
	return ..()

/datum/antagonist/brother/create_team(datum/objective_team/brother_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/brother/get_team()
	return team

/datum/antagonist/brother/on_gain()
	SSticker.mode.brothers += owner
	owner.objectives += team.objectives
	owner.special_role = special_role
	finalize_brother()
	return ..()

/datum/antagonist/brother/on_removal()
	SSticker.mode.brothers -= owner
	owner.objectives -= team.objectives
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'>You are no longer the [special_role]!</span>")
	owner.special_role = null
	return ..()

/datum/antagonist/brother/proc/give_meeting_area()
	if(!owner.current || !team || !team.meeting_area)
		return
	to_chat(owner.current, "<B>Your designated meeting area:</B> [team.meeting_area]")
	owner.store_memory("<b>Meeting Area</b>: [team.meeting_area]")

/datum/antagonist/brother/greet()
	var/brother_text = ""
	var/list/brothers = team.members - owner
	for(var/i = 1 to brothers.len)
		var/datum/mind/M = brothers[i]
		brother_text += M.name
		if(i == brothers.len - 1)
			brother_text += " and "
		else if(i != brothers.len)
			brother_text += ", "
	to_chat(owner.current, "<B><font size=3 color=red>You are the [owner.special_role] of [brother_text].</font></B>")
	to_chat(owner.current, "The Syndicate only accepts those that have proven themself. Prove yourself and prove your [team.member_name]s by completing your objectives together!")
	owner.announce_objectives()
	give_meeting_area()

/datum/antagonist/brother/proc/finalize_brother()
	SSticker.mode.update_brother_icons_added(owner)
