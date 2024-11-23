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
	var/static/list/exception_cache = typecacheof(list(/obj/item/fish_tank))
	exception_hold = exception_cache

/datum/storage/backpack/santabag
	max_total_storage = 60
	max_slots = 21
	max_specific_storage = WEIGHT_CLASS_NORMAL
