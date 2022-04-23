/obj/item/gun/ballistic/automatic/ppsh
	name = "\improper Asha 76"
	desc = "A reproduction of a simple Soviet SMG chambered in 7.62x25 Tokarev rounds. Its heavy wooden stock and leather breech buffer help absorb the bolt’s heavy recoil, making it great for spraying and praying. Uraaaa!"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_guns40x32.dmi'
	icon_state = "ppsh"
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_righthand.dmi'
	inhand_icon_state = "ppsh"
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_back.dmi'
	worn_icon_state = "ppsh"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	mag_type = /obj/item/ammo_box/magazine/ppsh
	can_suppress = FALSE
	spread = 20
	burst_size = 6
	fire_delay = 0.5
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/ppsh_fire.ogg'
	fire_sound_volume = 80
	alt_icons = TRUE
	realistic = TRUE
	dirt_modifier = 0.3
	rack_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_cock.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magout.ogg'
	company_flag = COMPANY_OLDARMS

/obj/item/ammo_box/magazine/ppsh
	name = "Asha 76 magazine (7.62x25mm)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_items.dmi'
	icon_state = "ppsh"
	ammo_type = /obj/item/ammo_casing/realistic/a762x25
	caliber = "a762x25"
	max_ammo = 71
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/ppsh/modern
	name = "\improper PPsh-59"
	desc = "A modernized reproduction of a simple Soviet SMG with aftermarket parts. Its heavy synthetic stock and composite breech buffer help absorb the bolt’s heavy recoil, a mix of two worlds that should not exist."
	icon_state = "ppsh_modern"
	worn_icon_state = "ppsh"
	inhand_icon_state = "ppsh"
	spread = 15
	burst_size = 5
