/datum/map_template/shuttle/voidcrew/luxembourg
	name = "Luxembourg-class Delivery Vessel"
	suffix = "luxembourg"
	short_name = "Luxembourg-Class"

	job_slots = list(
		list(
			name = "Quartermaster",
			officer = TRUE,
			outfit = /datum/outfit/job/quartermaster,
			slots = 1,
		),
		list(
			name = "Cargo Technician",
			outfit = /datum/outfit/job/cargo_tech,
			slots = 2,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer,
			slots = 1,
		),
		list(
			name = "Atmospherics Technician",
			outfit = /datum/outfit/job/atmos,
			slots = 1,
		),
		list(
			name = "Bartender",
			outfit = /datum/outfit/job/bartender,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 1,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)
