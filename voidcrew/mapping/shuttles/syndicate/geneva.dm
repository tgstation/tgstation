/datum/map_template/shuttle/voidcrew/geneva
	name = "Geneva-class Search and Rescue Vessel"
	suffix = "syndicate_geneva"
	short_name = "Geneva-class"
	faction_prefix = SYNDICATE_SHIP
	part_cost = 3

	job_slots = list(
		list(
			name = "Chief Medical Officer",
			officer = TRUE,
			outfit = /datum/outfit/job/cmo/syndicate,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor/syndicate,
			slots = 2,
		),
		list(
			name = "Botanist",
			outfit = /datum/outfit/job/botanist/syndicate,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer/syndicate,
			slots = 2,
		),
		list(
			name = "Rescue Specialist",
			outfit = /datum/outfit/job/miner/syndicate,
			slots = 2,
		),
		list(
			name = "Paramedic",
			outfit = /datum/outfit/job/paramedic/syndicate/gorlex,
			slots = 1,
		),
	)


/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/geneva
	name = "Geneva-class Search and Rescue Vessel"
	area_type = /area/shuttle/voidcrew/geneva
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///

/area/shuttle/voidcrew/geneva/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/shuttle/voidcrew/geneva/bridge/cmo
	name = "Chief Medical Officer's Office"
	icon_state = "cmo_office"

/// Engineering ///

/area/shuttle/voidcrew/geneva/engineering
	name = "Engineering Wing"
	icon_state = "engine"

/// Cargo ///

/area/shuttle/voidcrew/geneva/cargo_bay
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/// Medbay ///

/area/shuttle/voidcrew/geneva/medbay
	name = "Medbay Central"
	icon_state = "medbay"

/area/shuttle/voidcrew/geneva/medbay/operating
	name = "Operating Theatre"
	icon_state = "exam_room"

/area/shuttle/voidcrew/geneva/medbay/paramedic
	name = "Paramedic's Quarters"
	icon_state = "paramedic"

/// Service ///

/area/shuttle/voidcrew/geneva/breakroom
	name = "Breakroom"
	icon_state = "station"

/area/shuttle/voidcrew/geneva/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"

/area/shuttle/voidcrew/geneva/dorms
	name = "Dormitories"
	icon_state = "dorms"
