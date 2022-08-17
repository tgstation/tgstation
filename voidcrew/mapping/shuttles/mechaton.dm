/datum/map_template/shuttle/voidcrew/mechaton
	name = "Mechaton-class Robotics Production Facility"
	suffix = "mechaton"
	short_name = "Mechaton-Class"

	job_slots = list(
		list(
			name = "Research Director",
			officer = TRUE,
			outfit = /datum/outfit/job/rd,
			slots = 1,
		),
		list(
			name = "Scientist",
			outfit = /datum/outfit/job/scientist,
			slots = 2,
		),
		list(
			name = "Roboticist",
			outfit = /datum/outfit/job/roboticist,
			slots = 2,
		),
		list(
			name = "Atmospherics Technician",
			outfit = /datum/outfit/job/atmos,
			slots = 1,
		),
		list(
			name = "Geneticist",
			outfit = /datum/outfit/job/geneticist,
			slots = 2,
		),
	)
