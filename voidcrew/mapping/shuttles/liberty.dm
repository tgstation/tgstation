/datum/map_template/shuttle/voidcrew/liberty
	name = "Liberty-class Interceptor"
	suffix = "liberty"
	short_name = "Liberty-Class"

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Executive Officer",
			outfit = /datum/outfit/job/hop,
			slots = 1,
		),
		list(
			name = "Marine",
			outfit = /datum/outfit/job/security,
			slots = 2,
		),
		list(
			name = "Brig Officer",
			outfit = /datum/outfit/job/warden,
			slots = 1,
		),
		list(
			name = "Combat Medic",
			outfit = /datum/outfit/job/paramedic,
			slots = 1,
		),
		list(
			name = "Sailor",
			outfit = /datum/outfit/job/assistant,
			slots = 4,
		),
	)
