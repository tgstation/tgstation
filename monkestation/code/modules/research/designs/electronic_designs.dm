/datum/design/nanite_remote
	name = "Nanite Remote"
	desc = "Allows for the construction of a nanite remote."
	id = "nanite_remote"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500)
	build_path = /obj/item/nanite_remote
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE

/datum/design/nanite_comm_remote
	name = "Nanite Communication Remote"
	desc = "Allows for the construction of a nanite communication remote."
	id = "nanite_comm_remote"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500)
	build_path = /obj/item/nanite_remote/comm
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE

/datum/design/nanite_scanner
	name = "Nanite Scanner"
	desc = "Allows for the construction of a nanite scanner."
	id = "nanite_scanner"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500)
	build_path = /obj/item/nanite_scanner
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE

/datum/design/nanite_disk
	name = "Nanite Program Disk"
	desc = "Stores nanite programs."
	id = "nanite_disk"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	build_path = /obj/item/disk/nanite_program
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE
