/obj/item/gun/energy/shrink_ray/one_shot
	name = "shrink ray blaster"
	desc = "This is a piece of frightening alien tech that enhances the magnetic pull of atoms in a localized space to temporarily make an object shrink. \
		That or it's just space magic. Either way, it shrinks stuff, This one is jerry-rigged to work with a non alien cell. It still recharges though."
	ammo_type = list(/obj/item/ammo_casing/energy/shrink/worse)

/obj/item/ammo_casing/energy/shrink/worse
	projectile_type = /obj/projectile/magic/shrink/alien
	select_name = "shrink ray"
	e_cost = LASER_SHOTS(1, STANDARD_CELL_CHARGE)

/obj/item/gun/ballistic/automatic/napad
	name = "\improper 'Napad' Submachine Gun"
	desc = "A 9mm submachine gun with a sizeable magazine, there are no other markings on it, why is it so big?"
	icon = 'icons/obj/weapons/guns/ninemmsmg/napad_item.dmi'
	icon_state = "napad"
	worn_icon = 'icons/obj/weapons/guns/ninemmsmg/napad_worn.dmi'
	worn_icon_state = "napad"
	lefthand_file = 'icons/obj/weapons/guns/ninemmsmg/napad_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/ninemmsmg/napad_righthand.dmi'
	inhand_icon_state = "napad"
	special_mags = FALSE
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/napad
	fire_sound = 'sound/items/weapons/gun/rifle/smg_heavy.ogg'
	fire_sound_volume = 80
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 0.55 SECONDS
	actions_types = list()
	projectile_wound_bonus = -10
	projectile_damage_multiplier = 0.65

/obj/item/gun/ballistic/automatic/napad/no_mag
	spawnwithmagazine = FALSE

/obj/item/ammo_box/magazine/napad
	name = "\improper Napad submachinegun magazine"
	desc = "A magazine for a submachine gun. Holds twenty five rounds of 9mm ammunition."
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	icon_state = "napad_mag"
	w_class = WEIGHT_CLASS_NORMAL
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 25

/obj/item/ammo_box/magazine/napad/spawns_empty
	start_empty = TRUE
