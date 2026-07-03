// MARK:  Wespe aka sol pistol
/obj/item/ammo_box/magazine/c35sol_pistol
	name = "pistol magazine (.35 Sol Short)"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .35 Sol Short, вмещает 12 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "pistol_35_standard"
	base_icon_state = "pistol_35_standard"
	w_class = WEIGHT_CLASS_TINY
	ammo_type = /obj/item/ammo_casing/c35sol
	caliber = CALIBER_SOL35SHORT
	max_ammo = 12
	ammo_band_icon = "+35_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/stendo
	name = "extended pistol magazine (.35 Sol Short)"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 16 патронов."
	icon_state = "pistol_35_stended"
	base_icon_state = "pistol_35_stended"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 16

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/rubber
	name = "pistol magazine (.35 Sol Short rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/rubber
	name = "extended pistol magazine (.35 Sol Short rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/ap
	name = "pistol magazine (.35 Sol Short AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/ap
	name = "extended pistol magazine (.35 Sol Short AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/hp
	name = "pistol magazine (.35 Sol Short HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/hp

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/hp
	name = "extended pistol magazine (.35 Sol Short HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/hp

/obj/item/ammo_box/magazine/c35sol_pistol/drum
	name = "drum pistol magazine (.35 Sol Short)"
	desc = "Барабанный магазин для пистолетов ТСФ калибра .35 Sol Short, вмещает 35 патронов."
	icon_state = "pistol_35_drum"
	base_icon_state = "pistol_35_drum"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 35

/obj/item/ammo_box/magazine/c35sol_pistol/drum/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/drum/rubber
	name = "drum pistol magazine (.35 Sol Short rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c35sol/rubber

/obj/item/ammo_box/magazine/c35sol_pistol/drum/ap
	name = "drum pistol magazine (.35 Sol Short AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c35sol/ap

/obj/item/ammo_box/magazine/c35sol_pistol/drum/hp
	name = "drum pistol magazine (.35 Sol Short HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c35sol/hp

// MARK: AMK(AKM)
/obj/item/ammo_box/magazine/c762x39mm
	name = "rifle magazine (7.62x39mm)"
	desc = "Бананообразный двухрядный магазин, вмещающий 30 патронов калибра 7.62x39мм. Говорят, что на заре распространения ТСФ, повстанцы из испанских колоний часто называли их «козьими рогами»."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "amk"
	ammo_band_icon = "+amk_ammo_band"
	ammo_band_color = null
	w_class = WEIGHT_CLASS_SMALL
	ammo_type = /obj/item/ammo_casing/c762x39
	caliber = CALIBER_762x39mm
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/c762x39mm/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c762x39mm/ricochet
	name = "rifle magazine (7.62x39mm match)"
	desc = parent_type::desc + "<br>Содержит патроны с высокой рикошетностью."
	ammo_band_color = COLOR_AMMO_MATCH
	ammo_type = /obj/item/ammo_casing/c762x39/ricochet

/obj/item/ammo_box/magazine/c762x39mm/incendiary
	name = "rifle magazine (7.62x39mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c762x39/incendiary

/obj/item/ammo_box/magazine/c762x39mm/ap
	name = "rifle magazine (7.62x39mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c762x39/ap

/obj/item/ammo_box/magazine/c762x39mm/emp
	name = "rifle magazine (7.62x39mm EMP)"
	desc = parent_type::desc + "<br>Содержит ионные патроны, которые хорошо подходят для выведения из строя электроники и разрушения мехов."
	ammo_band_color = "#1ea2ee"
	ammo_type = /obj/item/ammo_casing/c762x39/emp

/obj/item/ammo_box/magazine/c762x39mm/rubber
	name = "rifle magazine (7.62x39mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c762x39/rubber

/obj/item/ammo_box/magazine/c762x39mm/small
	name = "rifle short magazine (7.62x39mm)"
	desc = "Укороченный двухрядный магазин, вмещающий 15 патронов калибра 7.62x39мм."
	icon_state = "amk_small"
	max_ammo = 15

/obj/item/ammo_box/magazine/c762x39mm/small/civ
	desc = parent_type::desc + "<br>Содержит гражданские патроны."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c762x39/civilian

/obj/item/ammo_box/magazine/c762x39mm/small/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c762x39mm/hunting
	name = "rifle magazine (7.62x39mm hunting)"
	desc = parent_type::desc + "<br>Содержит охотничьи патроны."
	ammo_band_color = "#05880c"
	ammo_type = /obj/item/ammo_casing/c762x39/hunting

/obj/item/ammo_box/magazine/miecz
	name = "miecz magazine (7.62x39mm)"
	desc = "Магазин для штурмовых винтовок калибра 7.62x39мм, вмещающий 30 патронов. Подходит для винтовок AMK-874 \"Мечь\"."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "miecz"
	ammo_band_icon = "+miecz_ammo_band"
	ammo_band_color = null
	w_class = WEIGHT_CLASS_SMALL
	ammo_type = /obj/item/ammo_casing/c762x39
	caliber = CALIBER_762x39mm
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/miecz/ap
	name = "rifle magazine (7.62x39mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c762x39/ap

/obj/item/ammo_box/magazine/miecz/emp
	name = "rifle magazine (7.62x39mm EMP)"
	desc = parent_type::desc + "<br>Содержит ионные патроны, которые хорошо подходят для выведения из строя электроники и разрушения мехов."
	ammo_band_color = "#1ea2ee"
	ammo_type = /obj/item/ammo_casing/c762x39/emp

/obj/item/ammo_box/magazine/miecz/rubber
	name = "rifle magazine (7.62x39mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c762x39/rubber

/obj/item/ammo_box/magazine/miecz/incendiary
	name = "rifle magazine (7.62x39mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c762x39/incendiary

// MARK: Fal aka Carwo
/obj/item/ammo_box/magazine/c40sol_rifle
	name = "rifle short magazine (.40 Sol Long)"
	desc = "Укороченный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 15 патронов."
	ammo_band_icon = "+40_ammo_band"
	ammo_band_color = null
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "rifle_short"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_TINY
	ammo_type = /obj/item/ammo_casing/c40sol
	caliber = CALIBER_SOL40LONG
	max_ammo = 10

/obj/item/ammo_box/magazine/c40sol_rifle/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/fragmentation
	name = "rifle short magazine (.40 Sol Long rubber-fragmentation)"
	desc = parent_type::desc + "<br>Содержит нелетальные осколочно-травматические патроны."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/ap
	name = "rifle short magazine (.40 Sol Long AP)"
	ammo_type = /obj/item/ammo_casing/c40sol/ap
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/incendiary
	name = "rifle short magazine (.40 Sol Long incendiary)"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/standard
	name = "rifle magazine (.40 Sol Long)"
	desc = "Магазин стандартного размера для винтовок ТСФ калибра .40 Sol Long, вмещает 20 патронов."
	icon_state = "rifle_standard"
	w_class = WEIGHT_CLASS_SMALL
	max_ammo = 20

/obj/item/ammo_box/magazine/c40sol_rifle/standard/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/standard/fragmentation
	name = "rifle magazine (.40 Sol Long rubber-fragmentation)"
	desc = parent_type::desc + "<br>Содержит нелетальные осколочно-травматические патроны."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/standard/ap
	name = "rifle magazine (.40 Sol Long AP)"
	ammo_type = /obj/item/ammo_casing/c40sol/ap
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/standard/incendiary
	name = "rifle magazine (.40 Sol Long incendiary)"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/long
	name = "rifle long magazine (.40 Sol Long)"
	desc = "Удлиненный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 30 патронов."
	icon_state = "rifle_long"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 30

/obj/item/ammo_box/magazine/c40sol_rifle/long/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/long/fragmentation
	name = "rifle long magazine (.40 Sol Long rubber-fragmentation)"
	desc = parent_type::desc + "<br>Содержит нелетальные осколочно-травматические патроны."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/long/ap
	name = "rifle long magazine (.40 Sol Long AP)"
	ammo_type = /obj/item/ammo_casing/c40sol/ap
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/long/incendiary
	name = "rifle long magazine (.40 Sol Long incendiary)"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/drum
	name = "rifle drum magazine (.40 Sol Long)"
	desc = "Барабанный магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 60 патронов."
	icon_state = "rifle_drum"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 60

/obj/item/ammo_box/magazine/c40sol_rifle/drum/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/drum/fragmentation
	name = "rifle drum magazine (.40 Sol Long rubber-fragmentation)"
	desc = parent_type::desc + "<br>Содержит нелетальные осколочно-травматические патроны."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/drum/ap
	name = "rifle drum magazine (.40 Sol Long AP)"
	ammo_type = /obj/item/ammo_casing/c40sol/ap
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/drum/incendiary
	name = "rifle drum magazine (.40 Sol Long incendiary)"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

/obj/item/ammo_box/magazine/c40sol_rifle/box
	name = "rifle box magazine (.40 Sol Long)"
	desc = "Коробчатый магазин для винтовок ТСФ калибра .40 Sol Long, вмещает 100 патронов."
	icon_state = "rifle_box"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 100

/obj/item/ammo_box/magazine/c40sol_rifle/box/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/box/fragmentation
	name = "rifle box magazine (.40 Sol Long rubber-fragmentation)"
	desc = parent_type::desc + "<br>Содержит нелетальные осколочно-травматические патроны."
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	ammo_band_color = COLOR_AMMO_RUBBER

/obj/item/ammo_box/magazine/c40sol_rifle/box/ap
	name = "rifle box magazine (.40 Sol Long AP)"
	ammo_type = /obj/item/ammo_casing/c40sol/ap
	MAGAZINE_TYPE_ARMORPIERCE

/obj/item/ammo_box/magazine/c40sol_rifle/box/incendiary
	name = "rifle box magazine (.40 Sol Long incendiary)"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	MAGAZINE_TYPE_INCENDIARY

// MARK: NT Glock aka GP-9
/obj/item/ammo_box/magazine/c9x25mm_pistol
	name = "pistol magazine (9x25mm NT)"
	desc = "Магазин стандартного размера для пистолетов GP-9 калибра 9x25мм, вмещает 12 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "pistol_9x25_standart"
	base_icon_state = "pistol_9x25_standart"
	w_class = WEIGHT_CLASS_TINY
	ammo_type = /obj/item/ammo_casing/c9x25mm
	caliber = CALIBER_9x25NT
	max_ammo = 12
	ammo_band_icon = "+9x25_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE

/obj/item/ammo_box/magazine/c9x25mm_pistol/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo
	name = "extended pistol magazine (9x25mm NT)"
	desc = "Увеличенный магазин для пистолетов GP-9 калибра 9x25мм, вмещает 22 патрона."
	icon_state = "pistol_9x25_stendo"
	base_icon_state = "pistol_9x25_stendo"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 22

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c9x25mm_pistol/rubber
	name = "pistol magazine (9x25mm NT rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c9x25mm/rubber

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/rubber
	name = "extended pistol magazine (9x25mm NT rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c9x25mm/rubber

/obj/item/ammo_box/magazine/c9x25mm_pistol/ap
	name = "pistol magazine (9x25mm NT AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9x25mm/ap

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/ap
	name = "extended pistol magazine (9x25mm NT AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9x25mm/ap

/obj/item/ammo_box/magazine/c9x25mm_pistol/hp
	name = "pistol magazine (9x25mm NT HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9x25mm/hp

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/hp
	name = "extended pistol magazine (9x25mm NT HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9x25mm/hp

// MARK: CM5 - SMG
/obj/item/ammo_box/magazine/cm5
	name = "SMG magazine (9x25mm NT)"
	desc = "Магазин для пистолетов-пулеметов CM5 калибра 9x25мм НТ, вмещающий 30 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "cm5_mag"
	base_icon_state = "cm5_mag"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_9x25NT
	max_ammo = 30
	ammo_band_icon = "+cm5_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c9x25mm

/obj/item/ammo_box/magazine/cm5/rubber
	name = "SMG magazine (9x25mm NT rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c9x25mm/rubber

/obj/item/ammo_box/magazine/cm5/hp
	name = "SMG magazine (9x25mm NT HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9x25mm/hp

/obj/item/ammo_box/magazine/cm5/ap
	name = "SMG magazine (9x25mm NT AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9x25mm/ap

// MARK: CM82 - assault rifle
/obj/item/ammo_box/magazine/c223
	name = "assault rifle magazine (5.56x45mm)"
	desc = "Магазин для штурмовых винтовок калибра 5.56x45мм, вмещающий 30 патронов. Подходит для винтовок CM82 и АРГ."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "cm82_mag"
	base_icon_state = "cm82_mag"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_A223
	max_ammo = 30
	ammo_band_icon = "+cm82_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/a223

/obj/item/ammo_box/magazine/c223/rubber
	name = "assault rifle magazine (5.56x45mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей. Подходит для винтовок CM82 и АРГ."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/a223/rubber

/obj/item/ammo_box/magazine/c223/hp
	name = "assault rifle magazine (5.56x45mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/a223/hp

/obj/item/ammo_box/magazine/c223/ap
	name = "assault rifle magazine (5.56x45mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/a223/ap

/obj/item/ammo_box/magazine/c223/phasic
	name = "assault rifle magazine (5.56x45mm phasic)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/a223/phasic

/obj/item/ammo_box/magazine/c223/incendiary
	name = "assault rifle magazine (5.56x45mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/a223/incendiary

// MARK: CM15 - auto shotgun
/obj/item/ammo_box/magazine/cm15
	name = "CM15 magazine (12ga buckshot)"
	desc = "Магазин для штурмовых дробовиков CM15 12-го калибра, вмещающий 8 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "cm15_standart"
	base_icon_state = "cm15_standart"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_SHOTGUN
	max_ammo = 8
	ammo_band_icon = "+cm15_standart_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec

/obj/item/ammo_box/magazine/cm15/beanbag
	name = "CM15 magazine (12ga beanbag)"
	ammo_band_color = COLOR_GREEN
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/cm15/rubbershot
	name = "CM15 magazine (12ga rubbershot)"
	ammo_band_color = COLOR_PINK
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/magazine/cm15/executioner
	name = "CM15 magazine (12ga HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/shotgun/executioner

/obj/item/ammo_box/magazine/cm15/slug
	name = "CM15 magazine (12ga slugs)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/cm15/breacher
	name = "CM15 magazine (12ga breaching)"
	ammo_band_color = COLOR_BLUE_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/breacher

/obj/item/ammo_box/magazine/cm15/frag12
	name = "CM15 magazine (12ga FRAG-12)"
	ammo_band_color = COLOR_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/magazine/cm15/dragonsbreath
	name = "CM15 magazine (12ga dragonsbreath)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/cm15/flechette
	name = "CM15 magazine (12ga flechette)"
	ammo_band_color = COLOR_ALMOST_BLACK
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/cm15/drum
	name = "CM15 drum magazine (12ga buckshot)"
	desc = "Барабан для штурмовых дробовиков CM15 12-го калибра, вмещающий 16 патронов."
	icon_state = "cm15_drum"
	base_icon_state = "cm15_drum"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 16
	ammo_band_icon = "+cm15_drum_ammo_band"

/obj/item/ammo_box/magazine/cm15/drum/beanbag
	name = "CM15 drum magazine (12ga beanbag)"
	ammo_band_color = COLOR_GREEN
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/cm15/drum/rubbershot
	name = "CM15 drum magazine (12ga rubbershot)"
	ammo_band_color = COLOR_PINK
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/magazine/cm15/drum/executioner
	name = "CM15 drum magazine (12ga HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/shotgun/executioner

/obj/item/ammo_box/magazine/cm15/drum/slug
	name = "CM15 drum magazine (12ga slugs)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/cm15/drum/breacher
	name = "CM15 drum magazine (12ga breaching)"
	ammo_band_color = COLOR_BLUE_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/breacher

/obj/item/ammo_box/magazine/cm15/drum/frag12
	name = "CM15 drum magazine (12ga FRAG-12)"
	ammo_band_color = COLOR_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/magazine/cm15/drum/dragonsbreath
	name = "CM15 drum magazine (12ga dragonsbreath)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/cm15/drum/flechette
	name = "CM15 drum magazine (12ga flechette)"
	ammo_band_color = COLOR_ALMOST_BLACK
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

// MARK: F4 - battle rifle
/obj/item/ammo_box/magazine/c762x51mm
	name = "battle rifle magazine (7.62x51mm)"
	desc = "Магазин для боевых винтовок калибра 7.62x51мм, вмещающий 20 патронов. Подходит для винтовок F4 и FN4."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "762x51_mag"
	base_icon_state = "762x51_mag"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_762x51mm
	max_ammo = 20
	ammo_band_icon = "+762x51_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c762x51mm

/obj/item/ammo_box/magazine/c762x51mm/rubber
	name = "battle rifle magazine (7.62x51mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей. Подходит для винтовок F4 и FN4."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c762x51mm/rubber

/obj/item/ammo_box/magazine/c762x51mm/hp
	name = "battle rifle magazine (7.62x51mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c762x51mm/hp

/obj/item/ammo_box/magazine/c762x51mm/ap
	name = "battle rifle magazine (7.62x51mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c762x51mm/ap

/obj/item/ammo_box/magazine/c762x51mm/incendiary
	name = "battle rifle magazine (7.62x51mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c762x51mm/incendiary

// MARK: CM40 - LMG
/obj/item/ammo_box/magazine/cm40
	name = "CM40 box (7.62x51mm)"
	desc = "Короб для легких пулеметов CM40 калибра 7.62x51мм, вмещающий 80 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "cm40_mag"
	base_icon_state = "cm40_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_762x51mm
	max_ammo = 80
	ammo_band_icon = "+cm40_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c762x51mm

/obj/item/ammo_box/magazine/cm40/rubber
	name = "CM40 box (7.62x51mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c762x51mm/rubber

/obj/item/ammo_box/magazine/cm40/hp
	name = "CM40 box (7.62x51mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c762x51mm/hp

/obj/item/ammo_box/magazine/cm40/ap
	name = "CM40 box (7.62x51mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c762x51mm/ap

/obj/item/ammo_box/magazine/cm40/incendiary
	name = "CM40 box (7.62x51mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c762x51mm/incendiary

// MARK: F90 - sniper rifle
/obj/item/ammo_box/magazine/c338
	name = "sniper rifle magazine (.338)"
	desc = "Магазин для снайперских винтовок калибра .338, вмещающий 5 патронов. Подходит для винтовок F90 и HLRM2."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "338_mag"
	base_icon_state = "338_mag"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_338
	max_ammo = 5
	ammo_band_icon = "+338_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c338

/obj/item/ammo_box/magazine/c338/hp
	name = "sniper rifle magazine (.338 HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c338/hp

/obj/item/ammo_box/magazine/c338/ap
	name = "sniper rifle magazine (.338 AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c338/ap

/obj/item/ammo_box/magazine/c338/incendiary
	name = "sniper rifle magazine (.338 incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c338/incendiary

/obj/item/ammo_box/magazine/c338/extended
	name = "extended sniper rifle magazine (.338)"
	desc = "Магазин для снайперских винтовок калибра .338, вмещающий 10 патронов. Подходит для винтовок F90 и HLRM2."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "338_mag_ext"
	base_icon_state = "338_mag_ext"
	w_class = WEIGHT_CLASS_NORMAL
	ammo_band_icon = "+338_ext_ammo_band"
	ammo_band_color = null
	max_ammo = 10

/obj/item/ammo_box/magazine/c338/extended/hp
	name = "extended sniper rifle magazine (.338 HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c338/hp

/obj/item/ammo_box/magazine/c338/extended/ap
	name = "extended sniper rifle magazine (.338 AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c338/ap

/obj/item/ammo_box/magazine/c338/extended/incendiary
	name = "extended sniper rifle magazine (.338 incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c338/incendiary

// MARK: CM23 - .38 cal pistol
/obj/item/ammo_box/magazine/c38
	name = "pistol magazine (.38)"
	desc = "Пистолетный магазин калибра .38, вмещающий 12 патронов. Подходит для пистолетов GP-38."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "c38_mag"
	base_icon_state = "c38_mag"
	w_class = WEIGHT_CLASS_TINY
	caliber = CALIBER_38
	max_ammo = 12
	ammo_band_icon = "+c38_mag_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_PER_BULLET
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c38

/obj/item/ammo_box/magazine/c38/rubber
	name = "pistol magazine (.38 Rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy

/obj/item/ammo_box/magazine/c38/match
	name = "pistol magazine (.38 Match)"
	ammo_band_color = COLOR_AMMO_MATCH
	ammo_type = /obj/item/ammo_casing/c38/match

/obj/item/ammo_box/magazine/c38/true
	name = "pistol magazine (.38 True Strike)"
	ammo_band_color = COLOR_AMMO_TRUESTRIKE
	ammo_type = /obj/item/ammo_casing/c38/match/true

/obj/item/ammo_box/magazine/c38/laser
	name = "pistol magazine (.38 Flare)"
	ammo_band_color = COLOR_AMMO_HELLFIRE
	ammo_type = /obj/item/ammo_casing/c38/flare

/obj/item/ammo_box/magazine/c38/hotshot
	name = "pistol magazine (.38 Hot Shot)"
	ammo_band_color = COLOR_AMMO_HOTSHOT
	ammo_type = /obj/item/ammo_casing/c38/hotshot

/obj/item/ammo_box/magazine/c38/iceblox
	name = "pistol magazine (.38 Iceblox)"
	ammo_band_color = COLOR_AMMO_ICEBLOX
	ammo_type = /obj/item/ammo_casing/c38/iceblox

/obj/item/ammo_box/magazine/c38/ap
	name = "pistol magazine (.38 AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c38/ap

/obj/item/ammo_box/magazine/c38/hp
	name = "pistol magazine (.38 DumDum)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c38/dumdum

// MARK: CM357 - .357 cal pistol
/obj/item/ammo_box/magazine/c357
	name = "pistol magazine (.357)"
	desc = "Пистолетный магазин калибра .357, вмещающий 8 патронов. Подходит для пистолетов GP-357."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "c357_mag"
	base_icon_state = "c357_mag"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_357
	max_ammo = 8
	ammo_band_icon = "+c357_mag_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_PER_BULLET
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c357

/obj/item/ammo_box/magazine/c357/ap
	name = "pistol magazine (.357 Phasic)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c357/phasic

/obj/item/ammo_box/magazine/c357/match
	name = "pistol magazine (.357 Match)"
	ammo_band_color = COLOR_AMMO_MATCH
	ammo_type = /obj/item/ammo_casing/c357/match

/obj/item/ammo_box/magazine/c357/heartseeker
	name = "pistol magazine (.357 Heartseeker)"
	ammo_band_color = "#a91e1e"
	ammo_type = /obj/item/ammo_casing/c357/heartseeker

// MARK: CM70 - .45 cal pistol
/obj/item/ammo_box/magazine/c45
	name = "pistol magazine (.45)"
	desc = "Пистолетный магазин калибра .45, вмещающий 10 патронов. Подходит для пистолетов GP-45 и TP-14."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "c45_mag"
	base_icon_state = "c45_mag"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_45
	max_ammo = 10
	ammo_band_icon = "+c45_mag_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_PER_BULLET
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c45

/obj/item/ammo_box/magazine/c45/ap
	name = "pistol magazine (.45 AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c45/ap

/obj/item/ammo_box/magazine/c45/rubber
	name = "pistol magazine (.45 rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c45/rubber

/obj/item/ammo_box/magazine/c45/hp
	name = "pistol magazine (.45 HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c45/hp

/obj/item/ammo_box/magazine/c45/incendiary
	name = "pistol magazine (.45 incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c45/inc

// MARK: Wylom AMR - .60 Strela
/obj/item/ammo_box/magazine/wylom
	name = "Wylom magazine (.60 Strela)"
	desc = "Магазин для антиматериальных винтовок Wylom калибра .60 Стрела, вмещающий 4 патрона."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "wylom_mag"
	base_icon_state = "wylom_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_STRELA60
	max_ammo = 4
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/strela60

// MARK: DKSH - 12.7x108mm
/obj/item/ammo_box/magazine/dshk
	name = "DKSH box (12.7x108mm)"
	desc = "Короб для тяжелых пулеметов ДКШ калибра 12.7x108мм, вмещающий 50 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "dshk_mag"
	base_icon_state = "dshk_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_127x108mm
	max_ammo = 50
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c127x108mm

/obj/item/ammo_box/magazine/dshk/c12ga
	name = "DKSH-12 box (12ga)"
	desc = "Короб для тяжелых пулеметов ДКШ 12-го калибра, вмещающий 40 патронов."
	icon_state = "dshk12_mag"
	base_icon_state = "dshk12_mag"
	caliber = CALIBER_SHOTGUN
	max_ammo = 40
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/dshk/c12ga/slug
	name = "DKSH-12 box (12ga slug)"
	icon_state = "dshk12_mag_slug"
	base_icon_state = "dshk12_mag_slug"
	ammo_type = /obj/item/ammo_casing/shotgun

// MARK: Volna-12 (Kord) - 12.7x108mm
/obj/item/ammo_box/magazine/volna
	name = "volna box (12.7x108mm)"
	desc = "Короб для тяжелых пулеметов Волна калибра 12.7x108мм, вмещающий 50 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "volna_mag"
	base_icon_state = "volna_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_127x108mm
	max_ammo = 50
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c127x108mm

// MARK: PMK - .310 / 7.62x54mmR
/obj/item/ammo_box/magazine/pmk
	name = "PMK box (7.62x54mmR)"
	desc = "Короб для легких пулеметов ПМК калибра 7.62x54мм, вмещающий 100 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "pmk_mag"
	base_icon_state = "pmk_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_762x54mmR
	max_ammo = 100
	ammo_band_icon = "+pmk_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c762x54mmr

/obj/item/ammo_box/magazine/pmk/rubber
	name = "PMK box (7.62x54mmR rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c762x54mmr/rubber

/obj/item/ammo_box/magazine/pmk/hp
	name = "PMK box (7.62x54mmR HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c762x54mmr/hp

/obj/item/ammo_box/magazine/pmk/ap
	name = "PMK box (7.62x54mmR AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c762x54mmr/ap

/obj/item/ammo_box/magazine/pmk/incendiary
	name = "PMK box (7.62x54mmR incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c762x54mmr/incendiary

/obj/item/ammo_box/magazine/pmk/starts_empty
	start_empty = TRUE

// MARK: Zashch - 10mm
/obj/item/ammo_box/magazine/zashch
	name = "pistol magazine (10mm)"
	desc = "Двухрядный пистолетный магазин калибра 10мм, вмещающий 15 патронов. Подходит для пистолетов П-10."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "zashch_mag"
	base_icon_state = "zashch_mag"
	w_class = WEIGHT_CLASS_TINY
	ammo_band_icon = "+zashch_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = CALIBER_10MM
	max_ammo = 15

/obj/item/ammo_box/magazine/zashch/rubber
	name = "pistol magazine (10mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c10mm/rubber

/obj/item/ammo_box/magazine/zashch/fire
	name = "pistol magazine (10mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/zashch/hp
	name = "pistol magazine (10mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/zashch/ap
	name = "pistol magazine (10mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c10mm/ap

// MARK: Lanca - .310 Strilka
/obj/item/ammo_box/magazine/strilka310
	name = "battle rifle magazine (.310 Strilka)"
	desc = "Магазин для боевых винтовок калибра .310 Стрилка, вмещающий 15 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "lanca_mag"
	base_icon_state = "lanca_mag"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_STRILKA310
	max_ammo = 15
	ammo_band_icon = "+lanca_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/strilka310

/obj/item/ammo_box/magazine/strilka310/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/strilka310/rubber
	name = "battle rifle magazine (.310 Strilka rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/strilka310/rubber

/obj/item/ammo_box/magazine/strilka310/hp
	name = "battle rifle magazine (.310 Strilka HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/strilka310/hp

/obj/item/ammo_box/magazine/strilka310/ap
	name = "battle rifle magazine (.310 Strilka AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/strilka310/ap

/obj/item/ammo_box/magazine/strilka310/incendiary
	name = "battle rifle magazine (.310 Strilka incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/strilka310/incendiary

// MARK: Vityaz - 10mm
/obj/item/ammo_box/magazine/smg10mm
	name = "SMG magazine (10mm)"
	desc = "Магазин для пистолетов-пулеметов калибра 10мм, вмещающий 30 патронов. Подходит для ПП \"Витязь\"."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "vityaz_mag"
	base_icon_state = "vityaz_mag"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_10MM
	max_ammo = 30
	ammo_band_icon = "+vityaz_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c10mm

/obj/item/ammo_box/magazine/smg10mm/rubber
	name = "SMG magazine (10mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c10mm/rubber

/obj/item/ammo_box/magazine/smg10mm/hp
	name = "SMG magazine (10mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/smg10mm/ap
	name = "SMG magazine (10mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/smg10mm/incendiary
	name = "SMG magazine (10mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c10mm/fire

// MARK: Bison - 9mm
/obj/item/ammo_box/magazine/bison
	name = "bison magazine (9mm)"
	desc = "Шнековый магазин для пистолетов-пулеметов \"Бисон\" калибра 9мм, вмещающий 64 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "bison_mag"
	base_icon_state = "bison_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_9MM
	max_ammo = 64
	ammo_band_icon = "+bison_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c9mm

/obj/item/ammo_box/magazine/bison/rubber
	name = "bison magazine (9mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c9mm/rubber

/obj/item/ammo_box/magazine/bison/hp
	name = "bison magazine (9mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9mm/hp

/obj/item/ammo_box/magazine/bison/ap
	name = "bison magazine (9mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/bison/fire
	name = "bison magazine (9mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c9mm/fire

// MARK: Dvoystvol - 7.62x38mm / .310 Strilka / .60 Strela

/obj/item/ammo_box/magazine/internal/cylinder/dvoystvol/rev762
	name = "Dvoystvol-8 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/n762
	caliber = CALIBER_N762
	max_ammo = 8

/obj/item/ammo_box/magazine/internal/cylinder/dvoystvol/rev310
	name = "Dvoystvol-6 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/strilka310
	caliber = CALIBER_STRILKA310
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/dvoystvol/rev60
	name = "Dvoystvol-60 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/strela60
	caliber = CALIBER_STRELA60
	max_ammo = 4

// MARK: Bobr - 12ga

/obj/item/ammo_box/magazine/internal/cylinder/rev12ga
	name = "Bobr-12 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/shotgun
	caliber = CALIBER_SHOTGUN
	max_ammo = 4

// MARK: RPG

/obj/item/ammo_box/magazine/internal/rocketlauncher/rpg
	name = "rpg-70 internal tube"
	ammo_type = /obj/item/ammo_casing/rocket/rpg

// MARK: Mosin / SKS
/obj/item/ammo_box/magazine/internal/boltaction/mosin
	ammo_type = /obj/item/ammo_casing/c762x54mmr
	caliber = CALIBER_762x54mmR

/obj/item/ammo_box/magazine/internal/boltaction/mosin/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/boltaction/mosin/strilka
	ammo_type = /obj/item/ammo_casing/strilka310

/obj/item/ammo_box/magazine/internal/boltaction/mosin/strilka/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/sks/c762x54mmr
	ammo_type = /obj/item/ammo_casing/c762x54mmr
	caliber = CALIBER_762x54mmR

/obj/item/ammo_box/magazine/internal/sks/c762x54mmr/empty
	start_empty = TRUE

// MARK: FN18 - 9mm SMG
/obj/item/ammo_box/magazine/fn18
	name = "SMG magazine (9mm)"
	desc = "Магазин для пистолетов-пулеметов калибра 9мм, вмещающий 40 патронов. Подходит для ПП FN18."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "fn18_mag"
	base_icon_state = "fn18_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_9MM
	max_ammo = 40
	ammo_band_icon = "+fn18_mag_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c9mm

/obj/item/ammo_box/magazine/fn18/rubber
	name = "SMG magazine (9mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c9mm/rubber

/obj/item/ammo_box/magazine/fn18/hp
	name = "SMG magazine (9mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9mm/hp

/obj/item/ammo_box/magazine/fn18/ap
	name = "SMG magazine (9mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/fn18/incendiary
	name = "SMG magazine (9mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c9mm/fire

// MARK: AS32 - auto shotgun
/obj/item/ammo_box/magazine/as32
	name = "AS32 magazine (12ga buckshot)"
	desc = "Магазин для штурмовых дробовиков AS32 12-го калибра, вмещающий 8 патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "as32_mag"
	base_icon_state = "as32_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_SHOTGUN
	max_ammo = 8
	ammo_band_icon = "+as32_mag_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec

/obj/item/ammo_box/magazine/as32/beanbag
	name = "AS32 magazine (12ga beanbag)"
	ammo_band_color = COLOR_GREEN
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/as32/rubbershot
	name = "AS32 magazine (12ga rubbershot)"
	ammo_band_color = COLOR_PINK
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/magazine/as32/executioner
	name = "AS32 magazine (12ga HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/shotgun/executioner

/obj/item/ammo_box/magazine/as32/slug
	name = "AS32 magazine (12ga slugs)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/as32/breacher
	name = "AS32 magazine (12ga breaching)"
	ammo_band_color = COLOR_BLUE_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/breacher

/obj/item/ammo_box/magazine/as32/frag12
	name = "AS32 magazine (12ga FRAG-12)"
	ammo_band_color = COLOR_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/magazine/as32/dragonsbreath
	name = "AS32 magazine (12ga dragonsbreath)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/as32/flechette
	name = "AS32 magazine (12ga flechette)"
	ammo_band_color = COLOR_ALMOST_BLACK
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/as32/drum
	name = "AS32 drum magazine (12ga buckshot)"
	desc = "Барабан для штурмовых дробовиков AS32 12-го калибра, вмещающий 12 патронов."
	icon_state = "as32_drum"
	base_icon_state = "as32_drum"
	max_ammo = 12
	ammo_band_icon = "+as32_drum_ammo_band"

/obj/item/ammo_box/magazine/as32/drum/beanbag
	name = "AS32 drum magazine (12ga beanbag)"
	ammo_band_color = COLOR_GREEN
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/as32/drum/rubbershot
	name = "AS32 drum magazine (12ga rubbershot)"
	ammo_band_color = COLOR_PINK
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/magazine/as32/drum/executioner
	name = "AS32 drum magazine (12ga HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/shotgun/executioner

/obj/item/ammo_box/magazine/as32/drum/slug
	name = "AS32 drum magazine (12ga slugs)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/as32/drum/breacher
	name = "AS32 drum magazine (12ga breaching)"
	ammo_band_color = COLOR_BLUE_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/breacher

/obj/item/ammo_box/magazine/as32/drum/frag12
	name = "AS32 drum magazine (12ga FRAG-12)"
	ammo_band_color = COLOR_GRAY
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/magazine/as32/drum/dragonsbreath
	name = "AS32 drum magazine (12ga dragonsbreath)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/as32/drum/flechette
	name = "AS32 drum magazine (12ga flechette)"
	ammo_band_color = COLOR_ALMOST_BLACK
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

// MARK: M45A5 - 1911 / .456 Magnum
/obj/item/ammo_box/magazine/m45a5
	name = "pistol magazine (.456 Magnum)"
	desc = "Пистолетный магазин калибра .456, вмещающий 7 патронов. Подходит для пистолетов M45A5."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "c456_mag"
	base_icon_state = "c456_mag"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_456MAG
	max_ammo = 7
	ammo_band_icon = "+c456_mag_ammo_band"
	ammo_band_color = null
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	ammo_type = /obj/item/ammo_casing/c456magnum

// MARK: 4.6x30mm
/obj/item/ammo_box/magazine/wt550m9/wtrubber
	name = "WT-550 magazine (4.6x30mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber
