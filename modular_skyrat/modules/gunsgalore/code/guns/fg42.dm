/obj/item/gun/ballistic/automatic/fg42
	name = "\improper FGP-90"
	desc = "A German paratrooper rifle designed to be used at long range chambered in 7.92x57mm. Most likely a reproduction of the original."
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_guns40x32.dmi'
	icon_state = "fg42"
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_righthand.dmi'
	inhand_icon_state = "fg42"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/fg42
	can_suppress = FALSE
	burst_size = 2
	spread = 0
	fire_delay = 2
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_back.dmi'
	worn_icon_state = "fg42"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/fg42_fire.ogg'
	alt_icons = TRUE
	realistic = TRUE
	rack_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/batrifle_cock.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/batrifle_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/batrifle_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/batrifle_magout.ogg'
	eject_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/batrifle_magout.ogg'

/obj/item/gun/ballistic/automatic/fg42/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1)

/obj/item/ammo_box/magazine/fg42
	name = "fg42 magazine (7.92x57mm)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_items.dmi'
	icon_state = "fg42"
	ammo_type = /obj/item/ammo_casing/realistic/a792x57
	caliber = "a792x57"
	max_ammo = 20
	multiple_sprites = AMMO_BOX_FULL_EMPTY
