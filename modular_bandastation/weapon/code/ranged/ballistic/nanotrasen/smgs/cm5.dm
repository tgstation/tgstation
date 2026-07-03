/obj/item/gun/ballistic/automatic/cm5
	name = "CM-5"
	desc = "Стандартный пистолет-пулемёт НТ в калибре 9x25мм НТ. Популярен благодаря своей точности, стабильности и простоте использования по сравнению с другими пистолетами-пулемётами."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "cm5"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "cm5"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "cm5"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/cm5
	spawn_magazine_type = /obj/item/ammo_box/magazine/cm5
	fire_sound = 'modular_bandastation/weapon/sound/ranged/cm5.ogg'
	can_suppress = TRUE
	burst_size = 1
	fire_delay = 0.13 SECONDS
	actions_types = list()
	spread = 5
	recoil = 0.1
	load_sound = 'modular_bandastation/weapon/sound/ranged/cm5_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm5_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/cm5_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm5_unload.ogg'

/obj/item/gun/ballistic/automatic/cm5/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/cm5/update_icon_state()
	. = ..()
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"
	worn_icon_state = "[icon_state][magazine ? "":"_nomag"]"

/obj/item/gun/ballistic/automatic/cm5/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/cm5/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 26, \
		overlay_y = 13 \
	)

/obj/item/gun/ballistic/automatic/cm5/examine_more(mob/user)
	. = ..()
	. += "CM-5 - пистолет-пулемет разработанный оружейным отделом Нанотрейзен \
	под малоимпульсные патроны калибра 9x25мм. Данный пистолет-пулемет был создан для использования отделами \
	службы безопасности и группами быстрого реагирования на обьектах Нанотрейзен во всех возможных условиях, в которых обычно работает НТ, \
	в частности в условиях повышенной ионической среды, где использование стандартного лазерного вооружения \
	менее эффективно."

/obj/item/gun/ballistic/automatic/cm5/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/cm5/compact
	name = "CM-5c"
	desc = "Стандартный пистолет-пулемёт НТ в калибре 9x25мм НТ. Компактный укороченный вариант."
	icon_state = "cm5c"
	inhand_icon_state = "cm5c"
	worn_icon_state = "cm5c"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_LIGHT
	spread = 7
	recoil = 0.3

/obj/item/gun/ballistic/automatic/cm5/compact/examine_more(mob/user)
	. = ..()
	. += "Модель CM-5с является модификацией CM-5 с значительно укороченным стволом и удаленным прикладом. \
	Разработана для сотрудников корпоративных спецслужб Нанотрейзен с целью максимального увеличения мобильности без ущерба для огневой мощи, \
	хотя точность стрельбы на дальних дистанциях оставляет желать лучшего."

/obj/item/gun/ballistic/automatic/cm5/compact/no_mag
	spawnwithmagazine = FALSE
