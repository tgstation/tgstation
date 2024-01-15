// Base Sol SMG

/obj/item/gun/ballistic/automatic/sol_smg
	name = "\improper Carwo 'Sindano' Submachinegun"
	desc = "A small submachinegun commonly seen in the hands of PMCs and other unsavory corpos. Accepts any standard Sol pistol magazine."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns32x.dmi'
	icon_state = "sindano"

	inhand_icon_state = "c20r"

	special_mags = TRUE

	bolt_type = BOLT_TYPE_OPEN

	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	slot_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_BELT

	accepted_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol
	spawn_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol/stendo

	fire_sound = 'modular_skyrat/modules/modular_weapons/sounds/smg_light.ogg'
	can_suppress = TRUE

	can_bayonet = FALSE

	suppressor_x_offset = 11

	burst_size = 3
	fire_delay = 0.2 SECONDS

	spread = 7.5

/obj/item/gun/ballistic/automatic/sol_smg/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CARWO)

/obj/item/gun/ballistic/automatic/sol_smg/examine_more(mob/user)
	. = ..()

	. += "The Sindano submachinegun was originally produced for military contract. \
		These guns were seen in the hands of anyone from medics, ship techs, logistics officers, \
		and shuttle pilots often had several just to show off. Due to SolFed's quest to \
		extend the lifespans of their logistics officers and quartermasters, the weapon \
		uses the same standard pistol cartridge that most other miltiary weapons of \
		small caliber use. This results in interchangeable magazines between pistols \
		and submachineguns, neat!"

	return .

/obj/item/gun/ballistic/automatic/sol_smg/no_mag
	spawnwithmagazine = FALSE

// Sindano (evil)

/obj/item/gun/ballistic/automatic/sol_smg/evil
	desc = "A small submachinegun, this one is painted in tacticool black. Accepts any standard Sol pistol magazine."

	icon_state = "sindano_evil"

/obj/item/gun/ballistic/automatic/sol_smg/evil/no_mag
	spawnwithmagazine = FALSE
