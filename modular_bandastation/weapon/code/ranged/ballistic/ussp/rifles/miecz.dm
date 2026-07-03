/obj/item/gun/ballistic/automatic/miecz
	name = "AMC-874 'Miecz' assault rifle"
	desc = "Модернизированный дизайн штурмовой винтовки под патрон 7.62x39мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "miecz"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "miecz"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "miecz"
	bolt_type = BOLT_TYPE_STANDARD
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/miecz
	fire_sound = 'modular_bandastation/weapon/sound/ranged/ak_shoot.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/ltrifle_cock.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/ltrifle_magin.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/ltrifle_magin.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/ltrifle_magout.ogg'
	fire_sound_volume = 70
	can_suppress = TRUE
	suppressor_x_offset = 2
	burst_size = 1
	fire_delay = 0.18 SECONDS
	actions_types = list()
	spread = 1.5
	recoil = 0.1
	SET_BASE_PIXEL(-8, 0)

/obj/item/gun/ballistic/automatic/miecz/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/miecz/examine_more(mob/user)
	. = ..()
	. += "Штурмовая винтовка AMC-874 \"Мечь\", это усовершенствованная конструкция на основе прошлых образцов по типу автомата АМК. \
	Эта винтовка была спроектированная с требованиями максимальной возможной управляемости и точности стрельбы.<br>\
	На затворе выгравировано «Оборонная Коллегия СССП». По центру приклада мелким шрифтом написано: 'Изделие-874 не использует компановку Бул-пап'."

/obj/item/gun/ballistic/automatic/miecz/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 32, \
		overlay_y = 10 \
	)

/obj/item/gun/ballistic/automatic/miecz/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/automatic_fire, fire_delay)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/gun/ballistic/automatic/miecz/update_icon_state()
	. = ..()
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"
	worn_icon_state = "[icon_state][magazine ? "":"_nomag"]"

/obj/item/gun/ballistic/automatic/miecz/no_mag
	spawnwithmagazine = FALSE
