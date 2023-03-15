/datum/design/board/bountypad_control
	name = "Computer Design (Civilian Bounty Pad Control)"
	desc = "Allows for the construction of circuit boards used to build a new civilian bounty pad console."
	id = "bounty_pad_control"
	build_type = PROTOLATHE | IMPRINTER
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 300)
	build_path = /obj/item/circuitboard/computer/bountypad
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO
