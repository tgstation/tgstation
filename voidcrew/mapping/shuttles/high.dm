/datum/map_template/shuttle/voidcrew/high
	name = "High-class Corporate Luxury Ship"
	suffix = "high"
	short_name = "High-class"

	job_slots = list(
		list(
			name = "Chief Executive Officer",
			officer = TRUE,
			outfit = /datum/outfit/job/captain/corporate,
			slots = 1,
		),
		list(
			name = "Chief Supply Officer",
			outfit = /datum/outfit/job/quartermaster/corporate,
			slots = 1,
		),
		list(
			name = "Corporate Security",
			outfit = /datum/outfit/job/security/corporate,
			slots = 2,
		),
		list(
			name = "Contracted Engineer",
			outfit = /datum/outfit/job/engineer/corporate,
			slots = 2,
		),
		list(
			name = "Business Associate",
			outfit = /datum/outfit/job/assistant/corporate,
			slots = 3,
		),
	)
