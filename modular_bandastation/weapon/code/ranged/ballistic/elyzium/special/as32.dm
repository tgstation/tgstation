/obj/item/gun/ballistic/automatic/as32
	name = "AS-32"
	desc = "Автоматический дробовик 12-го калибра используемый вооруженными силами Республики Элизиум."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "as32"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "as32"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "as32"
	SET_BASE_PIXEL(-8, 0)
	bolt_type = BOLT_TYPE_STANDARD
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/as32
	spawn_magazine_type = /obj/item/ammo_box/magazine/as32
	fire_sound = 'modular_bandastation/weapon/sound/ranged/shotgun_automatic.ogg'
	fire_sound_volume = 80
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	can_suppress = TRUE
	special_mags = TRUE
	suppressor_x_offset = 8
	burst_size = 1
	fire_delay = 0.4 SECONDS
	actions_types = list()
	spread = 2.5
	recoil = 0.8
	rack_sound = 'sound/items/weapons/gun/general/chunkyrack.ogg'
	pb_knockback = 2

/obj/item/gun/ballistic/automatic/as32/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/gun/ballistic/automatic/as32/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 29, \
		overlay_y = 13 \
	)

/obj/item/gun/ballistic/automatic/as32/no_mag
	spawnwithmagazine = FALSE
