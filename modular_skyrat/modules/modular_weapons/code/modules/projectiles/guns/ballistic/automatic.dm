////////////////////////
//ID: MODULAR_WEAPONS //
////////////////////////

// Magazines

/obj/item/ammo_box/magazine/multi_sprite/cfa_wildcat
	name = "CFA Wildcat Magazine (.32)"
	desc = "Magazines taking .32 ammunition; it fits in the CFA Wildcat. Alt+click to reskin it."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/ammo.dmi'
	icon_state = "smg32"
	possible_types = list(AMMO_TYPE_LETHAL, AMMO_TYPE_AP, AMMO_TYPE_RUBBER, AMMO_TYPE_INCENDIARY)
	ammo_type = /obj/item/ammo_casing/c32
	caliber = "c32acp"
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY_BASIC

/obj/item/ammo_box/magazine/multi_sprite/cfa_wildcat/ap
	ammo_type = /obj/item/ammo_casing/c32/ap
	round_type = AMMO_TYPE_AP

/obj/item/ammo_box/magazine/multi_sprite/cfa_wildcat/rubber
	ammo_type = /obj/item/ammo_casing/c32/rubber
	round_type = AMMO_TYPE_RUBBER

/obj/item/ammo_box/magazine/multi_sprite/cfa_wildcat/incendiary
	ammo_type = /obj/item/ammo_casing/c32_incendiary
	round_type = AMMO_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/multi_sprite/cfa_wildcat/empty
	start_empty = 1

///////////////
//  Wildcat  //
///////////////
// 3rnd burst .32 calibre, 15 damage.
// Fills the role of a low damage, high magazine capacity secondary.
/obj/item/gun/ballistic/automatic/cfa_wildcat
	name = "\improper CFA Wildcat"
	desc = "An old SMG, this one is chambered in .32, a very common and dirt-cheap cartridge. It has <b><span style='color:purple'>Cantalan Federal Arms</span></b> etched above the magazine well."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/guns/projectile40x32.dmi'
	icon_state = "mp5"
	inhand_icon_state = "arg"
	selector_switch_icon = TRUE
	mag_type = /obj/item/ammo_box/magazine/multi_sprite/cfa_wildcat
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 1.25
	spread = 5
	mag_display = TRUE
	empty_indicator = FALSE
	fire_sound = 'sound/weapons/gun/smg/shot_alt.ogg'
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/ballistic/automatic/cfa_wildcat/no_mag
	spawnwithmagazine = FALSE

///////////////
//    MP7    //
///////////////

/obj/item/gun/ballistic/automatic/cfa_lynx
	name = "\improper CFA Lynx"
	desc = "A carbine with a high magazine capacity. Chambered in 4.6x30mm. It has <b><span style='color:purple'>Cantalan Federal Arms</span></b> etched above the magazine well."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/guns/projectile.dmi'
	icon_state = "cfa-lynx"
	inhand_icon_state = "arg"
	selector_switch_icon = FALSE
	mag_type = /obj/item/ammo_box/magazine/multi_sprite/cfa_lynx
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 1.90 //Previously 0.5. Changed due to it being the Blueshield's default firearm.
	spread = 2
	mag_display = TRUE
	empty_indicator = FALSE
	fire_sound = 'sound/weapons/gun/smg/shot_alt.ogg'
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/ballistic/automatic/cfa_lynx/no_mag
	spawnwithmagazine = FALSE

/obj/item/ammo_box/magazine/multi_sprite/cfa_lynx
	name = "CFA Lynx Magazine (4.6x30mm)"
	desc = "A magazine for the CFA Lynx. It has a small inscription on the base, '4.6x30mm'. Alt+click to reskin it."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/ammo.dmi'
	icon_state = "lynx"
	possible_types = list(AMMO_TYPE_LETHAL, AMMO_TYPE_AP, AMMO_TYPE_RUBBER, AMMO_TYPE_INCENDIARY)
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = CALIBER_46X30MM
	max_ammo = 40
	multiple_sprites = AMMO_BOX_FULL_EMPTY_BASIC

/obj/item/ammo_box/magazine/multi_sprite/cfa_lynx/ap
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap
	round_type = AMMO_TYPE_AP

/obj/item/ammo_box/magazine/multi_sprite/cfa_lynx/rubber
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber
	round_type = AMMO_TYPE_RUBBER

/obj/item/ammo_box/magazine/multi_sprite/cfa_lynx/incendiary
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc
	round_type = AMMO_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/multi_sprite/cfa_lynx/empty
	start_empty = TRUE
