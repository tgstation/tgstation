#define ARMAMENT_CATEGORY_IZHEVSK "Izhevsk Coalition"

/datum/armament_entry/cargo_gun/izhevsk
	category = ARMAMENT_CATEGORY_IZHEVSK
	company_bitflag = COMPANY_IZHEVSK

/datum/armament_entry/cargo_gun/izhevsk/pistol
	subcategory = ARMAMENT_SUBCATEGORY_PISTOL

/datum/armament_entry/cargo_gun/izhevsk/pistol/makarov
	item_type = /obj/item/gun/ballistic/automatic/pistol/makarov
	lower_cost = CARGO_CRATE_VALUE * 4
	upper_cost = CARGO_CRATE_VALUE * 5

/datum/armament_entry/cargo_gun/izhevsk/smg
	subcategory = ARMAMENT_SUBCATEGORY_SUBMACHINEGUN

/datum/armament_entry/cargo_gun/izhevsk/smg/surplus
	item_type = /obj/item/gun/ballistic/automatic/plastikov
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 4

/datum/armament_entry/cargo_gun/izhevsk/smg/croon
	item_type = /obj/item/gun/ballistic/automatic/croon
	lower_cost = CARGO_CRATE_VALUE * 5
	upper_cost = CARGO_CRATE_VALUE * 7

/datum/armament_entry/cargo_gun/izhevsk/rifle
	subcategory = ARMAMENT_SUBCATEGORY_ASSAULTRIFLE

/datum/armament_entry/cargo_gun/izhevsk/rifle/akm
	item_type = /obj/item/gun/ballistic/automatic/akm
	lower_cost = CARGO_CRATE_VALUE * 40
	upper_cost = CARGO_CRATE_VALUE * 45
	interest_required = HIGH_INTEREST

/datum/armament_entry/cargo_gun/izhevsk/rifle/surplus
	item_type = /obj/item/gun/ballistic/automatic/surplus
	lower_cost = CARGO_CRATE_VALUE * 5
	upper_cost = CARGO_CRATE_VALUE * 6

/datum/armament_entry/cargo_gun/izhevsk/rifle/mosin
	item_type = /obj/item/gun/ballistic/rifle/boltaction
	lower_cost = CARGO_CRATE_VALUE * 5
	upper_cost = CARGO_CRATE_VALUE * 6

/datum/armament_entry/cargo_gun/izhevsk/rifle/revrifle
	item_type = /obj/item/gun/ballistic/revolver/rifle
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 4
