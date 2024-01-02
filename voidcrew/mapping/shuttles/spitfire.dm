/datum/map_template/shuttle/voidcrew/spitfire
	name = "Spitfire-class Search and Rescue Vessel"
	suffix = "spitfire"
	short_name = "Spitfire-class"
	part_cost = 2

	job_slots = list(
		list(
			name = "Chief Medical Officer",
			officer = TRUE,
			outfit = /datum/outfit/job/cmo,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor,
			slots = 1,
		),
		list(
			name = "Paramedic",
			outfit = /datum/outfit/job/paramedic,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer,
			slots = 1,
		),
		list(
			name = "Shaft Miner",
			outfit = /datum/outfit/job/miner,
			slots = 1,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 1,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/spitfire
	name = "Spitfire-class Search and Rescue Vessel"
	area_type = /area/shuttle/voidcrew/spitfire
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/spitfire/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Cargo ///

/area/shuttle/voidcrew/spitfire/cargo_bay
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/area/shuttle/voidcrew/spitfire/cargo_bay/production
	name = "Production"
	icon_state = "station"

/// Medbay ///

/area/shuttle/voidcrew/spitfire/medbay
	name = "Medbay"
	icon_state = "medbay"

/area/shuttle/voidcrew/spitfire/medbay/operating
	name = "Operating Theatre"
	icon_state = "med_central"

/// Service ///

/area/shuttle/voidcrew/spitfire/dormitories
	name = "Dormitories"
	icon_state = "dorms"

/// Hallway ///

/area/shuttle/voidcrew/spitfire/hallway
	name = "Central Hallway"
	icon_state = "hall"

/// Maintenance ///

/area/shuttle/voidcrew/spitfire/maintenance
	name = "Maintenance"
	icon_state = "centralmaint"
