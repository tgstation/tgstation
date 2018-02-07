//Both ERT and DS are handled by the same datums since they mostly differ in equipment in objective.
/datum/team/ert
	name = "Emergency Response Team"
	var/datum/objective/mission //main mission

/datum/antagonist/ert
	name = "Emergency Response Officer"
	var/datum/team/ert/ert_team
	var/role = ERT_SEC
	var/high_alert = FALSE
	show_in_antagpanel = FALSE

/datum/antagonist/ert/on_gain()
	update_name()
	forge_objectives()
	equipERT()
	. = ..()

/datum/antagonist/ert/get_team()
	return ert_team

/datum/antagonist/ert/proc/update_name()
	var/new_name
	switch(role)
		if(ERT_ENG)
			new_name = "Engineer [pick(GLOB.last_names)]"
		if(ERT_MED)
			new_name = "Medical Officer [pick(GLOB.last_names)]"
		if(ERT_SEC)
			new_name = "Security Officer [pick(GLOB.last_names)]"
		if(ERT_LEADER)
			new_name = "Commander [pick(GLOB.last_names)]"
			name = "Emergency Response Commander"
		if(DEATHSQUAD)
			new_name = "Trooper [pick(GLOB.commando_names)]"
			name = "Deathsquad Trooper"
		if(DEATHSQUAD_LEADER)
			new_name = "Officer [pick(GLOB.commando_names)]"
			name = "Deathsquad Officer"
	owner.current.fully_replace_character_name(owner.current.real_name,new_name)

/datum/antagonist/ert/create_team(datum/team/ert/new_team)
	if(istype(new_team))
		ert_team = new_team

/datum/antagonist/ert/proc/forge_objectives()
	if(ert_team)
		objectives |= ert_team.objectives

/datum/antagonist/ert/proc/equipERT()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	var/outfit
	switch(role)
		if(ERT_LEADER)
			outfit = high_alert ? /datum/outfit/ert/commander/alert : /datum/outfit/ert/commander
		if(ERT_ENG)
			outfit = high_alert ? /datum/outfit/ert/engineer/alert : /datum/outfit/ert/engineer
		if(ERT_MED)
			outfit = high_alert ? /datum/outfit/ert/medic/alert : /datum/outfit/ert/medic
		if(ERT_SEC)
			outfit = high_alert ? /datum/outfit/ert/security/alert : /datum/outfit/ert/security
		if(DEATHSQUAD)
			outfit = /datum/outfit/death_commando/officer
		if(DEATHSQUAD_LEADER)
			outfit = /datum/outfit/death_commando
	H.equipOutfit(outfit)

/datum/antagonist/ert/greet()
	if(!ert_team)
		return
	
	var/leader = role == ERT_LEADER || role == DEATHSQUAD_LEADER
	
	to_chat(owner, "<B><font size=3 color=red>You are the [name].</font></B>")
	
	var/missiondesc = "Your squad is being sent on a mission to [station_name()] by Nanotrasen's Security Division."
	if(leader) //If Squad Leader
		missiondesc += " Lead your squad to ensure the completion of the mission. Board the shuttle when your team is ready."
	else
		missiondesc += " Follow orders given to you by your squad leader."
	if(role != DEATHSQUAD && role != DEATHSQUAD_LEADER)
		missiondesc += "Avoid civilian casualites when possible."
	
	missiondesc += "<BR><B>Your Mission</B> : [ert_team.mission.explanation_text]"
	to_chat(owner,missiondesc)
