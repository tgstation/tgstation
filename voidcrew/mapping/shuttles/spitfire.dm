/datum/map_template/shuttle/voidcrew/spitfire
	name = "Spitfire-class Search and Rescue Vessel"
	suffix = "spitfire"
	short_name = "Spitfire-class"
	part_cost = 2

	job_slots = list(
		list(
			name = "Chief Medical Officer",
			officer = TRUE,
			outfit = /datum/outfit/job/cmo,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 1,
		),
		list(
			name = "Paramedic",
			outfit = /datum/outfit/job/paramedic,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer,
			slots = 1,
		),
		list(
			name = "Shaft Miner",
			outfit = /datum/outfit/job/miner,
			slots = 1,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 1,
		),
	)
