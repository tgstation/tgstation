/datum/map_template/shuttle/voidcrew/metis
	name = "Metis-class Experimental Extrasolar Pathfinder"
	suffix = "metis"
	short_name = "Metis-Class"
	part_cost = 2

	job_slots = list(
		list(
			name = "Extraterrestrial Exploratory Project Supervisor",
			officer = TRUE,
			outfit = /datum/outfit/job/rd,
			slots = 1,
		),
		list(
			name = "Invertebrate Xenofauna Morphology Analyst",
			outfit = /datum/outfit/job/scientist,
			slots = 4,
		),
		list(
			name = "Mechatronic Hydraulics Calibration Engineer",
			outfit = /datum/outfit/job/roboticist,
			slots = 1,
		),
		list(
			name = "Ionic Dynamo Engineer",
			outfit = /datum/outfit/job/engineer,
			slots = 1,
		),
		list(
			name = "Percussive Acquisitions-Focused Minerologist",
			outfit = /datum/outfit/job/miner,
			slots = 2,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/metis
	name = "Metis-class Experimental Extrasolar Pathfinder"
	area_type = /area/shuttle/voidcrew/metis
	port_direction = 8
	preferred_direction = 1


/// AREAS ///

/// Command ///
/area/shuttle/voidcrew/metis/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/shuttle/voidcrew/metis/eepsoffice
	name = "EEPS' Office"
	icon_state = "rd_office"

/area/shuttle/voidcrew/metis/ai_core
	name = "AI Core"
	icon_state = "ai"

/// Science ///

/area/shuttle/voidcrew/metis/science
	name = "Research Lab"
	icon_state = "science"

/area/shuttle/voidcrew/metis/science/nanites // INFINITELY funny that willard slapped a restroom area on this originally
	name = "Nanite Lab"
	icon_state = "station"

/area/shuttle/voidcrew/metis/science/robotics
	name = "Robotics Lab"
	icon_state = "ass_line"

/area/shuttle/voidcrew/metis/science/xenobiology
	name = "Xenobiology"
	icon_state = "xenobio"

/// Engineering ///

/area/shuttle/voidcrew/metis/engineering
	name = "Engineering"
	icon_state = "engine"

/// Service ///

/area/shuttle/voidcrew/metis/dorms
	name = "Dormitories"
	icon_state = "dorms"

/area/shuttle/voidcrew/metis/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/// Hallways ///

/area/shuttle/voidcrew/metis/hallway/fore
	name = "Fore Hallway"
	icon_state = "forehall"

/area/shuttle/voidcrew/metis/hallway/aft
	name = "Aft Hallway"
	icon_state = "afthall"

/// Maintenance ///

/area/shuttle/voidcrew/metis/maintenance
	name = "Maintenance"
	icon_state = "starboardmaint"
