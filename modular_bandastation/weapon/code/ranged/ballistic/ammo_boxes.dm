// MARK: .35 Sol Short
/obj/item/ammo_box/c35sol
	name = "ammo box (.35 Sol Short)"
	desc = "Коробка с пистолетными патронами калибра .35 Sol Short, вмещает 30 патрона."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "35box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_SOL35SHORT
	ammo_type = /obj/item/ammo_casing/c35sol
	max_ammo = 30

/obj/item/ammo_box/c35sol/rubber
	name = "ammo box (.35 Sol Short rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "35box_disabler"
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/c35sol/hp
	name = "ammo box (.35 Sol Short hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "35box_shrapnel"
	ammo_type = /obj/item/ammo_casing/c35sol/hp

/obj/item/ammo_box/c35sol/ap
	name = "ammo box (.35 Sol Short armor-piercing)"
	desc = parent_type::desc + "<br>Серебрянная полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "35box_ap"
	ammo_type = /obj/item/ammo_casing/c35sol/ap

// MARK: .40 Sol Long
/obj/item/ammo_box/c40sol
	name = "ammo box (.40 Sol Long)"
	desc = "Коробка с винтовочными патронами калибра .40 Sol Long, вмещает 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "40box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_SOL40LONG
	ammo_type = /obj/item/ammo_casing/c40sol
	max_ammo = 30

/obj/item/ammo_box/c40sol/fragmentation
	name = "ammo box (.40 Sol Long resin-fragmentation)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что в ней должны храниться травматические боеприпасы."
	icon_state = "40box_disabler"
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation

/obj/item/ammo_box/c40sol/ap
	name = "ammo box (.40 Sol Long armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "40box_pierce"
	ammo_type = /obj/item/ammo_casing/c40sol/ap

/obj/item/ammo_box/c40sol/incendiary
	name = "ammo box (.40 Sol Long incendiary)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "40box_flame"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary

// MARK: 7.62x39mm
/obj/item/ammo_box/c762x39
	name = "ammo box (7.62x39mm)"
	desc = "Коробка с винтовочными патронами калибра 7.62x39мм, вмещает 45 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "762x39box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_762x39mm
	ammo_type = /obj/item/ammo_casing/c762x39
	max_ammo = 45

/obj/item/ammo_box/c762x39/ricochet
	name = "ammo box (7.62x39mm ricochet)"
	desc = parent_type::desc + "<br>Темно-красная марка указывает на то, что в ней должны храниться спортивные боеприпасы."
	icon_state = "762x39box_ricochet"
	ammo_type = /obj/item/ammo_casing/c762x39/ricochet

/obj/item/ammo_box/c762x39/incendiary
	name = "ammo box (7.62x39mm incendiary)"
	desc = parent_type::desc + "<br>Красная марка указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "762x39box_fire"
	ammo_type = /obj/item/ammo_casing/c762x39/incendiary

/obj/item/ammo_box/c762x39/ap
	name = "ammo box (7.62x39mm armor-piercing)"
	desc = parent_type::desc + "<br>Серая марка указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "762x39box_ap"
	ammo_type = /obj/item/ammo_casing/c762x39/ap

/obj/item/ammo_box/c762x39/emp
	name = "ammo box (7.62x39mm ion)"
	desc = parent_type::desc + "<br>Голубая марка указывает на то, что в ней должны храниться ионные боеприпасы электромагнитного действия."
	icon_state = "762x39box_emp"
	ammo_type = /obj/item/ammo_casing/c762x39/emp

/obj/item/ammo_box/c762x39/civilian
	name = "ammo box (7.62x39mm civilian)"
	desc = parent_type::desc + "<br>Желтая марка указывает на то, что в ней должны храниться гражданские боеприпасы."
	icon_state = "762x39boxmini_civ"
	ammo_type = /obj/item/ammo_casing/c762x39/civilian
	max_ammo = 30

/obj/item/ammo_box/c762x39/rubber
	name = "ammo box (7.62x39mm rubber)"
	desc = parent_type::desc + "<br>Темно-синия марка указывает на то, что в ней должны храниться травматические боеприпасы."
	icon_state = "762x39box_rubber"
	ammo_type = /obj/item/ammo_casing/c762x39/rubber

/obj/item/ammo_box/c762x39/hunting
	name = "ammo box (7.62x39mm hunting)"
	desc = parent_type::desc + "<br>Темно-зеленая марка указывает на то, что в ней должны храниться охотничьи боеприпасы."
	icon_state = "762x39box_xeno"
	ammo_type = /obj/item/ammo_casing/c762x39/hunting

/obj/item/ammo_box/c762x39/blank
	name = "ammo box (7.62x39mm blank)"
	desc = parent_type::desc + "<br>Белая марка указывает на то, что в ней должны храниться холостые боеприпасы."
	icon_state = "762x39box_blank"
	ammo_type = /obj/item/ammo_casing/c762x39/blank

// MARK: 7.62x38mmR
/obj/item/ammo_box/speedloader/n762_cylinder
	name = "speed loader (7.62x38mmR)"
	desc = "Предназначен для быстрой перезарядки револьверов калибра 7.62x38ммР. Произведено в СССП."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 7
	caliber = CALIBER_N762
	multiple_sprites = AMMO_BOX_PER_BULLET
	item_flags = NO_MAT_REDEMPTION
	ammo_band_icon = "+357_ammo_band"
	ammo_band_color = null

/obj/item/ammo_box/speedloader/strilka310_cylinder
	name = "speed loader (.310 Strilka)"
	desc = "Предназначен для быстрой перезарядки револьверов калибра .310 Стрилка. Произведено в СССП, не удивительно."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "310speedload"
	ammo_type = /obj/item/ammo_casing/strilka310
	max_ammo = 8
	caliber = CALIBER_STRILKA310
	multiple_sprites = AMMO_BOX_PER_BULLET
	item_flags = NO_MAT_REDEMPTION
	ammo_band_icon = "+357_ammo_band"
	ammo_band_color = null

// MARK: .310
/obj/item/ammo_box/speedloader/strilka310
	desc = "Пятизарядная обойма для винтовок калибра .310 Strilka."

/obj/item/ammo_box/speedloader/strilka310/ap
	name = "stripper clip (.310 Strilka armor-piercing)"
	desc = parent_type::desc + " В этой должны находиться бронебойные патроны."
	ammo_type = /obj/item/ammo_casing/strilka310/ap

/obj/item/ammo_box/speedloader/strilka310/hp
	name = "stripper clip (.310 Strilka hollow-point)"
	desc = parent_type::desc + " В этой должны находиться экспансивные патроны."
	ammo_type = /obj/item/ammo_casing/strilka310/hp

/obj/item/ammo_box/speedloader/strilka310/incendiary
	name = "stripper clip (.310 Strilka incendiary)"
	desc = parent_type::desc + " В этой должны находиться зажигательные патроны."
	ammo_type = /obj/item/ammo_casing/strilka310/incendiary

/obj/item/ammo_box/speedloader/strilka310/surplus
	desc = parent_type::desc + " На этой есть несколько пятен ржавчины там, где нет избыточного количества оружейной смазки."

/obj/item/ammo_box/speedloader/strilka310/phasic
	desc = parent_type::desc + " В этой должны находиться фазовые патроны. \
		Они были спешно разработанными после инцидента, когда в результате осечки было уничтожено бесценное яйцо Фаберже из Вигокса, принадлежавшее Атракору Силверскейлу. \
		Эти причудливые пули проходят сквозь ценные предметы, пока не попадают в гораздо менее дорогой человеческий череп."

/obj/item/ammo_box/strilka310
	name = "ammo box (.310 Strilka)"
	desc = "Коробка с винтовочными патронами калибра .310, вмещает 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "310_box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_STRILKA310
	ammo_type = /obj/item/ammo_casing/strilka310
	max_ammo = 30

/obj/item/ammo_box/strilka310/hp
	name = "ammo box (.310 Strilka hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "310_box_hp"
	ammo_type = /obj/item/ammo_casing/strilka310/hp

/obj/item/ammo_box/strilka310/ap
	name = "ammo box (.310 Strilka armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "310_box_ap"
	ammo_type = /obj/item/ammo_casing/strilka310/ap

/obj/item/ammo_box/strilka310/incendiary
	name = "ammo box (.310 Strilka incendiary)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "310_box_incendiary"
	ammo_type = /obj/item/ammo_casing/strilka310/incendiary

// MARK: 7.62x54mmR
/obj/item/ammo_box/speedloader/c762x54mmr
	name = "stripper clip (7.62x54mmR)"
	desc = "Пятизарядная обойма для винтовок калибра 7.62x54ммР."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "762_strip"
	ammo_type = /obj/item/ammo_casing/c762x54mmr
	max_ammo = 5
	ammo_box_multiload = AMMO_BOX_MULTILOAD_ALL
	caliber = CALIBER_762x54mmR

/obj/item/ammo_box/speedloader/c762x54mmr/rubber
	name = "stripper clip (7.62x54mmR rubber)"
	desc = parent_type::desc + "В этой должны находиться травматические патроны. Кто вообще до такого додумался?"
	ammo_type = /obj/item/ammo_casing/c762x54mmr/rubber

/obj/item/ammo_box/speedloader/c762x54mmr/ap
	name = "stripper clip (7.62x54mmR armor-piercing)"
	desc = parent_type::desc + "В этой должны находиться бронебойные патроны."
	ammo_type = /obj/item/ammo_casing/c762x54mmr/ap

/obj/item/ammo_box/speedloader/c762x54mmr/hp
	name = "stripper clip (7.62x54mmR hollow-point)"
	desc = parent_type::desc + "В этой должны находиться экспансивные патроны."
	ammo_type = /obj/item/ammo_casing/c762x54mmr/hp

/obj/item/ammo_box/speedloader/c762x54mmr/incendiary
	name = "stripper clip (7.62x54mmR incendiary)"
	desc = parent_type::desc + "В этой должны находиться зажигательные патроны."
	ammo_type = /obj/item/ammo_casing/c762x54mmr/incendiary

/obj/item/ammo_box/c762x54mmr
	name = "ammo box (7.62x54mmR)"
	desc = "Коробка с винтовочными патронами калибра 7.62x54ммР, вмещает 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "a762_54box"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_762x54mmR
	ammo_type = /obj/item/ammo_casing/c762x54mmr
	max_ammo = 30

/obj/item/ammo_box/c762x54mmr/rubber
	name = "ammo box (7.62x54mmR rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что в ней должны храниться травматические боеприпасы."
	icon_state = "a762_54box-rubber"
	ammo_type = /obj/item/ammo_casing/c762x54mmr/rubber

/obj/item/ammo_box/c762x54mmr/hp
	name = "ammo box (7.62x54mmR hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "a762_54box-hp"
	ammo_type = /obj/item/ammo_casing/c762x54mmr/hp

/obj/item/ammo_box/c762x54mmr/ap
	name = "ammo box (7.62x54mmR armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "a762_54box-ap"
	ammo_type = /obj/item/ammo_casing/c762x54mmr/ap

/obj/item/ammo_box/c762x54mmr/incendiary
	name = "ammo box (7.62x54mmR incendiary)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "a762_54box-incendiary"
	ammo_type = /obj/item/ammo_casing/c762x54mmr/incendiary

// MARK: 9x25mm NT
/obj/item/ammo_box/c9x25mm
	name = "ammo box (9x25mm NT)"
	desc = "Коробка с пистолетными патронами калибра 9x25мм НТ, вмещает 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "9mmbox"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_9x25NT
	ammo_type = /obj/item/ammo_casing/c9x25mm
	max_ammo = 30

/obj/item/ammo_box/c9x25mm/rubber
	name = "ammo box (9x25mm NT rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "9mmbox-rubber"
	ammo_type = /obj/item/ammo_casing/c9x25mm/rubber

/obj/item/ammo_box/c9x25mm/hp
	name = "ammo box (9x25mm NT hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "9mmbox-hp"
	ammo_type = /obj/item/ammo_casing/c9x25mm/hp

/obj/item/ammo_box/c9x25mm/ap
	name = "ammo box (9x25mm NT armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "9mmbox-ap"
	ammo_type = /obj/item/ammo_casing/c9x25mm/ap

// MARK: .38
/obj/item/ammo_box/c38
	name = "ammo box (.38)"
	desc = "Коробка с пистолетными патронами калибра .38, вмещает 25 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "38box"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_38
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 25

/obj/item/ammo_box/c38/rubber
	name = "ammo box (.38 rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "38box-rubber"
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy

/obj/item/ammo_box/c38/hp
	name = "ammo box (.38 DumDum)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы Дум-Дум."
	icon_state = "38box-hp"
	ammo_type = /obj/item/ammo_casing/c38/dumdum

/obj/item/ammo_box/c38/ap
	name = "ammo box (.38 armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "38box-ap"
	ammo_type = /obj/item/ammo_casing/c38/ap

/obj/item/ammo_box/c38/iceblox
	name = "ammo box (.38 Iceblox)"
	desc = parent_type::desc + "<br>Надпись на коробке указывает на то, что в ней должны храниться замораживающие боеприпасы."
	icon_state = "38box-iceblox"
	ammo_type = /obj/item/ammo_casing/c38/iceblox

/obj/item/ammo_box/c38/hotshot
	name = "ammo box (.38 Hot-Shot)"
	desc = parent_type::desc + "<br>Надпись на коробке указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "38box-hotshot"
	ammo_type = /obj/item/ammo_casing/c38/hotshot

// MARK: .357
/obj/item/ammo_box/c357
	name = "ammo box (.357)"
	desc = "Коробка с пистолетными патронами калибра .357, вмещает 20 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "357box"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_357
	ammo_type = /obj/item/ammo_casing/c357
	max_ammo = 20

/obj/item/ammo_box/c357/heartseeker
	name = "ammo box (.357 heartseeker)"
	desc = parent_type::desc + "<br>Красная пуля указывает на то, что здесь должны храниться специальные самодоводящиеся боеприпасы."
	icon_state = "357box-heartseeker"
	ammo_type = /obj/item/ammo_casing/c357/heartseeker

/obj/item/ammo_box/c357/match
	name = "ammo box (.357 match)"
	desc = parent_type::desc + "<br>Синяя пуля указывает на то, что в ней должны храниться рикошетно-способные боеприпасы."
	icon_state = "357box-match"
	ammo_type = /obj/item/ammo_casing/c357/match

/obj/item/ammo_box/c357/ap
	name = "ammo box (.357 phasic)"
	desc = parent_type::desc + "<br>Серая пуля указывает на то, что в ней должны храниться бронебойно-фазовые боеприпасы."
	icon_state = "357box-ap"
	ammo_type = /obj/item/ammo_casing/c357/phasic

// MARK: .45
/obj/item/ammo_box/c45
	name = "ammo box (.45)"
	desc = "Коробка с пистолетными патронами калибра .45, вмещает 20 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "45box"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_45
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/c45/rubber
	name = "ammo box (.45 rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "45box-rubber"
	ammo_type = /obj/item/ammo_casing/c45/rubber

/obj/item/ammo_box/c45/hp
	name = "ammo box (.45 hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "45box-hp"
	ammo_type = /obj/item/ammo_casing/c45/hp

/obj/item/ammo_box/c45/ap
	name = "ammo box (.45 armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "45box-ap"
	ammo_type = /obj/item/ammo_casing/c45/ap

// MARK: 10mm
/obj/item/ammo_box/c10mm
	name = "ammo box (10mm)"
	desc = "Коробка с пистолетными патронами калибра 10мм, вмещает 20 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "10mmbox"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/c10mm/rubber
	name = "ammo box (10mm rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "10mmbox-rubber"
	ammo_type = /obj/item/ammo_casing/c10mm/rubber

/obj/item/ammo_box/c10mm/hp
	name = "ammo box (10mm hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "10mmbox-hp"
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/c10mm/ap
	name = "ammo box (10mm armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "10mmbox-ap"
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/c10mm/incendiary
	name = "ammo box (10mm incendiary)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "10mmbox-incendiary"
	ammo_type = /obj/item/ammo_casing/c10mm/fire

// MARK: 9mm
/obj/item/ammo_box/c9mm
	name = "ammo box (9mm)"
	desc = "Коробка с пистолетными патронами калибра 9мм, вмещает 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "9mmbox-surplus"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/c9mm/rubber
	name = "ammo box (9mm rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "9mmbox-rubber"
	ammo_type = /obj/item/ammo_casing/c9mm/rubber

/obj/item/ammo_box/c9mm/hp
	name = "ammo box (9mm hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "9mmbox-hp"
	ammo_type = /obj/item/ammo_casing/c9mm/hp

/obj/item/ammo_box/c9mm/ap
	name = "ammo box (9mm armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "9mmbox-ap"
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/c9mm/incendiary
	name = "ammo box (9mm incendiary)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "9mmbox-incendiary"
	ammo_type = /obj/item/ammo_casing/c9mm/fire

// MARK: 5.56x45
/obj/item/ammo_box/c223
	name = "ammo box (5.56x45mm)"
	desc = "Коробка с винтовочными патронами калибра 5.56x45мм, вмещает 45 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "556box_big"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_A223
	ammo_type = /obj/item/ammo_casing/a223
	max_ammo = 45

/obj/item/ammo_box/c223/rubber
	name = "ammo box (5.56x45mm rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "556box_big-rubber"
	ammo_type = /obj/item/ammo_casing/a223/rubber

/obj/item/ammo_box/c223/ap
	name = "ammo box (5.56x45mm armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "556box_big-ap"
	ammo_type = /obj/item/ammo_casing/a223/ap

/obj/item/ammo_box/c223/hp
	name = "ammo box (5.56x45mm hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "556box_big-hp"
	ammo_type = /obj/item/ammo_casing/a223/hp

/obj/item/ammo_box/c223/incendiary
	name = "ammo box (5.56x45mm incendiary)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "556box_big-incendiary"
	ammo_type = /obj/item/ammo_casing/a223/incendiary

// MARK: 7.62x51
/obj/item/ammo_box/c762x51
	name = "ammo box (7.62x51mm)"
	desc = "Коробка с винтовочными патронами калибра 7.62x51мм, вмещает 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "762_51box_big"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_762x51mm
	ammo_type = /obj/item/ammo_casing/c762x51mm
	max_ammo = 30

/obj/item/ammo_box/c762x51/rubber
	name = "ammo box (7.62x51mm rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "762_51box_big-rubber"
	ammo_type = /obj/item/ammo_casing/c762x51mm/rubber

/obj/item/ammo_box/c762x51/hp
	name = "ammo box (7.62x51mm hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "762_51box_big-hp"
	ammo_type = /obj/item/ammo_casing/c762x51mm/hp

/obj/item/ammo_box/c762x51/ap
	name = "ammo box (7.62x51mm armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "762_51box_big-ap"
	ammo_type = /obj/item/ammo_casing/c762x51mm/ap

/obj/item/ammo_box/c762x51/incendiary
	name = "ammo box (7.62x51mm incendiary)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "762_51box_big-incendiary"
	ammo_type = /obj/item/ammo_casing/c762x51mm/incendiary

// MARK: .338
/obj/item/ammo_box/c338
	name = "ammo box (.338)"
	desc = "Коробка с винтовочными патронами калибра .338, вмещает 15 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "86x70mmbox"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_338
	ammo_type = /obj/item/ammo_casing/c338
	max_ammo = 15

/obj/item/ammo_box/c338/hp
	name = "ammo box (.338 hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "86x70mmbox-hp"
	ammo_type = /obj/item/ammo_casing/c338/hp

/obj/item/ammo_box/c338/ap
	name = "ammo box (.338 armor-piercing)"
	desc = parent_type::desc + "<br>Черная полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "86x70mmbox-trac"
	ammo_type = /obj/item/ammo_casing/c338/ap

/obj/item/ammo_box/c338/incendiary
	name = "ammo box (.338 incendiary)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "86x70mmbox-incendiary"
	ammo_type = /obj/item/ammo_casing/c338/incendiary

// MARK: .50 BMG
/obj/item/ammo_box/c50
	name = "ammo box (.50 BMG)"
	desc = "Коробка с винтовочными патронами калибра .50 BMG, вмещает 10 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "a50box"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_50BMG
	ammo_type = /obj/item/ammo_casing/p50
	max_ammo = 10

/obj/item/ammo_box/c50/penetrator
	name = "ammo box (.50 penetrator)"
	desc = parent_type::desc + "<br>Желтая полоска указывает на то, что в ней должны храниться пробивные боеприпасы."
	icon_state = "a50box-penetrator"
	ammo_type = /obj/item/ammo_casing/p50/penetrator

/obj/item/ammo_box/c50/disruptor
	name = "ammo box (.50 disruptor)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "a50box-disruptor"
	ammo_type = /obj/item/ammo_casing/p50/disruptor

/obj/item/ammo_box/c50/marksman
	name = "ammo box (.50 marksman)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что здесь должны храниться высокоскоростные боеприпасы."
	icon_state = "a50box-marksman"
	ammo_type = /obj/item/ammo_casing/p50/marksman

/obj/item/ammo_box/c50/incendiary
	name = "ammo box (.50 incendiary)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "a50box-incendiary"
	ammo_type = /obj/item/ammo_casing/p50/incendiary

// MARK: 4.6x30mm
/obj/item/ammo_box/c46x30
	name = "ammo box (4.6x30mm)"
	desc = "Коробка с патронами калибра 4.6x30мм, вмещает 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "46x30mmbox"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_46X30MM
	ammo_type = /obj/item/ammo_casing/c46x30mm
	max_ammo = 30

/obj/item/ammo_box/c46x30/rubber
	name = "ammo box (4.6x30mm rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "46x30mmbox-rubber"
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber

/obj/item/ammo_box/c46x30/ap
	name = "ammo box (4.6x30mm armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "46x30mmbox-ap"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/c46x30/incendiary
	name = "ammo box (4.6x30mm incendiary)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "46x30mmbox-incendiary"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc

// MARK: 12ga
/obj/item/ammo_box/c12ga
	name = "ammo box (12 gauge)"
	desc = "Коробка с патронами для дробовиков 12-калибра, вмещает 20 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "12gbox-buckshot"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_SHOTGUN
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 20

/obj/item/ammo_box/c12ga/milspec
	name = "ammo box (12 gauge)"
	desc = parent_type::desc + "<br>Качественная, почти новая коробка. На коробке имеется спец маркировка, указывающая что внутри картечь военного типа."
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec

/obj/item/ammo_box/c12ga/old
	name = "ammo box (12 gauge)"
	desc = parent_type::desc + "<br>Старая, потрепанная и странно пахнущая.. <br>Неизвестно какого качества патроны внутри, но вероятно не самого лучшего.. или безопастного."
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/old

/obj/item/ammo_box/c12ga/slug
	name = "ammo box (12 gauge slug)"
	desc = parent_type::desc + "<br>Белый цвет патрона на коробке указывает на то, что в ней должны храниться пулевые патроны."
	icon_state = "12gbox-slug"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/c12ga/slug/milspec
	name = "ammo box (12 gauge slug)"
	desc = parent_type::desc + "<br>Качественная, почти новая коробка. На коробке имеется спец маркировка, указывающая что внутри патроны военного типа."
	icon_state = "12gbox-slug"
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/c12ga/rubbershot
	name = "ammo box (12 gauge rubbershot)"
	desc = parent_type::desc + "<br>Розовый цвет патрона на коробке указывает на то, что в ней должны храниться патроны резиновой дроби."
	icon_state = "12gbox-rubbershot"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/c12ga/beanbag
	name = "ammo box (12 gauge beanbag)"
	desc = parent_type::desc + "<br>Зеленый цвет патрона на коробке указывает на то, что в ней должны храниться резиновые пули."
	icon_state = "12gbox-beanbag"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/c12ga/flechette
	name = "ammo box (12 gauge flechette)"
	desc = parent_type::desc + "<br>Черный цвет патрона на коробке указывает на то, что в ней должны храниться флешетты."
	icon_state = "12gbox-flechette"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/c12ga/executioner
	name = "ammo box (12 gauge executioner)"
	desc = parent_type::desc + "<br>Желтый цвет патрона на коробке указывает на то, что в ней должны храниться экспансивные пули."
	icon_state = "12gbox-executioner"
	ammo_type = /obj/item/ammo_casing/shotgun/executioner

/obj/item/ammo_box/c12ga/incendiary
	name = "ammo box (12 gauge incendiary slug)"
	desc = parent_type::desc + "<br>Оранжевый цвет патрона на коробке указывает на то, что в ней должны храниться зажигательные пули."
	icon_state = "12gbox-incendiary"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/c12ga/dragonsbreath
	name = "ammo box (12 gauge dragonsbreath)"
	desc = parent_type::desc + "<br>Оранжевый цвет патрона с фиолетовой полоской на коробке указывает на то, что в ней должны храниться патроны зажигательной дроби."
	icon_state = "12gbox-dragonsbreath"
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/c12ga/breacher
	name = "ammo box (12 gauge breacher)"
	desc = parent_type::desc + "<br>Синий цвет патрона на коробке указывает на то, что в ней должны храниться пробивные пули."
	icon_state = "12gbox-breacher"
	ammo_type = /obj/item/ammo_casing/shotgun/breacher

/obj/item/ammo_box/c12ga/frag12
	name = "ammo box (12 gauge frag-12)"
	desc = parent_type::desc + "<br>Серый цвет патрона на коробке указывает на то, что в ней должны храниться фугасно-пробивные пули 'ФРАГ-12'."
	icon_state = "12gbox-frag"
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

// MARK: BOXES WITH MAGAZINES / AMMO BOXES
/obj/item/storage/toolbox/ammobox/c9x25mm_mags
	name = "9x25mm NT GP-9 pistol magazines box"
	desc = "Содержит несколько магазинов обычного размера для пистолетов GP-9 калибра 9x25мм."
	ammo_to_spawn = /obj/item/ammo_box/magazine/c9x25mm_pistol

/obj/item/storage/toolbox/ammobox/c9x25mm_mags/extended
	name = "9x25mm NT GP-9 pistol extended magazines box"
	desc = "Содержит несколько магазинов увеличенного размера для пистолетов GP-9 калибра 9x25мм."
	ammo_to_spawn = /obj/item/ammo_box/magazine/c9x25mm_pistol/stendo

/obj/item/storage/toolbox/ammobox/c9x25mm_bullets
	name = "9x25mm NT ammo box"
	desc = "Содержит несколько коробок с патронами калибра 9x25мм."
	ammo_to_spawn = /obj/item/ammo_box/c9x25mm

/obj/item/storage/toolbox/ammobox/amk_mags
	name = "7.62x39mm AMK magazines box"
	desc = "Содержит несколько магазинов для автоматов образца АМК калибра 7.62x39мм."
	ammo_to_spawn = /obj/item/ammo_box/magazine/c762x39mm

/obj/item/storage/toolbox/ammobox/amk_bullets
	name = "7.62x39mm ammo box"
	desc = "Содержит несколько коробок с патронами калибра 7.62x39мм."
	ammo_to_spawn = /obj/item/ammo_box/c762x39

/obj/item/storage/toolbox/ammobox/c40sol_mags
	name = ".40 Sol Long standart magazines box"
	desc = "Содержит несколько стандартных магазинов для боевых винтовок \"Карво\" калибра .40 Sol Long."
	ammo_to_spawn = /obj/item/ammo_box/magazine/c40sol_rifle/standard

/obj/item/storage/toolbox/ammobox/c40sol_bullets
	name = ".40 Sol Long ammo box"
	desc = "Содержит несколько коробок с патронами калибра .40 Sol Long."
	ammo_to_spawn = /obj/item/ammo_box/c40sol

/obj/item/storage/toolbox/ammobox/c35sol_mags
	name = ".35 Sol short standart pistol magazines box"
	desc = "Содержит несколько магазинов обычного размера для пистолетов \"Оса\" калибра .35 Sol short."
	ammo_to_spawn = /obj/item/ammo_box/magazine/c35sol_pistol

/obj/item/storage/toolbox/ammobox/c35sol_bullets
	name = ".35 Sol short ammo box"
	desc = "Содержит несколько коробок с патронами калибра .35 Sol Short."
	ammo_to_spawn = /obj/item/ammo_box/c35sol

/obj/item/storage/toolbox/ammobox/c762x51mm_mags
	name = "7.62x51mm battle rifle magazines box"
	desc = "Содержит несколько стандартных магазинов для боевых винтовок калибра 7.62x51мм."
	ammo_to_spawn = /obj/item/ammo_box/magazine/c762x51mm

/obj/item/storage/toolbox/ammobox/c762x51mm_bullets
	name = "7.62x51mm ammo box"
	desc = "Содержит несколько коробок с патронами калибра 7.62x51мм."
	ammo_to_spawn = /obj/item/ammo_box/c762x51

/obj/item/storage/toolbox/ammobox/c762x54mmr_bullets
	name = "7.62x54mmR ammo box"
	desc = "Содержит несколько коробок с патронами калибра 7.62x54ммР."
	ammo_to_spawn = /obj/item/ammo_box/c762x54mmr

/obj/item/storage/toolbox/ammobox/c762x54mmr_clips
	name = "7.62x54mmR stripper clips box"
	desc = "Содержит несколько обойм для патронов калибра 7.62x54ммР."
	ammo_to_spawn = /obj/item/ammo_box/speedloader/c762x54mmr

/obj/item/storage/toolbox/ammobox/c223_arg_mags
	name = "5.56x45mm ARG/CM-82 magazines box"
	desc = "Содержит несколько стандартных магазинов для штурмовых винтовок калибра 5.56x45мм."
	ammo_to_spawn = /obj/item/ammo_box/magazine/c223

/obj/item/storage/toolbox/ammobox/c223_bullets
	name = "5.56x45mm ammo box"
	desc = "Содержит несколько коробок с патронами калибра 5.56x45мм."
	ammo_to_spawn = /obj/item/ammo_box/c223

/obj/item/storage/toolbox/ammobox/c45_cm45_mags
	name = ".45 pistol GP-45 magazines box"
	desc = "Содержит несколько магазинов для пистолетов GP-45 калибра .45."
	ammo_to_spawn = /obj/item/ammo_box/magazine/c45

/obj/item/storage/toolbox/ammobox/c45_bullets
	name = ".45 ammo box"
	desc = "Содержит несколько коробок с патронами калибра .45."
	ammo_to_spawn = /obj/item/ammo_box/c45

/obj/item/storage/toolbox/ammobox/m9mm_magazines
	name = "9mm Saber magazines box"
	desc = "Содержит несколько магазинов для пистолетов-пулеметов \"Saber\" калибра 9мм."
	ammo_to_spawn = /obj/item/ammo_box/magazine/smgm9mm

/obj/item/storage/toolbox/ammobox/m9mm_bullets
	name = "9mm ammo box"
	desc = "Содержит несколько коробок с патронами калибра 9мм."
	ammo_to_spawn = /obj/item/ammo_box/c9mm

/obj/item/storage/toolbox/ammobox/m10mm_magazines
	name = "10mm Vityaz magazines box"
	desc = "Содержит несколько магазинов для пистолетов-пулеметов \"Витязь\" калибра 10мм."
	ammo_to_spawn = /obj/item/ammo_box/magazine/smg10mm

/obj/item/storage/toolbox/ammobox/m10mm_bullets
	name = "10mm ammo box"
	desc = "Содержит несколько коробок с патронами калибра 10мм."
	ammo_to_spawn = /obj/item/ammo_box/c10mm

/obj/item/storage/toolbox/ammobox/c46x30
	name = "4.6x30mm ammo box"
	desc = "Содержит несколько коробок с патронами калибра 4.6x30мм."
	ammo_to_spawn = /obj/item/ammo_box/c46x30

/obj/item/storage/toolbox/ammobox/c12ga_buck_mil
	name = "12ga buckshot ammo box"
	desc = "Содержит несколько коробок с дробью для дробовиков 12-го калибра."
	ammo_to_spawn = /obj/item/ammo_box/c12ga

/obj/item/storage/toolbox/ammobox/c12ga_slug_mil
	name = "12ga slug ammo box"
	desc = "Содержит несколько коробок с пулями для дробовиков 12-го калибра."
	ammo_to_spawn = /obj/item/ammo_box/c12ga/slug/milspec

/obj/item/storage/toolbox/ammobox/c50
	name = ".50 BMG ammo box"
	desc = "Содержит несколько коробок с патронами калибра .50 BMG."
	ammo_to_spawn = /obj/item/ammo_box/c50

/obj/item/storage/toolbox/ammobox/c357
	name = ".357 ammo box"
	desc = "Содержит несколько коробок с патронами калибра .357."
	ammo_to_spawn = /obj/item/ammo_box/c357

/obj/item/storage/toolbox/ammobox/c38
	name = ".38 ammo box"
	desc = "Содержит несколько коробок с патронами калибра .38."
	ammo_to_spawn = /obj/item/ammo_box/c38

/obj/item/storage/toolbox/ammobox/c338
	name = ".338 ammo box"
	desc = "Содержит несколько коробок с патронами калибра .338."
	ammo_to_spawn = /obj/item/ammo_box/c338

/obj/item/storage/toolbox/ammobox/n762_speedloaders
	name = "7.62x38mmR ammo box"
	desc = "Содержит несколько ускорителей заряжания для револьверов калибра 7.62x38ммР."
	ammo_to_spawn = /obj/item/ammo_box/speedloader/n762_cylinder

/obj/item/storage/toolbox/ammobox/strilka310_bullets
	name = ".310 Strilka ammo box"
	desc = "Содержит несколько коробок с патронами калибра .310 Стрилка."
	ammo_to_spawn = /obj/item/ammo_box/strilka310
