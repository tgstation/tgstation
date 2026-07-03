/obj/item/gun/ballistic/automatic/lanca
	name = "BV-27 'Lanca' battle rifle"
	desc = "Боевая винтовка под патрон .310 Стрилка. Имеет встроенный прицел с удивительно высокой кратностью увеличения, учитывая его происхождение."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "lanca"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "lanca"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "lanca"
	SET_BASE_PIXEL(-8, 0)
	special_mags = FALSE
	bolt_type = BOLT_TYPE_STANDARD
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/strilka310
	fire_sound = 'modular_bandastation/weapon/sound/ranged/rifle_heavy_2.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/dmr_cocked.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/dmr_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/dmr_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/dmr_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/dmr_unload.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 4
	burst_size = 1
	fire_delay = 1 SECONDS
	actions_types = list()
	recoil = 0.5
	spread = 2.5

/obj/item/gun/ballistic/automatic/lanca/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/lanca/examine_more(mob/user)
	. = ..()
	. += "Разработка боевой винтовки \"Ланка\" началась как попытка заменить устаревшую \"Сахно\", на новую полуавтоматическую винтовку для армии СССП. <br>\
		Первоначальная разработка на основе модернизированной \"Сахно\" с добавлением возможности вести полуавтоматический огонь не удовлетворило комиссию. \
		Поэтому была взяты за основу модификации \"Сахно\" под именованием \"Ворон\" и немного измененны под запросы комиссии. \
		Для этого приклад был скелетонизирован, а ствольная нарезка заменена на минималистичный дизайн."

/obj/item/gun/ballistic/automatic/lanca/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)
	AddElement(/datum/element/update_icon_updates_onmob)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/gun/ballistic/automatic/lanca/update_icon_state()
	. = ..()
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"

/obj/item/gun/ballistic/automatic/lanca/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/lanca/army
	name = "BV-30 'Lanca' battle rifle"
	desc = "Относительно новая компактная длинноствольная боевая винтовка под патрон .310 Стрилка. Имеет встроенный прицел с \
		удивительно высокой кратностью увеличения, учитывая его происхождение."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "lanca_army"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "lanca_army"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "lanca_army"
	fire_delay = 0.3 SECONDS

/obj/item/gun/ballistic/automatic/lanca/army/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)

/obj/item/gun/ballistic/automatic/lanca/army/examine_more(mob/user)
	. = ..()
	. = "Образец боевой винтовки \"Ланка\" номер 30, это последняя вариация винтовки этого вида, созданная для специальных сил СССП.<br>\
		Новый вариант был основан на базе автомата АМК-462, изменение калибра потребовало обновления верхнего ресивера и установки мощной возвратной пружины, \
		что привело к увеличению веса винтовки, но это было компенсировано изпользованием новой компоновки и полимеров."

/obj/item/gun/ballistic/automatic/lanca/army/no_mag
	spawnwithmagazine = FALSE
