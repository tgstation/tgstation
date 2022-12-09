/datum/map_template/shuttle/voidcrew/energia
	name = "Energia-class Experimental Vessel"
	suffix = "energia"
	short_name = "Energia-class"
	part_cost = 2

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 2,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer/western,
			slots = 2,
		),
		list(
			name = "Shaft Miner",
			outfit = /datum/outfit/job/miner/western,
			slots = 3,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 2,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/energia
	name = "Energia-class Experimental Vessel"
	area_type = /area/shuttle/voidcrew/energia
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/energia/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Medbay ///

/area/shuttle/voidcrew/energia/medbay
	name = "Medbay"
	icon_state = "medbay"

/// Cargo ///

/area/shuttle/voidcrew/energia/cargo_bay
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/// Engineering ///

/area/shuttle/voidcrew/energia/supermatter
	name = "Supermatter Engine"
	icon_state = "engine_sm"

/area/shuttle/voidcrew/energia/supermatter/chamber
	name = "Supermatter Chamber"
	icon_state = "engine_sm_room"

/// Service ///

/area/shuttle/voidcrew/energia/dorms
	name = "Dormitories"
	icon_state = "dorms"

/// Hallways ///

/area/shuttle/voidcrew/energia/hallway
	name = "Central Hallway"
	icon_state = "hall"

/// Maintenance ///

/area/shuttle/voidcrew/energia/maintenance
	name = "Aft Maintenance"
	icon_state = "aftmaint"
