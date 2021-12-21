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
/proc/tgui_input_text(mob/user, message = null, title = "Text Input", default = null, max_length = MAX_MESSAGE_LEN, multiline = FALSE, encode = TRUE, timeout = 0)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	/// Client does NOT have tgui_input on: Returns regular input
	if(!user.client.prefs.read_preference(/datum/preference/toggle/tgui_input))
		if(max_length)
			if(multiline)
				return stripped_multiline_input(user, message, title, default, max_length)
			else
				return stripped_input(user, message, title, default, max_length)
		else
			return input(user, message, title, default)
	var/datum/tgui_input_text/text_input = new(user, message, title, default, max_length, multiline, encode, timeout)
	text_input.ui_interact(user)
	text_input.wait()
	if (text_input)
		. = text_input.entry
		qdel(text_input)

/**
 * Creates an asynchronous TGUI text input window with an associated callback.
 *
 * This proc should be used to create text inputs that invoke a callback with the user's entry.
 * Arguments:
 * * user - The user to show the text input to.
 * * message - The content of the text input, shown in the body of the TGUI window.
 * * title - The title of the text input modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder.
 * * max_length - Specifies a max length for input.
 * * multiline -  Bool that determines if the input box is much larger. Good for large messages, laws, etc.
 * * encode - If toggled, input is filtered via html_encode. Setting this to FALSE gives raw input.
 * * callback - The callback to be invoked when a choice is made.
 */
/proc/tgui_input_text_async(mob/user, message = null, title = "Text Input", default = null, max_length = null, multiline = FALSE, encode = TRUE, datum/callback/callback, timeout = 60 SECONDS)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_input_text/async/text_input = new(user, message, title, default, max_length, multiline, encode, callback, timeout)
	text_input.ui_interact(user)

/**
 * # tgui_input_text
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


/datum/tgui_input_text/New(mob/user, message, title, default, max_length, multiline, encode, timeout)
	src.default = default
	src.encode = encode
	src.max_length = max_length
	src.message = message
	src.multiline = multiline
	src.title = title
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_input_text/Destroy(force, ...)
	SStgui.close_uis(src)
	. = ..()

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
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/tgui_input_text/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_input_text/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_input_text/ui_static_data(mob/user)
	. = list(
		"max_length" = max_length,
		"message" = message,
		"multiline" = multiline,
		"placeholder" = default, /// You cannot use default as a const
		"preferences" = list(),
		"title" = title
	)
	.["preferences"]["large_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_large)
	.["preferences"]["swapped_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_swapped)

/datum/tgui_input_text/ui_data(mob/user)
	. = list()
	if(timeout)
		.["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

/datum/tgui_input_text/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			if(max_length)
				if(length(params["entry"]) > max_length)
					return FALSE
				if(encode && (length(html_encode(params["entry"])) > max_length))
					to_chat(usr, span_notice("Input uses special characters, thus reducing the maximum length."))
			set_entry(params["entry"])
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			set_entry(null)
			SStgui.close_uis(src)
			return TRUE

/datum/tgui_input_text/proc/set_entry(entry)
	var/converted_entry = encode ? html_encode(entry) : entry
	src.entry = trim(converted_entry, max_length)

/**
 * # async tgui_input_text
 *
 * An asynchronous version of tgui_input_text to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_input_text/async
	/// The callback to be invoked by the tgui_input_text upon having a choice made.
	var/datum/callback/callback

/datum/tgui_input_text/async/New(mob/user, message, title, default, max_length, multiline, encode, callback, timeout)
	..(user, message, title, default, max_length, multiline, encode, timeout)
	src.callback = callback

/datum/tgui_input_text/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

/datum/tgui_input_text/async/set_entry(entry)
	. = ..()
	if(!isnull(src.entry))
		callback?.InvokeAsync(src.entry)

/datum/tgui_input_text/async/wait()
	return
