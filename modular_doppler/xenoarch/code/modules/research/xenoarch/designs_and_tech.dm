#define RND_SUBCATEGORY_MACHINE_XENOARCH "/Xenoarchaeology Machinery"
#define RND_SUBCATEGORY_EQUIPMENT_XENOARCH "/Xenoarchaeology Equipment"
#define RND_SUBCATEGORY_TOOLS_XENOARCH "/Xenoarchaeology Tools"
#define RND_SUBCATEGORY_TOOLS_XENOARCH_ADVANCED "/Xenoarchaeology Tools (Advanced)"

/datum/design/xenoarch
	build_type = PROTOLATHE | AWAY_LATHE
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_CARGO
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
	)

/datum/design/xenoarch/tool
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_XENOARCH,
	)

/datum/design/xenoarch/tool/hammer
	desc = "A hammer that can slowly remove debris on strange rocks."

/datum/design/xenoarch/tool/hammer/cm1
	name = "Hammer (cm 1)"
	id = "hammer_cm1"
	build_path = /obj/item/xenoarch/hammer/cm1

/datum/design/xenoarch/tool/hammer/cm2
	name = "Hammer (cm 2)"
	id = "hammer_cm2"
	build_path = /obj/item/xenoarch/hammer/cm2

/datum/design/xenoarch/tool/hammer/cm3
	name = "Hammer (cm 3)"
	id = "hammer_cm3"
	build_path = /obj/item/xenoarch/hammer/cm3

/datum/design/xenoarch/tool/hammer/cm4
	name = "Hammer (cm 4)"
	id = "hammer_cm4"
	build_path = /obj/item/xenoarch/hammer/cm4

/datum/design/xenoarch/tool/hammer/cm5
	name = "Hammer (cm 5)"
	id = "hammer_cm5"
	build_path = /obj/item/xenoarch/hammer/cm5

/datum/design/xenoarch/tool/hammer/cm6
	name = "Hammer (cm 6)"
	id = "hammer_cm6"
	build_path = /obj/item/xenoarch/hammer/cm6

/datum/design/xenoarch/tool/hammer/cm10
	name = "Hammer (cm 10)"
	id = "hammer_cm10"
	build_path = /obj/item/xenoarch/hammer/cm10

/datum/design/xenoarch/tool/brush
	name = "Brush"
	desc = "A brush that can slowly remove debris on a strange rock."
	id = "xenoarch_brush"
	build_path = /obj/item/xenoarch/brush

/datum/design/xenoarch/tool/xeno_tape
	name = "Xenoarch Tape Measure"
	desc = "A tape measure used to measure the dug depth of strange rocks."
	id = "xenoarch_tapemeasure"
	build_path = /obj/item/xenoarch/tape_measure

/datum/design/xenoarch/tool/scanner
	name = "Xenoarch Handheld Scanner"
	desc = "A handheld scanner for strange rocks, capable of tagging a \"safe\" depth and maximum depth."
	id = "xenoarch_handscanner"
	build_path = /obj/item/xenoarch/handheld_scanner

/datum/design/xenoarch/tool/advanced
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_XENOARCH_ADVANCED,
	)


/datum/design/xenoarch/tool/advanced/scanner
	name = "Xenoarch Advanced Handheld Scanner"
	id = "xenoarch_handscanner_adv"
	build_path = /obj/item/xenoarch/handheld_scanner/advanced

/datum/design/xenoarch/tool/advanced/recoverer
	name = "Xenoarch Handheld Recoverer"
	desc = "A device with the capabilities to recover items lost due to time."
	id = "xenoarch_handrecoverer"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
	)
	// rebalance material req after first repath/categorization?
	build_path = /obj/item/xenoarch/handheld_recoverer

/datum/design/xenoarch/tool/advanced/adv_hammer
	name = "Advanced Hammer"
	desc = "A hammer that can quickly remove debris on a strange rock and change digging depths."
	id = "xenoarch_adv_hammer"
	build_path = /obj/item/xenoarch/hammer/adv

/datum/design/xenoarch/tool/advanced/adv_brush
	name = "Advanced Brush"
	desc = "A brush that can quickly remove debris on a strange rock."
	id = "xenoarch_adv_brush"
	build_path = /obj/item/xenoarch/brush/adv

/datum/design/xenoarch/equipment
	// everything under this except the adv bag feels redundant because cloth/leather are there too
	// but i guess we'll burn that bridge another time
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_XENOARCH,
	)

/datum/design/xenoarch/equipment/bag
	name = "Xenoarchaeology Bag"
	desc = "A bag that can hold about twenty-five strange rocks."
	id = "xenoarch_bag"
	build_path = /obj/item/storage/bag/xenoarch

/datum/design/xenoarch/equipment/belt
	name = "Xenoarchaeology Belt"
	desc = "A belt that can hold all of the essential tools for xenoarchaeology."
	id = "xenoarch_belt"
	build_path = /obj/item/storage/belt/utility/xenoarch

/datum/design/xenoarch/equipment/bag_adv
	name = "Advanced Xenoarch Bag"
	desc = "A bag that can hold about fifty strange rocks."
	id = "xenoarch_bag_adv"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
	)
	// i kinda hate how this requires diamond, but this is supposed to be a fix pr, burn the gbp on it later
	build_path = /obj/item/storage/bag/xenoarch/adv

/datum/design/board/xenoarch
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_XENOARCH,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/xenoarch/researcher
	name = "Machine Design (Xenoarch Researcher)"
	desc = "Allows for the construction of circuit boards used to build a new xenoarch researcher."
	id = "xeno_researcher"
	build_path = /obj/item/circuitboard/machine/xenoarch_machine/xenoarch_researcher

/datum/design/board/xenoarch/scanner
	name = "Machine Design (Xenoarch Scanner)"
	desc = "Allows for the construction of circuit boards used to build a new xenoarch scanner."
	id = "xeno_scanner"
	build_path = /obj/item/circuitboard/machine/xenoarch_machine/xenoarch_scanner

/datum/design/board/xenoarch/recoverer
	name = "Machine Design (Xenoarch Recoverer)"
	desc = "Allows for the construction of circuit boards used to build a new xenoarch recoverer."
	id = "xeno_recoverer"
	build_path = /obj/item/circuitboard/machine/xenoarch_machine/xenoarch_recoverer

/datum/design/board/xenoarch/digger
	name = "Machine Design (Xenoarch Digger)"
	desc = "Allows for the construction of circuit boards used to build a new xenoarch digger."
	id = "xeno_digger"
	build_path = /obj/item/circuitboard/machine/xenoarch_machine/xenoarch_digger

/datum/techweb_node/basic_xenoarch
	id = TECHWEB_NODE_XENOARCH_BASIC
	starting_node = TRUE
	display_name = "Basic Xenoarchaeology"
	description = "The basic designs of xenoarchaeology."
	design_ids = list(
		"hammer_cm1",
		"hammer_cm2",
		"hammer_cm3",
		"hammer_cm4",
		"hammer_cm5",
		"hammer_cm6",
		"hammer_cm10",
		"xenoarch_brush",
		"xenoarch_tapemeasure",
		"xenoarch_handscanner",
	)

/datum/techweb_node/xenoarch_storage
	id = TECHWEB_NODE_XENOARCH_STORAGE
	display_name = "Xenoarchaeology Storage"
	description = "When dealing with xenoarchaeology, one may need storage."
	prereq_ids = list(TECHWEB_NODE_XENOARCH_BASIC)
	design_ids = list(
		"xenoarch_belt",
		"xenoarch_bag",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/xenoarch_machines
	id = TECHWEB_NODE_XENOARCH_MACHINES
	display_name = "Xenoarchaeology Machines"
	description = "Sometimes, xenoarchaeology can be time consuming, perhaps machines can help?"
	prereq_ids = list(TECHWEB_NODE_XENOARCH_BASIC)
	design_ids = list(
		"xeno_researcher",
		"xeno_scanner",
		"xeno_recoverer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_xenoarch
	id = TECHWEB_NODE_XENOARCH_ADVANCED
	display_name = "Advanced Xenoarchaeology"
	description = "After some time, those tools we used have become antiquated-- we need an upgrade."
	prereq_ids = list(TECHWEB_NODE_XENOARCH_BASIC, TECHWEB_NODE_XENOARCH_MACHINES, TECHWEB_NODE_XENOARCH_STORAGE)
	design_ids = list(
		"xenoarch_adv_hammer",
		"xenoarch_adv_brush",
		"xenoarch_bag_adv",
		"xenoarch_handscanner_adv",
		"xenoarch_handrecoverer",
		"xeno_digger",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	required_experiments = list(/datum/experiment/scanning/points/xenoarch)

/datum/experiment/scanning/points/xenoarch
	name = "Advanced Xenoarchaeology Tools"
	description = "It is possible to create even more advanced tools for xenoarchaeoloy."
	required_points = 10
	required_atoms = list(
		/obj/item/xenoarch/useless_relic = 1,
		/obj/item/xenoarch/broken_item = 2,
	)
