/datum/design/board/incubator
	name = "Dish Incubator Board"
	desc = "The circuit board for a Dish Incubator."
	id = "incubator"
	build_path = /obj/item/circuitboard/machine/incubator
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/analyzer
	name = "Disease Analyzer Board"
	desc = "The circuit board for a Disease Analyzer."
	id = "diseaseanalyzer"
	build_path = /obj/item/circuitboard/machine/diseaseanalyser
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/centrifuge
	name = "Centrifuge Board"
	desc = "The circuit board for a Centrifuge."
	id = "centrifuge"
	build_path = /obj/item/circuitboard/machine/centrifuge
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/board/diseasesplicer
	name = "Disease Splicer Board"
	desc = "The circuit board for a Disease Splicer."
	id = "diseasesplicer"
	build_path = /obj/item/circuitboard/computer/diseasesplicer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL
