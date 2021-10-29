/obj/item/gun/ballistic/automatic/battle_rifle/fg42
	name = "\improper Fallschirmjägergewehr 42"
	desc = "A German paratrooper rifle designed to be used at the very least, five-hundred and fifty years ago. It's most likely reproduction, and you should be concerned more than excited to have this in your hands."
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/fg42/fg42.dmi'
	icon_state = "fg42"
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/fg42/fg42_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/fg42/fg42_righthand.dmi'
	inhand_icon_state = "fg42"
	slot_flags = ITEM_SLOT_BELT
	mag_type = /obj/item/ammo_box/magazine/fg42
	can_suppress = FALSE
	burst_size = 2
	spread = 0
	fire_delay = 2
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/fg42/fg42_back.dmi'
	worn_icon_state = "fg42"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/fg42/fg42.ogg'
	alt_icons = TRUE
	realistic = TRUE
	zoomable = TRUE

/obj/item/ammo_box/magazine/fg42
	name = "fg42 magazine (7.92×57mm)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/fg42/fg42.dmi'
	icon_state = "7.92mm"
	ammo_type = /obj/item/ammo_casing/realistic/a792x57
	caliber = "a792x57"
	max_ammo = 20
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/battle_rifle/fg42/modern
	name = "\improper Fallschirmjägergewehr 42 MK. VII"
	desc = "An absolute disgrace to any sane person's eyes, this is a cheap reproduction of an extremely old German paratrooper rifle filled to the brim with aftermarket parts, some of them shouldn't even be in there. Louis Stange is rolling in their grave."
	icon_state = "fg42_modern"
	inhand_icon_state = "fg42"
	worn_icon_state = "fg42"
	burst_size = 3
	fire_delay = 1
