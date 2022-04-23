#define ARMAMENT_CATEGORY_ARMADYNE "Armadyne Corporation"

/datum/armament_entry/cargo_gun/armadyne
	category = ARMAMENT_CATEGORY_ARMADYNE
	company_bitflag = COMPANY_ARMADYNE

/datum/armament_entry/cargo_gun/armadyne/pistol
	subcategory = ARMAMENT_SUBCATEGORY_PISTOL

/datum/armament_entry/cargo_gun/armadyne/pistol/osprey
	item_type = /obj/item/gun/ballistic/automatic/pistol/pdh
	lower_cost = CARGO_CRATE_VALUE * 8
	upper_cost = CARGO_CRATE_VALUE * 14

/datum/armament_entry/cargo_gun/armadyne/pistol/ladon
	item_type = /obj/item/gun/ballistic/automatic/pistol/ladon
	lower_cost = CARGO_CRATE_VALUE * 6
	upper_cost = CARGO_CRATE_VALUE * 13

/datum/armament_entry/cargo_gun/armadyne/pistol/firefly
	item_type = /obj/item/gun/ballistic/automatic/pistol/firefly
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 4

/datum/armament_entry/cargo_gun/armadyne/pistol/pdh6b
	item_type = /obj/item/gun/ballistic/automatic/pistol/pdh/peacekeeper
	lower_cost = CARGO_CRATE_VALUE * 2
	upper_cost = CARGO_CRATE_VALUE * 3

/datum/armament_entry/cargo_gun/armadyne/pistol/mk58
	item_type = /obj/item/gun/ballistic/automatic/pistol/mk58
	lower_cost = CARGO_CRATE_VALUE * 6
	upper_cost = CARGO_CRATE_VALUE * 8

/datum/armament_entry/cargo_gun/armadyne/shotgun
	subcategory = ARMAMENT_SUBCATEGORY_SHOTGUN

/datum/armament_entry/cargo_gun/armadyne/shotgun/as2
	item_type = /obj/item/gun/ballistic/shotgun/automatic/as2
	lower_cost = CARGO_CRATE_VALUE * 7
	upper_cost = CARGO_CRATE_VALUE * 8

/datum/armament_entry/cargo_gun/armadyne/smg
	subcategory = ARMAMENT_SUBCATEGORY_SUBMACHINEGUN
	interest_required = PASSED_INTEREST

/datum/armament_entry/cargo_gun/armadyne/smg/dozer
	item_type = /obj/item/gun/ballistic/automatic/dozer
	lower_cost = CARGO_CRATE_VALUE * 8
	upper_cost = CARGO_CRATE_VALUE * 12

/datum/armament_entry/cargo_gun/armadyne/rifle
	subcategory = ARMAMENT_SUBCATEGORY_ASSAULTRIFLE
	interest_required = HIGH_INTEREST

/datum/armament_entry/cargo_gun/armadyne/rifle/ripper
	item_type = /obj/item/gun/ballistic/automatic/dmr
	lower_cost = CARGO_CRATE_VALUE * 24
	upper_cost = CARGO_CRATE_VALUE * 28

/datum/armament_entry/cargo_gun/armadyne/rifle/norwind
	item_type = /obj/item/gun/energy/norwind
	lower_cost = CARGO_CRATE_VALUE * 10
	upper_cost = CARGO_CRATE_VALUE * 14

/datum/armament_entry/cargo_gun/armadyne/rifle/ostwind
	item_type = /obj/item/gun/energy/ostwind
	lower_cost = CARGO_CRATE_VALUE * 10
	upper_cost = CARGO_CRATE_VALUE * 14
