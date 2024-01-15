/obj/item/gun/ballistic/automatic/ak25
	name = "\improper AK-25 rifle"
	desc = "A cheap reproduction of the timeless AK rifle. The price tag is lower than usual, but expect it to blow up in your hands."
	icon = 'modular_skyrat/modules/company_imports/icons/ak25/ak25.dmi'
	icon_state = "ak25"
	lefthand_file = 'modular_skyrat/modules/company_imports/icons/ak25/ak25_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/company_imports/icons/ak25/ak25_righthand.dmi'
	inhand_icon_state = "ak25"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/ak25
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	worn_icon = 'modular_skyrat/modules/company_imports/icons/ak25/ak25_back.dmi'
	worn_icon_state = "ak25"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/akm_fire.ogg'
	rack_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_cock.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_magout.ogg'
	alt_icons = TRUE
	spread = 29
	recoil = 0.1

/obj/item/gun/ballistic/automatic/ak25/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_IZHEVSK)

/obj/item/ammo_box/magazine/ak25
	name = "\improper AK-25 magazine"
	desc = "A banana-shaped double-stack magazine able to hold 30 rounds of 7.32x29mm ammunition."
	icon = 'modular_skyrat/modules/company_imports/icons/ak25/ak25_ammo.dmi'
	icon_state = "ak25_mag"
	ammo_type = /obj/item/ammo_casing/realistic/a732x29
	caliber = CALIBER_732x29
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_casing/realistic/a732x29
	name = "7.32x29 bullet casing"
	desc = "A 7.32x29mm M43 bullet casing."
	icon_state = "762x39-casing"
	caliber = CALIBER_732x29
	projectile_type = /obj/projectile/bullet/a732x29

/obj/projectile/bullet/a732x29
	name = "7.62x25 bullet"
	damage = 22
