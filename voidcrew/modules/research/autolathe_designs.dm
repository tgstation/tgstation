/datum/design/research
	name = "Research & Development Kit"
	id = "rndkit"
	build_type = AUTOLATHE
	materials = list(/datum/material/cardboard = 2000, /datum/material/glass = 4000) // The materials for one box + all boards inside exactly.
	build_path = /obj/item/storage/box/rndboards
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MACHINERY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING
