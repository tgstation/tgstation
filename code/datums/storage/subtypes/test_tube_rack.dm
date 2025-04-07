/datum/storage/test_tube_rack
	max_slots = 8
	screen_max_columns = 4
	screen_max_rows = 2
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE

/datum/storage/test_tube_rack/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(/obj/item/reagent_containers/cup/tube)
