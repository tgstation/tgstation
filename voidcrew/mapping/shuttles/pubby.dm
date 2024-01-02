/datum/map_template/shuttle/voidcrew/pubby
	name = "Pubby-class Light Carrier"
	suffix = "pubby"
	short_name = "Pubby-class"
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
			name = "Shaft Miner",
			outfit = /datum/outfit/job/miner,
			slots = 2,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 2,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/pubby
	name = "Pubby-class Light Carrier"
	area_type = /area/shuttle/voidcrew/pubby
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/pubby/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Cargo ///

/area/shuttle/voidcrew/pubby/cargo
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/// Engineering ///

/area/shuttle/voidcrew/pubby/engineering
	name = "Engineering"
	icon_state = "engine"
