/datum/design/board/bountypad
	name = "Machine Design (Civilian Bounty Pad)"
	desc = "The circuit board for a Civilian Bounty Pad."
	id = "bounty_pad"
	build_type = PROTOLATHE | IMPRINTER
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 300)
	build_path = /obj/item/circuitboard/machine/bountypad
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/electrolyzer
	name = "Machine Design (Electrolyzer Board)"
	desc = "The circuit board for an electrolyzer."
	id = "electrolyzer"
	build_path = /obj/item/circuitboard/machine/electrolyzer
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/crystallizer
	name = "Machine Design (Crystallizer)"
	desc = "The circuit board for a crystallizer."
	id = "crystallizer"
	build_path = /obj/item/circuitboard/machine/crystallizer
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/atmos_machine
	name = "Machine Design (Evaporation Machine)"
	desc = "The circuit board for a evaporation machine."
	id = "evaporation_machine"
	build_path = /obj/item/circuitboard/machine/atmos_machine
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
