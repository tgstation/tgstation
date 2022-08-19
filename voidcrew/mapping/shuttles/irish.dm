/datum/map_template/shuttle/voidcrew/resistance
	name = "Resistance-Class IRA Safehouse"
	suffix = "irish"
	short_name = "Resistance-class"

	job_slots = list(
		list(
			name = "IRA Leader",
			officer = TRUE,
			outfit = /datum/outfit/job/assistant/provo,
			slots = 1,
		),
		list(
			name = "IRA Member",
			outfit = /datum/outfit/job/assistant/provo,
			slots = 5,
		),
	)
