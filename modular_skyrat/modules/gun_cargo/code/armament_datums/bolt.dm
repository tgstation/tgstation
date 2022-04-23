#define ARMAMENT_CATEGORY_BOLT "Bolt Fabrications"

/datum/armament_entry/cargo_gun/bolt
	category = ARMAMENT_CATEGORY_BOLT
	company_bitflag = COMPANY_BOLT

/datum/armament_entry/cargo_gun/bolt/pistol
	subcategory = ARMAMENT_SUBCATEGORY_PISTOL

/datum/armament_entry/cargo_gun/bolt/pistol/responder
	item_type = /obj/item/gun/energy/disabler/bolt_disabler
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 4

/datum/armament_entry/cargo_gun/bolt/pistol/m1911
	item_type = /obj/item/gun/ballistic/automatic/pistol/m1911
	lower_cost = CARGO_CRATE_VALUE * 4
	upper_cost = CARGO_CRATE_VALUE * 5

/datum/armament_entry/cargo_gun/bolt/pistol/pepperball
	item_type = /obj/item/gun/ballistic/automatic/pistol/pepperball
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 5

/datum/armament_entry/cargo_gun/bolt/pistol/spurchamber
	item_type = /obj/item/gun/ballistic/revolver/zeta
	lower_cost = CARGO_CRATE_VALUE * 5
	upper_cost = CARGO_CRATE_VALUE * 7

/datum/armament_entry/cargo_gun/bolt/pistol/spurmaster
	item_type = /obj/item/gun/ballistic/revolver/revolution
	lower_cost = CARGO_CRATE_VALUE * 6
	upper_cost = CARGO_CRATE_VALUE * 8

/datum/armament_entry/cargo_gun/bolt/shotgun
	subcategory = ARMAMENT_SUBCATEGORY_SHOTGUN

/datum/armament_entry/cargo_gun/bolt/m23
	item_type = /obj/item/gun/ballistic/shotgun/m23
	lower_cost = CARGO_CRATE_VALUE * 10
	upper_cost = CARGO_CRATE_VALUE * 12

/datum/armament_entry/cargo_gun/bolt/generic_shotgun
	item_type = /obj/item/gun/ballistic/shotgun
	lower_cost = CARGO_CRATE_VALUE * 8
	upper_cost = CARGO_CRATE_VALUE * 10

/datum/armament_entry/cargo_gun/bolt/smg
	subcategory = ARMAMENT_SUBCATEGORY_SUBMACHINEGUN
	interest_required = PASSED_INTEREST

/datum/armament_entry/cargo_gun/bolt/smg/pcr
	item_type = /obj/item/gun/energy/pcr
	lower_cost = CARGO_CRATE_VALUE * 16
	upper_cost = CARGO_CRATE_VALUE * 20

/datum/armament_entry/cargo_gun/bolt/smg/pitbull
	item_type = /obj/item/gun/energy/pitbull
	lower_cost = CARGO_CRATE_VALUE * 16
	upper_cost = CARGO_CRATE_VALUE * 20
