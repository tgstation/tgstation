/**
 * Creates a TGUI window with a key input. Returns the user's response as a full key with modifiers, eg ShiftK.
 *
 * This proc should be used to create windows for key entry that the caller will wait for a response from.
 * If tgui fancy chat is turned off: Will return a normal input.
 *
 * Arguments:
 * * user - The user to show the number input to.
 * * message - The content of the number input, shown in the body of the TGUI window.
 * * title - The title of the number input modal, shown on the top of the TGUI window.
 * * default - The default (or current) key, shown as a placeholder.
 */
/proc/tgui_input_keycombo(mob/user = usr, message, title = "Key Input", default = 0, timeout = 0, ui_state = GLOB.always_state)
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return null

	if (isnull(user.client))
		return null

	// Client does NOT have tgui_input on: Returns regular input
	if(!user.client.prefs.read_preference(/datum/preference/toggle/tgui_input))
		var/input_key = input(user, message, title + "(Modifiers are TGUI only, sorry!)", default) as null|text
		return input_key[1]
	var/datum/tgui_input_keycombo/key_input = new(user, message, title, default, timeout, ui_state)
	key_input.ui_interact(user)
	key_input.wait()
	if (key_input)
		. = key_input.entry
		qdel(key_input)

/**
 * # tgui_input_keycombo
 *
 * Datum used for instantiating and using a TGUI-controlled key input that prompts the user with
 * a message and listens for key presses.
 */
/datum/tgui_input_keycombo
	/// Boolean field describing if the tgui_input_number was closed by the user.
	var/closed
	/// The default (or current) value, shown as a default. Users can press reset with this.
	var/default
	/// The entry that the user has return_typed in.
	var/entry
	/// The prompt's body, if any, of the TGUI window.
	var/message
	/// The time at which the number input was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the number input, after which the window will close and delete itself.
	var/timeout
	/// The title of the TGUI window
	var/title
	/// The TGUI UI state that will be returned in ui_state(). Default: always_state
	var/datum/ui_state/state

/datum/tgui_input_keycombo/New(mob/user, message, title, default, timeout, ui_state)
	src.default = default
	src.message = message
	src.title = title
	src.state = ui_state
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_input_keycombo/Destroy(force)
	SStgui.close_uis(src)
	state = null
	return ..()

/**
 * Waits for a user's response to the tgui_input_keycombo's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_input_keycombo/proc/wait()
	while (!entry && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_input_keycombo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KeyComboModal")
		ui.open()

/datum/tgui_input_keycombo/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_input_keycombo/ui_state(mob/user)
	return state

/datum/tgui_input_keycombo/ui_static_data(mob/user)
	var/list/data = list()
	data["init_value"] = default // Default is a reserved keyword
	data["large_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_large)
	data["message"] = message
	data["swapped_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_swapped)
	data["title"] = title
	return data

/datum/tgui_input_keycombo/ui_data(mob/user)
	var/list/data = list()
	if(timeout)
		data["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))
	return data

/datum/tgui_input_keycombo/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			set_entry(params["entry"])
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

/datum/tgui_input_keycombo/proc/set_entry(entry)
	src.entry = entry
