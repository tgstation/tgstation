#define TIME_TO_START_MOVING_HAND_ICON (0.5 SECONDS)

#define STAGE_SHOULD_SWAP_HAND 1
#define STAGE_PICK_UP_ITEM 2

// MBTODO: If no keybinds (???) just say "click the other hand"
// MBTODO: Fade out stuff before completing rather than destroying immediately
// MBTODO: Don't perform if item in both hands
/datum/tutorial/switch_hands
	grandfather_date = "2022-12-25"

	var/stage = STAGE_SHOULD_SWAP_HAND
	var/atom/movable/screen/hand_preview

	// So that they don't just drop the item
	var/hand_to_watch

/datum/tutorial/switch_hands/New(mob/user)
	. = ..()

	hand_to_watch = (user.active_hand_index % user.held_items.len) + 1

/datum/tutorial/switch_hands/Destroy(force, ...)
	user.client?.screen -= hand_preview
	QDEL_NULL(hand_preview)

	return ..()

/datum/tutorial/switch_hands/perform(list/params)
	create_hand_preview(params[SCREEN_LOC])
	addtimer(CALLBACK(src, PROC_REF(show_instructions)), TIME_TO_START_MOVING_HAND_ICON)

	RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_swap_hands))
	RegisterSignal(user, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(on_pick_up_item))

/datum/tutorial/switch_hands/perform_completion_effects()
	UnregisterSignal(user, list(COMSIG_MOB_SWAP_HANDS, COMSIG_LIVING_PICKED_UP_ITEM))

	return 0

/datum/tutorial/switch_hands/proc/create_hand_preview(initial_screen_loc)
	hand_preview = new
	hand_preview.icon = ui_style2icon(user.client?.prefs.read_preference(/datum/preference/choiced/ui_style) || GLOB.available_ui_styles[1])
	hand_preview.icon_state = "hand_[hand_to_watch % 2 == 0 ? "r" : "l"]"
	hand_preview.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	hand_preview.screen_loc = "1,1"

	var/view = user.client?.view

	var/list/origin_offsets = screen_loc_to_offset(initial_screen_loc, view)

	// A little offset to the right (origin offsets on its own already starts pretty far)
	var/matrix/origin_transform = TRANSLATE_MATRIX(origin_offsets[1] - world.icon_size * 0.5, origin_offsets[2] - world.icon_size * 1.5)

	var/list/target_offsets = screen_loc_to_offset(ui_hand_position(hand_to_watch), view)
	// `- world.icon_Size * 0.5` to patch over a likely bug in screen_loc_to_offset with CENTER, needs more looking at
	var/matrix/animate_to_transform = TRANSLATE_MATRIX(target_offsets[1] - world.icon_size * 1.5, target_offsets[2] - world.icon_size)

	hand_preview.transform = origin_transform

	hand_preview.alpha = 0
	animate(hand_preview, time = TIME_TO_START_MOVING_HAND_ICON, alpha = 255, easing = CUBIC_EASING)
	animate(1.4 SECONDS)
	animate(transform = animate_to_transform, time = 2 SECONDS, easing = SINE_EASING | EASE_IN)
	animate(alpha = 0, time = 2.4 SECONDS, easing = CUBIC_EASING | EASE_IN, flags = ANIMATION_PARALLEL)

	user.client?.screen += hand_preview

/datum/tutorial/switch_hands/proc/show_instructions()
	if (QDELETED(src))
		return

	switch (stage)
		if (STAGE_SHOULD_SWAP_HAND)
			var/hand_name = hand_to_watch % 2 == 0 ? "right" : "left"
			show_instruction(keybinding_message(
				/datum/keybinding/mob/swap_hands,
				"Press '%KEY%' to use your [hand_name] hand",
				"Click '[span_bold("SWAP")]' to use your [hand_name] hand",
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
