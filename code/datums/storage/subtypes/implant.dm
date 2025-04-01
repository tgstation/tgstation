/datum/storage/implant
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = 6
	max_slots = 2
	silent = TRUE
	allow_big_nesting = TRUE

/datum/storage/implant/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(cant_hold_list = /obj/item/disk/nuclear)
