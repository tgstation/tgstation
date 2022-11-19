/datum/map_template/shuttle/voidcrew/kilo
	name = "Kilo-class Mining Ship"
	suffix = "kilo"
	short_name = "Kilo-Class"
	part_cost = 3

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
			name = "Ship's Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 2,
		),
		list(
			name = "Ship's Engineer",
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
			slots = 2,
		),
	)
