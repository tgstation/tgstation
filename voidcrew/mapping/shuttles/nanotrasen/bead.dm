/datum/map_template/shuttle/voidcrew/bead
	name = "Bead-class Corporate Frigate"
	suffix = "nano_bead"
	short_name = "Bead-Class"
	faction_prefix = NANOTRASEN_SHIP
	part_cost = 1

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
			name = "Security Officer",
			outfit = /datum/outfit/job/security,
			slots = 3,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/bead
	name = "Bead-Class Corporate Frigate"
	area_type = /area/shuttle/voidcrew/bead
	port_direction = 4
	preferred_direction = 4

/// AREAS ///

/// Command ///
/area/shuttle/voidcrew/bead/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Security ///

/area/shuttle/voidcrew/bead/brig
	name = "Brig"
	icon_state = "brig"

/area/shuttle/voidcrew/bead/armory
	name = "Armory"
	icon_state = "armory"

/// Engineering ///

/area/shuttle/voidcrew/bead/engineering
	name = "Engineering"
	icon_state = "engine"

/// Cargo ///

/area/shuttle/voidcrew/bead/cargo
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/// Hallways ///

/area/shuttle/voidcrew/bead/hallway
	name = "Central Hallway"
	icon_state = "centralhall"

/// Maintenance ///

/area/shuttle/voidcrew/bead/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "aftmaint"

/area/shuttle/voidcrew/bead/maintenance/port
	name = "Port Maintenance"
	icon_state = "portmaint"

/area/shuttle/voidcrew/bead/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "starboardmaint"

