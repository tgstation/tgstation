#define TIME_TO_START_MOVING_DROP_ICON (0.5 SECONDS)

#define STAGE_DROP_ITEM "STAGE_DROP_ITEM"
#define STAGE_SHOULD_SWAP_HAND "STAGE_SHOULD_SWAP_HAND"

/datum/tutorial/drop
	grandfather_date = "2022-12-25"

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

	RegisterSignal(user, COMSIG_MOB_DROPPING_ITEM, PROC_REF(complete))
	RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_swap_hands))

	// We didn't properly complete the tutorial, so we'll just try again some other round
	RegisterSignal(user, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(dismiss))

	update_held_item()

/datum/tutorial/drop/perform_completion_effects()
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
		if (STAGE_SHOULD_SWAP_HAND)
			// learn, damn it
			show_instruction(keybinding_message(
				/datum/keybinding/mob/swap_hands,
				"Press '%KEY%' to swap back to your other hand",
				"Click '<b>SWAP</b>' to swap back to your other hand",
			))

/datum/tutorial/drop/proc/on_swap_hands()
	SIGNAL_HANDLER

	if (isnull(user.get_active_held_item()))
		if (stage != STAGE_SHOULD_SWAP_HAND)
			stage = STAGE_SHOULD_SWAP_HAND
			show_instructions()
	else if (stage == STAGE_SHOULD_SWAP_HAND)
		stage = STAGE_DROP_ITEM
		show_instructions()

	update_held_item()

// Exists so that if we, say, place the item on a table, we don't count that as completion
/datum/tutorial/drop/proc/update_held_item()
	if (!isnull(last_held_item))
		UnregisterSignal(last_held_item, COMSIG_MOVABLE_MOVED)

	last_held_item = user.get_active_held_item()
	if (isnull(last_held_item))
		return

	RegisterSignal(last_held_item, COMSIG_MOVABLE_MOVED, PROC_REF(dismiss))

#undef STAGE_DROP_ITEM
#undef STAGE_SHOULD_SWAP_HAND
#undef TIME_TO_START_MOVING_DROP_ICON
