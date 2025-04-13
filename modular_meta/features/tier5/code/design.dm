/datum/design/noneuclid_capacitor
	name = "Noneuclid Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "noneuclid_capacitor"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 2, /datum/material/glass =SMALL_MATERIAL_AMOUNT * 2, /datum/material/gold =SMALL_MATERIAL_AMOUNT, /datum/material/diamond =SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/stock_parts/capacitor/noneuclid
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/noneuclid_scanning
	name = "Noneuclid Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "noneuclid_scanning"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 2, /datum/material/glass =SMALL_MATERIAL_AMOUNT * 2, /datum/material/diamond = SMALL_MATERIAL_AMOUNT*0.3, /datum/material/bluespace = SMALL_MATERIAL_AMOUNT*0.5)
	build_path = /obj/item/stock_parts/scanning_module/noneuclid
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/noneuclid_servo
	name = "Noneuclid Servo"
	desc = "A stock part used in the construction of various devices."
	id = "noneuclid_servo"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 2, /datum/material/diamond = SMALL_MATERIAL_AMOUNT*0.3, /datum/material/titanium = SMALL_MATERIAL_AMOUNT*0.3)
	build_path = /obj/item/stock_parts/servo/noneuclid
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/noneuclid_micro_laser
	name = "Noneuclid Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "noneuclid_micro_laser"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 2, /datum/material/glass =SMALL_MATERIAL_AMOUNT * 2, /datum/material/uranium =SMALL_MATERIAL_AMOUNT, /datum/material/diamond = SMALL_MATERIAL_AMOUNT*0.6)
	build_path = /obj/item/stock_parts/micro_laser/noneuclid
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/noneuclid_matter_bin
	name = "Noneuclid Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "noneuclid_matter_bin"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*2.5, /datum/material/diamond =SMALL_MATERIAL_AMOUNT, /datum/material/bluespace =SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/stock_parts/matter_bin/noneuclid
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/void_core
	name = "Void Core"
	desc = "An alien power cell that produces energy seemingly out of nowhere."
	id = "void_core"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 12, /datum/material/gold = SHEET_MATERIAL_AMOUNT * 12, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 6, /datum/material/diamond = SHEET_MATERIAL_AMOUNT * 16, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 30, /datum/material/bluespace = SHEET_MATERIAL_AMOUNT*5)
	build_path = /obj/item/stock_parts/power_store/cell/infinite/abductor
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 10 SECONDS
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/techweb_node/parts_noneuclid
	id = TECHWEB_NODE_PARTS_NONEUCLID
	display_name = "Noneuclid Parts"
	description = "By reverse engineering alien technology, we were able to improve the bluespace parts, which undoubtedly opens up new (as yet unknown to us) frontiers of scientific discovery."
	prereq_ids = list(TECHWEB_NODE_PARTS_BLUESPACE, TECHWEB_NODE_ALIENTECH)
	design_ids = list(
		"noneuclid_capacitor",
		"noneuclid_scanning",
		"noneuclid_servo",
		"noneuclid_micro_laser",
		"noneuclid_matter_bin",
		"void_core",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier4_any = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)
