// Base yellow carwo case

/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case
	desc = "A thick yellow gun case with foam inserts laid out to fit a weapon, magazines, and gear securely."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/gunsets.dmi'
	icon_state = "case_carwo"

	worn_icon_state = "yellowcase"

	lefthand_file = 'modular_skyrat/modules/modular_weapons/icons/mob/inhands/cases_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/modular_weapons/icons/mob/inhands/cases_righthand.dmi'
	inhand_icon_state = "yellowcase"

// Empty version of the case

/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/empty

/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/empty/PopulateContents()
	return

// Sindano in a box, how innovative!

/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/sindano
	name = "\improper Carwo 'Sindano' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/sol_smg/no_mag
	extra_to_spawn = /obj/item/ammo_box/magazine/c35sol_pistol/stendo

/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/sindano/PopulateContents()
	new weapon_to_spawn (src)

	generate_items_inside(list(
		/obj/item/ammo_box/c35sol/incapacitator = 1,
		/obj/item/ammo_box/c35sol = 1,
		/obj/item/ammo_box/magazine/c35sol_pistol/stendo/starts_empty = 1,
		/obj/item/ammo_box/magazine/c35sol_pistol/starts_empty = 2,
	), src)

// Boxed grenade launcher, grenades sold seperately on this one

/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/kiboko_magless
	name = "\improper Carwo 'Kiboko' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/sol_grenade_launcher/no_mag
	extra_to_spawn = /obj/item/ammo_box/magazine/c980_grenade/starts_empty


/obj/structure/closet/secure_closet/armory_kiboko
	name = "heavy equipment locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "shotguncase"

/obj/structure/closet/secure_closet/armory_kiboko/PopulateContents()
	. = ..()

	generate_items_inside(list(
		/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/kiboko_magless = 1,
		/obj/item/ammo_box/c980grenade = 2,
		/obj/item/ammo_box/c980grenade/smoke = 1,
		/obj/item/ammo_box/c980grenade/riot = 1,
	), src)

/obj/structure/closet/secure_closet/armory_kiboko_but_evil
	name = "heavy equipment locker"
	icon = 'modular_skyrat/master_files/icons/obj/closet.dmi'
	icon_door = "riot"
	icon_state = "riot"
	req_access = list(ACCESS_SYNDICATE)
	anchored = 1

/obj/structure/closet/secure_closet/armory_kiboko_but_evil/PopulateContents()
	. = ..()

	generate_items_inside(list(
		/obj/item/gun/ballistic/automatic/sol_grenade_launcher/evil/no_mag = 1,
		/obj/item/ammo_box/magazine/c980_grenade/drum/starts_empty = 2,
		/obj/item/ammo_box/c980grenade/shrapnel = 1,
		/obj/item/ammo_box/c980grenade/shrapnel/phosphor = 1,
		/obj/item/ammo_box/c980grenade/smoke = 1,
		/obj/item/ammo_box/c980grenade/riot = 1,
	), src)
