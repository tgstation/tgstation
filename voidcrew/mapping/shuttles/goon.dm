/datum/map_template/shuttle/voidcrew/goon
	name = "Goon-class Repurposed Emergency Shuttle"
	suffix = "goon"
	short_name = "Goon-class"
	part_cost = 2

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Shaft Miner",
			outfit = /datum/outfit/job/miner,
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
			slots = 1,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/goon // Brewing up something awful here
	name = "Goon-class Repurposed Emergency Shuttle"
	area_type = /area/shuttle/voidcrew/goon


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/goon/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Engineering ///

/area/shuttle/voidcrew/goon/engineering
	name = "Engineering"
	icon_state = "engine"

/// Medbay ///

/area/shuttle/voidcrew/goon/medbay
	name = "Medbay"
	icon_state = "medbay"

/// Misc ///

/area/shuttle/voidcrew/goon/commons
	name = "Commons"
	icon_state = "station"
