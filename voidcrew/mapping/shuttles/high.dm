/datum/map_template/shuttle/voidcrew/high
	name = "High-class Corporate Luxury Ship"
	suffix = "high"
	short_name = "High-class"
	part_cost = 1

	job_slots = list(
		list(
			name = "Chief Executive Officer",
			officer = TRUE,
			outfit = /datum/outfit/job/captain/corporate,
			slots = 1,
		),
		list(
			name = "Chief Supply Officer",
			outfit = /datum/outfit/job/quartermaster/corporate,
			slots = 1,
		),
		list(
			name = "Corporate Security",
			outfit = /datum/outfit/job/security/corporate,
			slots = 2,
		),
		list(
			name = "Contracted Engineer",
			outfit = /datum/outfit/job/engineer/corporate,
			slots = 2,
		),
		list(
			name = "Business Associate",
			outfit = /datum/outfit/job/assistant/corporate,
			slots = 3,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/high
	name = "High-class Corporate Luxury Ship"
	area_type = /area/shuttle/voidcrew/high
	port_direction = 4


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/high/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/shuttle/voidcrew/high/bridge/captain
	name = "Captain's Office"
	icon_state = "captain"

/area/shuttle/voidcrew/high/bridge/boardroom
	name = "Boardroom"
	icon_state = "meeting"

/area/shuttle/voidcrew/high/bridge/reception
	name = "Reception"
	icon_state = "station"

/// Security ///

/area/shuttle/voidcrew/high/security
	name = "Security Checkpoint"
	icon_state = "checkpoint"

/// Engineering ///

/area/shuttle/voidcrew/high/engineering
	name = "Engineering"
	icon_state = "engine"

/// Cargo ///

/area/shuttle/voidcrew/high/cargo_bay
	name = "Cargo Bay"
	icon_state = "cargo_warehouse"

/// Service ///

/area/shuttle/voidcrew/high/dorms
	name = "Dormitories"
	icon_state = "dorms"

/// Hallway ///

/area/shuttle/voidcrew/high/hallway
	name = "Entrance Hall"
	icon_state = "hall"

/area/shuttle/voidcrew/high/hallway/main
	name = "Main Hall"
	icon_state = "centralhall"
