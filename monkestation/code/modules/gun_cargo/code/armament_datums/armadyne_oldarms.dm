#define ARMAMENT_CATEGORY_OLDARMS "Armadyne Oldarms"

/datum/armament_entry/cargo_gun/oldarms
	category = ARMAMENT_CATEGORY_OLDARMS
	company_bitflag = COMPANY_OLDARMS

/datum/armament_entry/cargo_gun/oldarms/pistol
	subcategory = ARMAMENT_SUBCATEGORY_PISTOL

/datum/armament_entry/cargo_gun/oldarms/pistol/luger
	item_type = /obj/item/gun/ballistic/automatic/pistol/luger
	lower_cost = CARGO_CRATE_VALUE * 7
	upper_cost = CARGO_CRATE_VALUE * 9

/datum/armament_entry/cargo_gun/oldarms/smg
	subcategory = ARMAMENT_SUBCATEGORY_SUBMACHINEGUN

/datum/armament_entry/cargo_gun/oldarms/smg/mp40
	item_type = /obj/item/gun/ballistic/automatic/mp40
	lower_cost = CARGO_CRATE_VALUE * 20
	upper_cost = CARGO_CRATE_VALUE * 24
	interest_required = HIGH_INTEREST

/datum/armament_entry/cargo_gun/oldarms/smg/uzi
	item_type = /obj/item/gun/ballistic/automatic/mini_uzi
	lower_cost = CARGO_CRATE_VALUE * 14
	upper_cost = CARGO_CRATE_VALUE * 18

/datum/armament_entry/cargo_gun/oldarms/smg/ppsh
	item_type = /obj/item/gun/ballistic/automatic/ppsh
	lower_cost = CARGO_CRATE_VALUE * 32
	upper_cost = CARGO_CRATE_VALUE * 38
	interest_required = HIGH_INTEREST

/datum/armament_entry/cargo_gun/oldarms/smg/thompson
	item_type = /obj/item/gun/ballistic/automatic/tommygun
	lower_cost = CARGO_CRATE_VALUE * 30
	upper_cost = CARGO_CRATE_VALUE * 36
	interest_required = HIGH_INTEREST

/datum/armament_entry/cargo_gun/oldarms/rifle
	subcategory = ARMAMENT_SUBCATEGORY_ASSAULTRIFLE
	interest_required = HIGH_INTEREST

/datum/armament_entry/cargo_gun/oldarms/rifle/vintorez
	item_type = /obj/item/gun/energy/vintorez
	lower_cost = CARGO_CRATE_VALUE * 12
	upper_cost = CARGO_CRATE_VALUE * 18

/datum/armament_entry/cargo_gun/oldarms/rifle/stg
	item_type = /obj/item/gun/ballistic/automatic/stg
	lower_cost = CARGO_CRATE_VALUE * 24
	upper_cost = CARGO_CRATE_VALUE * 28

/datum/armament_entry/cargo_gun/oldarms/rifle/g11
	item_type = /obj/item/gun/ballistic/automatic/g11
	lower_cost = CARGO_CRATE_VALUE * 30
	upper_cost = CARGO_CRATE_VALUE * 35
