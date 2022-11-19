/datum/map_template/shuttle/voidcrew/pill_black
	name = "Pill-class-B(lack) Suicide Device"
	suffix = "pill_black"
	short_name = "Blackpill-class"
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
			slots = 2,
		),
	)
