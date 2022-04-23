#define ARMAMENT_CATEGORY_INTERDYNE "Interdyne Pharmaceuticals"

/datum/armament_entry/cargo_gun/interdyne
	category = ARMAMENT_CATEGORY_INTERDYNE
	company_bitflag = COMPANY_INTERDYNE

/datum/armament_entry/cargo_gun/interdyne/pistol
	subcategory = ARMAMENT_SUBCATEGORY_PISTOL

/datum/armament_entry/cargo_gun/interdyne/pistol/honeybee
	item_type = /obj/item/gun/ballistic/automatic/pistol/firefly/smartdart
	lower_cost = CARGO_CRATE_VALUE * 5
	upper_cost = CARGO_CRATE_VALUE * 6

/datum/armament_entry/cargo_gun/interdyne/special
	subcategory = ARMAMENT_SUBCATEGORY_SPECIAL

/datum/armament_entry/cargo_gun/interdyne/special/syringe_gun
	item_type = /obj/item/gun/syringe
	lower_cost = CARGO_CRATE_VALUE * 8
	upper_cost = CARGO_CRATE_VALUE * 12

/datum/armament_entry/cargo_gun/interdyne/special/smartdart_gun
	item_type = /obj/item/gun/syringe/smartdart
	lower_cost = CARGO_CRATE_VALUE * 6
	upper_cost = CARGO_CRATE_VALUE * 8

/datum/armament_entry/cargo_gun/interdyne/special/rapid_syringe_gun
	item_type = /obj/item/gun/syringe/rapidsyringe
	lower_cost = CARGO_CRATE_VALUE * 16
	upper_cost = CARGO_CRATE_VALUE * 18
	interest_required = PASSED_INTEREST

/datum/armament_entry/cargo_gun/interdyne/ammo
	subcategory = ARMAMENT_SUBCATEGORY_AMMO
	interest_addition = COMPANY_INTEREST_AMMO

/datum/armament_entry/cargo_gun/interdyne/ammo/pierce_syringe
	item_type = /obj/item/storage/box/syringes/piercing
	lower_cost = CARGO_CRATE_VALUE * 5
	upper_cost = CARGO_CRATE_VALUE * 8
	interest_required = PASSED_INTEREST

/datum/armament_entry/cargo_gun/interdyne/ammo/bluespace_syringe
	item_type = /obj/item/storage/box/syringes/bluespace
	lower_cost = CARGO_CRATE_VALUE * 9
	upper_cost = CARGO_CRATE_VALUE * 12
	interest_required = HIGH_INTEREST

/datum/armament_entry/cargo_gun/interdyne/chemical
	subcategory = ARMAMENT_SUBCATEGORY_CHEMICAL
	interest_addition = COMPANY_INTEREST_CHEMICAL
	contraband = TRUE

/datum/armament_entry/cargo_gun/interdyne/chemical/toxin
	item_type = /obj/item/reagent_containers/glass/bottle/toxin
	lower_cost = CARGO_CRATE_VALUE * 2
	upper_cost = CARGO_CRATE_VALUE * 4

/datum/armament_entry/cargo_gun/interdyne/chemical/cyanide
	item_type = /obj/item/reagent_containers/glass/bottle/cyanide
	lower_cost = CARGO_CRATE_VALUE * 4
	upper_cost = CARGO_CRATE_VALUE * 6
	interest_required = PASSED_INTEREST
