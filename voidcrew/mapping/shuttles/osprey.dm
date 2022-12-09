/datum/map_template/shuttle/voidcrew/osprey
	name = "Osprey-class Exploration Ship"
	suffix = "osprey"
	short_name = "Osprey-Class"
	part_cost = 3

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "First Officer",
			outfit = /datum/outfit/job/hop,
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
			name = "Scientist",
			outfit = /datum/outfit/job/scientist,
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
			name = "Quartermaster",
			outfit = /datum/outfit/job/quartermaster,
			slots = 1,
		),
		list(
			name = "Cargo Technician",
			outfit = /datum/outfit/job/cargo_tech,
			slots = 1,
		),
		list(
			name = "Shaft Miner",
			outfit = /datum/outfit/job/miner,
			slots = 1,
		),
		list(
			name = "Cook",
			outfit = /datum/outfit/job/cook,
			slots = 1,
		),
		list(
			name = "Janitor",
			outfit = /datum/outfit/job/janitor,
			slots = 1,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 5,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/osprey
	name = "Osprey-Class Exploration Ship"
	area_type = /area/shuttle/voidcrew/osprey
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Engineering ///
/area/shuttle/voidcrew/osprey/engineering
	name = "Engineering"
	icon_state = "engine"

/area/shuttle/voidcrew/osprey/engineering/atmospherics
	name = "Atmospherics"
	icon_state = "atmos"

/// Research ///

/area/shuttle/voidcrew/osprey/research
	name = "Research"
	icon_state = "research"

/area/shuttle/voidcrew/osprey/research/robotics
	name = "Robotics"
	icon_state = "robotics"

/// Cargo ///

/area/shuttle/voidcrew/osprey/cargo
	name = "Cargo Office"
	icon_state = "cargo_office"

/area/shuttle/voidcrew/osprey/cargo/warehouse
	name = "Warehouse"
	icon_state = "cargo_warehouse"

/area/shuttle/voidcrew/osprey/cargo/quartermaster
	name = "Quartermaster's Office"
	icon_state = "qm_office"

/area/shuttle/voidcrew/osprey/cargo/mining_dock
	name = "Mining Dock"
	icon_state = "mining_dock"

/// Medbay ///

/area/shuttle/voidcrew/osprey/medbay
	name = "Medbay"
	icon_state = "medbay"

/area/shuttle/voidcrew/osprey/medbay/lobby
	name = "Medbay Lobby"
	icon_state = "med_lobby"

/// Service ///

/area/shuttle/voidcrew/osprey/service/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/shuttle/voidcrew/osprey/service/janitor
	name = "Custodial Closet"
	icon_state = "janitor"

/area/shuttle/voidcrew/osprey/service/dormitories
	name = "Dormitories"
	icon_state = "dorms"

/// Command ///

/area/shuttle/voidcrew/osprey/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Hallways ///

/area/shuttle/voidcrew/osprey/hallway/central
	name = "Central Hallway"
	icon_state = "centralhall"

/area/shuttle/voidcrew/osprey/hallway/aft
	name = "Aft Hallway"
	icon_state = "afthall"

/area/shuttle/voidcrew/osprey/hallway/port
	name = "Port Hallway"
	icon_state = "porthall"

/area/shuttle/voidcrew/osprey/hallway/starboard
	name = "Starboard Hallway"
	icon_state = "starboardhall"

/// Maintenance ///

/area/shuttle/voidcrew/osprey/maintenance/port
	name = "Port Maintenance"
	icon_state = "portmaint"

/area/shuttle/voidcrew/osprey/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "starboardmaint"
