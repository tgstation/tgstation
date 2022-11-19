/datum/map_template/shuttle/voidcrew/pill
	name = "Pill-class Torture Device"
	suffix = "pill"
	short_name = "Pill-class"
	part_cost = 1

	job_slots = list(
		list(
			name = "Head Prisoner",
			officer = TRUE,
			outfit = /datum/outfit/job/prisoner,
			slots = 1,
		),
		list(
			name = "Prisoner",
			outfit = /datum/outfit/job/prisoner,
			slots = 3,
		),
	)
