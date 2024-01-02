/datum/map_template/shuttle/voidcrew/blackbeard
	name = "Blackbeard-class Heavy Boarder"
	suffix = "syndicate_blackbeard"
	short_name = "Blackbeard-Class"
	faction_prefix = SYNDICATE_SHIP
	part_cost = 1

	job_slots = list(
		list(
			name = "Syndicate Strike Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain/syndicate,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor/syndicate,
			slots = 1,
		),
		list(
			name = "Syndicate Marine",
			outfit = /datum/outfit/job/assistant/syndicate,
			slots = 4,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/blackbeard
	name = "Blackbeard-class Heavy Boarder"
	area_type = /area/shuttle/voidcrew/blackbeard
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/blackbeard/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Cargo ///

/area/shuttle/voidcrew/blackbeard/cargo
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/// Security ///

/area/shuttle/voidcrew/blackbeard/equipment
	name = "Equipment Room"
	icon_state = "station"

/// Medbay ///

/area/shuttle/voidcrew/blackbeard/medbay
	name = "Medbay"
	icon_state = "medbay"

/// Engineering ///

/area/shuttle/voidcrew/blackbeard/engineering
	name = "Engineering"
	icon_state = "engine"

/// Hallway ///

/area/shuttle/voidcrew/blackbeard/hallway/fore
	name = "Fore Hallway"
	icon_state = "forehall"

/area/shuttle/voidcrew/blackbeard/hallway/aft
	name = "Aft Hallway"
	icon_state = "afthall"
