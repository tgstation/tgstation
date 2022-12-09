/datum/map_template/shuttle/voidcrew/mechaton
	name = "Mechaton-class Robotics Production Facility"
	suffix = "mechaton"
	short_name = "Mechaton-Class"
	part_cost = 2

	job_slots = list(
		list(
			name = "Research Director",
			officer = TRUE,
			outfit = /datum/outfit/job/rd,
			slots = 1,
		),
		list(
			name = "Scientist",
			outfit = /datum/outfit/job/scientist,
			slots = 2,
		),
		list(
			name = "Roboticist",
			outfit = /datum/outfit/job/roboticist,
			slots = 2,
		),
		list(
			name = "Atmospheric Technician",
			outfit = /datum/outfit/job/atmos,
			slots = 1,
		),
		list(
			name = "Geneticist",
			outfit = /datum/outfit/job/geneticist,
			slots = 2,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/mechaton
	name = "Mechaton-class Robotics Production Facility"
	area_type = /area/shuttle/voidcrew/mechaton
	port_direction = 8
	preferred_direction = 4


/// AREAS ///

/// Command ///
/area/shuttle/voidcrew/mechaton/bridge
	name = "Bridge"
	icon_state = "bridge"

/// Cargo ///

/area/shuttle/voidcrew/mechaton/mining
	name = "Mining Dock"
	icon_state = "mining"

/// Engineering ///

/area/shuttle/voidcrew/mechaton/engineering
	name = "Engineering"
	icon_state = "engine"

/// Science ///

/area/shuttle/voidcrew/mechaton/robotics
	name = "Robotics"
	icon_state = "ass_line"

/// Hallways ///

/area/shuttle/voidcrew/mechaton/concourse
	name = "Concourse"
	icon_state = "hall"
