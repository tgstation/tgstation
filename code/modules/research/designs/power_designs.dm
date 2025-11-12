////////////////////////////////////////
//////////////////Power/////////////////
////////////////////////////////////////

/datum/design/basic_cell
	name = "Basic Power Cell"
	desc = "A basic power cell that holds 10 KW of energy."
	id = "basic_cell"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE |MECHFAB
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7, /datum/material/glass =SMALL_MATERIAL_AMOUNT * 0.5)
	build_path = /obj/item/stock_parts/power_store/cell/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "A power cell that holds 100 KW of energy."
	id = "high_cell"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE | MECHFAB
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.6)
	build_path = /obj/item/stock_parts/power_store/cell/high/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "A power cell that holds 200 KW of energy."
	id = "super_cell"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.7)
	build_path = /obj/item/stock_parts/power_store/cell/super/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_2
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "A power cell that holds 300 KW of energy."
	id = "hyper_cell"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 1.5, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 1.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.8)
	build_path = /obj/item/stock_parts/power_store/cell/hyper/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_3
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/bluespace_cell
	name = "Bluespace Power Cell"
	desc = "A power cell that holds 400 KW of energy."
	id = "bluespace_cell"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 1.2, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 1.6, /datum/material/diamond = SMALL_MATERIAL_AMOUNT * 1.6, /datum/material/titanium =SMALL_MATERIAL_AMOUNT * 3, /datum/material/bluespace =SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/stock_parts/power_store/cell/bluespace/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_4
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/basic_battery
	name = "Basic Megacell"
	desc = "A basic megacell that holds 1 MJ of energy."
	id = "basic_battery"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE |MECHFAB
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 12, /datum/material/glass =SMALL_MATERIAL_AMOUNT * 2)
	construction_time = 5 SECONDS
	build_path = /obj/item/stock_parts/power_store/battery/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/high_battery
	name = "High-Capacity Megacell"
	desc = "A megacell that holds 10 MJ of energy."
	id = "high_battery"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE | MECHFAB
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 12, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 3)
	construction_time = 5 SECONDS
	build_path = /obj/item/stock_parts/power_store/battery/high/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_2
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/super_battery
	name = "Super-Capacity Megacell"
	desc = "A megacell that holds 20 MJ of energy."
	id = "super_battery"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 12, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 4)
	construction_time = 5 SECONDS
	build_path = /obj/item/stock_parts/power_store/battery/super/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_3
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/hyper_battery
	name = "Hyper-Capacity Megacell"
	desc = "A megacell that holds 30 MJ of energy."
	id = "hyper_battery"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 12, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 1.5, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 1.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 5)
	construction_time = 5 SECONDS
	build_path = /obj/item/stock_parts/power_store/battery/hyper/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_3
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/bluespace_battery
	name = "Bluespace Megacell"
	desc = "A megacell that holds 40 MJ of energy."
	id = "bluespace_battery"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 12, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 1.2, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 6, /datum/material/diamond = SMALL_MATERIAL_AMOUNT * 1.6, /datum/material/titanium =SMALL_MATERIAL_AMOUNT * 3, /datum/material/bluespace =SMALL_MATERIAL_AMOUNT)
	construction_time = 5 SECONDS
	build_path = /obj/item/stock_parts/power_store/battery/bluespace/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_4
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING


/datum/design/inducer
	name = "Inducer"
	desc = "The NT-75 Electromagnetic Power Inducer can wirelessly induce electric charge in an object, allowing you to recharge power cells without having to remove them."
	id = "inducer"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/inducer/sci
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/inducerengi
	name = "Inducer"
	desc = "The NT-75 Electromagnetic Power Inducer can wirelessly induce electric charge in an object, allowing you to recharge power cells without having to remove them."
	id = "inducerengi"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/inducer/empty
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/pacman
	name = "PACMAN Board"
	desc = "The circuit board for a PACMAN-type portable generator."
	id = "pacman"
	build_path = /obj/item/circuitboard/machine/pacman
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/bioelec_gen
	name = "Aquarium Bioelectricity Kit"
	desc = "The required components to convert an aquarium into a bioelectricity generator."
	id = "bioelec_gen"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5, /datum/material/gold = SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/aquarium_upgrade/bioelec_gen
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/turbine_part_compressor
	name = "Turbine Compressor"
	desc = "The basic tier of a compressor blade."
	id = "turbine_part_compressor"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	build_path = /obj/item/turbine_parts/compressor
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_TURBINE
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/turbine_part_rotor
	name = "Turbine Rotor"
	desc = "The basic tier of a rotor shaft."
	id = "turbine_part_rotor"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	build_path = /obj/item/turbine_parts/rotor
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_TURBINE
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/turbine_part_stator
	name = "Turbine Stator"
	desc = "The basic tier of a stator."
	id = "turbine_part_stator"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	build_path = /obj/item/turbine_parts/stator
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_TURBINE
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/diode_disk_stamina
	name = "Electrodisruptive Diode Disk"
	desc = "A stamina damaging and supermatter crystal healing Diode Disk."
	id = "diode_disk_stamina"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass =SMALL_MATERIAL_AMOUNT, /datum/material/gold =SMALL_MATERIAL_AMOUNT)
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/stamina
	category = list(
		RND_CATEGORY_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/diode_disk_healing
	name = "Bioregenerative Diode Disk"
	desc = "A living creature healing Diode Disk."
	id = "diode_disk_healing"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass =SMALL_MATERIAL_AMOUNT, /datum/material/silver =SMALL_MATERIAL_AMOUNT) //silver is medical metal. Why? who knows.
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/healing
	category = list(
		RND_CATEGORY_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/diode_disk_incendiary
	name = "Conflagratory Diode Disk"
	desc = "A high energy incendiary Diode Disk."
	id = "diode_disk_incendiary"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass =SMALL_MATERIAL_AMOUNT, /datum/material/diamond =SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/plasma =SMALL_MATERIAL_AMOUNT * 2)
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/incendiary
	category = list(
		RND_CATEGORY_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/diode_disk_sanity
	name = "Psychosiphoning Diode Disk"
	desc = "An supermatter comforting creature depressing Diode Disk."
	id = "diode_disk_sanity"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass =SMALL_MATERIAL_AMOUNT, /datum/material/uranium =SMALL_MATERIAL_AMOUNT * 0.5) //Uranium, the metal of love and warmth (from decay heat).
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/sanity
	category = list(
		RND_CATEGORY_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/diode_disk_magnetic
	name = "Magnetogenerative Diode Disk"
	desc = "A mol absorbing item attracting Diode Disk."
	id = "diode_disk_magnetic"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass =SMALL_MATERIAL_AMOUNT, /datum/material/titanium =SMALL_MATERIAL_AMOUNT * 0.5)
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/magnetic
	category = list(
		RND_CATEGORY_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
