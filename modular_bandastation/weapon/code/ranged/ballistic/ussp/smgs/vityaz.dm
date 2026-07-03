/obj/item/gun/ballistic/automatic/vityaz
	name = "PP-694 'Vityaz' submachine gun"
	desc = "Пистолет-пулемет калибра 10мм, используемый специальными силами СССП."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "vityaz"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "vityaz"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "vityaz"
	bolt_type = BOLT_TYPE_OPEN
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	empty_indicator = TRUE
	mag_display = TRUE
	accepted_magazine_type = /obj/item/ammo_box/magazine/smg10mm
	fire_sound = 'modular_bandastation/weapon/sound/ranged/smg_heavy_2.ogg'
	fire_sound_volume = 70
	load_sound = 'modular_bandastation/weapon/sound/ranged/napad_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/napad_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/napad_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/napad_unload.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 4
	burst_size = 1
	fire_delay = 0.2 SECONDS
	actions_types = list()
	spread = 6
	recoil = 0.1

/obj/item/gun/ballistic/automatic/vityaz/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/vityaz/examine_more(mob/user)
	. = ..()
	. += "ПП-694 \"Витязь\" - одно из новейших оружий, созданных Оборонной Коллегией для армии СССП. \
		Этот пистолет-пулемет был разработан для специальных сил СССП, в качестве скорострельного, компактного и мощного оружия для ближнего боя. \
		Поэтому он оснащен складным прикладом, магазином на 30 калибра 10мм, а также множественными планками для установки тактических аксессуаров. \
		Хотя он немного больше, чем пистолеты-пулеметы, используемые в ТСФ, он с лихвой компенсирует это своим калибром и значительной скорострельностью."

/obj/item/gun/ballistic/automatic/vityaz/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 38, \
		overlay_y = 11 \
	)

/obj/item/gun/ballistic/automatic/vityaz/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/automatic_fire, fire_delay)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/gun/ballistic/automatic/vityaz/update_icon_state()
	. = ..()
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"
	worn_icon_state = "[icon_state][magazine ? "":"_nomag"]"

/obj/item/gun/ballistic/automatic/vityaz/no_mag
	spawnwithmagazine = FALSE
