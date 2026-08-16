/datum/design/c9x25mm
	name = "pistol magazine (9x25mm) (Lethal)"
	desc = "Designed to quickly reload GP-9 pistols."
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10
	)
	build_path = /obj/item/ammo_box/magazine/c9x25mm_pistol
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9x25mm/sec
	build_type = PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9x25mm_rubber
	name = "pistol magazine (9x25mm Rubber) (Less Lethal)"
	desc = "Designed to quickly reload GP-9 pistols. Rubber bullets are bouncy and less-than-lethal."
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT * 10
	)
	build_path = /obj/item/ammo_box/magazine/c9x25mm_pistol/rubber
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9x25mm_rubber/sec
	build_type = PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9x25mm/hp
	name = "pistol magazine (9x25mm) (Hollow-point)"
	desc = "Designed to quickly reload GP-9 pistols. Hollow-point bullets are great against unarmored targets, but useless against armored ones."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT * 2.5
	)
	build_path = /obj/item/ammo_box/magazine/c9x25mm_pistol/hp
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9x25mm/ap
	name = "pistol magazine (9x25mm) (Armor-piercing)"
	desc = "Designed to quickly reload GP-9 pistols. Armor-piercing bullets are great against armored targets, but strikes with less damage."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT * 2.5
	)
	build_path = /obj/item/ammo_box/magazine/c9x25mm_pistol/ap
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/breaching_slug
	name = "Breaching Slug (Non-Lethal/Highly Destructive)"
	desc = "Designed for breaching airlocks and windows, quickly and efficiently."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 5
	)
	build_path = /obj/item/ammo_casing/shotgun/breacher
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/techweb_node/basic_arms/New()
	. = ..()
	unlocked_designs += list(
		/datum/design/c9x25mm_rubber/sec,
		/datum/design/breaching_slug,
	)

/datum/techweb_node/riot_supression/New()
	. = ..()
	unlocked_designs += /datum/design/c9x25mm/sec

/datum/techweb_node/exotic_ammo/New()
	. = ..()
	unlocked_designs += list(
		/datum/design/c9x25mm/hp,
		/datum/design/c9x25mm/ap,
	)
