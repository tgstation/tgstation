/datum/map_template/shuttle/voidcrew/dwayne
	name = "Dwayne-class Long Range Mining Transport"
	suffix = "dwayne"
	short_name = "Dwayne-class"
	part_cost = 2

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain/western,
			slots = 1,
		),
		list(
			name = "Foreman",
			outfit = /datum/outfit/job/quartermaster/western,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer/western,
			slots = 1,
		),
		list(
			name = "Asteroid Miner",
			outfit = /datum/outfit/job/miner/western,
			slots = 2,
		),
		list(
			name = "Deckhand",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/dwayne
	name = "Dwayne-Class Long Range Mining Transport"
	area_type = /area/shuttle/voidcrew/dwayne
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///
/area/shuttle/voidcrew/dwayne/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Medbay ///

/area/shuttle/voidcrew/dwayne/medbay
	name = "Medbay"
	icon_state = "medbay"

/// Cargo ///

/area/shuttle/voidcrew/dwayne/cargo_bay
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/// Engineering ///

/area/shuttle/voidcrew/dwayne/engineering
	name = "Engineering"
	icon_state = "engine"

/// Service ///

/area/shuttle/voidcrew/dwayne/crew
	name = "Crew Commons"
	icon_state = "dorms"
