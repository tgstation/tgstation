/obj/item/gun/ballistic/automatic/submachine_gun/ppsh
	name = "\improper PPSh-41"
	desc = "A reproduction of a simple Soviet SMG chambered in 7.62x25 Tokarev rounds. Its heavy wooden stock and leather breech buffer help absorb the bolt’s heavy recoil, making it great for spraying and praying. Uraaaa!"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/ppsh/ppsh.dmi'
	icon_state = "ppsh"
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/ppsh/ppsh_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/ppsh/ppsh_righthand.dmi'
	inhand_icon_state = "ppsh"
	slot_flags = ITEM_SLOT_BELT
	mag_type = /obj/item/ammo_box/magazine/ppsh
	can_suppress = FALSE
	spread = 20
	burst_size = 6
	fire_delay = 0.5
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/ppsh/ppsh_back.dmi'
	worn_icon_state = "ppsh"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/ppsh/ppsh.ogg'
	fire_sound_volume = 80
	alt_icons = TRUE
	realistic = TRUE
	dirt_modifier = 0.3

/obj/item/ammo_box/magazine/ppsh
	name = "ppsh-41 magazine (7.62×25mm)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/ppsh/ppsh.dmi'
	icon_state = "7.62mm"
	ammo_type = /obj/item/ammo_casing/realistic/a762x25
	caliber = "a762x25"
	max_ammo = 71
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/submachine_gun/ppsh/modern
	name = "\improper PPsh-59"
	desc = "A modernized reproduction of a simple Soviet SMG with aftermarket parts. Its heavy synthetic stock and composite breech buffer help absorb the bolt’s heavy recoil, a mix of two worlds that should not exist."
	icon_state = "ppsh_modern"
	worn_icon_state = "ppsh"
	inhand_icon_state = "ppsh"
	spread = 15
	burst_size = 5
