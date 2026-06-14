/datum/design/material
	build_type = AUTOLATHE
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	//We can reasonably believe that material sheets already have said materials to begin with and don't need this.
	inherit_materials = DESIGN_DONT_INHERIT_MATS

/datum/design/material/iron
	name = "Iron"
	id = "iron"
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/iron

/datum/design/material/rods
	name = "Iron Rod"
	id = "rods"
	materials = list(/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/rods
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)

/datum/design/material/glass
	name = "Glass"
	id = "glass"
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/glass
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)

/datum/design/material/rglass
	name = "Reinforced Glass"
	id = "rglass"
	build_type = AUTOLATHE | SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/rglass
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/material/silver
	name = "Silver"
	id = "silver"
	materials = list(/datum/material/silver = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/silver

/datum/design/material/gold
	name = "Gold"
	id = "gold"
	materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/gold

/datum/design/material/diamond
	name = "Diamond"
	id = "diamond"
	materials = list(/datum/material/diamond = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/diamond

/datum/design/material/plasma
	name = "Plasma"
	id = "plasma"
	materials = list(/datum/material/plasma = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/plasma

/datum/design/material/uranium
	name = "Uranium"
	id = "uranium"
	materials = list(/datum/material/uranium = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/uranium

/datum/design/material/bananium
	name = "Bananium"
	id = "bananium"
	materials = list(/datum/material/bananium = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/bananium

/datum/design/material/titanium
	name = "Titanium"
	id = "titanium"
	materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/titanium
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)

/datum/design/material/plastic
	name = "Plastic"
	id = "plastic"
	materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plastic

/datum/design/material/bs_crystal
	name = "Bluespace Crystal"
	id = "bscrystal"
	materials = list(/datum/material/bluespace = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/bluespace_crystal

/datum/design/material/mythril
	name = "Mythril"
	id = "mythril"
	materials = list(/datum/material/mythril = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/mythril

/datum/design/material/alien_alloy
	name = "Alien Alloy"
	id = "allienalloy"
	materials = list(/datum/material/alloy/alien = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/abductor
