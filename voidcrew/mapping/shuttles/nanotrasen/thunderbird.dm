/datum/map_template/shuttle/voidcrew/thunderbird
	name = "Thunderbird-class Emergency military vessel"
	suffix = "nano_thunderbird"
	short_name = "Thunderbird-Class"
	faction_prefix = NANOTRASEN_SHIP
	part_cost = 2

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
			name = "Scientist",
			outfit = /datum/outfit/job/scientist,
			slots = 2,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 2,
		),
		list(
			name = "Security Officer",
			outfit = /datum/outfit/job/security,
			slots = 2,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/thunderbird
	name = "Thunderbird-class Emergency military vessel"
	area_type = /area/shuttle/voidcrew/thunderbird
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/thunderbird/bridge
	name = "Bridge"
	icon_state = "bridge"

 /// Security ///

/area/shuttle/voidcrew/thunderbird/security
	name = "Security Equipment"
	icon_state = "security"

/area/shuttle/voidcrew/thunderbird/security/armory
	name = "Armory"
	icon_state = "armory"

/// Cargo ///

/area/shuttle/voidcrew/thunderbird/cargo_bay
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/// Engineering ///

/area/shuttle/voidcrew/thunderbird/engineering
	name = "Engineering"
	icon_state = "engine"

/// Service ///

/area/shuttle/voidcrew/thunderbird/dormitories
	name = "Dormitories"
	icon_state = "dorms"

/// Hallway ///

/area/shuttle/voidcrew/thunderbird/hallway
	name = "Hallway"
	icon_state = "hall"

