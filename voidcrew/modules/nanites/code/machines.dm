/datum/design/board/nanite_chamber_control
	name = "Computer Design (Nanite Chamber Control)"
	desc = "Allows for the construction of circuit boards used to build a new nanite chamber control console."
	id = "nanite_chamber_control"
	build_path = /obj/item/circuitboard/computer/nanite_chamber_control
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_cloud_control
	name = "Computer Design (Nanite Cloud Control)"
	desc = "Allows for the construction of circuit boards used to build a new nanite cloud control console."
	id = "nanite_cloud_control"
	build_path = /obj/item/circuitboard/computer/nanite_cloud_controller
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
