/datum/map_template/shuttle/voidcrew/geneva
	name = "Geneva-class Search and Rescue Vessel"
	suffix = "syndicate_geneva"
	short_name = "Geneva-class"

	job_slots = list(
		list(
			name = "Chief Medical Officer",
			officer = TRUE,
			outfit = /datum/outfit/job/cmo/syndicate,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor/syndicate,
			slots = 2,
		),
		list(
			name = "Botanist",
			outfit = /datum/outfit/job/botanist/syndicate,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer/syndicate,
			slots = 2,
		),
		list(
			name = "Rescue Specialist",
			outfit = /datum/outfit/job/miner/syndicate,
			slots = 2,
		),
		list(
			name = "Paramedic",
			outfit = /datum/outfit/job/paramedic/syndicate/gorlex,
			slots = 1,
		),
	)
