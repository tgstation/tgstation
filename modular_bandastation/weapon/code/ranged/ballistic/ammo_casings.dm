// MARK: .35 Sol
/obj/item/ammo_casing/c35sol
	name = ".35 Sol Short bullet casing"
	desc = "Стандартный летальный пистолетный патрон ТСФ калибра .35 Sol Short."
	caliber = CALIBER_SOL35SHORT
	projectile_type = /obj/projectile/bullet/c35sol

/obj/item/ammo_casing/c35sol/rubber
	name = ".35 Sol Short rubber bullet casing"
	desc = "Стандартный травматический пистолетный патрон ТСФ с резиновой пулей калибра .35 Sol Short с пониженной летальностью. Изнуряет цель при попадании, имеет тенденцию отскакивать от стен под небольшим углом."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sr-casing"
	projectile_type = /obj/projectile/bullet/c35sol/rubber

// .35 Sol ripper, similar to the detective revolver's dumdum rounds, causes slash wounds and is weak to armor
/obj/item/ammo_casing/c35sol/hp
	name = ".35 Sol Short hollow-point bullet casing"
	desc = "Стандартный экспансивный пистолетный патрон ТСФ калибра .35 Sol Short. Наносит целям режущие раны, но слаб против брони."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sh-casing"
	projectile_type = /obj/projectile/bullet/c35sol/hp

// .35 sol armor piercing are the AP rounds for this weapon
/obj/item/ammo_casing/c35sol/ap
	name = ".35 Sol Short armor-piercing bullet casing"
	desc = "Стандартный бронебойный пистолетный патрон ТСФ калибра .35 Sol Short. Пробивает броню, но довольно слаб против небронированных целей."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sa-casing"
	projectile_type = /obj/projectile/bullet/c35sol/ap

// MARK: 7.62x39mm
/obj/item/ammo_casing/c762x39
	name = "7.62x39mm bullet casing"
	desc = "Патрон калибра 7.62x39мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "762x39-casing"
	caliber = CALIBER_762x39mm
	projectile_type = /obj/projectile/bullet/c762x39

/obj/item/ammo_casing/c762x39/ricochet
	name = "7.62x39mm match bullet casing"
	desc = "Спортивный патрон калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/c762x39/ricochet

/obj/item/ammo_casing/c762x39/incendiary
	name = "7.62x39mm incendiary bullet casing"
	desc = "Патрон с зажигательной пулей калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/incendiary/c762x39

/obj/item/ammo_casing/c762x39/ap
	name = "7.62x39mm armor-piercing bullet casing"
	desc = "Патрон с бронебойной пулей калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/c762x39/ap

/obj/item/ammo_casing/c762x39/emp
	name = "7.62x39mm ion bullet casing"
	desc = "Патрон с ионной пулей калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/c762x39/emp

/obj/item/ammo_casing/c762x39/civilian
	name = "7.62x39mm civilian bullet casing"
	desc = "Гражданский патрон калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/c762x39/civilian

/obj/item/ammo_casing/c762x39/rubber
	name = "7.62x39mm rubber bullet casing"
	desc = "Патрон с резиновой пулей калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/c762x39/rubber

/obj/item/ammo_casing/c762x39/hunting
	name = "7.62x39mm hunting bullet casing"
	desc = "Патрон с оболочечной пулей 7.62x39мм с мягким наконечником."
	projectile_type = /obj/projectile/bullet/c762x39/hunting

/obj/item/ammo_casing/c762x39/blank
	name = "7.62x39mm blank bullet casing"
	desc = "Холостой патрон калибра 7.62x39мм."
	projectile_type = /obj/projectile/bullet/c762x39/blank
	harmful = FALSE

// MARK: .40 Sol Long
/obj/item/ammo_casing/c40sol
	name = ".40 Sol Long bullet casing"
	desc = "Стандартный винтовочный патрон ТСФ калибра .40 Sol Long."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "40sol"
	caliber = CALIBER_SOL40LONG
	projectile_type = /obj/projectile/bullet/c40sol

// .40 Sol rubber-fragmentation rounds, embeds shrapnel in the target almost every time at close to medium range. Teeeechnically less lethals.
/obj/item/ammo_casing/c40sol/fragmentation
	name = ".40 Sol Long rubber-fragmentation bullet casing"
	desc = "Стандартный осколочно-травматический винтовочный патрон ТСФ с резиновой пулей калибра .40 Sol Long. Разрывается при ударе, выбрасывая резиновую шрапнель, которая может вывести цель из строя."
	icon_state = "40sol_disabler"
	projectile_type = /obj/projectile/bullet/c40sol/fragmentation

// .40 Sol armor-pierce grade, bounces a lot, and if there's less than 20 bullet armor on wherever these hit, it'll go completely through the target and out the other side
/obj/item/ammo_casing/c40sol/ap
	name = ".40 Sol Long armor-pierce bullet casing"
	desc = "Стандартный бронебойный винтовочный патрон ТСФ калибра .40 Sol Long. Стреляет под более высоким давлением и, \
	следовательно, несколько быстрее. По слухам, с ними можно пробивать несколько препятствий или противников насквозь, \
	хотя официальная рекомендация - стрелять только в цель, а не в стену рядом с ней."
	icon_state = "40sol_pierce"
	projectile_type = /obj/projectile/bullet/c40sol/ap

// .40 Sol incendiary
/obj/item/ammo_casing/c40sol/incendiary
	name = ".40 Sol Long incendiary bullet casing"
	desc = "Стандартный зажигательный винтовочный патрон ТСФ калибра .40 Sol Long. Не оставляет огненного следа, воспламеняя цель только при попадании."
	icon_state = "40sol_flame"
	projectile_type = /obj/projectile/bullet/incendiary/c40sol

// MARK: 9x25mm NT
/obj/item/ammo_casing/c9x25mm
	name = "9x25mm NT bullet casing"
	desc = "Стандартный летальный пистолетный патрон НТ калибра 9x25мм."
	caliber = CALIBER_9x25NT
	projectile_type = /obj/projectile/bullet/c9x25mm

/obj/item/ammo_casing/c9x25mm/rubber
	name = "9x25mm NT rubber bullet casing"
	desc = "Стандартный травматический пистолетный патрон НТ с резиновой пулей калибра 9x25мм. Изнуряет цель при попадании, имеет тенденцию отскакивать от стен под небольшим углом."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sr-casing"
	projectile_type = /obj/projectile/bullet/c9x25mm/rubber

/obj/item/ammo_casing/c9x25mm/hp
	name = "9x25mm NT hollow-point bullet casing"
	desc = "Стандартный экспансивный пистолетный патрон НТ калибра 9x25мм. Наносит целям режущие раны, но слаб против брони."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sh-casing"
	projectile_type = /obj/projectile/bullet/c9x25mm/hp

/obj/item/ammo_casing/c9x25mm/ap
	name = "9x25mm NT armor-piercing bullet casing"
	desc = "Стандартный бронебойный пистолетный патрон НТ калибра 9x25мм. Пробивает броню, но довольно слаб против небронированных целей."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sa-casing"
	projectile_type = /obj/projectile/bullet/c9x25mm/ap

// MARK: .223 aka 5.56mm
/obj/item/ammo_casing/a223
	name = "5.56x45mm bullet casing"
	desc = "Стандартный летальный винтовочный патрон калибра 5.56x45мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "556-casing"
	caliber = CALIBER_A223
	projectile_type = /obj/projectile/bullet/a223

/obj/item/ammo_casing/a223/rubber
	name = "5.56x45mm rubber bullet casing"
	desc = "Травматический винтовочный патрон c резиновой пулей калибра 5.56x45мм."
	icon_state = "556r-casing"
	projectile_type = /obj/projectile/bullet/a223/rubber

/obj/item/ammo_casing/a223/hp
	name = "5.56x45mm hollow-point bullet casing"
	desc = "Экспансивный винтовочный патрон калибра 5.56x45мм."
	icon_state = "556hp-casing"
	projectile_type = /obj/projectile/bullet/a223/hp

/obj/item/ammo_casing/a223/ap
	name = "5.56x45mm armor-piercing bullet casing"
	desc = "Бронебойный винтовочный патрон калибра 5.56x45мм."
	icon_state = "556ap-casing"
	projectile_type = /obj/projectile/bullet/a223/ap

/obj/item/ammo_casing/a223/phasic
	name = "5.56x45mm phasic bullet casing"
	desc = "Бронебойный-фазовый винтовочный патрон калибра 5.56x45мм."
	icon_state = "556pen-casing"
	projectile_type = /obj/projectile/bullet/a223/phasic

/obj/item/ammo_casing/a223/incendiary
	name = "5.56x45mm incendiary bullet casing"
	desc = "Зажигательный винтовочный патрон калибра 5.56x45мм."
	icon_state = "556i-casing"
	projectile_type = /obj/projectile/bullet/incendiary/a223

// MARK: 7.62x51mm
/obj/item/ammo_casing/c762x51mm
	name = "7.62x51mm bullet casing"
	desc = "Стандартный летальный винтовочный патрон калибра 7.62x51мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "762x51-casing"
	caliber = CALIBER_762x51mm
	projectile_type = /obj/projectile/bullet/c762x51mm

/obj/item/ammo_casing/c762x51mm/rubber
	name = "7.62x51mm rubber bullet casing"
	desc = "Травматический винтовочный патрон c резиновой пулей калибра 7.62x51мм."
	icon_state = "762x51r-casing"
	projectile_type = /obj/projectile/bullet/c762x51mm/rubber

/obj/item/ammo_casing/c762x51mm/hp
	name = "7.62x51mm hollow-point bullet casing"
	desc = "Экспансивный винтовочный патрон калибра 7.62x51мм."
	icon_state = "762x51hp-casing"
	projectile_type = /obj/projectile/bullet/c762x51mm/hp

/obj/item/ammo_casing/c762x51mm/ap
	name = "7.62x51mm armor-piercing bullet casing"
	icon_state = "762x51ap-casing"
	desc = "Бронебойный винтовочный патрон калибра 7.62x51мм."
	projectile_type = /obj/projectile/bullet/c762x51mm/ap

/obj/item/ammo_casing/c762x51mm/incendiary
	name = "7.62x51mm incendiary bullet casing"
	icon_state = "762x51i-casing"
	desc = "Зажигательный винтовочный патрон калибра 7.62x51мм."
	projectile_type = /obj/projectile/bullet/incendiary/c762x51mm

// MARK: .338 aka 8.6x70mm
/obj/item/ammo_casing/c338
	name = ".338 bullet casing"
	desc = "Крупнокалиберный винтовочный патрон калибра .338."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "338-casing"
	caliber = CALIBER_338
	projectile_type = /obj/projectile/bullet/c338

/obj/item/ammo_casing/c338/hp
	name = ".338 hollow-point bullet casing"
	desc = "Крупнокалиберный экспансивный винтовочный патрон калибра .338."
	icon_state = "338hp-casing"
	projectile_type = /obj/projectile/bullet/c338/hp

/obj/item/ammo_casing/c338/ap
	name = ".338 armor-piercing bullet casing"
	desc = "Крупнокалиберный бронебойный винтовочный патрон калибра .338."
	icon_state = "338ap-casing"
	projectile_type = /obj/projectile/bullet/c338/ap

/obj/item/ammo_casing/c338/incendiary
	name = ".338 incendiary bullet casing"
	icon_state = "338i-casing"
	desc = "Крупнокалиберный зажигательный винтовочный патрон калибра .338."
	projectile_type = /obj/projectile/bullet/incendiary/c338

// MARK: .38
/obj/item/ammo_casing/c38/ap
	name = ".38 armor-piercing bullet casing"
	desc = "Бронебойный пистолетный патрон калибра .38."
	projectile_type = /obj/projectile/bullet/c38/ap
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sa-casing"

/obj/item/ammo_casing/c38/dumdum
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sh-casing"

/obj/item/ammo_casing/c38/match
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sr-casing"

/obj/item/ammo_casing/c38/hotshot
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "si-casing"

// MARK: .357
/obj/item/ammo_casing/c357/match
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sr-casing"

/obj/item/ammo_casing/c357/phasic
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sa-casing"

/obj/item/ammo_casing/c357/heartseeker
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sh-casing"

// MARK: 9mm
/obj/item/ammo_casing/c9mm/hp
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sh-casing"

/obj/item/ammo_casing/c9mm/ap
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sa-casing"

/obj/item/ammo_casing/c9mm/fire
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "si-casing"

/obj/item/ammo_casing/c9mm/rubber
	name = "9mm rubber bullet casing"
	desc = "Травматический пистолетный патрон с резиновой пулей калибра 9мм. Изнуряет цель при попадании, имеет тенденцию отскакивать от стен под небольшим углом."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sr-casing"
	projectile_type = /obj/projectile/bullet/c9mm/rubber

// MARK: .45
/obj/item/ammo_casing/c45/rubber
	name = ".45 rubber bullet casing"
	desc = "Травматический пистолетный патрон калибра .45 с резиновой пулей. Изнуряет цель при попадании, имеет тенденцию отскакивать от стен под небольшим углом."
	projectile_type = /obj/projectile/bullet/c45/rubber
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sr-casing"

/obj/item/ammo_casing/c45/ap
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sa-casing"

/obj/item/ammo_casing/c45/hp
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sh-casing"

/obj/item/ammo_casing/c45/inc
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "si-casing"

// MARK: .456 Magnum
/obj/item/ammo_casing/c456magnum
	name = ".456 magnum bullet casing"
	desc = "Пистолетный патрон калибра .456 Магнум."
	projectile_type = /obj/projectile/bullet/c456magnum
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sa-casing"
	caliber = CALIBER_456MAG

// MARK: 10mm
/obj/item/ammo_casing/c10mm/rubber
	name = "10mm rubber bullet casing"
	desc = "Травматический пистолетный патрон калибра 10мм."
	projectile_type = /obj/projectile/bullet/c10mm/rubber
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sr-casing"

// MARK: 4.6x30mm
/obj/item/ammo_casing/c46x30mm/rubber
	name = "4.6x30mm rubber bullet casing"
	desc = "Травматический патрон с резиновой пулей калибра 4.6x30мм. Изнуряет цель при попадании, имеет тенденцию отскакивать от стен под небольшим углом."
	projectile_type = /obj/projectile/bullet/c46x30mm/rubber
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sr-casing"

/obj/item/ammo_casing/c46x30mm/ap
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "sa-casing"

/obj/item/ammo_casing/c46x30mm/inc
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "si-casing"

// MARK: .310 Strilka
/obj/item/ammo_casing/strilka310/rubber
	name = ".310 Strilka rubber bullet casing"
	desc = "Травматический безгильзовый винтовочный патрон c резиновой пулей калибра .310 Стрилка."
	icon_state = "762x51r-casing"
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	projectile_type = /obj/projectile/bullet/strilka310/rubber

/obj/item/ammo_casing/strilka310/ap
	name = ".310 Strilka armor-piercing bullet casing"
	desc = "Бронебойный винтовочный безгильзовый патрон калибра .310 Стрилка."
	projectile_type = /obj/projectile/bullet/strilka310/ap
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "310ap-casing"

/obj/item/ammo_casing/strilka310/hp
	name = ".310 Strilka hollow-point bullet casing"
	desc = "Экспансивный винтовочный безгильзовый патрон калибра .310 Стрилка."
	projectile_type = /obj/projectile/bullet/strilka310/hp
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "310hp-casing"

/obj/item/ammo_casing/strilka310/incendiary
	name = ".310 Strilka incendiary bullet casing"
	desc = "Зажигательный винтовочный безгильзовый патрон калибра .310 Стрилка."
	projectile_type = /obj/projectile/bullet/incendiary/strilka310
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "310ic-casing"

/obj/item/ammo_casing/strilka310/phasic
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	desc = "Фазовый винтовочный безгильзовый патрон калибра .310 Стрилка."
	icon_state = "310ap-casing"

// MARK: .60 Strela
/obj/item/ammo_casing/strela60
	name = ".60 Strela anti-material bullet casing"
	desc = "Крупнокалиберный безгильзовый винтовочный патрон калибра .60 Стрела."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "strela60-casing"
	caliber = CALIBER_STRELA60
	projectile_type = /obj/projectile/bullet/p50/strela60

/obj/item/ammo_casing/strela60/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

// MARK: 7.62x54mmR
/obj/item/ammo_casing/c762x54mmr
	name = "7.62x54mmR bullet casing"
	desc = "Винтовочный патрон калибра 7.62x54мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "762x51-casing"
	caliber = CALIBER_762x54mmR
	projectile_type = /obj/projectile/bullet/c762x54mmr

/obj/item/ammo_casing/c762x54mmr/rubber
	name = "7.62x54mmR rubber bullet casing"
	desc = "Травматический винтовочный патрон c резиновой пулей калибра 7.62x54мм."
	icon_state = "762x51r-casing"
	projectile_type = /obj/projectile/bullet/c762x54mmr/rubber

/obj/item/ammo_casing/c762x54mmr/hp
	name = "7.62x54mmR hollow-point bullet casing"
	desc = "Экспансивный винтовочный патрон калибра 7.62x54мм."
	icon_state = "762x51hp-casing"
	projectile_type = /obj/projectile/bullet/c762x54mmr/hp

/obj/item/ammo_casing/c762x54mmr/ap
	name = "7.62x54mmR armor-piercing bullet casing"
	icon_state = "762x51ap-casing"
	desc = "Бронебойный винтовочный патрон калибра 7.62x54мм."
	projectile_type = /obj/projectile/bullet/c762x54mmr/ap

/obj/item/ammo_casing/c762x54mmr/incendiary
	name = "7.62x54mmR incendiary bullet casing"
	icon_state = "762x51i-casing"
	desc = "Зажигательный винтовочный патрон калибра 7.62x54мм."
	projectile_type = /obj/projectile/bullet/incendiary/c762x54mmr

// MARK: 12.7x108mm
/obj/item/ammo_casing/c127x108mm
	name = "12.7x108mm bullet casing"
	desc = "Крупнокалиберный патрон калибра 12.7x108мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "c127x108mm-casing"
	caliber = CALIBER_127x108mm
	projectile_type = /obj/projectile/bullet/c127x108mm

// MARK: RPG
/obj/item/ammo_casing/rocket
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_casing/rocket/rpg
	name = "RPG-70 HE rocket"
	desc = "84-мм фугасная ракета. Стреляйте в людей и молитесь."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "rpg_rocket"
	base_icon_state = "rpg_rocket"
	projectile_type = /obj/projectile/bullet/rocket

/obj/item/ammo_casing/rocket/rpg/heap
	name = "RPG-70 HE-AP rocket"
	desc = "84-мм фугасная-бронебойная тандемная ракета. Для тех случаев, когда нужно, чтобы что-то просто перестало существовать."
	icon_state = "rpg_rocket_heap"
	base_icon_state = "rpg_rocket_heap"
	projectile_type = /obj/projectile/bullet/rocket/heap

/obj/item/ammo_casing/rocket/rpg/weak
	name = "RPG-70 HE Low-Yield rocket"
	desc = "84-мм фугасная ракета малого действия. Не такая разрушительная, для самых юных гранатометчиков."
	icon_state = "rpg_rocket_low_yield"
	base_icon_state = "rpg_rocket_low_yield"
	projectile_type = /obj/projectile/bullet/rocket/weak
