/datum/armament_entry/company_import/blacksteel
	category = BLACKSTEEL_FOUNDATION_NAME
	company_bitflag = CARGO_COMPANY_BLACKSTEEL

// A collection of melee weapons fitting the company's more exotic feeling weapon selection

/datum/armament_entry/company_import/blacksteel/blade
	subcategory = "Bladed Weapons"

/datum/armament_entry/company_import/blacksteel/blade/hunting_knife
	item_type = /obj/item/knife/hunting
	cost = PAYCHECK_CREW * 2

/datum/armament_entry/company_import/blacksteel/blade/survival_knife
	item_type = /obj/item/knife/combat/survival
	cost = PAYCHECK_CREW * 2

/datum/armament_entry/company_import/blacksteel/blade/bowie_knife
	item_type = /obj/item/storage/belt/bowie_sheath
	cost = PAYCHECK_COMMAND * 3

/datum/armament_entry/company_import/blacksteel/blade/shamshir_sabre
	item_type = /obj/item/storage/belt/sabre/cargo
	cost = PAYCHECK_COMMAND * 3
