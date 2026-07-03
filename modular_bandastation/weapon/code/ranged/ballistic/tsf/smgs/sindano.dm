// MARK: Base TSF SMG
/obj/item/gun/ballistic/automatic/sindano
	name = "Sindano submachine gun"
	desc = "Небольшой пистолет-пулемет, стреляющий патронами калибра .35 Sol. Часто встречается в руках ЧВК и других неблагонадежных корпораций. Принимает любой стандартный магазин от пистолетов ТСФ."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "sindano"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "sindano"
	special_mags = TRUE
	bolt_type = BOLT_TYPE_OPEN
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol
	spawn_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol/stendo
	fire_sound = 'modular_bandastation/weapon/sound/ranged/smg_light.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 11
	burst_size = 1
	spread = 5
	fire_delay = 0.2 SECONDS
	actions_types = list()
	recoil = 0.3

/obj/item/gun/ballistic/automatic/sindano/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 22, \
		overlay_y = 9 \
	)

/obj/item/gun/ballistic/automatic/sindano/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/gun/ballistic/automatic/sindano/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/sindano/examine_more(mob/user)
	. = ..()
	. += "Первоначально пистолет-пулемет \"Синдано\" производился по военному заказу для армии ТСФ. \
		Эти ПП можно было увидеть в руках у всех: медиков, корабельных техников, логистов, \
		а пилоты часто имели по несколько пушек, чтобы просто похвастаться. Из-за потребности ТСФ \
		продлить срок службы своих офицеров по логистике и квартирмейстеров, это оружие \
		использует тот же стандартный пистолетный патрон, что и большинство другого армейского оружия \
		малого калибра производимого для ТСФ. Это позволяет использовать взаимозаменяемые магазины для пистолетов \
		и пистолетов-пулеметов, круто!"

/obj/item/gun/ballistic/automatic/sindano/no_mag
	spawnwithmagazine = FALSE

// MARK: Compact TSF SMG
/obj/item/gun/ballistic/automatic/sindano/compact
	name = "compact Sindano submachine gun"
	icon_state = "sindano_compact"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_LIGHT
	suppressor_x_offset = 11
	spread = 7.5
	recoil = 0.5
	spawn_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol

/obj/item/gun/ballistic/automatic/sindano/compact/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/sindano/compact/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)
	spawnwithmagazine = /obj/item/ammo_box/magazine/c35sol_pistol/drum/ap

/obj/item/gun/ballistic/automatic/sindano/compact/examine_more(mob/user)
	. = ..()
	. += "Этот вариант \"Синдано\" является укороченной, компактной модификацией. \
		Благодаря малым габаритам эту версию пистолета-пулемета можно поместить в небольшую сумку даже \
		с глушителем, что делает этот вариант идеальным для скрытого ношения. \
		Но к сожалению, малая длина ствола и почти что несуществующий приклад не \
		позволяют стрелять точно на далекие или средние дистанции."

// MARK: Tactical(black) TSF SMG
/obj/item/gun/ballistic/automatic/sindano/black
	name = "tactical Sindano submachine gun"
	icon_state = "sindano_black"
	inhand_icon_state = "sindano_black"
	spawn_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol/drum
	spread = 5
	fire_delay = 0.1 SECONDS
	recoil = 0.1

/obj/item/gun/ballistic/automatic/sindano/black/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)
	spawnwithmagazine = /obj/item/ammo_box/magazine/c35sol_pistol/drum/ap
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/ballistic/automatic/sindano/black/examine_more(mob/user)
	. = ..()
	. += "На этом варианте \"Синдано\" установлены рукоятка и прицел, что значительно \
		улучшает контроль и точность стрельбы. Внутренний механизм также был настроен так \
		чтобы выстреливать намного больше боеприпасов в секунду. Этот экземпляр покрашен в черные \
		цвета для повышения тактикульности и серьезности намерений владельца."

/obj/item/gun/ballistic/automatic/sindano/black/no_mag
	spawnwithmagazine = FALSE
