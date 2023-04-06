/// Opens a window with a list of checkboxes and returns a list of selected items.
/proc/tgui_input_multi_select(mob/user, message, title = "Select", list/items, list/defaults = list(), timeout = 0)
	if (!user)
		user = usr
	if(!length(items))
		return
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	if(!user.client.prefs.read_preference(/datum/preference/toggle/tgui_input))
		return input(user, message, title, defaults) as null|list(items)
	var/datum/tgui_checkbox_input/input = new(user, message, title, items, defaults, timeout)
	input.ui_interact(user)
	input.wait()
	if (input)
		. = input.choices
		qdel(input)

/**
 * ### tgui_input_checkbox
 * Opens a window with a list of checkboxes and returns a list of selected items.
 */
/datum/tgui_multi_select_input
	/// Title of the window
	var/title
	/// Message to display
	var/message
	/// List of items to display
	var/list/items
	/// Map of items to display
	var/list/items_map
	/// List of selected items
	var/list/choices
	/// List of default selected items
	var/list/defaults
	/// Time when the input was created
	var/start_time
	/// Timeout for the input
	var/timeout
	/// Whether the input was closed
	var/closed

/datum/tgui_multi_select_input/New(mob/user, message, title, list/items, list/defaults, timeout)
	src.title = title
	src.message = message
	src.items = list()
	src.items_map = list()
	src.choices = list()
	src.defaults = defaults
	var/list/repeat_items = list()
	var/static/regex/whitelistedWords = regex(@{"([^\u0020-\u8000]+)"})
	for(var/i in items)
		if(!i)
			continue
		var/string_key = whitelistedWords.Replace("[i]", "")
		string_key = avoid_assoc_duplicate_keys(string_key, repeat_items)
		src.items += string_key
		src.items_map[string_key] = i
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_multi_select_input/Destroy(force, ...)
	SStgui.close_uis(src)
	QDEL_NULL(items)

	return ..()

/datum/tgui_multi_select_input/proc/wait()
	while (!length(choices) && !closed)
		stoplag(1)

/datum/tgui_multi_select_input/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "MultiSelectInput")
	ui.set_autoupdate(FALSE)
	ui.open()

/datum/tgui_multi_select_input/ui_static_data(mob/user)
	var/list/data = list()

	data["init_values"] = defaults || list()
	data["items"] = items
	data["large_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_large)
	data["message"] = message
	data["swapped_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_swapped)
	data["title"] = title

	return data

/datum/tgui_multi_select_input/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	switch(action)
		if("submit")
			if (!length(params["entries"]))
				return FALSE
			set_choices(params["entries"])
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

	return FALSE

/datum/tgui_multi_select_input/proc/set_choices(list/selected_entries)
	for(var/entry in selected_entries)
