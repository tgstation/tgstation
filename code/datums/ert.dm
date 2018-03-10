/datum/ert
	var/mobtype = /mob/living/carbon/human
	var/team = /datum/team/ert
	var/antagtype = /datum/antagonist/ert
	var/opendoors = TRUE
	var/leader_role = ERT_LEADER
	var/enforce_human = TRUE
	var/roles = list(ERT_SEC,ERT_MED,ERT_ENG) //List of possible sub-roles to be assigned to ERT members
	var/high_alert = FALSE
	var/rename_team
	var/code
	var/mission = "Assist the station."
	var/teamsize = 5
	var/polldesc

/datum/ert/New()
	if (!polldesc)
		polldesc = "a Code [code] Nanotrasen Emergency Response Team"

/datum/ert/blue
	opendoors = FALSE
	code = "Blue"

/datum/ert/amber
	code = "Amber"

/datum/ert/red
	high_alert = TRUE
	code = "Red"

/datum/ert/deathsquad
	roles = list(DEATHSQUAD)
	leader_role = DEATHSQUAD_LEADER
	rename_team = "Deathsquad"
	code = "Delta"
	mission = "Leave no witnesses."
	polldesc = "an elite Nanotrasen Strike Team"

/datum/ert/centcom_official
	code = "Green"
	teamsize = 1
	opendoors = FALSE
	antagtype = /datum/antagonist/official
	rename_team = "CentCom Officials"
	polldesc = "a CentCom Official"

/datum/ert/centcom_official/New()
	mission = "Conduct a routine preformance review of [station_name()] and its Captain."
