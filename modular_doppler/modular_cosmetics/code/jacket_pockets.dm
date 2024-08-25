/datum/storage/pockets/jacket
	max_slots = 2
	max_total_storage = 5

/datum/storage/pockets/jacket/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(list(
		/obj/item/,
		))

/datum/storage/pockets/jacket/jumbo
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 3
	max_total_storage = 6

/datum/storage/pockets/jacket/jumbo/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(list(
		/obj/item/,
		))
