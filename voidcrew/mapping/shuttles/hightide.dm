/datum/map_template/shuttle/voidcrew/hightide
	name = "HighTide-Class Entrepreneur Ship"
	suffix = "hightide"
	short_name = "HighTide-Class"

	job_slots = list(
		list(
			name = "Head Assistant",
			officer = TRUE,
			outfit = /datum/outfit/job/assistant/corporate,
			slots = 1,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 7,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/hightide
	name = "HighTide-Class Entrepreneur Ship"
	area_type = /area/shuttle/voidcrew/hightide
	port_direction = 4


/// AREAS ///

/// Maintenance ///
/area/shuttle/voidcrew/hightide/maintenance
	name = "Central Maintenance"
	icon_state = "centralmaint"

/area/shuttle/voidcrew/hightide/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "foremaint"

/area/shuttle/voidcrew/hightide/maintenance/port
	name = "Port Maintenance"
	icon_state = "portmaint"

/area/shuttle/voidcrew/hightide/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "starboardmaint"

/area/shuttle/voidcrew/hightide/maintenance/cargo
	name = "Cargo Maintenance"
	icon_state = "maint_cargo"

/area/shuttle/voidcrew/hightide/maintenance/kitchen
	name = "Kitchen Maintenance"
	icon_state = "station"
