/*
*	AMMO
*/

/datum/design/strilka310_rubber
	name = ".310 Rubber Bullet (Less Lethal)"
	id = "astrilka310_rubber"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/ammo_casing/strilka310/rubber
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

// 4.6x30mm - SMG round, used in the WT550 and in numerous modular guns as a weaker alternative to 9mm.

/datum/design/c46x30mm
	name = "4.6x30mm Bullet"
	id = "c46x30mm"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7.5,
	)
	build_path = /obj/item/ammo_casing/c46x30mm
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

/datum/design/c46x30mm_rubber
	name = "4.6x30mm Rubber Bullet"
	id = "c46x30mm_rubber"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7.5
	)
	build_path = /obj/item/ammo_casing/c46x30mm/rubber
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

// .45

/datum/design/c45_lethal
	name = ".45 Bullet"
	id = "c45_lethal"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7.5,
	)
	build_path = /obj/item/ammo_casing/c45
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

/datum/design/c45_rubber
	name = ".45 Bouncy Rubber Ball"
	id = "c45_rubber"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7.5,
	)
	build_path = /obj/item/ammo_casing/c45/rubber
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

// 10mm
/datum/design/c10mm_lethal
	name = "10mm Bullet"
	id = "c10mm_lethal"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7.5,
	)
	build_path = /obj/item/ammo_casing/c10mm
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

/datum/design/c10mm_rubber
	name = "10mm Rubber Bullet"
	id = "c10mm_rubber"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7.5,
	)
	build_path = /obj/item/ammo_casing/c10mm/rubber
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

/datum/techweb_node/robotics/New()
	design_ids += list(
		"mini_soulcatcher",
	)
	return ..()

/datum/techweb_node/neural_programming/New()
	design_ids += list(
		"soulcatcher_device",
	)
	return ..()

//12 Gauge
/datum/design/shotgun_slug
	name = "Shotgun Slug"
	id = "shotgun_slug"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/ammo_casing/shotgun
	category = list(
		RND_CATEGORY_HACKED, RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

/datum/design/shotgun_slug/sec
	id = "sec_shotgun_slug"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY
	autolathe_exportable = FALSE

/datum/design/buckshot_shell
	name = "Buckshot Shell"
	id = "buckshot_shell"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/ammo_casing/shotgun/buckshot
	category = list(
		RND_CATEGORY_HACKED, RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

/datum/design/buckshot_shell/sec
	id = "sec_buckshot_shell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY
	autolathe_exportable = FALSE

//Existing Designs Discounting

/datum/design/rubbershot
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
	)

/datum/design/rubbershot/sec
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)

/datum/design/beanbag_slug
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
	)

/datum/design/beanbag_slug/sec
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)

/datum/design/shotgun_dart
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
	)

/datum/design/shotgun_dart/sec
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)

/datum/design/incendiary_slug
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
	)

/datum/design/incendiary_slug/sec
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)


/datum/techweb_node/integrated_hud/New()
	design_ids += list(
		"permit_glasses",
		"nifsoft_money_sense",
		"nifsoft_hud_kit",
		"nifsoft_hud_science",
		"nifsoft_hud_meson",
		"nifsoft_hud_medical",
		"nifsoft_hud_security",
		"nifsoft_hud_diagnostic",
		"nifsoft_hud_cargo",
	)
	return ..()
