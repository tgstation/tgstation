#define ARMAMENT_CATEGORY_DYNAMICS "Armament Dynamics Inc."

/datum/armament_entry/cargo_gun/dynamics
	category = ARMAMENT_CATEGORY_DYNAMICS
	company_bitflag = COMPANY_DYNAMICS
	stock_mult = 2 //To compensate for their interest being fairly low most of the time

/datum/armament_entry/cargo_gun/dynamics/ammo
	subcategory = ARMAMENT_SUBCATEGORY_AMMO
	lower_cost = CARGO_CRATE_VALUE * 0.75
	upper_cost = CARGO_CRATE_VALUE * 1.25
	interest_addition = COMPANY_INTEREST_AMMO

/datum/armament_entry/cargo_gun/dynamics/ammo/c9mm
	item_type = /obj/item/ammo_box/c9mm

/datum/armament_entry/cargo_gun/dynamics/ammo/c9mm_ap
	item_type = /obj/item/ammo_box/c9mm/ap

/datum/armament_entry/cargo_gun/dynamics/ammo/c9mm_hp
	item_type = /obj/item/ammo_box/c9mm/hp

/datum/armament_entry/cargo_gun/dynamics/ammo/c9mm_in
	item_type = /obj/item/ammo_box/c9mm/fire

/datum/armament_entry/cargo_gun/dynamics/ammo/c10mm
	item_type = /obj/item/ammo_box/c10mm

/datum/armament_entry/cargo_gun/dynamics/ammo/c10mm_ap
	item_type = /obj/item/ammo_box/c10mm/ap

/datum/armament_entry/cargo_gun/dynamics/ammo/c10mm_hp
	item_type = /obj/item/ammo_box/c10mm/hp

/datum/armament_entry/cargo_gun/dynamics/ammo/c10mm_in
	item_type = /obj/item/ammo_box/c10mm/fire

/datum/armament_entry/cargo_gun/dynamics/ammo/c12ga
	item_type = /obj/item/storage/box/lethalshot

/datum/armament_entry/cargo_gun/dynamics/ammo/c12ga_rub
	item_type = /obj/item/storage/box/rubbershot

/datum/armament_entry/cargo_gun/dynamics/ammo/c12ga_bean
	item_type = /obj/item/storage/box/beanbag

/datum/armament_entry/cargo_gun/dynamics/ammo/c12ga_tech
	item_type = /obj/item/storage/box/techshell

/datum/armament_entry/cargo_gun/dynamics/ammo/c46mm
	item_type = /obj/item/ammo_box/c46x30mm

/datum/armament_entry/cargo_gun/dynamics/ammo/c46mm_ap
	item_type = /obj/item/ammo_box/c46x30mm/ap

/datum/armament_entry/cargo_gun/dynamics/ammo/c46mm_rub
	item_type = /obj/item/ammo_box/c46x30mm/rubber

/datum/armament_entry/cargo_gun/dynamics/ammo/c32
	item_type = /obj/item/ammo_box/c32

/datum/armament_entry/cargo_gun/dynamics/ammo/c32_ap
	item_type = /obj/item/ammo_box/c32/ap

/datum/armament_entry/cargo_gun/dynamics/ammo/c32_in
	item_type = /obj/item/ammo_box/c32/fire

/datum/armament_entry/cargo_gun/dynamics/ammo/c32_rub
	item_type = /obj/item/ammo_box/c32/rubber

/datum/armament_entry/cargo_gun/dynamics/ammo/c38
	item_type = /obj/item/ammo_box/c38
	lower_cost = CARGO_CRATE_VALUE * 0.5
	upper_cost = CARGO_CRATE_VALUE * 1
	stock_mult = 3

/datum/armament_entry/cargo_gun/dynamics/ammo/c38/dum
	item_type = /obj/item/ammo_box/c38/dumdum

/datum/armament_entry/cargo_gun/dynamics/ammo/c38/hot
	item_type = /obj/item/ammo_box/c38/hotshot

/datum/armament_entry/cargo_gun/dynamics/ammo/c38/ice
	item_type = /obj/item/ammo_box/c38/iceblox

/datum/armament_entry/cargo_gun/dynamics/ammo/c38/mat
	item_type = /obj/item/ammo_box/c38/match

/datum/armament_entry/cargo_gun/dynamics/ammo/c38/trc
	item_type = /obj/item/ammo_box/c38/trac

/datum/armament_entry/cargo_gun/dynamics/ammo/b10mm
	item_type = /obj/item/ammo_box/b10mm

/datum/armament_entry/cargo_gun/dynamics/ammo/b10mm_hp
	item_type = /obj/item/ammo_box/b10mm/hp

/datum/armament_entry/cargo_gun/dynamics/ammo/b10mm_rub
	item_type = /obj/item/ammo_box/b10mm/rubber

/datum/armament_entry/cargo_gun/dynamics/misc
	subcategory = ARMAMENT_SUBCATEGORY_SPECIAL

/datum/armament_entry/cargo_gun/dynamics/misc/bandolier
	item_type = /obj/item/storage/belt/bandolier
	lower_cost = CARGO_CRATE_VALUE * 2
	upper_cost = CARGO_CRATE_VALUE * 4

/datum/armament_entry/cargo_gun/dynamics/misc/ammo_bench
	item_type = /obj/item/circuitboard/machine/ammo_workbench
	lower_cost = CARGO_CRATE_VALUE * 28
	upper_cost = CARGO_CRATE_VALUE * 33
	interest_required = PASSED_INTEREST

/datum/armament_entry/cargo_gun/dynamics/misc/lethal_disk
	item_type = /obj/item/disk/ammo_workbench/lethal
	lower_cost = CARGO_CRATE_VALUE * 22
	upper_cost = CARGO_CRATE_VALUE * 27
	interest_required = HIGH_INTEREST
