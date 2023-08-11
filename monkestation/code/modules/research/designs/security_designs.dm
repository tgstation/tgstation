/datum/design/rubber_c35
	name = ".35 Rubber Ammo Box (Less Lethal)"
	id = "rubber_c35"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 20000)
	build_path = /obj/item/ammo_box/c35/rubber
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/lethal_c35
	name = ".35 Ammo Box (Lethal)"
	id = "lethal_c35"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 40000)
	build_path = /obj/item/ammo_box/c35
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY
