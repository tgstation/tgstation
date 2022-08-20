/datum/map_template/shuttle/voidcrew/hightide
	name = "HighTide-Class Entrepreneur Ship"
	suffix = "hightide"
	short_name = "HighTide-Class"

	job_slots = list(
		list(
			name = "Head Assistant",
			officer = TRUE,
			outfit = /datum/outfit/job/assistant/corporate,
			slots = 1,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 7,
		),
	)
