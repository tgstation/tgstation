/datum/antagonist/official/dropkick
	name = "Captain Dropkick"

/datum/antagonist/official/dropkick/greet()
	to_chat(owner, "<B><font size=3 color=red>You are Captain Dropkick!</font></B>")
	if (ert_team)
		to_chat(owner, "Central Command is sending you to [station_name()] with the task: [ert_team.mission.explanation_text]")
	else
		to_chat(owner, "Central Command is sending you to [station_name()] with the task: [mission.explanation_text]")

/datum/antagonist/official/dropkick/forge_objectives()
	if (ert_team)
		objectives |= ert_team.objectives
	else if (!mission)
		var/datum/objective/missionobj = new
		missionobj.owner = owner
		missionobj.explanation_text = "Conduct a routine dropkicking of [station_name()] and its Captain."
		missionobj.completed = 1
		mission = missionobj
		objectives |= mission
