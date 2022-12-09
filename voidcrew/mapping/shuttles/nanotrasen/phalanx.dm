/datum/map_template/shuttle/voidcrew/phalanx
	name = "Phalanx-Class Super Battlecruiser"
	suffix = "nano_phalanx"
	short_name = "Phalanx-Class"
	faction_prefix = NANOTRASEN_SHIP
	part_cost = 3

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Chaplain",
			outfit = /datum/outfit/job/chaplain,
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
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 2,
		),
		list(
			name = "Cook",
			outfit = /datum/outfit/job/cook,
			slots = 1,
		),
		list(
			name = "Security Officer",
			outfit = /datum/outfit/job/security,
			slots = 10,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/phalanx
	name = "Phalanx-Class Super Battlecruiser"
	area_type = /area/shuttle/voidcrew/phalanx
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/phalanx/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/shuttle/voidcrew/phalanx/bridge/captain
	name = "Captain's Office"
	icon_state = "captain"

/// Security ///

/area/shuttle/voidcrew/phalanx/security
	name = "Security Equipment"
	icon_state = "security"

/area/shuttle/voidcrew/phalanx/security/armory
	name = "Armory"
	icon_state = "armory"

/// Cargo ///

/area/shuttle/voidcrew/phalanx/cargo
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/area/shuttle/voidcrew/phalanx/cargo/mining
	name = "Mining Bay"
	icon_state = "mining"

/// Engineering ///

/area/shuttle/voidcrew/phalanx/engineering
	name = "Engineering"
	icon_state = "engine"

/area/shuttle/voidcrew/phalanx/engineering/storage
	name = "Engineering Storage"
	icon_state = "engine_storage"

/area/shuttle/voidcrew/phalanx/engineering/atmospherics
	name = "Atmospherics"
	icon_state = "atmos"

/// Science ///

/area/shuttle/voidcrew/phalanx/nanites
	name = "Nanite Lab"
	icon_state = "station"

/// Medbay ///

/area/shuttle/voidcrew/phalanx/medbay
	name = "Medbay"
	icon_state = "medbay"

/area/shuttle/voidcrew/phalanx/medbay/morgue
	name = "Morgue"
	icon_state = "morgue"

/area/shuttle/voidcrew/phalanx/medbay/storage
	name = "Medical Equipment"
	icon_state = "med_storage"

/// Storage ///

/area/shuttle/voidcrew/phalanx/dorms
	name = "Dormitories"
	icon_state = "dorms"

/area/shuttle/voidcrew/phalanx/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/shuttle/voidcrew/phalanx/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/shuttle/voidcrew/phalanx/chapel
	name = "Chapel"
	icon_state = "chapel"

/area/shuttle/voidcrew/phalanx/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"

/// Hallways ///

/area/shuttle/voidcrew/phalanx/hallway/central
	name = "Central Hall"
	icon_state = "centralhall"

/area/shuttle/voidcrew/phalanx/hallway/aft
	name = "Aft Hall"
	icon_state = "afthall"
