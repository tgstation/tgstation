/obj/item/gun/ballistic/automatic/submachine_gun/mp40
	name = "\improper MP-40"
	desc = "The instantly recognizable 'nazi gun'. Extremely outdated SMG that has only seen service during Sol-3's second World War. This one's a poor, unlicensed reproduction."
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/mp40/mp40.dmi'
	icon_state = "mp40"
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/mp40/mp40_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/mp40/mp40_righthand.dmi'
	inhand_icon_state = "mp40"
	slot_flags = ITEM_SLOT_BELT
	mag_type = /obj/item/ammo_box/magazine/mp40
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 1.7
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/mp40/mp40_back.dmi'
	worn_icon_state = "mp40"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/mp40/mp40.ogg'
	fire_sound_volume = 100
	rack_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_cock.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magout.ogg'
	alt_icons = TRUE
	realistic = TRUE

/obj/item/ammo_box/magazine/mp40
	name = "mp40 magazine (9mmx19)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/mp40/mp40.dmi'
	icon_state = "9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "c9mm"
	max_ammo = 32
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/submachine_gun/mp40/modern
	name = "\improper MP-40k"
	desc = "An extremely outdated German SMG that has been modified extensively with aftermarket parts. It looks like it came straight out of the videogame Return to Fortress Dogenstein."
	icon_state = "mp40_modern"
	inhand_icon_state = "mp40"
	worn_icon_state = "mp40"
	burst_size = 4
	fire_delay = 1.5
