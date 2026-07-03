/obj/item/gun/ballistic/automatic/pistol/zashch
	name = "P-10 'Zashchitnik' pistol"
	desc = "Массивный самозарядный пистолет калибра 10мм, получивший название 'Защитник'. Питается магазинами на 15 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "zashch"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "zashch"
	w_class = WEIGHT_CLASS_SMALL
	accepted_magazine_type = /obj/item/ammo_box/magazine/zashch
	can_suppress = TRUE
	suppressor_x_offset = 10
	fire_sound = 'modular_bandastation/weapon/sound/ranged/pistol_heavy.ogg'
	rack_sound = 'sound/items/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'
	fire_sound_volume = 80
	recoil = 0.3

/obj/item/gun/ballistic/automatic/pistol/zashch/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/pistol/zashch/examine_more(mob/user)
	. = ..()
	. += "Самозарядный пистолет \"Защитник\" — это мощный пистолет, в котором основное внимание уделено надежности и емкости магазина. <br>\
		Первоначально разработанный как замена устаревшим Макаровым и Стечкинам для армии СССП, а после как стандартный пистолет для милиции. \
		Оборонная Коллегия решила использовать патрон 10мм из-за его исключительной останавливающей силы \
		Этот массивный пистолет известен как мощное оружие с удивительно слабой отдачей благодаря \
		своим габаритам. Некоторые считают эту особенность преимуществом, а другие — недостатком при ведении прицельной стрельбы. \
		Размер был продиктован несколькими причинами во время проектирования, не в последнюю очередь тем, что он позволяет заряжать \
		большие магазины, которые позволяют вести чрезвычайно интенсивный огонь."

/obj/item/gun/ballistic/automatic/pistol/zashch/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		starting_light = new /obj/item/flashlight/seclite(src), \
		is_light_removable = FALSE, \
	)

/obj/item/gun/ballistic/automatic/pistol/zashch/no_mag
	spawnwithmagazine = FALSE
