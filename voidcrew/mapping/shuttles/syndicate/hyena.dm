/datum/map_template/shuttle/voidcrew/hyena
	name = "Hyena-class Wrecking Tug"
	suffix = "syndicate_hyena"
	short_name = "Hyena-Class"

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain/syndicate,
			slots = 1,
		),
		list(
			name = "Foreman",
			outfit = /datum/outfit/job/ce/syndicate,
			slots = 1,
		),
		list(
			name = "Mechanic",
			outfit = /datum/outfit/job/engineer/syndicate,
			slots = 1,
		),
		list(
			name = "Atmospheric Mechanic",
			outfit = /datum/outfit/job/atmos/syndicate,
			slots = 1,
		),
		list(
			name = "Wrecker",
			outfit = /datum/outfit/job/miner/syndicate,
			slots = 2,
		),
		list(
			name = "Junior Agent",
			outfit = /datum/outfit/job/assistant/syndicate,
			slots = 3,
		),
	)
