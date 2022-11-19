/datum/map_template/shuttle/voidcrew/phalanx
	name = "Phalanx-Class Super Battlecruiser"
	suffix = "nano_phalanx"
	short_name = "Phalanx-Class"
	faction_prefix = NANOTRASEN_SHIP
	part_cost = 3

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Chaplain",
			outfit = /datum/outfit/job/chaplain,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer,
			slots = 1,
		),
		list(
			name = "Atmospheric Technician",
			outfit = /datum/outfit/job/atmos,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 2,
		),
		list(
			name = "Cook",
			outfit = /datum/outfit/job/cook,
			slots = 1,
		),
		list(
			name = "Security Officer",
			outfit = /datum/outfit/job/security,
			slots = 10,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)
