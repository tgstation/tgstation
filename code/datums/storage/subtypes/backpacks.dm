///Regular backpack
/datum/storage/backpack
	max_total_storage = 21
	max_slots = 21

/datum/storage/backpack/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()

	set_holdable(exception_hold_list = /obj/item/fish_tank)

///Sadle bag
/datum/storage/backpack/sadle_bag
	max_total_storage = 26

///Satchel flat
/datum/storage/backpack/satchel
	max_total_storage = 15
	allow_big_nesting = TRUE

/datum/storage/backpack/satchel/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(cant_hold_list = /obj/item/storage/backpack/satchel/flat) //muh recursive backpacks

///Santa backpack
/datum/storage/backpack/santabag
	max_total_storage = 60
	max_slots = 21
	max_specific_storage = WEIGHT_CLASS_NORMAL

///Banner pack
/datum/storage/backpack/bannerpack
	max_total_storage = 27 //6 more then normal, for the tradeoff of declaring yourself an antag at all times.
