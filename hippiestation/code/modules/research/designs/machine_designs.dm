/datum/design/board/clonecontrol	//hippie start, re-add cloning
	name = "Computer Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	build_path = /obj/item/circuitboard/computer/cloning
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	category = list("Medical Machinery")

/datum/design/board/clonepod
	name = "Machine Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	build_path = /obj/item/circuitboard/machine/clonepod
	category = list("Medical Machinery")

/datum/design/board/clonescanner	//hippie end, re-add cloning
	name = "Machine Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	build_path = /obj/item/circuitboard/machine/clonescanner
	category = list("Medical Machinery")
