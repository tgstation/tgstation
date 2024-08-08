/**
 * ### tgui_input_checkbox
 * Opens a window with a list of checkboxes and returns a list of selected choices.
 *
 * user - The mob to display the window to
 * message - The message inside the window
 * title - The title of the window
 * list/items - The list of items to display
 * min_checked - The minimum number of checkboxes that must be checked (defaults to 1)
 * max_checked - The maximum number of checkboxes that can be checked (optional)
 * timeout - The timeout for the input (optional)
 */
/proc/tgui_input_checkboxes(mob/user, message, title = "Select", list/items, min_checked = 1, max_checked = 50, timeout = 0, ui_state = GLOB.always_state)
	if (!user)
		user = usr
	if(!length(items))
		return null
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return null

	if(isnull(user.client))
		return null

	if(!user.client.prefs.read_preference(/datum/preference/toggle/tgui_input))
		return input(user, message, title) as null|anything in items
	var/datum/tgui_checkbox_input/input = new(user, message, title, items, min_checked, max_checked, timeout, ui_state)
	input.ui_interact(user)
	input.wait()
	if (input)
		. = input.choices
		qdel(input)

/// Window for tgui_input_checkboxes
/datum/tgui_checkbox_input
	/// Title of the window
	var/title
	/// Message to display
	var/message
	/// List of items to display
	var/list/items
	/// List of selected items
	var/list/choices
	/// Time when the input was created
	var/start_time
	/// Timeout for the input
	var/timeout
	/// Whether the input was closed
	var/closed
	/// Minimum number of checkboxes that must be checked
	var/min_checked
	/// Maximum number of checkboxes that can be checked
	var/max_checked
	/// The TGUI UI state that will be returned in ui_state(). Default: always_state
	var/datum/ui_state/state

/datum/tgui_checkbox_input/New(mob/user, message, title, list/items, min_checked, max_checked, timeout, ui_state)
	src.title = title
	src.message = message
	src.items = items.Copy()
	src.min_checked = min_checked
	src.max_checked = max_checked
	src.state = ui_state

	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_checkbox_input/Destroy(force)
	SStgui.close_uis(src)
	state = null
	QDEL_NULL(items)

	return ..()

/datum/tgui_checkbox_input/proc/wait()
	while (!closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_checkbox_input/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CheckboxInput")
		ui.open()

/datum/tgui_checkbox_input/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_checkbox_input/ui_state(mob/user)
	return state

/datum/tgui_checkbox_input/ui_data(mob/user)
	var/list/data = list()

	if(timeout)
		data["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

	return data

/datum/tgui_checkbox_input/ui_static_data(mob/user)
	var/list/data = list()

	data["items"] = items
	data["min_checked"] = min_checked
	data["max_checked"] = max_checked
	data["large_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_large)
	data["message"] = message
	data["swapped_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_swapped)
	data["title"] = title

	return data

/datum/tgui_checkbox_input/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch(action)
		if("submit")
			var/list/selections = params["entry"]
			if(length(selections) >= min_checked && length(selections) <= max_checked)
				set_choices(selections)
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

	return FALSE

/datum/tgui_checkbox_input/proc/set_choices(list/selections)
	src.choices = selections.Copy()
