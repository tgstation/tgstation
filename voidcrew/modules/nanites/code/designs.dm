/datum/design/nanite_remote
	name = "Nanite Remote"
	desc = "Allows for the construction of a nanite remote."
	id = "nanite_remote"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500)
	build_path = /obj/item/nanite_remote
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_ELECTRONICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/nanite_comm_remote
	name = "Nanite Communication Remote"
	desc = "Allows for the construction of a nanite communication remote."
	id = "nanite_comm_remote"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500)
	build_path = /obj/item/nanite_remote/comm
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_ELECTRONICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/nanite_scanner
	name = "Nanite Scanner"
	desc = "Allows for the construction of a nanite scanner."
	id = "nanite_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500)
	build_path = /obj/item/nanite_scanner
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_ELECTRONICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/nanite_disk
	name = "Nanite Program Disk"
	desc = "Stores nanite programs."
	id = "nanite_disk"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	build_path = /obj/item/disk/nanite_program
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_ELECTRONICS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_chamber
	name = "Machine Design (Nanite Chamber Board)"
	desc = "The circuit board for a Nanite Chamber."
	id = "nanite_chamber"
	build_path = /obj/item/circuitboard/machine/nanite_chamber
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/public_nanite_chamber
	name = "Machine Design (Public Nanite Chamber Board)"
	desc = "The circuit board for a Public Nanite Chamber."
	id = "public_nanite_chamber"
	build_path = /obj/item/circuitboard/machine/public_nanite_chamber
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_programmer
	name = "Machine Design (Nanite Programmer Board)"
	desc = "The circuit board for a Nanite Programmer."
	id = "nanite_programmer"
	build_path = /obj/item/circuitboard/machine/nanite_programmer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_program_hub
	name = "Machine Design (Nanite Program Hub Board)"
	desc = "The circuit board for a Nanite Program Hub."
	id = "nanite_program_hub"
	build_path = /obj/item/circuitboard/machine/nanite_program_hub
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
