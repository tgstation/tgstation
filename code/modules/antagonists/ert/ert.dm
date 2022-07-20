//Both ERT and DS are handled by the same datums since they mostly differ in equipment in objective.
/datum/team/ert
	name = "Emergency Response Team"
	var/datum/objective/mission //main mission

/datum/antagonist/ert
	name = "Emergency Response Officer"
	can_elimination_hijack = ELIMINATION_PREVENT
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	suicide_cry = "FOR NANOTRASEN!!"
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/ert/ert_team
	var/leader = FALSE
	var/datum/outfit/outfit = /datum/outfit/centcom/ert/security
	var/datum/outfit/plasmaman_outfit = /datum/outfit/plasmaman/centcom_official
	var/role = "Security Officer"
	var/list/name_source
	var/random_names = TRUE
	var/rip_and_tear = FALSE
	var/equip_ert = TRUE
	var/forge_objectives_for_ert = TRUE
	/// Typepath indicating the kind of job datum this ert member will have.
	var/ert_job_path = /datum/job/ert_generic


/datum/antagonist/ert/on_gain()
	if(random_names)
		update_name()
	if(forge_objectives_for_ert)
		forge_objectives()
	if(equip_ert)
		equipERT()
	. = ..()

/datum/antagonist/ert/get_team()
	return ert_team

/datum/antagonist/ert/New()
	. = ..()
	name_source = GLOB.last_names

/datum/antagonist/ert/proc/update_name()
	owner.current.fully_replace_character_name(owner.current.real_name,"[role] [pick(name_source)]")

/datum/antagonist/ert/official
	name = "CentCom Official"
	show_name_in_check_antagonists = TRUE
	var/datum/objective/mission
	role = "Inspector"
	random_names = FALSE
	outfit = /datum/outfit/centcom/centcom_official

/datum/antagonist/ert/official/greet()
	. = ..()
	if (ert_team)
		to_chat(owner, "<span class='warningplain'>Central Command is sending you to [station_name()] with the task: [ert_team.mission.explanation_text]</span>")
	else
		to_chat(owner, "<span class='warningplain'>Central Command is sending you to [station_name()] with the task: [mission.explanation_text]</span>")

/datum/antagonist/ert/official/forge_objectives()
	if (ert_team)
		return ..()
	if(mission)
		return
	var/datum/objective/missionobj = new ()
	missionobj.owner = owner
	missionobj.explanation_text = "Conduct a routine performance review of [station_name()] and its Captain."
	missionobj.completed = TRUE
	mission = missionobj
	objectives |= mission

/datum/antagonist/ert/security // kinda handled by the base template but here for completion

/datum/antagonist/ert/security/red
	outfit = /datum/outfit/centcom/ert/security/alert

/datum/antagonist/ert/engineer
	role = "Engineer"
	outfit = /datum/outfit/centcom/ert/engineer

/datum/antagonist/ert/engineer/red
	outfit = /datum/outfit/centcom/ert/engineer/alert

/datum/antagonist/ert/medic
	role = "Medical Officer"
	outfit = /datum/outfit/centcom/ert/medic

/datum/antagonist/ert/medic/red
	outfit = /datum/outfit/centcom/ert/medic/alert

/datum/antagonist/ert/commander
	role = "Commander"
	outfit = /datum/outfit/centcom/ert/commander
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_commander

/datum/antagonist/ert/commander/red
	outfit = /datum/outfit/centcom/ert/commander/alert

/datum/antagonist/ert/janitor
	role = "Janitor"
	outfit = /datum/outfit/centcom/ert/janitor

/datum/antagonist/ert/janitor/heavy
	role = "Heavy Duty Janitor"
	outfit = /datum/outfit/centcom/ert/janitor/heavy

/datum/antagonist/ert/deathsquad
	name = "Deathsquad Trooper"
	outfit = /datum/outfit/centcom/death_commando
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_commander
	role = "Trooper"
	rip_and_tear = TRUE

/datum/antagonist/ert/deathsquad/New()
	. = ..()
	name_source = GLOB.commando_names

/datum/antagonist/ert/deathsquad/leader
	name = "Deathsquad Officer"
	outfit = /datum/outfit/centcom/death_commando
	role = "Officer"

/datum/antagonist/ert/medic/inquisitor
	outfit = /datum/outfit/centcom/ert/medic/inquisitor

/datum/antagonist/ert/medic/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/security/inquisitor
	outfit = /datum/outfit/centcom/ert/security/inquisitor

/datum/antagonist/ert/security/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/chaplain
	role = "Chaplain"
	outfit = /datum/outfit/centcom/ert/chaplain

/datum/antagonist/ert/chaplain/inquisitor
	outfit = /datum/outfit/centcom/ert/chaplain/inquisitor

/datum/antagonist/ert/chaplain/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/commander/inquisitor
	outfit = /datum/outfit/centcom/ert/commander/inquisitor

/datum/antagonist/ert/commander/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/intern
	name = "CentCom Intern"
	outfit = /datum/outfit/centcom/centcom_intern
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_intern
	random_names = FALSE
	role = "Intern"
	suicide_cry = "FOR MY INTERNSHIP!!"

/datum/antagonist/ert/intern/leader
	name = "CentCom Head Intern"
	outfit = /datum/outfit/centcom/centcom_intern/leader
	random_names = FALSE
	role = "Head Intern"

/datum/antagonist/ert/intern/unarmed
	outfit = /datum/outfit/centcom/centcom_intern/unarmed

/datum/antagonist/ert/intern/leader/unarmed
	outfit = /datum/outfit/centcom/centcom_intern/leader/unarmed

/datum/antagonist/ert/clown
	role = "Clown"
	outfit = /datum/outfit/centcom/ert/clown
	plasmaman_outfit = /datum/outfit/plasmaman/party_comedian

/datum/antagonist/ert/clown/New()
	. = ..()
	name_source = GLOB.clown_names

/datum/antagonist/ert/janitor/party
	role = "Party Cleaning Service"
	outfit = /datum/outfit/centcom/ert/janitor/party
	plasmaman_outfit = /datum/outfit/plasmaman/party_janitor

/datum/antagonist/ert/security/party
	role = "Party Bouncer"
	outfit = /datum/outfit/centcom/ert/security/party
	plasmaman_outfit = /datum/outfit/plasmaman/party_bouncer

/datum/antagonist/ert/engineer/party
	role = "Party Constructor"
	outfit = /datum/outfit/centcom/ert/engineer/party
	plasmaman_outfit = /datum/outfit/plasmaman/party_constructor

/datum/antagonist/ert/clown/party
	role = "Party Comedian"
	outfit = /datum/outfit/centcom/ert/clown/party

/datum/antagonist/ert/commander/party
	role = "Party Coordinator"
	outfit = /datum/outfit/centcom/ert/commander/party

/datum/antagonist/ert/create_team(datum/team/ert/new_team)
	if(istype(new_team))
		ert_team = new_team

/datum/antagonist/ert/bounty_armor
	role = "Armored Bounty Hunter"
	outfit = /datum/outfit/bountyarmor/ert

/datum/antagonist/ert/bounty_hook
	role = "Hookgun Bounty Hunter"
	outfit = /datum/outfit/bountyhook/ert

/datum/antagonist/ert/bounty_synth
	role = "Synthetic Bounty Hunter"
	outfit = /datum/outfit/bountysynth/ert

/datum/antagonist/ert/proc/forge_objectives()
	if(ert_team)
		objectives |= ert_team.objectives

/datum/antagonist/ert/proc/equipERT()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	if(isplasmaman(H))
		H.equipOutfit(plasmaman_outfit)
		H.internal = H.get_item_for_held_index(2)
		H.update_internals_hud_icon(1)
	H.equipOutfit(outfit)


/datum/antagonist/ert/greet()
	if(!ert_team)
		return

	to_chat(owner, "<span class='warningplain'><B><font size=3 color=red>You are the [name].</font></B></span>")

	var/missiondesc = "Your squad is being sent on a mission to [station_name()] by Nanotrasen's Security Division."
	if(leader) //If Squad Leader
		missiondesc += " Lead your squad to ensure the completion of the mission. Board the shuttle when your team is ready."
	else
		missiondesc += " Follow orders given to you by your squad leader."
	if(!rip_and_tear)
		missiondesc += " Avoid civilian casualties when possible."

	missiondesc += "<span class='warningplain'><BR><B>Your Mission</B> : [ert_team.mission.explanation_text]</span>"
	to_chat(owner,missiondesc)

/datum/antagonist/ert/marine
	name = "Marine Commander"
	outfit = /datum/outfit/centcom/ert/marine
	role = "Commander"

/datum/antagonist/ert/marine/security
	name = "Marine Heavy"
	outfit = /datum/outfit/centcom/ert/marine/security
	role = "Trooper"

/datum/antagonist/ert/marine/engineer
	name = "Marine Engineer"
	outfit = /datum/outfit/centcom/ert/marine/engineer
	role = "Engineer"

/datum/antagonist/ert/marine/medic
	name = "Marine Medic"
	outfit = /datum/outfit/centcom/ert/marine/medic
	role = "Medical Officer"
