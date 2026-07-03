/datum/supply_pack/security/webbings
	name = "Ammo Webbings"
	crate_name = "ammo webbings crate"
	desc = "В этом ящике находятся две тактические разгрузки под магазины - обычная и темная, которые практично и удобно надеваются поверх униформы."
	cost = CARGO_CRATE_VALUE * 5
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/clothing/accessory/ammo_vest = 1,
		/obj/item/clothing/accessory/ammo_vest/black = 1,
	)

/datum/supply_pack/security/gp9_pistols
	name = "GP-9 Pistols Crate"
	desc = "В этом ящике находятся два пистолета GP-9 калибра 9x25мм, а также четыре нелетальных магазина калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 10
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/gp9/no_mag = 2,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/rubber = 4,
	)
	crate_name = "GP-9 handguns crate"

/datum/supply_pack/security/gp9_ammo
	name = "9x25mm NT Ammo Crate"
	desc = "В этом ящике находятся два нелетальных магазина и два летальных магазина калибра 9x25мм НТ, и соответствующие коробки с боеприпасами."
	cost = CARGO_CRATE_VALUE * 6
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/c9x25mm_pistol = 2,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/rubber = 2,
		/obj/item/ammo_box/c9x25mm = 1,
		/obj/item/ammo_box/c9x25mm/rubber = 1,
	)
	crate_name = "9x25mm NT ammo crate"

/datum/supply_pack/security/gp9_ammospecial
	name = "9x25mm NT Special Ammo Crate"
	desc = "В этом ящике находятся два бронебойных магазина и два экспансивных магазина калибра 9x25мм НТ, и соответствующие коробки с боеприпасами."
	cost = CARGO_CRATE_VALUE * 8
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/c9x25mm_pistol/ap = 2,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/hp = 2,
		/obj/item/ammo_box/c9x25mm/ap = 1,
		/obj/item/ammo_box/c9x25mm/hp = 1,
	)
	crate_name = "9x25mm NT special ammo crate"

/datum/supply_pack/security/gp9_mags_extended
	name = "9x25mm NT Extended Magazines Crate"
	desc = "В этом ящике находятся два увеличенных магазина калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 6
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo = 1,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/rubber = 1,
	)
	crate_name = "9x25mm NT extended magazines crate"

/datum/supply_pack/goody/gp9_mags_extended_single
	name = "9x25mm NT Extended Magazine Crate"
	desc = "B этом ящике находится один увеличенный магазин калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/starts_empty = 1,
	)

/datum/supply_pack/goody/gp9_single
	name = "GP-9 Pistol Single-Pack"
	desc = "В этом ящике находится один пистолет GP-9 калибра 9x25мм НТ с пустым магазином."
	cost = CARGO_CRATE_VALUE * 6
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/gp9/no_mag = 1,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/starts_empty = 1,
	)

/datum/supply_pack/goody/c9x25mmrubber
	name = "9x25mm NT Rubber Ammo Box"
	desc = "В этом ящике находится коробка резиновых патронов калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c9x25mm/rubber = 1,
	)

/datum/supply_pack/goody/c9x25mmhp
	name = "9x25mm NT HP Ammo Box"
	desc = "В этом ящике находится коробка экспансивных патронов калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c9x25mm/hp = 1,
	)

/datum/supply_pack/goody/c9x25mmap
	name = "9x25mm NT AP Ammo Box"
	desc = "В этом ящике находится коробка бронебойных патронов калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c9x25mm/ap = 1,
	)

/datum/supply_pack/goody/c9x25mm
	name = "9x25mm NT Ammo Box"
	desc = "В этом ящике находится коробка летальных патронов калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c9x25mm = 1,
	)

/datum/supply_pack/security/armory/sledgehammer
	name = "D4 Tactical Sledgehammer"
	crate_name = "D4 tactical sledgehammer crate"
	desc = "В этом ящике находится композитный молот для создания брешей или уничтожения препятствий."
	cost = CARGO_CRATE_VALUE * 15
	access_view = ACCESS_ARMORY
	contains = list(
		/obj/item/sledgehammer/tactical = 1,
	)

/datum/supply_pack/security/holsters
	name = "Holsters (uniform)"
	crate_name = "holsters crate"
	desc = "В этом ящике находятся две обычные кобуры для пистолетов, которые надеваются поверх униформы."
	cost = CARGO_CRATE_VALUE * 10
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/clothing/accessory/holster = 2
	)

// MARK: GUNCASE
/obj/item/storage/toolbox/guncase/soviet
	desc = "Оружейный кейс. Символ СССП отпечатан на боковой стороне."
