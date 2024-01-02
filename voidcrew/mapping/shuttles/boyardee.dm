/datum/map_template/shuttle/voidcrew/bogardee
	name = "Boyardee-Class Type Entertainement Vessel"
	suffix = "boyardee"
	short_name = "Boyardee-class"
	part_cost = 1

	job_slots = list(
		list(
			name = "Clown",
			officer = TRUE,
			outfit = /datum/outfit/job/clown,
			slots = 1,
		),
		list(
			name = "Cook",
			outfit = /datum/outfit/job/cook,
			slots = 2,
		),
		list(
			name = "Bartender",
			outfit = /datum/outfit/job/bartender,
			slots = 1,
		),
		list(
			name = "Janitor",
			outfit = /datum/outfit/job/janitor,
			slots = 1,
		),
		list(
			name = "Botanist",
			outfit = /datum/outfit/job/botanist,
			slots = 2,
		),
	)

/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/bogardee // I'm not correcting this, it's funny.
	name = "Boyardee-Class Type Entertainement Vessel"
	area_type = /area/shuttle/voidcrew/bogardee
	port_direction = 2
	preferred_direction = 4

/// AREAS ///

/// Cargo ///

/area/shuttle/voidcrew/bogardee/cargo
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/// Service ///

/area/shuttle/voidcrew/bogardee/service/janitor
	name = "Custodial Closet"
	icon_state = "janitor"

/area/shuttle/voidcrew/bogardee/service/kitchen
	name = "Kitchen-Bridge"
	icon_state = "kitchen"

/area/shuttle/voidcrew/bogardee/service/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"

/area/shuttle/voidcrew/bogardee/service/hydroponics/chemistry
	name = "Botanical Chemistry"
	icon_state = "chem"

/area/shuttle/voidcrew/bogardee/service/coldroom
	name = "Coldroom"
	icon_state = "kitchen_cold"

/area/shuttle/voidcrew/bogardee/service/quarters
	name = "Service Quarters"
	icon_state = "dorms"

/area/shuttle/voidcrew/bogardee/service/bar
	name = "Bar"
	icon_state = "bar"

/area/shuttle/voidcrew/bogardee/service/restroom
	name = "Restroom"
	icon_state = "restrooms"

/area/shuttle/voidcrew/bogardee/service/entrance
	name = "Reception"
	icon_state = "station"

/// Maintenance ///

/area/shuttle/voidcrew/bogardee/maintenance
	name = "Maintenance"
	icon_state = "maint_bar"
