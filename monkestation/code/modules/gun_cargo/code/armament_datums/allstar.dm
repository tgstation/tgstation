#define ARMAMENT_CATEGORY_ALLSTAR "Allstar Lasers"

/datum/armament_entry/cargo_gun/allstar
	category = ARMAMENT_CATEGORY_ALLSTAR
	company_bitflag = COMPANY_ALLSTAR

/datum/armament_entry/cargo_gun/allstar/laser
	subcategory = ARMAMENT_SUBCATEGORY_LASER

/datum/armament_entry/cargo_gun/allstar/laser/sc1
	item_type = /obj/item/gun/energy/laser
	lower_cost = CARGO_CRATE_VALUE * 4
	upper_cost = CARGO_CRATE_VALUE * 5

/datum/armament_entry/cargo_gun/allstar/laser/sc2
	item_type = /obj/item/gun/energy/e_gun
	lower_cost = CARGO_CRATE_VALUE * 6
	upper_cost = CARGO_CRATE_VALUE * 8

/datum/armament_entry/cargo_gun/allstar/laser/sc3
	item_type = /obj/item/gun/energy/laser/hellgun/blueshield
	lower_cost = CARGO_CRATE_VALUE * 7
	upper_cost = CARGO_CRATE_VALUE * 9

/datum/armament_entry/cargo_gun/allstar/laser/mini_egun
	item_type = /obj/item/gun/energy/e_gun/mini
	lower_cost = CARGO_CRATE_VALUE * 5
	upper_cost = CARGO_CRATE_VALUE * 7

/datum/armament_entry/cargo_gun/allstar/laser/disabler
	item_type = /obj/item/gun/energy/disabler
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 4

/datum/armament_entry/cargo_gun/allstar/laser/dragnet
	item_type = /obj/item/gun/energy/e_gun/dragnet
	lower_cost = CARGO_CRATE_VALUE * 4
	upper_cost = CARGO_CRATE_VALUE * 5

/datum/armament_entry/cargo_gun/allstar/gunkit
	subcategory = ARMAMENT_SUBCATEGORY_GUNPART
	interest_addition = COMPANY_INTEREST_ATTACHMENT

/datum/armament_entry/cargo_gun/allstar/gunkit/tempgun
	item_type = /obj/item/weaponcrafting/gunkit/temperature
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 4

/datum/armament_entry/cargo_gun/allstar/gunkit/adv_egun
	item_type = /obj/item/weaponcrafting/gunkit/nuclear
	lower_cost = CARGO_CRATE_VALUE * 6
	upper_cost = CARGO_CRATE_VALUE * 9

/datum/armament_entry/cargo_gun/allstar/gunkit/ion
	item_type = /obj/item/weaponcrafting/gunkit/ion
	lower_cost = CARGO_CRATE_VALUE * 6
	upper_cost = CARGO_CRATE_VALUE * 10

/datum/armament_entry/cargo_gun/allstar/gunkit/hellfire
	item_type = /obj/item/weaponcrafting/gunkit/hellgun
	lower_cost = CARGO_CRATE_VALUE * 5
	upper_cost = CARGO_CRATE_VALUE * 8
