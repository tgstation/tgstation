/obj/item/gun/ballistic/automatic/assault_rifle/m16
	name = "\improper M16A4 Rifle"
	desc = "The fourth iteration of the M16 series of infantry rifles, firing the extremely old (yet strangely stil in use) 5.56x45mm cartridge. This seems to be a reproduction, as the model was phased out in the early 2030's to accomodate for more modern designs."
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/m16/m16.dmi'
	icon_state = "m16"
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/m16/m16_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/m16/m16_righthand.dmi'
	inhand_icon_state = "m16"
	slot_flags = ITEM_SLOT_BELT
	mag_type = /obj/item/ammo_box/magazine/m16
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/m16/m16_back.dmi'
	worn_icon_state = "m16"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/m16/m16.ogg'
	fire_sound_volume = 50
	rack_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/sfrifle_cock.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/sfrifle_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/sfrifle_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/sfrifle_magout.ogg'
	alt_icons = TRUE
	realistic = TRUE

/obj/item/ammo_box/magazine/m16
	name = "m16 magazine (5.56×45mm)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/m16/m16.dmi'
	icon_state = "5.56mm"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "a556"
	max_ammo = 20
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/assault_rifle/m16/modern
	name = "\improper AR-25T"
	desc = "An M16 pattern infantry rifle, this one is a modern sporting/self defense model filled to the brim with aftermarket parts. Come and take it."
	icon_state = "m16_modern"
	inhand_icon_state = "m16"
	worn_icon_state = "m16"
	spread = 0.5
	burst_size = 3
	fire_delay = 1.90

/obj/item/gun/ballistic/automatic/assault_rifle/m16/modern/v2
	name = "\improper AR-24 'Patriot'"
	desc = "An M16 pattern infantry rifle with a short barrel and modified cycling mechanism that allows it to fire it significantly faster, with no care for accuracy or effectiveness. There's only room for one snake and one boss."
	icon_state = "m16_modern2"
	inhand_icon_state = "m16"
	worn_icon_state = "m16"
	burst_size = 4
	fire_delay = 1
