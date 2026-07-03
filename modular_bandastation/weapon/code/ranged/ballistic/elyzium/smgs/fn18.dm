/obj/item/gun/ballistic/automatic/fn18
	name = "FN-18 SMG"
	desc = "Стандартный пистолет-пулемёт вооруженных сил Республики Элизиум в калибре 9мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "fn18"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "fn18"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "fn18"
	SET_BASE_PIXEL(-8, 0)
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/fn18
	spawn_magazine_type = /obj/item/ammo_box/magazine/fn18
	fire_sound = 'modular_bandastation/weapon/sound/ranged/shot.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 4
	burst_size = 1
	fire_delay = 0.18 SECONDS
	actions_types = list()
	spread = 5
	recoil = 0.1

/obj/item/gun/ballistic/automatic/fn18/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 27, \
		overlay_y = 12 \
	)

/obj/item/gun/ballistic/automatic/fn18/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/gun/ballistic/automatic/fn18/no_mag
	spawnwithmagazine = FALSE
