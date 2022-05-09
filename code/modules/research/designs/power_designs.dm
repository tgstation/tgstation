////////////////////////////////////////
//////////////////Power/////////////////
////////////////////////////////////////

/datum/design/basic_cell
	name = "Basic Power Cell"
	desc = "A basic power cell that holds 1 MJ of energy."
	id = "basic_cell"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE |MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/glass = 50)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/empty
	category = list("Misc","Power Designs","Machinery","initial")

/datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "A power cell that holds 10 MJ of energy."
	id = "high_cell"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/glass = 60)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/high/empty
	category = list("Misc","Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "A power cell that holds 20 MJ of energy."
	id = "super_cell"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/glass = 70)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/super/empty
	category = list("Misc","Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "A power cell that holds 30 MJ of energy."
	id = "hyper_cell"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/gold = 150, /datum/material/silver = 150, /datum/material/glass = 80)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/hyper/empty
	category = list("Misc","Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/bluespace_cell
	name = "Bluespace Power Cell"
	desc = "A power cell that holds 40 MJ of energy."
	id = "bluespace_cell"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 800, /datum/material/gold = 120, /datum/material/glass = 160, /datum/material/diamond = 160, /datum/material/titanium = 300, /datum/material/bluespace = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/bluespace/empty
	category = list("Misc","Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/inducer
	name = "Inducer"
	desc = "The NT-75 Electromagnetic Power Inducer can wirelessly induce electric charge in an object, allowing you to recharge power cells without having to remove them."
	id = "inducer"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000)
	build_path = /obj/item/inducer/sci
	category = list("Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/pacman
	name = "Machine Design (PACMAN-type Generator Board)"
	desc = "The circuit board that for a PACMAN-type portable generator."
	id = "pacman"
	build_path = /obj/item/circuitboard/machine/pacman
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/turbine_part_compressor
	name = "Turbine Part - Compressor"
	desc = "The basic tier of a compressor blade."
	id = "turbine_part_compressor"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 500)
	construction_time = 100
	build_path = /obj/item/turbine_parts/compressor
	category = list("Misc","Power Designs","Machinery","initial")

/datum/design/turbine_part_rotor
	name = "Turbine Part - Rotor"
	desc = "The basic tier of a rotor shaft."
	id = "turbine_part_rotor"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 500)
	construction_time = 100
	build_path = /obj/item/turbine_parts/rotor
	category = list("Misc","Power Designs","Machinery","initial")

/datum/design/turbine_part_stator
	name = "Turbine Part - Stator"
	desc = "The basic tier of a stator."
	id = "turbine_part_stator"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 500)
	construction_time = 100
	build_path = /obj/item/turbine_parts/stator
	category = list("Misc","Power Designs","Machinery","initial")
