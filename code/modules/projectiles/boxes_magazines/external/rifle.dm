/obj/item/ammo_box/magazine/m10mm/rifle
	name = "rifle magazine (10mm)"
	desc = "A well-worn magazine fitted for the surplus rifle."
	icon_state = "75-full"
	base_icon_state = "75"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 10

/obj/item/ammo_box/magazine/m10mm/rifle/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[LAZYLEN(stored_ammo) ? "full" : "empty"]"

/obj/item/ammo_box/magazine/m223
	name = "toploader magazine (.223)"
	icon_state = ".223"
	ammo_type = /obj/item/ammo_casing/a223
	caliber = CALIBER_A223
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/m223/phasic
	name = "toploader magazine (.223 Phasic)"
	ammo_type = /obj/item/ammo_casing/a223/phasic


// AKM Mags

/obj/item/ammo_box/magazine/ak712x82
	name = "rifle magazine (7.12x82mm)"
	desc = "A 30-round 7.12x82mm magazine designed with the AKM specifically in mind."
	icon_state = "ak762x82"
	ammo_type = /obj/item/ammo_casing/mm712x82
	caliber = "7.12x82"
	max_ammo = 30

/obj/item/ammo_box/magazine/ak712x82/update_icon_state()
	. = ..()
	if (ammo_count() >= 1)
		icon_state = initial(icon_state)
	else
		icon_state = initial(icon_state) + "_empty"

/obj/item/ammo_box/magazine/ak712x82/ap
	name = "armor-piercing rifle magazine (7.12x82mm)"
	desc = "A 30-round 7.12x82mm magazine fitted with armor-piercing rounds and designed with the AKM specifically in mind."
	icon_state = "ak762x82P"
	ammo_type = /obj/item/ammo_casing/mm712x82/ap

/obj/item/ammo_box/magazine/ak712x82/hp
	name = "hollow-point rifle magazine (7.12x82mm)"
	desc = "A 30-round 7.12x82mm magazine fitted with hollow-point rounds and designed with the AKM specifically in mind."
	icon_state = "ak762x82L"
	ammo_type = /obj/item/ammo_casing/mm712x82/hollow

/obj/item/ammo_box/magazine/ak712x82/incendiary
	name = "incendiary rifle magazine (7.12x82mm)"
	desc = "A 30-round 7.12x82mm magazine fitted with incendiary rounds and designed with the AKM specifically in mind."
	icon_state = "ak762x82I"
	ammo_type = /obj/item/ammo_casing/mm712x82/inc
