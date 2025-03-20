///////SMELTABLE ALLOYS///////

/datum/design/plasteel_alloy
	name = "Пласталь"
	id = "plasteel"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/plasma = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasteel
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/plastitanium_alloy
	name = "Пластитаниум"
	id = "plastitanium"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT, /datum/material/plasma = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/plastitanium
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/plaglass_alloy
	name = "Стекло из плазмы"
	id = "plasmaglass"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 0.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmaglass
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/plasmarglass_alloy
	name = "Армированное стекло из плазмы"
	id = "plasmareinforcedglass"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 0.5, /datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.5,  /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmarglass
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/titaniumglass_alloy
	name = "Титановое стелко"
	id = "titaniumglass"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/titaniumglass
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/plastitaniumglass_alloy
	name = "Пластитановое стекло"
	id = "plastitaniumglass"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 0.5, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plastitaniumglass
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/alienalloy
	name = "Инопланетный сплав"
	desc = "A sheet of reverse-engineered alien alloy."
	id = "alienalloy"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2, /datum/material/plasma = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/stack/sheet/mineral/abductor
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
