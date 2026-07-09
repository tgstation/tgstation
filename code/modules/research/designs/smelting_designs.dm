///////SMELTABLE ALLOYS///////

/datum/design/alloy
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
	//The resulting alloy sheets have different material types, but can be deconstructed back to their base mats with a recycler iirc.
	inherit_materials = DESIGN_DONT_INHERIT_MATS

/datum/design/alloy/plasteel_alloy
	name = "Plasteel"
	id = "plasteel"
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/plasma = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasteel

/datum/design/alloy/plastitanium
	name = "Plastitanium"
	id = "plastitanium"
	materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT, /datum/material/plasma = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/plastitanium

/datum/design/alloy/plaglass
	name = "Plasma Glass"
	id = "plasmaglass"
	materials = list(/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmaglass

/datum/design/alloy/plasmarglass
	name = "Reinforced Plasma Glass"
	id = "plasmareinforcedglass"
	materials = list(/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,  /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmarglass

/datum/design/alloy/titaniumglass
	name = "Titanium Glass"
	id = "titaniumglass"
	materials = list(/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/titaniumglass

/datum/design/alloy/plastitaniumglass
	name = "Plastitanium Glass"
	id = "plastitaniumglass"
	materials = list(/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plastitaniumglass

/datum/design/alloy/alien
	name = "Alien Alloy"
	desc = "A sheet of reverse-engineered alien alloy."
	id = "alienalloy"
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2)
	build_path = /obj/item/stack/sheet/mineral/abductor
