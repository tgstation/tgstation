/datum/team/changeling
	name = "Thingling"
	member_name = "thinglings"

/datum/antagonist/changeling/create_team(datum/team/changeling/new_team)
	if(!new_team)
		//For now only one revolution at a time
		for(var/datum/antagonist/changeling/lings in GLOB.antagonists)
			if(!lings.owner)
				continue
			if(lings.changeling_team)
				changeling_team = lings.changeling_team
				return
		changeling_team = new /datum/team/changeling
		var/datum/objective/total_assimilation/assimilate = new
		assimilate.team = changeling_team
		changeling_team.objectives += assimilate
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	changeling_team = new_team

/datum/antagonist/changeling/get_team()
	return changeling_team

/datum/antagonist/changeling/proc/create_objectives()
	objectives |= changeling_team.objectives

/datum/antagonist/changeling/proc/remove_objectives()
	objectives -= changeling_team.objectives

///team objective

/datum/objective/total_assimilation
	name = "total assimilation"
	explanation_text = "Assimilate all station crewmembers. Third parties may be ignored, but new recruits always helps."
	team_explanation_text = "Assimilate all station crewmembers. Third parties may be ignored, but new recruits always helps."

/datum/objective/assassinate/check_completion()
	for(var/mob/living/carbon/human/assimilated in GLOB.player_list)
		if(!assimilated.client)
			continue
		if(assimilated.stat == DEAD)
			continue
		if(!(assimilated.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		if(!assimilated.mind.has_antag_datum(/datum/antagonist/changeling))
			return FALSE
	return TRUE

/datum/team/revolution/roundend_report()
	if(!members.len)
		return

	var/report

	for(var/datum/objective/assimilate as anything in objectives)
		if(assimilate.check_completion())
			report = "<span class='greentext big'>The thinglings win! Everyone was assimilated!</span>"
		else
			report = "<span class='redtext big'>The thinglings have failed!</span>"

	return report
