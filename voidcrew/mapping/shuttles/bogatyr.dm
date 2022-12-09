/datum/map_template/shuttle/voidcrew/bogatyr
	name = "Bogatyr-class Explorator"
	suffix = "bogatyr"
	short_name = "Bogatyr-class"
	part_cost = 2

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Uchenyy",
			outfit = /datum/outfit/job/scientist,
			slots = 1,
		),
		list(
			name = "Shakhter",
			outfit = /datum/outfit/job/miner,
			slots = 2,
		),
		list(
			name = "Vrach",
			outfit = /datum/outfit/job/doctor,
			slots = 1,
		),
		list(
			name = "Gruzovoy Tekhnik",
			outfit = /datum/outfit/job/cargo_tech,
			slots = 1,
		),
		list(
			name = "Pomoshchnik",
			outfit = /datum/outfit/job/assistant,
			slots = 4,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/bogatyr
	name = "Bogatyr-Class Explorator"
	area_type = /area/shuttle/voidcrew/bogatyr
	port_direction = 8
	preferred_direction = 4

/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/bogatyr/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Research ///

/area/shuttle/voidcrew/bogatyr/laboratory
	name = "Laboratory"
	icon_state = "aux_lab"

/// Medbay ///

/area/shuttle/voidcrew/bogatyr/infirmary
	name = "Infirmary"
	icon_state = "medbay"

/// Security ///

/area/shuttle/voidcrew/bogatyr/armory
	name = "Armory"
	icon_state = "armory"

/// Cargo ///

/area/shuttle/voidcrew/bogatyr/cargo
	name = "Cargo"
	icon_state = "cargo_bay"

/// Service ///

/area/shuttle/voidcrew/bogatyr/dormitories
	name = "Dormitories"
	icon_state = "dorms"

/// Maintenance ///

/area/shuttle/voidcrew/bogatyr/maintenance
	name = "Aft Maintenance"
	icon_state = "aftmaint"

/// Misc ///

/area/shuttle/voidcrew/bogatyr/central
	name = "Central"
	icon_state = "hall"
