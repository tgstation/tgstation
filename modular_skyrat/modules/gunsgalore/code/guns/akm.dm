/obj/item/gun/ballistic/automatic/akm
	name = "\improper AKM rifle"
	desc = "A timeless Russian infantry rifle chambered in an extremely outdated round. This is one of over two hundred million copies produced - in and outside of Sol. A tool for a revolution, an insurgency, justice, or crime. This rifle and its variants truly have no bounds."
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_guns40x32.dmi'
	icon_state = "akm"
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_righthand.dmi'
	inhand_icon_state = "akm"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/akm
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_back.dmi'
	worn_icon_state = "akm"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/akm_fire.ogg'
	rack_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_cock.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_magout.ogg'
	alt_icons = TRUE
	dirt_modifier = 0.75
	company_flag = COMPANY_IZHEVSK

/obj/item/ammo_box/magazine/akm
	name = "\improper AKM magazine"
	desc = "a banana-shaped double-stack magazine able to hold 30 rounds of 7.62x39mm Soviet ammunition. It's said that in the early days of SolFed's spread, Spanish colony rebels often referred to these as 'Goat Horns'."
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_items.dmi'
	icon_state = "akm"
	ammo_type = /obj/item/ammo_casing/realistic/a762x39
	caliber = "a762x39"
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/akm/banana
	name = "\improper RPK magazine"
	desc = "a banana-shaped double-stack magazine able to hold 45 rounds of 7.62x39mm Soviet ammunition. It's meant to be used on a light machine gun, but it's just a longer AK magazine."
	max_ammo = 45

/obj/item/gun/ballistic/automatic/akm/modern
	name = "\improper tactical AKMS"
	desc = "a modernized version of the most iconic infantry rifle ever produced. This one has aftermarket parts and attachments, making it a better contender against its modern buddies. It still uses the same outdated rounds."
	icon_state = "akm_modern"
	inhand_icon_state = "akm"
	worn_icon_state = "akm"
	fire_delay = 1
