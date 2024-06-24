/datum/round_event_control/antagonist/solo/bloodsucker
	antag_flag = ROLE_BLOODSUCKER
	tags = list(TAG_COMBAT, TAG_MAGICAL)
	antag_datum = /datum/antagonist/bloodsucker
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	min_players = 20
	weight = 10
	maximum_antags = 2

/datum/round_event_control/antagonist/solo/bloodsucker/roundstart
	name = "Bloodsuckers"
	roundstart = TRUE
	earliest_start = 0 SECONDS

/datum/round_event_control/antagonist/solo/bloodsucker/midround
	typepath = /datum/round_event/antagonist/solo/bloodsucker
	antag_flag = ROLE_VAMPIRICACCIDENT
	name = "Vampiric Accident"
	prompted_picking = TRUE
	max_occurrences = 1

/datum/round_event/antagonist/solo/bloodsucker/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = antag_mind.make_bloodsucker()
	bloodsuckerdatum.bloodsucker_level_unspent = rand(2,3)
