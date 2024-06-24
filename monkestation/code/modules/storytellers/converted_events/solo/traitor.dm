/datum/round_event_control/antagonist/solo/traitor
	antag_flag = ROLE_SYNDICATE_INFILTRATOR
	tags = list(TAG_COMBAT)
	antag_datum = /datum/antagonist/traitor/infiltrator
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
		JOB_WARDEN,
		JOB_SECURITY_ASSISTANT,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	weight = 15

/datum/round_event_control/antagonist/solo/traitor/roundstart
	name = "Traitors"
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	roundstart = TRUE
	earliest_start = 0 SECONDS

/datum/round_event_control/antagonist/solo/traitor/midround
	name = "Sleeper Agents (Traitors)"
	antag_flag = ROLE_SLEEPER_AGENT
	antag_datum = /datum/antagonist/traitor/infiltrator/sleeper_agent
	prompted_picking = TRUE
