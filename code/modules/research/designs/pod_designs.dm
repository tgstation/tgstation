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
//RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
