
/datum/design/board/clonecontrol	//hippie start, re-add cloning
	name = "Computer Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	build_path = /obj/item/circuitboard/computer/cloning
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags =  DEPARTMENT_BITFLAG_MEDICAL


/datum/design/board/clonepod
	name = "Machine Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	build_path = /obj/item/circuitboard/machine/clonepod
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags =  DEPARTMENT_BITFLAG_MEDICAL


/datum/design/board/clonescanner	//hippie end, re-add cloning
	name = "Machine Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	build_path = /obj/item/circuitboard/machine/clonescanner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags =  DEPARTMENT_BITFLAG_MEDICAL
