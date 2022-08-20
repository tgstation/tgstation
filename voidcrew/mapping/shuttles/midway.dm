/datum/map_template/shuttle/voidcrew/midway
	name = "Midway-class Atmospherics Mining Vessel"
	suffix = "midway"
	short_name = "Midway-Class"

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Quartermaster",
			outfit = /datum/outfit/job/quartermaster,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 1,
		),
		list(
			name = "Atmospheric Technician",
			outfit = /datum/outfit/job/atmos,
			slots = 2,
		),
		list(
			name = "Cargo Technician",
			outfit = /datum/outfit/job/cargo_tech,
			slots = 2,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 2,
		),
	)
