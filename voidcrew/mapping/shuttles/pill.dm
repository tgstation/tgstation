/datum/map_template/shuttle/voidcrew/pill
	name = "Pill-class Torture Device"
	suffix = "pill"
	short_name = "Pill-class"
	height = 5
	width = 5

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
