/obj/item/gun/ballistic/automatic/cm82
	name = "CM-82"
	desc = "Стандартная штурмовая винтовка Нанотрейзен в калибре 5.56мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "cm82"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "cm82"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "cm82"
	SET_BASE_PIXEL(-8, 0)
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c223
	spawn_magazine_type = /obj/item/ammo_box/magazine/c223
	fire_sound = 'modular_bandastation/weapon/sound/ranged/cm82.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_rifle.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 10
	burst_size = 1
	fire_delay = 0.18 SECONDS
	actions_types = list()
	spread = 2.5
	recoil = 0.2
	load_sound = 'modular_bandastation/weapon/sound/ranged/cm82_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm82_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/cm82_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm82_unload.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/ar_cock.ogg'

/obj/item/gun/ballistic/automatic/cm82/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/cm82/update_icon_state()
	. = ..()
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"
	worn_icon_state = "[icon_state][magazine ? "":"_nomag"]"

/obj/item/gun/ballistic/automatic/cm82/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 33, \
		overlay_y = 13 \
	)

/obj/item/gun/ballistic/automatic/cm82/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/cm82/examine_more(mob/user)
	. = ..()
	. += "Относительно новое боевое оружие. Точная, надежная и простая в использовании, CM-82 практически в одночасье заменила АРГ \"Пограничник\" в качестве штурмовой винтовки Нанотрейзен и с тех пор пользуется огромной популярностью."

/obj/item/gun/ballistic/automatic/cm82/no_mag
	spawnwithmagazine = FALSE
