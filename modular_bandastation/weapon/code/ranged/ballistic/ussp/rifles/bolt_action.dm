/obj/item/gun/ballistic/rifle/boltaction
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	desc = "Винтовка Сахно с продольно-скользящим затвором, которое было (и, безусловно, остается) популярным среди \
		колонистов, карготехников, частных охранных сил, исследователей и других неприятных типов. Эта конкретная модель винтовки берет свое начало еще в 2440 году."
	sawn_desc = "Обрезанная версия винтовки Сахно, широко известная как \"Обрез\". \
		Вероятно, была причина, по которой изначально она не производилась такой короткой. \
		Несмотря на ужасающий характер модификации, оружие в остальном выглядит в хорошем состоянии."

/obj/item/gun/ballistic/rifle/boltaction/surplus
	name = "Sakhno Precision Rifle"
	icon_state = "sakhno"
	inhand_icon_state = "sakhno"
	worn_icon_state = "sakhno"
	desc = parent_type::desc + "<br>По какой-то причине все внутренние детали покрыты влагой."
	sawn_desc = "Обрезанная версия винтовки Сахно, широко известная как \"Обрез\". \
		Вероятно, была причина, по которой изначально она не производилась такой короткой. \
		Несмотря на ужасающий характер модификации, оружие в остальном выглядит в хорошем состоянии. \
		Обрезка оружия, по-видимому, не помогла решить проблему влажности."

/obj/item/gun/ballistic/rifle/boltaction/tactical
	name = "Sakhno Tactical Precision Rifle"
	desc = "Модификация давно устаревшей винтовки Сахно. Неизвестно, кем и когда была изготовлена эта модель винтовки и использовалась ли она когда-либо."
	sawn_desc = "Обрезанная модель винтовки Сахно, широко известная как \"Обрез\". \
		Вероятно, изначально было веское основание не производить винтовки такой короткой длины."
	icon_state = "sakhno_tactifucked"
	recoil = 0.7

/obj/item/gun/ballistic/rifle/boltaction/tactical/surplus
	desc = parent_type::desc + "<br>Однако можно с уверенностью сказать, что предыдущий владелец не бережно относился к оружию. \
		По какой-то причине все внутренние детали покрыты влагой."
	sawn_desc = parent_type::sawn_desc + "<br>Обрезка оружия, по-видимому, не помогла решить проблему влажности."
	can_jam = TRUE

/obj/item/gun/ballistic/rifle/boltaction/donkrifle
	icon = 'icons/obj/weapons/guns/wide_guns.dmi'
	worn_icon = 'icons/mob/clothing/back.dmi'

/obj/item/gun/ballistic/rifle/boltaction/pipegun
	icon = 'icons/obj/weapons/guns/wide_guns.dmi'
	worn_icon = 'icons/mob/clothing/back.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'

/obj/item/gun/ballistic/rifle/boltaction/pipegun/pistol
	worn_icon = 'icons/mob/clothing/belt.dmi'

/obj/item/gun/ballistic/rifle/boltaction/harpoon
	worn_icon = 'icons/mob/clothing/back.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'

/obj/item/gun/ballistic/rifle/boltaction/army
	name = "Sakhno M2500 Army"
	desc = "Давно устаревшая винтовка Сахно поздней армейской модели. Эта конкретная модель винтовки датируется 2500 годом."
	sawn_desc = "Обрезанная военная модель винтовки Сахно, широко известная как \"Обрез\". \
		Вероятно, была причина, по которой изначально она не производилась такой короткой. \
		Несмотря на ужасающий характер модификации, оружие в остальном выглядит в хорошем состоянии."
	icon_state = "sakhno_army"
	inhand_icon_state = "sakhno_army"
	worn_icon_state = "sakhno_army"

/obj/item/gun/ballistic/rifle/boltaction/army/surplus
	desc = parent_type::desc + "<br>По какой-то причине все внутренние детали покрыты влагой."
	sawn_desc = "Обрезанная военная модель винтовки Сахно, широко известная как \"Обрез\". \
		Вероятно, была причина, по которой изначально она не производилась такой короткой. \
		Обрезка оружия, по-видимому, не помогла решить проблему влажности."
	can_jam = TRUE

/obj/item/gun/ballistic/rifle/boltaction/army/tactical
	name = "Sakhno M2550 Army"
	desc = "Модификация устаревшей винтовки Сахно поздней армейской модели, на боковой стороне которой выбита надпись \"Сахно M2550 Армейская\". \
		Неизвестно, для какой армии была изготовлена эта модель винтовки и использовалась ли она когда-либо в армии какого-либо рода."
	sawn_desc = "Обрезанная военная модель винтовки Сахно, широко известная как \"Обрез\". \
		На боковой стороне винтовки выбита надпись \"Сахно M2550 Армейская\". \
		Вероятно, изначально было веское основание не производить винтовки такой короткой длины."
	icon_state = "sakhno_tactifucked_army"
	recoil = 0.5

/obj/item/gun/ballistic/rifle/boltaction/army/tactical/surplus
	desc = parent_type::desc + "<br>Однако можно с уверенностью сказать, что предыдущий владелец не бережно относился к оружию. \
		По какой-то причине все внутренние детали покрыты влагой."
	sawn_desc = parent_type::sawn_desc + "<br>Обрезка оружия, по-видимому, не помогла решить проблему влажности."
	can_jam = TRUE

/obj/item/gun/ballistic/rifle/krov
	name = "Krov precision rifle"
	desc = "Сильно модифицированная винтовка Сахно, с деталями изготовленными компанией Xhihao. \
		Имеет корпус, в котором вместо внутреннего магазина используются магазины от винтовок \"Ланка\"."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "rengo"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "sakhno"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "sakhno"
	slot_flags = ITEM_SLOT_BACK
	SET_BASE_PIXEL(-8, 0)
	accepted_magazine_type = /obj/item/ammo_box/magazine/strilka310 //lanca
	mag_display = TRUE
	tac_reloads = TRUE
	internal_magazine = FALSE
	can_be_sawn_off = FALSE
	weapon_weight = WEAPON_HEAVY
	recoil = 0.5

/obj/item/gun/ballistic/rifle/krov/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/rifle/krov/examine_more(mob/user)
	. = ..()
	. += "Винтовка \"Ворон\" является модификацией известной винтовки Сахно, обладающей \"современными\" характеристиками, такими как направляющие для аксессуаров и съемные магазины. <br>\
		Первоначально набор деталей продавался в одном комплекте компанией Xhihao, комплект \"Ворон\" предназначен для замены большей части деталей типичной винтовки Сахно \
		с целью улучшения эргономики, уменьшения веса и общего повышения удобства для пользователя. <br>\
		Хотя это и не особо повышает характеристики винтовки, совместимость с магазинами от винтовок \"Ланка\" \
		позволяет увеличить вместимость по сравнению с внутренними магазинами на пять патронов, которые входят в стандартную комплектацию Сахно, \
		а прицел входящий в комплект, изначально предназначенный для использования с винтовками \"Ланка\", вполне подходит благодаря общей компоновке. \
		Оружие также в целом немного короче, что облегчает его обращение для стрелков небольшого роста и/или \
		в неудобных условиях близкого боя для высокоточного оружия. Из-за уменьшенного пространства между компонентами \"Ворон\" нельзя обрезать \
		срезание любой части этого оружия, по сути, сделает его либо опасным для стрельбы, либо нефункциональным."

/obj/item/gun/ballistic/rifle/krov/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)

/obj/item/gun/ballistic/rifle/krov/add_bayonet_point()
	AddComponent(/datum/component/bayonet_attachable, offset_x = 35, offset_y = 12)

/obj/item/gun/ballistic/rifle/krov/no_mag
	bolt_locked = TRUE // so the bolt starts visibly open
	spawn_magazine_type = /obj/item/ammo_box/magazine/strilka310/starts_empty

/obj/item/gun/ballistic/rifle/sks
	desc = "Возрождение старинной полуавтоматической винтовки СКС, переработанной для использования патронов калибра .310 Стрилка. \
		Эта винтовка должна была заменить Сахно, но была остановлена появлением боевых винтовок Ланка. Это оружие заняло уникальное место в истории среди населения союза. \
		Из-за малого количества произведенных образцов, оно встречается реже чем Сахно и поэтому является церемониальным оружием в армии СССП. \
		Пограничные поселенцы известны тем, что владеют таким оружием для охоты. Или для отражения назойливых сборщиков налогов."

/obj/item/gun/ballistic/rifle/sks/c762x54mmr
	name = "Old Sakhno SKS semi-automatic rifle"
	desc = parent_type::desc + "<br>Этот вариант винтовки еще более редкий, так как не был переделан под новый калибр .310 Стрилка. \
		Кто знает, может быть это даже раритеный оригинал."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/sks/c762x54mmr
	projectile_damage_multiplier = 1

/obj/item/gun/ballistic/rifle/sks/c762x54mmr/empty
	bolt_locked = TRUE
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/sks/c762x54mmr/empty

/obj/item/gun/ballistic/rifle/boltaction/mosin
	name = "Mosin-Nagant rifle"
	desc = "Классическая винтовка Мосина-Нагана. Такие больше не делают. Ладно, честно говоря, это на самом деле \
		новая отреставрированная версия. Так что работает просто отлично! Часто встречается в музеях, оружейных коллекциях или в руках новобранцев в качестве тренеровочного оружия, \
		а иногда и в руках революционеров, бандитов или работников оружейных складов. Все еще немного сырая на ощупь."
	sawn_desc = "Обрезанная винтовка Мосина-Нагана, больше известная как \"Обрез\". \
		Наверняка была причина, по которой изначально не производили столь короткие модели. \
		Этот экземпляр все еще находится в удивительно хорошем состоянии. Часто встречается в руках \
		коллекционеров или революционеров без чувства заботы об антиквариате, \
		пьяных бандитов, убийц из Кооператива \"Тигр\" и пьяных работников оружейных складов. <I>По-прежнему</I> немного сырая на ощупь."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "mosin"
	inhand_icon_state = "mosin"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "mosin"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/mosin

/obj/item/gun/ballistic/rifle/boltaction/mosin/add_bayonet_point()
	AddComponent(/datum/component/bayonet_attachable, offset_x = 27, offset_y = 13)

/obj/item/gun/ballistic/rifle/boltaction/mosin/surplus
	desc = "Классическая винтовка Мосина-Нагана, испорченная многовековой влагой. Некоторые оружейные эксперты утверждают, что влага \
		это знак удачи. Трезвый пользователь будет понимать, что эта штука будет блять заклинивать. Постоянно. \
		Часто встречается в руках бедных новобранцев, террористических ячеек из Кооператива \"Тигр\", бандитов, \
		криозамороженных космических русских и неудачливых работников оружейных складов. ЧРЕЗВЫЧАЙНО сырая."
	sawn_desc = "Обрезанная винтовка Мосина-Нагана, больше известная как \"Обрез\". \
		Наверняка была причина, по которой изначально не производили столь короткие модели. \
		Этот экземпляр был испорчен многовековой влажностью и БУДЕТ заклинивать. Часто встречается в руках \
		пьяных революционеров, ОЧЕНЬ пьяных бандитов, пьяных убийц из Кооператива \"Тигр\", \
		пьяных криозамороженных космических русских, пьяных работников оружейных складов с желанием умереть \
		и сотрудников охраны, не особо заботящихся о профессиональном поведении, когда «арестовывают» выстрелом в затылок \
		до тех пор, пока пушка не щелкнет. ЧРЕЗВЫЧАЙНО сырая."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/mosin
	can_jam = TRUE

/obj/item/gun/ballistic/rifle/boltaction/mosin/empty
	bolt_locked = TRUE
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/mosin/empty

/obj/item/gun/ballistic/rifle/boltaction/mosin/surplus/empty
	bolt_locked = TRUE
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/mosin/empty

/obj/item/gun/ballistic/rifle/boltaction/mosin/strilka310
	desc = parent_type::desc + "<br>Кто-то решил что эта винтовка еще должна послужить и переделал ее под новый калибр .310 Стрилка. Ужасный и безумный человек. \
		Остается надеятся что это не раритеный оригинал."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/mosin/strilka

/obj/item/gun/ballistic/rifle/boltaction/mosin/strilka310/empty
	bolt_locked = TRUE
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/mosin/strilka/empty
