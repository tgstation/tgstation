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

/datum/design/mag_autorifle
	name = "WT-550 Autorifle Magazine (4.6x30mm) (Lethal)"
	desc = "A 20 round magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 12000)
	build_path = /obj/item/ammo_box/magazine/wt550m9
	category = list(
					RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/mag_autorifle/ap_mag
	name = "WT-550 Autorifle Armour Piercing Magazine (4.6x30mm AP) (Lethal)"
	desc = "A 20 round armour piercing magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_ap"
	materials = list(/datum/material/iron = 15000, /datum/material/silver = 600)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtap
	category = list(
					RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/mag_autorifle/ic_mag
	name = "WT-550 Autorifle Incendiary Magazine (4.6x30mm IC) (Lethal/Highly Destructive)"
	desc = "A 20 round armour piercing magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_ic"
	materials = list(/datum/material/iron = 15000, /datum/material/silver = 600, /datum/material/glass = 1000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtic
	category = list(
					RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/mag_autorifle/rub_mag
	name = "WT-550 Autorifle Rubber Magazine (4.6x30mm R) (Lethal)"
	desc = "A 20 round rubber magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_rub"
	materials = list(/datum/material/iron = 6000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtrub
	category = list(
					RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/mag_autorifle/salt_mag
	name = "WT-550 Autorifle Saltshot Magazine (4.6x30mm SALT) (Non-Lethal)"
	desc = "A 20 round saltshot magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_salt"
	materials = list(/datum/material/iron = 6000, /datum/material/plasma = 600)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtsalt
	category = list(
					RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY
