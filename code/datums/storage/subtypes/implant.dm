/datum/storage/implant
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = 6
	max_slots = 2
	silent = TRUE
	allow_big_nesting = TRUE

/datum/storage/implant/New()
	. = ..()
	set_holdable(canthold = list(/obj/item/disk/nuclear))
