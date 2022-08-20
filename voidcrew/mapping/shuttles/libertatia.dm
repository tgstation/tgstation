/datum/map_template/shuttle/voidcrew/libertatia
	name = "Libertatia-class Hauler"
	suffix = "libertatia"
	short_name = "Libertatia-Class"

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain/pirate,
			slots = 1,
		),
		list(
			name = "First Mate",
			outfit = /datum/outfit/job/hop/pirate,
			slots = 1,
		),
		list(
			name = "Buccanner",
			outfit = /datum/outfit/job/security/pirate,
			slots = 2,
		),
		list(
			name = "Motorman",
			outfit = /datum/outfit/job/engineer/pirate,
			slots = 1,
		),
		list(
			name = "Ship's Doctor",
			outfit = /datum/outfit/job/doctor/pirate,
			slots = 1,
		),
		list(
			name = "Deckhand",
			outfit = /datum/outfit/job/assistant/pirate,
			slots = 4,
		),
	)
