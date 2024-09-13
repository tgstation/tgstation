/datum/design/board/shuttle/flight_control
	name = "Computer Design (Shuttle Flight Controls)"
	desc = "Allows for the construction of circuit boards used to build a console that enables shuttle flight"
	id = "shuttle_control"
	build_path = /obj/item/circuitboard/computer/shuttle/flight_control
	category = list("Computer Boards", "Shuttle Machinery")
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/shuttle/shuttle_docker
	name = "Computer Design (Shuttle Navigation Computer)"
	desc = "Allows for the construction of circuit boards used to build a console that enables the targetting of custom flight locations"
	id = "shuttle_docker"
	build_path = /obj/item/circuitboard/computer/shuttle/docker
	category = list("Computer Boards", "Shuttle Machinery")
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/shuttlecreator
	name = "Rapid Shuttle Designator"
	desc = "An advanced device capable of defining areas for use in the creation of shuttles"
	id = "shuttle_creator"
	build_path = /obj/item/shuttle_creator
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 500, /datum/material/bluespace = 100)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
