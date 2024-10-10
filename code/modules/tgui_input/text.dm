/**
 * Creates a TGUI window with a text input. Returns the user's response.
 *
 * This proc should be used to create windows for text entry that the caller will wait for a response from.
 * If tgui fancy chat is turned off: Will return a normal input. If max_length is specified, will return
 * stripped_multiline_input.
 *
 * Arguments:
 * * user - The user to show the text input to.
 * * message - The content of the text input, shown in the body of the TGUI window.
 * * title - The title of the text input modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder.
 * * max_length - Specifies a max length for input. MAX_MESSAGE_LEN is default (1024)
 * * multiline -  Bool that determines if the input box is much larger. Good for large messages, laws, etc.
 * * encode - Toggling this determines if input is filtered via html_encode. Setting this to FALSE gives raw input.
 * * timeout - The timeout of the textbox, after which the modal will close and qdel itself. Set to zero for no timeout.
 */
/proc/tgui_input_text(mob/user, message = "", title = "Text Input", default, max_length = INFINITY, multiline = FALSE, encode = TRUE, timeout = 0, ui_state = GLOB.always_state)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return null

	if(isnull(user.client))
		return null

	// Client does NOT have tgui_input on: Returns regular input
	if(!user.client.prefs.read_preference(/datum/preference/toggle/tgui_input))
		if(encode)
			if(multiline)
				return stripped_multiline_input(user, message, title, default, PREVENT_CHARACTER_TRIM_LOSS(max_length))
			else
				return stripped_input(user, message, title, default, PREVENT_CHARACTER_TRIM_LOSS(max_length))
		else
			if(multiline)
				return input(user, message, title, default) as message|null
			else
				return input(user, message, title, default) as text|null
	var/datum/tgui_input_text/text_input = new(user, message, title, default, max_length, multiline, encode, timeout, ui_state)
	text_input.ui_interact(user)
	text_input.wait()
	if (text_input)
		. = text_input.entry
		qdel(text_input)

/**
 * tgui_input_text
 *
 * Datum used for instantiating and using a TGUI-controlled text input that prompts the user with
 * a message and has an input for text entry.
 */
/datum/tgui_input_text
	/// Boolean field describing if the tgui_input_text was closed by the user.
	var/closed
	/// The default (or current) value, shown as a default.
	var/default
	/// Whether the input should be stripped using html_encode
	var/encode
	/// The entry that the user has return_typed in.
	var/entry
	/// The maximum length for text entry
	var/max_length
	/// The prompt's body, if any, of the TGUI window.
	var/message
	/// Multiline input for larger input boxes.
	var/multiline
	/// The time at which the text input was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the text input, after which the window will close and delete itself.
	var/timeout
	/// The title of the TGUI window
	var/title
	/// The TGUI UI state that will be returned in ui_state(). Default: always_state
	var/datum/ui_state/state

/datum/tgui_input_text/New(mob/user, message, title, default, max_length, multiline, encode, timeout, ui_state)
	src.default = default
	src.encode = encode
	src.max_length = max_length
	src.message = message
	src.multiline = multiline
	src.title = title
	src.state = ui_state
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_input_text/Destroy(force)
	SStgui.close_uis(src)
	state = null
	return ..()

/**
 * Waits for a user's response to the tgui_input_text's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_input_text/proc/wait()
	while (!entry && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_input_text/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TextInputModal")
		ui.open()

/datum/tgui_input_text/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_input_text/ui_state(mob/user)
	return state

/datum/tgui_input_text/ui_static_data(mob/user)
	var/list/data = list()
	data["large_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_large)
	data["max_length"] = max_length
	data["message"] = message
	data["multiline"] = multiline
	data["placeholder"] = default // Default is a reserved keyword
	data["swapped_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_swapped)
	data["title"] = title
	return data

/datum/tgui_input_text/ui_data(mob/user)
	var/list/data = list()
	if(timeout)
		data["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))
	return data

/datum/tgui_input_text/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			if(max_length)
				if(length_char(params["entry"]) > max_length)
					CRASH("[usr] typed a text string longer than the max length")
				if(encode && (length_char(html_encode(params["entry"])) > max_length))
					to_chat(usr, span_notice("Your message was clipped due to special character usage."))
			set_entry(params["entry"])
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

/**
 * Sets the return value for the tgui text proc.
 * If html encoding is enabled, the text will be encoded.
 * This can sometimes result in a string that is longer than the max length.
 * If the string is longer than the max length, it will be clipped.
 */
/datum/tgui_input_text/proc/set_entry(entry)
	if(!isnull(entry))
		var/converted_entry = encode ? html_encode(entry) : entry
		src.entry = trim(converted_entry, PREVENT_CHARACTER_TRIM_LOSS(max_length))
