/datum/design/board/pod
	name = "Pod Control module"
	desc = "Needed to create space pods."
	id = "pod_board"
	build_path = /obj/item/circuitboard/pod
	category = list(
		RND_CATEGORY_SPACE_POD
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/pod_runner
	name = "Pod Frame Runner"
	id = "podrunner"
	build_type = MECHFAB
	build_path = /obj/item/pod_runner
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
	)
	construction_time = 15 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_CHASSIS
	)

// equipment

//T1
/datum/design/pod_warpdrive
	name = "Bluespace Warp drive"
	id = "podwarpdrive"
	build_type = MECHFAB
	build_path = /obj/item/pod_equipment/warp_drive
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*6,
		/datum/material/bluespace=SHEET_MATERIAL_AMOUNT*2,
		/datum/material/gold=SHEET_MATERIAL_AMOUNT/2,
	)
	construction_time = 7 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_MISC
	)

/datum/design/pod_thrusters
	name = "Pod Ion Thruster Array"
	id = "podthruster1"
	build_type = MECHFAB
	build_path = /obj/item/pod_equipment/thrusters/default
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*8,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*12,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*5,
	)
	construction_time = 7 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_THRUSTERS
	)

/datum/design/pod_enginelight
	name = "Light Ion Engine"
	id = "podengine1"
	build_type = MECHFAB
	build_path = /obj/item/pod_equipment/engine/light
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*8,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*2,
		/datum/material/uranium=SHEET_MATERIAL_AMOUNT*2,
	)
	construction_time = 7 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_ENGINE
	)

/datum/design/pod_engine
	name = "Ion Engine"
	id = "podengine2"
	build_type = MECHFAB
	build_path = /obj/item/pod_equipment/engine/default
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*13,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*5,
		/datum/material/uranium=SHEET_MATERIAL_AMOUNT*4,
	)
	construction_time = 7 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_ENGINE
	)

/datum/design/podsensors
	name = /obj/item/pod_equipment/sensors::name
	id = "podsensors"
	build_type = MECHFAB
	build_path = /obj/item/pod_equipment/sensors
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*3,
		/datum/material/uranium=SHEET_MATERIAL_AMOUNT*2,
	)
	construction_time = 5 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SENSORS
	)


/datum/design/podcargohold
	name = /obj/item/pod_equipment/cargo_hold::name
	id = "podcargohold"
	build_type = MECHFAB
	build_path = /obj/item/pod_equipment/cargo_hold
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*6,
	)
	construction_time = 5 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SECONDARY
	)

/datum/design/podextraseats
	name = /obj/item/pod_equipment/extra_seats::name
	id = "podextraseats"
	build_type = MECHFAB
	build_path = /obj/item/pod_equipment/extra_seats
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*3,
	)
	construction_time = 5 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SECONDARY
	)
