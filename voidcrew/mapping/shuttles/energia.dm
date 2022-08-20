/datum/map_template/shuttle/voidcrew/energia
	name = "Energia-class Experimental Vessel"
	suffix = "energia"
	short_name = "Energia-class"

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 2,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer/western,
			slots = 2,
		),
		list(
			name = "Shaft Miner",
			outfit = /datum/outfit/job/miner/western,
			slots = 3,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 2,
		),
	)
