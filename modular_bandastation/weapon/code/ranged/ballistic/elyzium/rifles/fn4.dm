/obj/item/gun/ballistic/automatic/fn4
	name = "FN-VI \"Sharp\""
	desc = "Стандартная боевая винтовка вооруженных сил Республики Элизиум в калибре 7.62x51мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "fn4"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "fn4"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "fn4"
	SET_BASE_PIXEL(-8, 0)
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c762x51mm
	spawn_magazine_type = /obj/item/ammo_box/magazine/c762x51mm
	fire_sound = 'modular_bandastation/weapon/sound/ranged/rifle_heavy_3.ogg'
	fire_sound_volume = 80
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 9
	burst_size = 1
	fire_delay = 0.25 SECONDS
	actions_types = list()
	spread = 2.5
	recoil = 0.3
	rack_sound = 'modular_bandastation/weapon/sound/ranged/smg_rack.ogg'

/obj/item/gun/ballistic/automatic/fn4/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 28, \
		overlay_y = 13 \
	)

/obj/item/gun/ballistic/automatic/fn4/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/gun/ballistic/automatic/fn4/no_mag
	spawnwithmagazine = FALSE
