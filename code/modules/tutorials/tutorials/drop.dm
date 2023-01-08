#define TIME_TO_START_MOVING_DROP_ICON (0.5 SECONDS)

#define STAGE_DROP_ITEM "STAGE_DROP_ITEM"
#define STAGE_PICK_SOMETHING_UP "STAGE_PICK_SOMETHING_UP"

/// Tutorial for showing how to drop items.
/// Fired when clicking on an item with another item with a filled inactive hand.
/datum/tutorial/drop
	grandfather_date = "2023-01-07"

	var/stage = STAGE_DROP_ITEM
	var/atom/movable/screen/drop_preview
	var/obj/last_held_item

/datum/tutorial/drop/Destroy(force, ...)
	last_held_item = null
	user.client?.screen -= drop_preview
	QDEL_NULL(drop_preview)
	return ..()

/datum/tutorial/drop/perform(list/params)
	create_drop_preview(params[SCREEN_LOC])
	addtimer(CALLBACK(src, PROC_REF(show_instructions)), TIME_TO_START_MOVING_DROP_ICON)

	RegisterSignal(user, COMSIG_MOB_DROPPING_ITEM, PROC_REF(on_dropped_item))
	RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_swap_hands))
	RegisterSignal(user, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(on_pick_up_item))

	update_held_item()

/datum/tutorial/drop/perform_completion_effects_with_delay()
	UnregisterSignal(user, list(COMSIG_MOB_DROPPING_ITEM, COMSIG_MOB_SWAP_HANDS, COMSIG_LIVING_PICKED_UP_ITEM))
	if (!isnull(last_held_item))
		UnregisterSignal(last_held_item, COMSIG_MOVABLE_MOVED)

	return 0

/datum/tutorial/drop/proc/create_drop_preview(initial_screen_loc)
	drop_preview = animate_ui_element(
		"act_drop",
		initial_screen_loc,
		ui_drop_throw,
		TIME_TO_START_MOVING_DROP_ICON,
	)

/datum/tutorial/drop/proc/show_instructions()
	if (QDELETED(src))
		return

	switch (stage)
		if (STAGE_DROP_ITEM)
			show_instruction(keybinding_message(
				/datum/keybinding/mob/drop_item,
				"Press '%KEY%' to drop your current item",
				"Click '<b>DROP</b>' to drop your current item",
			))
		if (STAGE_PICK_SOMETHING_UP)
			show_instruction("Pick something up!")

/datum/tutorial/drop/proc/on_swap_hands()
	SIGNAL_HANDLER

	if (isnull(user.get_active_held_item()))
		if (stage != STAGE_PICK_SOMETHING_UP)
			stage = STAGE_PICK_SOMETHING_UP
			show_instructions()
	else if (stage == STAGE_PICK_SOMETHING_UP)
		stage = STAGE_DROP_ITEM
		show_instructions()

	update_held_item()

/datum/tutorial/drop/proc/on_dropped_item()
	SIGNAL_HANDLER

	stage = STAGE_PICK_SOMETHING_UP
	show_instructions()

/datum/tutorial/drop/proc/on_pick_up_item()
	SIGNAL_HANDLER

	if (stage != STAGE_PICK_SOMETHING_UP)
		dismiss()
		return

	complete()

// Exists so that if we, say, place the item on a table, we don't count that as completion
/datum/tutorial/drop/proc/update_held_item()
	if (!isnull(last_held_item))
		UnregisterSignal(last_held_item, COMSIG_MOVABLE_MOVED)

	last_held_item = user.get_active_held_item()
	if (isnull(last_held_item))
		return

	RegisterSignal(last_held_item, COMSIG_MOVABLE_MOVED, PROC_REF(on_held_item_moved))

/datum/tutorial/drop/proc/on_held_item_moved()
	SIGNAL_HANDLER

	if (stage == STAGE_PICK_SOMETHING_UP)
		return

	dismiss()

#undef STAGE_DROP_ITEM
#undef STAGE_PICK_SOMETHING_UP
#undef TIME_TO_START_MOVING_DROP_ICON
