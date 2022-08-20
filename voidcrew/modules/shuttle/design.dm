/datum/design/board/engine_electric
	name = "Machine Design (Ion Thruster Board)"
	desc = "The circuit board for an ion thruster."
	id = "engine_ion"
	build_path = /obj/item/circuitboard/machine/shuttle/engine/electric
	category = list (RND_CATEGORY_COMPUTER_BOARDS)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/engine_void
	name = "Machine Design (Void Thruster Board)"
	desc = "The circuit board for a void thruster."
	id = "engine_void"
	build_path = /obj/item/circuitboard/machine/shuttle/engine/void
	category = list (RND_CATEGORY_COMPUTER_BOARDS)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/engine_plasma
	name = "Machine Design (Plasma Thruster Board)"
	desc = "The circuit board for a plasma thruster."
	id = "engine_plasma"
	build_path = /obj/item/circuitboard/machine/shuttle/engine/plasma
	category = list (RND_CATEGORY_COMPUTER_BOARDS)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/engine_expulsion
	name = "Machine Design (Expulsion Thruster Board)"
	desc = "The circuit board for an expulsion thruster."
	id = "engine_expulsion"
	build_path = /obj/item/circuitboard/machine/shuttle/engine/expulsion
	category = list (RND_CATEGORY_COMPUTER_BOARDS)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/shuttle/shuttle_helm
	name = "Computer Design (Shuttle Helm Console)"
	desc = "Allows for the construction of circuit boards used to pilot a spacecraft."
	id = "shuttle_helm"
	build_path = /obj/item/circuitboard/computer/shuttle/helm
	category = list(RND_CATEGORY_COMPUTER_BOARDS, RND_CATEGORY_EQUIPMENT)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE
