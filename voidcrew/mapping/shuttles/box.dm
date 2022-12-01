/datum/map_template/shuttle/voidcrew/box
	name = "Box-class Hospital Ship"
	suffix = "box"
	short_name = "Box-class"
	part_cost = 1

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
			slots = 3,
		),
		list(
			name = "Paramedic",
			outfit = /datum/outfit/job/paramedic,
			slots = 2,
		),
		list(
			name = "Assistant",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		),
	)

/obj/docking_port/mobile/voidcrew/box
	name = "Box-Class Hospital Ship"
	area_type = /area/shuttle/voidcrew/box
	callTime = 25 SECONDS
	dir = 2
	port_direction = 8
	preferred_direction = 4

/area/shuttle/voidcrew/box/engine
	name = "Engine"
	icon_state = "engie"

/area/shuttle/voidcrew/box/medbay
	name = "Medbay"
	icon_state = "medbay"

/area/shuttle/voidcrew/box/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/shuttle/voidcrew/box/crew_quarters
	name = "Crew Quarters"
	icon_state = "commons"

/area/shuttle/voidcrew/box/cargo
	name = "Cargo"
	icon_state = "quart"
