/obj/item/gun/ballistic/revolver/dvoystvol
	name = "Dvoystvol-6 revolver"
	desc = "Уникальный дизайн револьвера имеющий два ствола под винтовочный калибр .310 для элитных подразделений СССП."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/dvoystvol/rev310
	recoil = 1
	weapon_weight = WEAPON_LIGHT
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "sakhnomanni"
	fire_sound = 'modular_bandastation/weapon/sound/ranged/revolver_fire.ogg'
	spread = 2
	burst_delay = 2
	burst_size = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/gun/ballistic/revolver/dvoystvol/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/revolver/dvoystvol/examine_more(mob/user)
	. = ..()
	. += "Револьвер Двоствол-7 был разработан Оборонной Коллегией СССП в конце 26 века как уникальное оружие для элитных подразделений. \
		Эта инновационная конструкция с двумя стволами и барабаном на 6 патронов калибра 7.62x54mmR сочетает в себе мощь винтовочных боеприпасов и компактность револьверной системы. \
		Двойные стволы позволяют вести одновременный огонь или переключаться между ними для повышения огневой мощи, а эргономичный хват и усиленная рама минимизируют отдачу. \
		Разработанный с использованием усиленных полимеров и титановых сплавов, он выдерживает высокое давление обоих выстрелов и обеспечивает высокую надежность.  \
		Конструкция включает усовершенствованный механизм взвода для работы в экстремальных условиях, что делает Двоствол-7 популярным среди командиров космических экспедиций СССП."

/obj/item/gun/ballistic/revolver/dvoystvol/high_caliber
	name = "Dvoystvol-60 revolver"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/dvoystvol/rev60
	recoil = 5
	weapon_weight = WEAPON_LIGHT
	icon_state = "sakhnomanni_big"
	fire_sound = 'modular_bandastation/weapon/sound/ranged/revolver_fire_2.ogg'
	fire_sound_volume = 100

/obj/item/gun/ballistic/revolver/dvoystvol/high_caliber/examine_more(mob/user)
	. = ..()
	. += "<br>Этот образец создан под крупнокалиберный безгильзовый винтовочный патрон .60 Стрела, что делает его еще более уникальнее чем оригинальная модель. \
		И в тоже время, кто в здравом уме сделал револьвер под крупнокалиберные винтовочные патроны?"

/obj/item/gun/ballistic/revolver/dvoystvol/low_caliber
	name = "Dvoystvol-8 revolver"
	desc = "Уникальный дизайн револьвера имеющий два ствола под калибр 7.62x38мм для элитных подразделений СССП."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/dvoystvol/rev762
	recoil = 1
	weapon_weight = WEAPON_LIGHT
	icon_state = "sakhnomanni_small"

/obj/item/gun/ballistic/revolver/dvoystvol/low_caliber/examine_more(mob/user)
	. = ..()
	. += "<br>Этот образец создан под более привычный патрон калибра 7.62x38мм, что делает его более приближенным к обычным револьверам."
