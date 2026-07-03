/obj/item/gun/ballistic/automatic/dshk
	name = "DKSH-12.7 'Dushka' HMG"
	desc = "Тяжелый стационарный пулемет калибра 12.7x108мм переоснащенный в ручной вариант, мощное оружие поддержки для пехоты. \
	За свои характеристики солдаты часто дают ему более ласковое название - \"Душка\""
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "dshk"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "dshk"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "dshkclosedmag"
	base_icon_state = "dshk"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/dshk
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	actions_types = list()
	can_suppress = FALSE
	recoil = 1.2
	spread = 10
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	mag_display = TRUE
	mag_display_ammo = TRUE
	tac_reloads = FALSE
	fire_sound = 'modular_bandastation/weapon/sound/ranged/dshk.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/dshk_cocked_alt.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/dshk_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/dshk_unload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/dshk_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/dshk_unload.ogg'
	suppressed_sound = 'sound/items/weapons/gun/general/heavy_shot_suppressed.ogg'
	slowdown = 1
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	var/cover_open = FALSE

/obj/item/gun/ballistic/automatic/dshk/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)
	AddElement(/datum/element/drag_pickup)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/gun/ballistic/automatic/dshk/examine(mob/user)
	. = ..()
	. += "<b>АЛЬТ + ЛКМ</b> чтобы [cover_open ? "закрыть" : "открыть"] крышку ствольной коробки."
	if(cover_open && magazine)
		. += span_notice("Кажется, вы могли бы использовать <b>пустую руку</b>, чтобы вынуть магазин.")
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/dshk/examine_more(mob/user)
	. = ..()
	. += "Тяжелый пулемет ДКШ был разработан Оборонной Коллегией СССП в начале 26 века как мощное стационарного оружие для поддержки войск. <br>\
		Созданный на основе древнего дизайна, этот пулемет был разработан с использованием титановых сплавов и керамических покрытий для повышения долговечности в условиях космоса. \
		Оснащенный калибром 12.7x108 и ленточным питанием на 50 патронов, он обеспечивает мощную огневую поддержку благодаря комбинации своей скорострельности и разрушительной силы калибра, \
		что делает его идеальным для обороны ключевых позиций. <br>Вместе с появлением и распространением нового пулемета \"Волна-12\", созданным на замену устаревшему ДКШ, \
		побудило Оборонную Коллегию придумать новые предназначения для этих пулеметов, что привело к появлению самых разных вариантов ДКШ, в том числе ручных, который вы видите сейчас."

/obj/item/gun/ballistic/automatic/dshk/click_alt(mob/user)
	cover_open = !cover_open
	balloon_alert(user, "крышка [cover_open ? "открыта" : "закрыта"]")
	playsound(src, 'sound/items/weapons/gun/l6/l6_door.ogg', 60, TRUE)
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/gun/ballistic/automatic/dshk/update_icon_state()
	. = ..()
	inhand_icon_state = "[base_icon_state][cover_open ? "open" : "closed"][magazine ? "mag":"nomag"]"

/obj/item/gun/ballistic/automatic/dshk/update_overlays()
	. = ..()
	. += "dshk_door_[cover_open ? "open" : "closed"]"

/obj/item/gun/ballistic/automatic/dshk/try_fire_gun(atom/target, mob/living/user, params)
	if(cover_open)
		balloon_alert(user, "закройте крышку!")
		return FALSE

	. = ..()
	if(.)
		update_appearance()
	return .

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/automatic/dshk/attack_hand(mob/user, list/modifiers)
	if (loc != user)
		..()
		return
	if (!cover_open)
		balloon_alert(user, "откройте крышку!")
		return
	..()

/obj/item/gun/ballistic/automatic/dshk/attackby(obj/item/A, mob/user, list/modifiers, list/attack_modifiers)
	if(!cover_open && istype(A, accepted_magazine_type))
		balloon_alert(user, "откройте крышку!")
		return
	..()

/obj/item/gun/ballistic/automatic/dshk/shotgun
	name = "DKSH-12ga 'Dashka' HMG"
	desc = "Тяжелый стационарный пулемет, редкий образец переоснащенный в ручной вариант под 12-ый калибр, оружие для зачистки всего живого и неживого в узких пространствах. \
	За свою индетичность с оригиналом, но в тоже время различие, солдаты часто дают ему схожее ласковое название - \"Дашка\""
	icon_state = "dshk12"
	base_icon_state = "dshk12"
	accepted_magazine_type = /obj/item/ammo_box/magazine/dshk/c12ga
	spread = 15

/obj/item/gun/ballistic/automatic/dshk/shotgun/examine_more(mob/user)
	. = ..()
	. += "<br>Этот образец ДКШ является ограниченной партией от Оборонной Коллегии... Или же самоделкой заскучавшего оружейника. При 'обновлении' данного ДКШ, \
	создатели либо были дико пьяны, что впрочем не удивительно, либо хотели ответить на вопрос: 'А что если?'"
