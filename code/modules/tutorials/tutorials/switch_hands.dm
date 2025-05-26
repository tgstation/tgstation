#define TIME_TO_START_MOVING_HAND_ICON (0.5 SECONDS)

#define STAGE_SHOULD_SWAP_HAND "STAGE_SHOULD_SWAP_HAND"
#define STAGE_PICK_UP_ITEM "STAGE_PICK_UP_ITEM"

/// Tutorial for showing how to switch hands.
/// Fired when clicking on an item with another item with an empty inactive hand.
/datum/tutorial/switch_hands
	grandfather_date = "2023-01-07"

	var/stage = STAGE_SHOULD_SWAP_HAND
	var/atom/movable/screen/hand_preview

	// So that they don't just drop the item
	var/hand_to_watch

/datum/tutorial/switch_hands/New(mob/user)
	. = ..()

	hand_to_watch = (user.active_hand_index % user.held_items.len) + 1

/datum/tutorial/switch_hands/Destroy(force)
	user.client?.screen -= hand_preview
	QDEL_NULL(hand_preview)

	return ..()

/datum/tutorial/switch_hands/perform(list/modifiers)
	create_hand_preview(modifiers[SCREEN_LOC])
	addtimer(CALLBACK(src, PROC_REF(show_instructions)), TIME_TO_START_MOVING_HAND_ICON)

	RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_swap_hands))
	RegisterSignal(user, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(on_pick_up_item))

/datum/tutorial/switch_hands/perform_completion_effects_with_delay()
	UnregisterSignal(user, list(COMSIG_MOB_SWAP_HANDS, COMSIG_LIVING_PICKED_UP_ITEM))
	return 0

/datum/tutorial/switch_hands/proc/create_hand_preview(initial_screen_loc)
	hand_preview = animate_ui_element(
		"hand_[user.held_index_to_dir(hand_to_watch)]",
		initial_screen_loc,
		ui_hand_position(hand_to_watch),
		TIME_TO_START_MOVING_HAND_ICON,
	)

/datum/tutorial/switch_hands/proc/show_instructions()
	if (QDELETED(src))
		return

	switch (stage)
		if (STAGE_SHOULD_SWAP_HAND)
			var/hand_name = IS_RIGHT_INDEX(hand_to_watch) ? "right" : "left"
			show_instruction(keybinding_message(
				/datum/keybinding/mob/swap_hands,
				"Press '%KEY%' to use your [hand_name] hand",
				"Click '<b>SWAP</b>' to use your [hand_name] hand",
			))
		if (STAGE_PICK_UP_ITEM)
			show_instruction("Pick something up!")

/datum/tutorial/switch_hands/proc/on_swap_hands()
	SIGNAL_HANDLER

	if (isnull(user.get_active_held_item()))
		stage = STAGE_PICK_UP_ITEM
		show_instructions()
	else if (isnull(user.get_inactive_held_item()))
		stage = STAGE_SHOULD_SWAP_HAND
		show_instructions()
	else
		// You somehow got an item in both hands during the tutorial without switching hands.
		// Good job I guess?
		complete()

/datum/tutorial/switch_hands/proc/on_pick_up_item()
	SIGNAL_HANDLER

	if (user.active_hand_index != hand_to_watch)
		return

	complete()

#undef STAGE_PICK_UP_ITEM
#undef STAGE_SHOULD_SWAP_HAND
#undef TIME_TO_START_MOVING_HAND_ICON
