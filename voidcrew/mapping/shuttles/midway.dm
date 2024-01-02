/datum/map_template/shuttle/voidcrew/midway
	name = "Midway-class Atmospherics Mining Vessel"
	suffix = "midway"
	short_name = "Midway-Class"
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
			name = "Atmospheric Technician",
			outfit = /datum/outfit/job/atmos,
			slots = 2,
		),
		list(
			name = "Cargo Technician",
			outfit = /datum/outfit/job/cargo_tech,
			slots = 2,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 2,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/midway
	name = "Midway-class Atmospherics Mining Vessel"
	area_type = /area/shuttle/voidcrew/midway
	port_direction = 8
	preferred_direction = 2


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/midway/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Cargo ///

/area/shuttle/voidcrew/midway/cargo
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/area/shuttle/voidcrew/midway/cargo/mining
	name = "Mining Dock"
	icon_state = "mining"

/// Medbay ///

/area/shuttle/voidcrew/midway/medbay
	name = "Medbay"
	icon_state = "medbay"

/// Engineering ///

/area/shuttle/voidcrew/midway/engineering
	name = "Engineering"
	icon_state = "engine"

/area/shuttle/voidcrew/midway/engineering/storage
	name = "Engineering Storage"
	icon_state = "engine_storage"

/area/shuttle/voidcrew/midway/atmospherics
	name = "Atmospherics"
	icon_state = "atmos"

/// Service ///

/area/shuttle/voidcrew/midway/dorms
	name = "Dormitories"
	icon_state = "dorms"

/// Hallways ///

/area/shuttle/voidcrew/midway/hallway
	name = "Central Hallway"
	icon_state = "hall"
