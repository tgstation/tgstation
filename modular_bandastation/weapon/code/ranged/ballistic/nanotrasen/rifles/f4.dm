/obj/item/gun/ballistic/automatic/f4
	name = "F4"
	desc = "Стандартная боевая винтовка Нанотрейзен под калибр 7.62x51мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "f4"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "f4"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "f4"
	SET_BASE_PIXEL(-8, 0)
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c762x51mm
	spawn_magazine_type = /obj/item/ammo_box/magazine/c762x51mm
	fire_sound = 'modular_bandastation/weapon/sound/ranged/f4.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_rifle.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 8
	burst_size = 1
	fire_delay = 0.4 SECONDS
	actions_types = list()
	spread = 1
	recoil = 0.4
	rack_sound = 'modular_bandastation/weapon/sound/ranged/smg_rack.ogg'

/obj/item/gun/ballistic/automatic/f4/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 31, \
		overlay_y = 12 \
	)

/obj/item/gun/ballistic/automatic/f4/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/f4/update_icon_state()
	. = ..()
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"
	worn_icon_state = "[icon_state][magazine ? "":"_nomag"]"

/obj/item/gun/ballistic/automatic/f4/no_mag
	spawnwithmagazine = FALSE
