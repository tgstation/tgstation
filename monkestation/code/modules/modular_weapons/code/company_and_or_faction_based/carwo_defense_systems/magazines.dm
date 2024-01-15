// .35 Sol pistol magazines

/obj/item/ammo_box/magazine/c35sol_pistol
	name = "\improper Sol pistol magazine"
	desc = "A standard size magazine for SolFed pistols, holds twelve rounds."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "pistol_35_standard"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_TINY

	ammo_type = /obj/item/ammo_casing/c35sol
	caliber = CALIBER_SOL35SHORT
	max_ammo = 12

/obj/item/ammo_box/magazine/c35sol_pistol/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c35sol_pistol/stendo
	name = "\improper Sol extended pistol magazine"
	desc = "An extended magazine for SolFed pistols, holds twenty-four rounds."

	icon_state = "pistol_35_stended"

	w_class = WEIGHT_CLASS_NORMAL

	max_ammo = 24

/obj/item/ammo_box/magazine/c35sol_pistol/stendo/starts_empty
	start_empty = TRUE

// .40 Sol rifle magazines

/obj/item/ammo_box/magazine/c40sol_rifle
	name = "\improper Sol rifle short magazine"
	desc = "A shortened magazine for SolFed rifles, holds fifteen rounds."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "rifle_short"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_TINY

	ammo_type = /obj/item/ammo_casing/c40sol
	caliber = CALIBER_SOL40LONG
	max_ammo = 15

/obj/item/ammo_box/magazine/c40sol_rifle/starts_empty

	start_empty = TRUE

/obj/item/ammo_box/magazine/c40sol_rifle/standard
	name = "\improper Sol rifle magazine"
	desc = "A standard size magazine for SolFed rifles, holds thirty rounds."

	icon_state = "rifle_standard"

	w_class = WEIGHT_CLASS_SMALL

	max_ammo = 30

/obj/item/ammo_box/magazine/c40sol_rifle/standard/starts_empty
	start_empty = TRUE


/obj/item/ammo_box/magazine/c40sol_rifle/drum
	name = "\improper Sol rifle drum magazine"
	desc = "A massive drum magazine for SolFed rifles, holds sixty rounds."

	icon_state = "rifle_drum"

	w_class = WEIGHT_CLASS_BULKY

	max_ammo = 60

/obj/item/ammo_box/magazine/c40sol_rifle/drum/starts_empty
	start_empty = TRUE

// .980 grenade magazines

/obj/item/ammo_box/magazine/c980_grenade
	name = "\improper Kiboko grenade box"
	desc = "A standard size box for .980 grenades, holds four shells."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "granata_standard"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_SMALL

	ammo_type = /obj/item/ammo_casing/c980grenade
	caliber = CALIBER_980TYDHOUER
	max_ammo = 4

/obj/item/ammo_box/magazine/c980_grenade/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c980_grenade/drum
	name = "\improper Kiboko grenade drum"
	desc = "A drum for .980 grenades, holds six shells."

	icon_state = "granata_drum"

	w_class = WEIGHT_CLASS_NORMAL

	max_ammo = 6

/obj/item/ammo_box/magazine/c980_grenade/drum/starts_empty
	start_empty = TRUE
