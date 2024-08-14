/obj/item/storage/toolbox/guncase
	name = "gun case"
	desc = "A weapon's case. Has a blood-red 'S' stamped on the cover."
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "infiltrator_case"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	inhand_icon_state = "infiltrator_case"
	has_latches = FALSE
	var/weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol
	var/extra_to_spawn = /obj/item/ammo_box/magazine/m9mm

/obj/item/storage/toolbox/guncase/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_total_storage = 7 //enough to hold ONE bulky gun and the ammo boxes
	atom_storage.max_slots = 4

/obj/item/storage/toolbox/guncase/PopulateContents()
	new weapon_to_spawn (src)
	for(var/i in 1 to 3)
		new extra_to_spawn (src)

/obj/item/storage/toolbox/guncase/bulldog
	name = "bulldog gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/shotgun/bulldog
	extra_to_spawn = /obj/item/ammo_box/magazine/m12g

/obj/item/storage/toolbox/guncase/c20r
	name = "c-20r gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/c20r
	extra_to_spawn = /obj/item/ammo_box/magazine/smgm45

/obj/item/storage/toolbox/guncase/clandestine
	name = "clandestine gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/clandestine
	extra_to_spawn = /obj/item/ammo_box/magazine/m10mm

/obj/item/storage/toolbox/guncase/m90gl
	name = "m-90gl gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/m90
	extra_to_spawn = /obj/item/ammo_box/magazine/m556

/obj/item/storage/toolbox/guncase/m90gl/PopulateContents()
	new weapon_to_spawn (src)
	for(var/i in 1 to 2)
		new extra_to_spawn (src)
	new /obj/item/ammo_box/a40mm/rubber (src)

/obj/item/storage/toolbox/guncase/rocketlauncher
	name = "rocket launcher gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/rocketlauncher
	extra_to_spawn = /obj/item/ammo_box/rocket

/obj/item/storage/toolbox/guncase/rocketlauncher/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)

/obj/item/storage/toolbox/guncase/revolver
	name = "revolver gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/revolver/syndicate/nuclear
	extra_to_spawn = /obj/item/ammo_box/a357

/obj/item/storage/toolbox/guncase/sword_and_board
	name = "energy sword and shield weapon case"
	weapon_to_spawn = /obj/item/melee/energy/sword
	extra_to_spawn = /obj/item/shield/energy

/obj/item/storage/toolbox/guncase/sword_and_board/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)

/obj/item/storage/toolbox/guncase/cqc
	name = "\improper CQC equipment case"
	weapon_to_spawn = /obj/item/book/granter/martial/cqc
	extra_to_spawn = /obj/item/storage/box/syndie_kit/imp_stealth

/obj/item/storage/toolbox/guncase/cqc/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)
	new /obj/item/storage/fancy/cigarettes/cigpack_syndicate (src)
	new /obj/item/clothing/mask/bandana/skull (src) // the bandana intended for this doesnt exist anymore so the best i can do is an eypatch and a skull bandana
	new /obj/item/clothing/glasses/thermal/eyepatch (src) //hngh colonel im trying to sneak around...
	new /obj/item/toy/plush/snakeplushie (src)


/*
*	GUNSET BOXES
*/

/obj/item/storage/toolbox/guncase/skyrat
	desc = "A thick gun case with foam inserts laid out to fit a weapon, magazines, and gear securely."

	icon = 'monkestation/code/modules/blueshift/icons/obj/gunsets.dmi'
	icon_state = "guncase"

	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/worn/cases.dmi'
	worn_icon_state = "darkcase"

	slot_flags = ITEM_SLOT_BACK

	material_flags = NONE

	/// Is the case visually opened or not
	var/opened = FALSE

/obj/item/storage/toolbox/guncase/skyrat/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 14 // Technically means you could fit multiple large guns in here but its a case you cant backpack anyways so what it do
	atom_storage.max_slots = 6 // We store some extra items in these so lets make a little extra room

/obj/item/storage/toolbox/guncase/skyrat/update_icon()
	. = ..()
	if(opened)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)

/obj/item/storage/toolbox/guncase/skyrat/AltClick(mob/user)
	opened = !opened
	update_icon()

/obj/item/storage/toolbox/guncase/skyrat/attack_self(mob/user)
	. = ..()
	opened = !opened
	update_icon()

// Empty guncase

/obj/item/storage/toolbox/guncase/skyrat/empty

/obj/item/storage/toolbox/guncase/skyrat/empty/PopulateContents()
	return

// Small case for pistols and whatnot

/obj/item/storage/toolbox/guncase/skyrat/pistol
	name = "small gun case"

	icon_state = "guncase_s"

	slot_flags = NONE

	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/toolbox/guncase/skyrat/pistol/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

// Empty pistol case

/obj/item/storage/toolbox/guncase/skyrat/pistol/empty

/obj/item/storage/toolbox/guncase/skyrat/pistol/empty/PopulateContents()
	return

// Base yellow carwo case

/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case
	desc = "A thick yellow gun case with foam inserts laid out to fit a weapon, magazines, and gear securely."

	icon = 'monkestation/code/modules/blueshift/icons/obj/gunsets.dmi'
	icon_state = "case_carwo"

	worn_icon_state = "yellowcase"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/cases_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/cases_righthand.dmi'
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

/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/sindano/evil
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/sol_smg/evil/no_mag

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
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet.dmi'
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

// Base yellow carwo case

/obj/item/storage/toolbox/guncase/skyrat/xhihao_large_case

	icon = 'monkestation/code/modules/blueshift/icons/obj/gunsets.dmi'
	icon_state = "case_xhihao"

// Empty version of the case

/obj/item/storage/toolbox/guncase/skyrat/xhihao_large_case/empty

/obj/item/storage/toolbox/guncase/skyrat/xhihao_large_case/empty/PopulateContents()
	return

// Contains the Bogseo submachinegun, excellent for breaking shoulders

/obj/item/storage/toolbox/guncase/skyrat/xhihao_large_case/bogseo
	name = "\improper Xhihao 'Bogseo' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/xhihao_smg/no_mag
	extra_to_spawn = /obj/item/ammo_box/magazine/c585trappiste_pistol

/obj/item/storage/toolbox/guncase/skyrat/xhihao_large_case/bogseo/PopulateContents()
	new weapon_to_spawn (src)

	generate_items_inside(list(
		/obj/item/ammo_box/c585trappiste/incapacitator = 1,
		/obj/item/ammo_box/c585trappiste = 1,
		/obj/item/ammo_box/magazine/c585trappiste_pistol/spawns_empty = 3,
	), src)

// Base yellow with symbol trappiste case

/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case
	desc = "A thick yellow gun case with foam inserts laid out to fit a weapon, magazines, and gear securely. The five square grid of Trappiste Fabriek is displayed prominently on the top."

	icon = 'monkestation/code/modules/blueshift/icons/obj/gunsets.dmi'
	icon_state = "case_trappiste"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/cases_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/cases_righthand.dmi'
	inhand_icon_state = "yellowcase"

// Empty version of the case

/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/empty

/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/empty/PopulateContents()
	return

// Gunset for the Wespe pistol

/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/wespe
	name = "Trappiste 'Wespe' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/sol/no_mag
	extra_to_spawn = /obj/item/ammo_box/magazine/c35sol_pistol

/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/eland
	name = "Trappiste 'Eland' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/revolver/sol
	extra_to_spawn = /obj/item/ammo_box/c35sol/incapacitator

// Gunset for the Skild heavy pistol

/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/skild
	name = "Trappiste 'Skild' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/trappiste/no_mag
	extra_to_spawn = /obj/item/ammo_box/magazine/c585trappiste_pistol

// Gunset for the Takbok Revolver

/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/takbok
	name = "Trappiste 'Takbok' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/revolver/takbok
	extra_to_spawn = /obj/item/ammo_box/c585trappiste
