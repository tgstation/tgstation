/datum/map_template/shuttle/voidcrew/bogardee_b
	name = "Boyardee-Class Type B Entertainement Vessel"
	suffix = "boyardee_b"
	short_name = "Boyardee-class (B)"
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
			name = "Security Officer",
			outfit = /datum/outfit/job/security,
			slots = 2,
		),
	)


/// DOCKING PORT ///

/obj/docking_port/mobile/voidcrew/bogardee_b
	name = "Boyardee-Class Type B Entertainement Vessel"
	area_type = /area/shuttle/voidcrew/bogardee_b
	port_direction = 2
	preferred_direction = 4

/// AREAS ///

/// Cargo ///

/area/shuttle/voidcrew/bogardee_b/cargo
	name = "Cargo Bay"
	icon_state = "cargo_bay"

/area/shuttle/voidcrew/bogardee_b/cargo/vault
	name = "Vault"
	icon_state = "nuke_storage"

/// Security ///

/area/shuttle/voidcrew/bogardee_b/armory
	name = "Armory"
	icon_state = "armory"

/// Medbay ///

/area/shuttle/voidcrew/bogardee_b/medbay
	name = "Medbay"
	icon_state = "medbay"

/// Service ///

/area/shuttle/voidcrew/bogardee_b/service/kitchen
	name = "Kitchen-Bridge"
	icon_state = "kitchen"

/area/shuttle/voidcrew/bogardee_b/service/quarters
	name = "Service Quarters"
	icon_state = "dorms"

/area/shuttle/voidcrew/bogardee_b/service/bar
	name = "Bar"
	icon_state = "bar"

/area/shuttle/voidcrew/bogardee_b/service/bar/backroom
	name = "Bar Backroom"
	icon_state = "bar_backroom"

/area/shuttle/voidcrew/bogardee_b/service/restroom
	name = "Restroom"
	icon_state = "restrooms"

/area/shuttle/voidcrew/bogardee_b/service/entrance
	name = "Reception"
	icon_state = "station"

/// Maintenance ///

/area/shuttle/voidcrew/bogardee_b/maintenance
	name = "Maintenance"
	icon_state = "maint_bar"
