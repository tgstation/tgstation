/datum/round_event_control/antagonist/solo/obsessed
	antag_flag = ROLE_TRAITOR
	tags = list(TAG_COMBAT)
	antag_datum = /datum/antagonist/obsessed
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
		ROLE_POSITRONIC_BRAIN,
	)
	weight = 4
	max_occurrences = 3

/datum/round_event_control/antagonist/solo/obsessed/midround
	name = "Compulsive Obsession"
	prompted_picking = TRUE
	maximum_antags = 4
