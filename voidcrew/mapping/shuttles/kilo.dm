/datum/map_template/shuttle/voidcrew/kilo
	name = "Kilo-class Mining Ship"
	suffix = "kilo"
	short_name = "Kilo-Class"
	part_cost = 3

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
			name = "Ship's Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 2,
		),
		list(
			name = "Ship's Engineer",
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
			slots = 2,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/kilo
	name = "Kilo-class Mining Ship"
	area_type = /area/shuttle/voidcrew/kilo
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/kilo/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Cargo ///

/area/shuttle/voidcrew/kilo/cargo
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/area/shuttle/voidcrew/kilo/cargo/mining_dock
	name = "Mining Dock"
	icon_state = "mining"

/// Engineering ///

/area/shuttle/voidcrew/kilo/engineering
	name = "Engineering"
	icon_state = "engine"

/// Service ///

/area/shuttle/voidcrew/kilo/cafe
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/shuttle/voidcrew/kilo/dorms
	name = "Dormitories"
	icon_state = "dorms"
