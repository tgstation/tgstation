/obj/item/gun/ballistic/automatic/volna
	name = "'Volna-12' HMG"
	desc = "Относительно новый крупнокалиберный станковый пулемет калибра 12.7x108мм, часто встречающийся на военных обьектах СССП."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic64x32.dmi'
	icon_state = "volna"
	SET_BASE_PIXEL(-16, 0)
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "pmk"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "volnaclosedmag"
	base_icon_state = "volna"
	w_class = WEIGHT_CLASS_HUGE
	accepted_magazine_type = /obj/item/ammo_box/magazine/volna
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	actions_types = list()
	can_suppress = FALSE
	recoil = 1.5
	spread = 15
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	mag_display = TRUE
	tac_reloads = FALSE
	fire_sound = 'modular_bandastation/weapon/sound/ranged/dshk.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/dshk_cocked.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/dshk_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/dshk_unload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/dshk_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/dshk_unload.ogg'
	suppressed_sound = 'sound/items/weapons/gun/general/heavy_shot_suppressed.ogg'
	var/cover_open = FALSE
	slowdown = 1
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND

/datum/atom_skin/volna
	abstract_type = /datum/atom_skin/volna
	change_base_icon_state = TRUE

/datum/atom_skin/volna/default
	preview_name = "Green"
	new_icon_state = "volna"

/datum/atom_skin/volna/black
	preview_name = "Black"
	new_icon_state = "volna_black"

/obj/item/gun/ballistic/automatic/volna/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/volna)
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/volna/examine(mob/user)
	. = ..()
	. += "<b>АЛЬТ + ЛКМ</b> чтобы [cover_open ? "закрыть" : "открыть"] крышку ствольной коробки."
	if(cover_open && magazine)
		. += span_notice("Кажется, вы могли бы использовать <b>пустую руку</b>, чтобы вынуть магазин.")
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/volna/examine_more(mob/user)
	. = ..()
	. += "Тяжелый пулемет Волна-12 был разработан Оборонной Коллегией СССП в середине 26 века как замена устаревшему пулемету образца ДКШ. <br>\
		Разработка началась с целью создания более надежного и точного оружия для поддержки огнем в условиях крупных космических сражений и операций на орбитальных станциях. \
		Внешне напоминающий своего предшественника, Волна-12 претерпел значительные внутренние изменения, \
		газовая система и дульный тормоз были переработаны для снижения отдачи, что повысило точность при длительной стрельбе. <br>\
		Оснащенный калибром 12.7x108 и ленточным питанием на 50 патронов, его усиленный корпус весом около 30кг требуют использования треноги для стабильной стрельбы, \
		что делает его неподходящим для мобильных операций без дополнительной поддержки, такой как экзоскелеты или стационарные позиции. Хотя иногда бывают и исключения... \
		Несмотря на вес, Волна-12 легче предшественников благодаря новым материалам, и его сниженная отдача позволяет вести точный огонь даже в условиях низкой гравитации, \
		делая его идеальным для обороны космических станций и подавления вражеских десантов."

/obj/item/gun/ballistic/automatic/volna/click_alt(mob/user)
	cover_open = !cover_open
	balloon_alert(user, "крышка [cover_open ? "открыта" : "закрыта"]")
	playsound(src, 'sound/items/weapons/gun/l6/l6_door.ogg', 60, TRUE)
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/gun/ballistic/automatic/volna/update_icon_state()
	. = ..()
	inhand_icon_state = "[base_icon_state][cover_open ? "open" : "closed"][magazine ? "mag":"nomag"]"

/obj/item/gun/ballistic/automatic/volna/update_overlays()
	. = ..()
	. += "volna_door_[cover_open ? "open" : "closed"]"


/obj/item/gun/ballistic/automatic/volna/try_fire_gun(atom/target, mob/living/user, params)
	if(cover_open)
		balloon_alert(user, "закройте крышку!")
		return FALSE

	. = ..()
	if(.)
		update_appearance()
	return .

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/automatic/volna/attack_hand(mob/user, list/modifiers)
	if (loc != user)
		..()
		return
	if (!cover_open)
		balloon_alert(user, "откройте крышку!")
		return
	..()

/obj/item/gun/ballistic/automatic/volna/attackby(obj/item/A, mob/user, list/modifiers, list/attack_modifiers)
	if(!cover_open && istype(A, accepted_magazine_type))
		balloon_alert(user, "откройте крышку!")
		return
	..()
