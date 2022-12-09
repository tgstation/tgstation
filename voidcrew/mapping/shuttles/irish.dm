/datum/map_template/shuttle/voidcrew/resistance
	name = "Resistance-Class IRA Safehouse"
	suffix = "irish"
	short_name = "Resistance-class"
	part_cost = 2

	job_slots = list(
		list(
			name = "IRA Leader",
			officer = TRUE,
			outfit = /datum/outfit/job/assistant/provo,
			slots = 1,
		),
		list(
			name = "IRA Member",
			outfit = /datum/outfit/job/assistant/provo,
			slots = 5,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/resistance
	name = "Resistance-Class IRA Safehouse"
	area_type = /area/shuttle/voidcrew/resistance
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/resistance/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Science ///

/area/shuttle/voidcrew/resistance/ordnance
	name = "Ordnance"
	icon_state = "ord_main"

/area/shuttle/voidcrew/resistance/ordnance/storage
	name = "Ordnance Storage"
	icon_state = "ord_storage"

/area/shuttle/voidcrew/resistance/ordnance/chemistry
	name = "Chemical Ordnance"
	icon_state = "chem"

/// Cargo ///

/area/shuttle/voidcrew/resistance/cargo
	name = "Cargo Bay"
	icon_state = "cargo_warehouse"

/// Maintenance ///

/area/shuttle/voidcrew/resistance/maintenance
	name = "Aft Maintenance"
	icon_state = "aftmaint"
