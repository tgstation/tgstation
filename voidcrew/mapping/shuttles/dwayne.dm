/datum/map_template/shuttle/voidcrew/dwayne
	name = "Dwayne-class Long Range Mining Transport"
	suffix = "dwayne"
	short_name = "Dwayne-class"

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain/western,
			slots = 1,
		),
		list(
			name = "Foreman",
			outfit = /datum/outfit/job/quartermaster/western,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer/western,
			slots = 1,
		),
		list(
			name = "Asteroid Miner",
			outfit = /datum/outfit/job/miner/western,
			slots = 2,
		),
		list(
			name = "Deckhand",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)
