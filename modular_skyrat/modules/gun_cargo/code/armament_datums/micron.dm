#define ARMAMENT_CATEGORY_MICRON "Micron Control Systems"

/datum/armament_entry/cargo_gun/micron
	category = ARMAMENT_CATEGORY_MICRON
	company_bitflag = COMPANY_MICRON

/datum/armament_entry/cargo_gun/micron/rifle
	subcategory = ARMAMENT_SUBCATEGORY_ASSAULTRIFLE

/datum/armament_entry/cargo_gun/micron/rifle/mcr
	item_type = /obj/item/gun/microfusion/mcr01 // Considering that you also have to buy mods, this is about as expensive as an allstar SC-2
	lower_cost = CARGO_CRATE_VALUE * 6
	upper_cost = CARGO_CRATE_VALUE * 8

/datum/armament_entry/cargo_gun/micron/ammo
	subcategory = ARMAMENT_SUBCATEGORY_AMMO
	interest_addition = COMPANY_INTEREST_AMMO

/datum/armament_entry/cargo_gun/micron/ammo/cell
	item_type = /obj/item/stock_parts/cell/microfusion
	lower_cost = CARGO_CRATE_VALUE * 1
	upper_cost = CARGO_CRATE_VALUE * 1

/datum/armament_entry/cargo_gun/micron/ammo/cell_bulk
	item_type = /obj/item/storage/box/ammo_box/microfusion
	lower_cost = CARGO_CRATE_VALUE * 1
	upper_cost = CARGO_CRATE_VALUE * 2
	interest_addition = COMPANY_INTEREST_AMMO_BULK

/datum/armament_entry/cargo_gun/micron/ammo/cell_adv
	item_type = /obj/item/stock_parts/cell/microfusion/advanced
	lower_cost = CARGO_CRATE_VALUE * 1
	upper_cost = CARGO_CRATE_VALUE * 2

/datum/armament_entry/cargo_gun/micron/ammo/cell_adv_bulk
	item_type = /obj/item/storage/box/ammo_box/microfusion/advanced
	lower_cost = CARGO_CRATE_VALUE * 2
	upper_cost = CARGO_CRATE_VALUE * 3
	interest_addition = COMPANY_INTEREST_AMMO_BULK

/datum/armament_entry/cargo_gun/micron/ammo/cell_blue
	item_type = /obj/item/stock_parts/cell/microfusion/bluespace
	interest_required = HIGH_INTEREST
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 3

/datum/armament_entry/cargo_gun/micron/ammo/cell_blue_bulk
	item_type = /obj/item/storage/box/ammo_box/microfusion/bluespace
	interest_required = HIGH_INTEREST
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 4
	interest_addition = COMPANY_INTEREST_AMMO_BULK

/datum/armament_entry/cargo_gun/micron/part
	subcategory = ARMAMENT_SUBCATEGORY_GUNPART
	interest_addition = COMPANY_INTEREST_ATTACHMENT

/datum/armament_entry/cargo_gun/micron/part/grip
	item_type = /obj/item/microfusion_gun_attachment/grip
	lower_cost = CARGO_CRATE_VALUE * 2
	upper_cost = CARGO_CRATE_VALUE * 3

/datum/armament_entry/cargo_gun/micron/part/scatter
	item_type = /obj/item/microfusion_gun_attachment/scatter
	lower_cost = CARGO_CRATE_VALUE * 4
	upper_cost = CARGO_CRATE_VALUE * 5

/datum/armament_entry/cargo_gun/micron/part/scope
	item_type = /obj/item/microfusion_gun_attachment/scope
	lower_cost = CARGO_CRATE_VALUE * 2
	upper_cost = CARGO_CRATE_VALUE * 3

/datum/armament_entry/cargo_gun/micron/part/rail
	item_type = /obj/item/microfusion_gun_attachment/rail
	lower_cost = CARGO_CRATE_VALUE * 2
	upper_cost = CARGO_CRATE_VALUE * 3

/datum/armament_entry/cargo_gun/micron/part/heatsink
	item_type = /obj/item/microfusion_gun_attachment/heatsink
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 5

/datum/armament_entry/cargo_gun/micron/part/lance
	item_type = /obj/item/microfusion_gun_attachment/lance
	interest_required = PASSED_INTEREST
	lower_cost = CARGO_CRATE_VALUE * 4
	upper_cost = CARGO_CRATE_VALUE * 5

/datum/armament_entry/cargo_gun/micron/emitter
	subcategory = ARMAMENT_SUBCATEGORY_EMITTER
	interest_addition = COMPANY_INTEREST_ATTACHMENT

/datum/armament_entry/cargo_gun/micron/emitter/enh_emitter
	item_type = /obj/item/microfusion_phase_emitter/enhanced
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 4

/datum/armament_entry/cargo_gun/micron/emitter/adv_emitter
	item_type = /obj/item/microfusion_phase_emitter/advanced
	lower_cost = CARGO_CRATE_VALUE * 5
	upper_cost = CARGO_CRATE_VALUE * 7

/datum/armament_entry/cargo_gun/micron/emitter/blue_emitter
	item_type = /obj/item/microfusion_phase_emitter/bluespace
	interest_required = HIGH_INTEREST
	lower_cost = CARGO_CRATE_VALUE * 7
	upper_cost = CARGO_CRATE_VALUE * 10

/datum/armament_entry/cargo_gun/micron/cell_upgrade
	subcategory = ARMAMENT_SUBCATEGORY_CELL_UPGRADE
	interest_addition = COMPANY_INTEREST_ATTACHMENT

/datum/armament_entry/cargo_gun/micron/cell_upgrade/stabilize
	item_type = /obj/item/microfusion_cell_attachment/stabiliser
	lower_cost = CARGO_CRATE_VALUE * 2
	upper_cost = CARGO_CRATE_VALUE * 3

/datum/armament_entry/cargo_gun/micron/cell_upgrade/overcapacity
	item_type = /obj/item/microfusion_cell_attachment/overcapacity
	lower_cost = CARGO_CRATE_VALUE * 3
	upper_cost = CARGO_CRATE_VALUE * 4

/datum/armament_entry/cargo_gun/micron/cell_upgrade/selfcharge
	item_type = /obj/item/microfusion_cell_attachment/selfcharging
	interest_required = HIGH_INTEREST
	lower_cost = CARGO_CRATE_VALUE * 5
	upper_cost = CARGO_CRATE_VALUE * 6
