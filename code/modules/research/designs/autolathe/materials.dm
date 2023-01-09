/datum/design/iron
	name = "Iron"
	id = "iron"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/iron
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50

/datum/design/rods
	name = "Iron Rod"
	id = "rods"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/stack/rods
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50

/datum/design/glass
	name = "Glass"
	id = "glass"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/glass
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50

/datum/design/rglass
	name = "Reinforced Glass"
	id = "rglass"
	build_type = AUTOLATHE | SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/rglass
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/silver
	name = "Silver"
	id = "silver"
	build_type = AUTOLATHE
	materials = list(/datum/material/silver = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/silver
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50

/datum/design/gold
	name = "Gold"
	id = "gold"
	build_type = AUTOLATHE
	materials = list(/datum/material/gold = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/gold
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50

/datum/design/diamond
	name = "Diamond"
	id = "diamond"
	build_type = AUTOLATHE
	materials = list(/datum/material/diamond = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/diamond
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50

/datum/design/plasma
	name = "Plasma"
	id = "plasma"
	build_type = AUTOLATHE
	materials = list(/datum/material/plasma = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/plasma
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50

/datum/design/uranium
	name = "Uranium"
	id = "uranium"
	build_type = AUTOLATHE
	materials = list(/datum/material/uranium = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/uranium
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50

/datum/design/bananium
	name = "Bananium"
	id = "bananium"
	build_type = AUTOLATHE
	materials = list(/datum/material/bananium = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/bananium
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50

/datum/design/titanium
	name = "Titanium"
	id = "titanium"
	build_type = AUTOLATHE
	materials = list(/datum/material/titanium = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/titanium
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50

/datum/design/plastic
	name = "Plastic"
	id = "plastic"
	build_type = AUTOLATHE
	materials = list(/datum/material/plastic = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plastic
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50
