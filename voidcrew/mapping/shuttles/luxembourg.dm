/datum/map_template/shuttle/voidcrew/luxembourg
	name = "Luxembourg-class Delivery Vessel"
	suffix = "luxembourg"
	short_name = "Luxembourg-Class"
	part_cost = 3

	job_slots = list(
		list(
			name = "Quartermaster",
			officer = TRUE,
			outfit = /datum/outfit/job/quartermaster,
			slots = 1,
		),
		list(
			name = "Cargo Technician",
			outfit = /datum/outfit/job/cargo_tech,
			slots = 2,
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
			name = "Bartender",
			outfit = /datum/outfit/job/bartender,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 1,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/luxembourg
	name = "Luxembourg-class Delivery Vessel"
	area_type = /area/shuttle/voidcrew/luxembourg


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/luxembourg/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Medbay ///

/area/shuttle/voidcrew/luxembourg/medbay
	name = "Medbay"
	icon_state = "medbay"

/// Cargo ///

/area/shuttle/voidcrew/luxembourg/cargo
	name = "Warehouse"
	icon_state = "cargo_warehouse"

/area/shuttle/voidcrew/luxembourg/cargo/mining
	name = "Mining Bay"
	icon_state = "mining"

/// Engineering ///

/area/shuttle/voidcrew/luxembourg/engineering
	name = "Engineering"
	icon_state = "engine"

/// Dormitories ///

/area/shuttle/voidcrew/luxembourg/dormitories
	name = "Dormitories"
	icon_state = "dorms"
