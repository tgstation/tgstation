///////SMELTABLE ALLOYS///////

/datum/design/plasteel_alloy
	name = "Plasma + Iron alloy"
	id = "plasteel"
	build_type = SMELTER
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT / 2, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT / 2)
	build_path = /obj/item/stack/sheet/plasteel
	category = list("initial","Alloys")


/datum/design/plastitanium_alloy
	name = "Plasma + Titanium alloy"
	id = "plastitanium"
	build_type = SMELTER
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT / 2, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT / 2)
	build_path = /obj/item/stack/sheet/mineral/plastitanium
	category = list("initial","Alloys")