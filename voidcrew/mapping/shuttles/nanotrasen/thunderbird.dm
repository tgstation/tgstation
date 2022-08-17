/datum/map_template/shuttle/voidcrew/thunderbird
	name = "Thunderbird-class Emergency military vessel"
	suffix = "nano_thunderbird"
	short_name = "Thunderbird-Class"

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer,
			slots = 1,
		),
		list(
			name = "Atmospheric Technician",
			outfit = /datum/outfit/job/atmos,
			slots = 1,
		),
		list(
			name = "Scientist",
			outfit = /datum/outfit/job/scientist,
			slots = 2,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 2,
		),
		list(
			name = "Security Officer",
			outfit = /datum/outfit/job/security,
			slots = 2,
		),
	)
