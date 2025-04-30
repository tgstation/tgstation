/datum/storage/cyborg_internal_storage
	allow_big_nesting = TRUE
	max_slots = 99
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = 99
	do_rustle = FALSE
	silent = TRUE
	screen_max_columns = 8
	storage_type = /datum/storage_interface/silicon

/datum/storage/cyborg_internal_storage/attempt_insert(obj/item/to_insert, mob/living/silicon/robot/user, override = FALSE, force = STORAGE_NOT_LOCKED, messages = TRUE)
	user.deactivate_module(to_insert)

