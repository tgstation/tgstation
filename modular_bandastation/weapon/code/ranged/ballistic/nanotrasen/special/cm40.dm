/obj/item/gun/ballistic/automatic/cm40
	name = "CM-40"
	desc = "Пулемет под калибр 7.62x51мм, способный вести интенсивный подавляющий огонь, используемый тяжеловооруженными боевыми отрядами Нанотрейзен."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "cm40"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "cm40"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "cm40"
	SET_BASE_PIXEL(-8, 0)
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/cm40
	spawn_magazine_type = /obj/item/ammo_box/magazine/cm40
	fire_sound = 'modular_bandastation/weapon/sound/ranged/cm40.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 8
	burst_size = 1
	fire_delay = 0.1 SECONDS
	actions_types = list()
	spread = 10
	recoil = 1
	rack_sound = 'modular_bandastation/weapon/sound/ranged/cm40_cocked.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/cm40_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm40_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/cm40_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm40_unload.ogg'

/obj/item/gun/ballistic/automatic/cm40/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/cm40/update_icon_state()
	. = ..()
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"
	worn_icon_state = "[icon_state][magazine ? "":"_nomag"]"

/obj/item/gun/ballistic/automatic/cm40/no_mag
	spawnwithmagazine = FALSE
