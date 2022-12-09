/datum/map_template/shuttle/voidcrew/meta
	name = "Meta-class Freighter"
	suffix = "meta"
	short_name = "Meta-Class"
	part_cost = 3

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Quartermaster",
			outfit = /datum/outfit/job/quartermaster,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer,
			slots = 1,
		),
		list(
			name = "Cook",
			outfit = /datum/outfit/job/cook,
			slots = 1,
		),
		list(
			name = "Shaft Miner",
			outfit = /datum/outfit/job/miner,
			slots = 2,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/meta
	name = "Meta-class Freighter"
	area_type = /area/shuttle/voidcrew/meta
	port_direction = 8
	preferred_direction = 2


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/meta/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Cargo ///

/area/shuttle/voidcrew/meta/cargo
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/// Engineering ///

/area/shuttle/voidcrew/meta/engineering
	name = "Engineering"
	icon_state = "engine"

/// Service ///

/area/shuttle/voidcrew/meta/dorms
	name = "Dormitories"
	icon_state = "dorms"

/area/shuttle/voidcrew/meta/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/shuttle/voidcrew/meta/kitchen
	name = "Kitchen"
	icon_state = "kitchen"
