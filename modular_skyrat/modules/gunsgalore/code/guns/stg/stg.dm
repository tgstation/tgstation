/obj/item/gun/ballistic/automatic/assault_rifle/stg
	name = "\improper StG-44"
	desc = "A reproduction of a German infantry rifle chambered in 7.92mm. An attempt to put rifle-cartridge automatic weapons outside the hands of machine gunners, it was almost the first select-fire rifle. Almost."
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/stg/stg.dmi'
	icon_state = "stg"
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/stg/stg_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/stg/stg_righthand.dmi'
	inhand_icon_state = "stg"
	slot_flags = ITEM_SLOT_BELT
	mag_type = /obj/item/ammo_box/magazine/stg
	can_suppress = FALSE
	burst_size = 4
	fire_delay = 1.5
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/stg/stg_back.dmi'
	worn_icon_state = "stg"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/stg/stg.ogg'
	fire_sound_volume = 70
	alt_icons = TRUE
	realistic = TRUE
	fire_select_modes = list(SELECT_SEMI_AUTOMATIC, SELECT_BURST_SHOT, SELECT_FULLY_AUTOMATIC)

/obj/item/ammo_box/magazine/stg
	name = "stg magazine (7.92×33mm)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/stg/stg.dmi'
	icon_state = "7.92mm"
	ammo_type = /obj/item/ammo_casing/realistic/a792x33
	caliber = "a792x33"
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY


/obj/item/gun/ballistic/automatic/assault_rifle/stg/modern
	name = "\improper StG-560"
	desc = "A modernized reproduction of the StG-44, full of aftermarket parts that barely make it perform any better. Looks like it's out of the videogame Return to Fortress Dogenstein."
	icon_state = "stg_modern"
	inhand_icon_state = "stg"
	worn_icon_state = "stg"
	fire_delay = 1.2

