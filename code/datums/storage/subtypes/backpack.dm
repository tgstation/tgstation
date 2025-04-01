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

/datum/storage/backpack/santabag
	max_total_storage = 60
	max_slots = 21
	max_specific_storage = WEIGHT_CLASS_NORMAL
