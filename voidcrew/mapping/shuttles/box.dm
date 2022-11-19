/datum/map_template/shuttle/voidcrew/box
	name = "Box-class Hospital Ship"
	suffix = "box"
	short_name = "Box-class"
	part_cost = 1

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
			slots = 3,
		),
		list(
			name = "Paramedic",
			outfit = /datum/outfit/job/paramedic,
			slots = 2,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)
