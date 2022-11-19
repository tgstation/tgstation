/datum/map_template/shuttle/voidcrew/bogatyr
	name = "Bogatyr-class Explorator"
	suffix = "bogatyr"
	short_name = "Bogatyr-class"
	part_cost = 2

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Uchenyy",
			outfit = /datum/outfit/job/scientist,
			slots = 1,
		),
		list(
			name = "Shakhter",
			outfit = /datum/outfit/job/miner,
			slots = 2,
		),
		list(
			name = "Vrach",
			outfit = /datum/outfit/job/doctor,
			slots = 1,
		),
		list(
			name = "Gruzovoy Tekhnik",
			outfit = /datum/outfit/job/cargo_tech,
			slots = 1,
		),
		list(
			name = "Pomoshchnik",
			outfit = /datum/outfit/job/assistant,
			slots = 4,
		),
	)
