/datum/map_template/shuttle/voidcrew/cultist
	name = "Express-Class Eldritch Hijacked Freighter"
	suffix = "express_cultist"
	short_name = "Cultist-class"
	antag_datum = /datum/antagonist/cult

	job_slots = list(
		list(
			name = "Cultist Leader",
			officer = TRUE,
			outfit = /datum/outfit/job/captain/western,
			slots = 1,
		),
		list(
			name = "Converted Foreman",
			outfit = /datum/outfit/job/quartermaster/western,
			slots = 1,
		),
		list(
			name = "Converted Engineer",
			outfit = /datum/outfit/job/engineer/hazard,
			slots = 1,
		),
		list(
			name = "Converted Miner",
			outfit = /datum/outfit/job/miner/hazard,
			slots = 2,
		),
		list(
			name = "Cultist",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)
