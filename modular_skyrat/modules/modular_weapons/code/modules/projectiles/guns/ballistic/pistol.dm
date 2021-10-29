////////////////////////
//ID: MODULAR_WEAPONS //
////////////////////////

////////////////////////
//       PISTOLS      //
////////////////////////

/obj/item/gun/ballistic/automatic/pistol/cfa_snub
	name = "CFA Snub"
	desc = "A small easily-concealable modern pistol chambered in the more widely-used 4.6x30mm. It's specifically designed to be compact. It has <b><span style='color:purple'>Cantalan Federal Arms</span></b> etched into the slide.	"
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/guns/projectile.dmi'
	icon_state = "cfa-snub"
	mag_type = /obj/item/ammo_box/magazine/multi_sprite/cfa_snub
	can_suppress = TRUE
	fire_sound_volume = 30
	w_class = WEIGHT_CLASS_SMALL
	has_gun_safety = FALSE

/obj/item/gun/ballistic/automatic/pistol/cfa_snub/empty
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/cfa_ruby
	name = "CFA Ruby"
	desc = "A large and loud modern handgun made to fit more universally used cartridges. It's chambered in .45, or 11.43x23mm. It has <b><span style='color:purple'>Cantalan Federal Arms</span></b> etched into the slide."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/guns/projectile.dmi'
	icon_state = "cfa_ruby"
	mag_type = /obj/item/ammo_box/magazine/multi_sprite/cfa_ruby
	can_suppress = FALSE
	fire_sound_volume = 120
	w_class = WEIGHT_CLASS_NORMAL
	has_gun_safety = FALSE

/obj/item/gun/ballistic/automatic/pistol/cfa_ruby/empty
	spawnwithmagazine = FALSE

////////////////////////
//        AMMO        //
////////////////////////
/obj/item/ammo_box/magazine/multi_sprite/cfa_snub
	name = "CFA Snub Magazine (4.6x30mm)"
	desc = "An advanced magazine with smart type displays. Alt+click to reskin it."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/ammo.dmi'
	icon_state = "m46x30"
	possible_types = list(AMMO_TYPE_LETHAL, AMMO_TYPE_AP, AMMO_TYPE_RUBBER, AMMO_TYPE_INCENDIARY)
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = CALIBER_46X30MM
	max_ammo = 16
	multiple_sprites = AMMO_BOX_FULL_EMPTY_BASIC

/obj/item/ammo_box/magazine/multi_sprite/cfa_snub/ap
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap
	round_type = AMMO_TYPE_AP

/obj/item/ammo_box/magazine/multi_sprite/cfa_snub/rubber
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber
	round_type = AMMO_TYPE_RUBBER

/obj/item/ammo_box/magazine/multi_sprite/cfa_snub/incendiary
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc
	round_type = AMMO_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/multi_sprite/cfa_snub/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/multi_sprite/cfa_ruby
	name = "CFA Ruby Magazine (10mm Magnum)"
	desc = "An advanced magazine with smart type displays. Alt+click to reskin it."
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/ammo.dmi'
	icon_state = "m10mm"
	possible_types = list(AMMO_TYPE_LETHAL, AMMO_TYPE_AP, AMMO_TYPE_RUBBER, AMMO_TYPE_HOLLOWPOINT, AMMO_TYPE_INCENDIARY)
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = CALIBER_10MM
	max_ammo = 8
	multiple_sprites = AMMO_BOX_FULL_EMPTY_BASIC

/obj/item/ammo_box/magazine/multi_sprite/cfa_ruby/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/multi_sprite/cfa_ruby/ap
	ammo_type = /obj/item/ammo_casing/c10mm/ap
	round_type = AMMO_TYPE_AP

/obj/item/ammo_box/magazine/multi_sprite/cfa_ruby/rubber
	ammo_type = /obj/item/ammo_casing/c10mm/rubber
	round_type = AMMO_TYPE_RUBBER

/obj/item/ammo_box/magazine/multi_sprite/cfa_ruby/hp
	ammo_type = /obj/item/ammo_casing/c10mm/hp
	round_type = AMMO_TYPE_HOLLOWPOINT

/obj/item/ammo_box/magazine/multi_sprite/cfa_ruby/incendiary
	ammo_type = /obj/item/ammo_casing/c10mm/fire
	round_type = AMMO_TYPE_INCENDIARY
