/datum/design/modglass
	name = "Malleable Glass"
	id = "mod_glass"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass=500, /datum/material/silver=100)
	build_path = /obj/item/reagent_containers/cup/glass/modglass
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_KITCHEN,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/modglass_small
	name = "Small Malleable Glass"
	id = "mod_glass_small"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass=100, /datum/material/silver=100)
	build_path = /obj/item/reagent_containers/cup/glass/modglass/small
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_KITCHEN,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/modglass_large
	name = "Large Malleable Glass"
	id = "mod_glass_large"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass=500, /datum/material/silver=100)
	build_path = /obj/item/reagent_containers/cup/glass/modglass/large
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_KITCHEN,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE
