/datum/supply_pack/security/armory/soft_armor
	name = "Soft Armor Kit Crate"
	crate_name = "soft armor kit crate"
	desc = "Contains three sets of SolFed-made soft body armor and matching helmets."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/clothing/head/helmet/sf_peacekeeper/debranded = 3,
		/obj/item/clothing/suit/armor/sf_peacekeeper/debranded = 3,
	)

/datum/supply_pack/security/armory/hardened_armor
	name = "Hardened Armor Kit Crate"
	crate_name = "hardened armor kit crate"
	desc = "Contains three sets of SolFed-made hardened body armor and matching helmets."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/clothing/head/helmet/toggleable/sf_hardened = 3,
		/obj/item/clothing/suit/armor/sf_hardened = 3,
	)

/datum/supply_pack/security/armory/sacrificial_armor
	name = "Sacrificial Armor Kit Crate"
	crate_name = "sacrificial armor kit crate"
	desc = "Contains three sets of SolFed-made sacrificial body armor and matching helmets."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/clothing/head/helmet/sf_sacrificial = 3,
		/obj/item/sacrificial_face_shield = 3,
		/obj/item/clothing/suit/armor/sf_sacrificial = 3,
	)
