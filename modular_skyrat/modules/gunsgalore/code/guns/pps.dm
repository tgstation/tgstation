/obj/item/gun/ballistic/automatic/pps
	name = "\improper PPS-43"
	desc = "A very cheap, barely reliable reproduction of a personal defense weapon based on the original Soviet model. Not nearly as infamous as the Mosin."
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_guns40x32.dmi'
	icon_state = "pps"
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_righthand.dmi'
	inhand_icon_state = "pps"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/pps
	can_suppress = FALSE
	fire_delay = 3
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_back.dmi'
	worn_icon_state = "pps"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/pps_fire.ogg'
	fire_sound_volume = 100
	alt_icons = TRUE
	rack_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_cock.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magout.ogg'

/obj/item/gun/ballistic/automatic/pps/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/pps
	name = "pps magazine (7.62x25mm)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_items.dmi'
	icon_state = "pps"
	ammo_type = /obj/item/ammo_casing/realistic/a762x25
	caliber = "a762x25"
	max_ammo = 35
	multiple_sprites = AMMO_BOX_FULL_EMPTY
