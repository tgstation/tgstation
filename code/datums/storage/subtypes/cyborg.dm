/datum/storage/cyborg_internal_storage
	allow_big_nesting = TRUE
	max_slots = 99
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = 99
	do_rustle = FALSE
	silent = TRUE
	screen_max_columns = 8
	storage_type = /datum/storage_interface/silicon

/datum/storage/cyborg_internal_storage/can_insert(obj/item/to_insert, mob/living/silicon/robot/user, messages = TRUE, force = STORAGE_NOT_LOCKED)
	return (to_insert in user.model.modules)

/datum/storage/cyborg_internal_storage/attempt_insert(obj/item/to_insert, mob/living/silicon/robot/user, override = FALSE, force = STORAGE_NOT_LOCKED, messages = TRUE)
	user.deactivate_module(to_insert)

/**
 * Cyborg internal storage orienting
 * We're using the model's total amount of modules as reference for how many slots we fill,
 * otherwise having enough items in hand and only 1 item in a row would mean, as we're a static inventory,
 * the rows won't fill for all items in the UI.
 * We also don't give an additional row if all slots are filled because as a static inventory borgs don't need extra space
 * to put items in, you can click on the slot you took it out from, or use the dedicated "store" button.
 */
/datum/storage/cyborg_internal_storage/orient_storage()
	var/obj/item/robot_model/model = real_location

	var/adjusted_contents = length(model.modules)
	var/list/datum/numbered_display/numbered_contents
	if(numerical_stacking)
		numbered_contents = process_numerical_display()
		adjusted_contents = length(numbered_contents)

	var/columns = clamp(max_slots, 1, screen_max_columns)
	var/rows = clamp(CEILING(adjusted_contents / columns, 1), 1, screen_max_rows)

	for (var/mob/ui_user as anything in storage_interfaces)
		if (isnull(storage_interfaces[ui_user]))
			continue
		storage_interfaces[ui_user].update_position(
			screen_start_x,
			screen_pixel_x,
			screen_start_y,
			screen_pixel_y,
			columns,
			rows,
			ui_user,
			real_location,
			numbered_contents,
		)
