
/datum/design/board/clonecontrol	//hippie start, re-add cloning
	name = "Computer Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	build_path = /obj/item/circuitboard/computer/cloning
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags =  DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE


/datum/design/board/clonepod
	name = "Machine Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	build_path = /obj/item/circuitboard/machine/clonepod
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags =  DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/clonepod_experimental
	name = "Machine Design (Experimental Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build an Experimental Cloning Pod."
	id = "clonepod_experimental"
	build_path = /obj/item/circuitboard/machine/clonepod/experimental
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE


/datum/design/board/clonescanner	//hippie end, re-add cloning
	name = "Machine Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	build_path = /obj/item/circuitboard/machine/clonescanner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags =  DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_chamber
	name = "Machine Design (Nanite Chamber Board)"
	desc = "The circuit board for a Nanite Chamber."
	id = "nanite_chamber"
	build_path = /obj/item/circuitboard/machine/nanite_chamber
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/public_nanite_chamber
	name = "Machine Design (Public Nanite Chamber Board)"
	desc = "The circuit board for a Public Nanite Chamber."
	id = "public_nanite_chamber"
	build_path = /obj/item/circuitboard/machine/public_nanite_chamber
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_programmer
	name = "Machine Design (Nanite Programmer Board)"
	desc = "The circuit board for a Nanite Programmer."
	id = "nanite_programmer"
	build_path = /obj/item/circuitboard/machine/nanite_programmer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_program_hub
	name = "Machine Design (Nanite Program Hub Board)"
	desc = "The circuit board for a Nanite Program Hub."
	id = "nanite_program_hub"
	build_path = /obj/item/circuitboard/machine/nanite_program_hub
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE
