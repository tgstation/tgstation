/**
 * Creates a fast TGUI window for speech input. Returns the user's response.
 *
 * This proc should be used to create windows for text entry that the caller will wait for a response from.
 * If tgui fancy chat is turned off: Will return a normal input.
 *
 * Arguments:
 * * user - The user to show the text input to.
 * * title - The title of the text input modal, shown on the top of the TGUI window.
 * * max_length - Specifies a max length for input. MAX_MESSAGE_LEN is default (1024)
 * * timeout - The timeout of the textbox, after which the modal will close and qdel itself. Set to zero for no timeout.
 */
/proc/tgui_say(mob/user, title = "Text Input", max_length = MAX_MESSAGE_LEN, timeout = 0)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	// Client does NOT have tgui_input on: Returns regular input
	if(!user.client.prefs.read_preference(/datum/preference/toggle/tgui_input))
		return stripped_input(user, title, max_length)

	var/datum/tgui_say/text_input = new(user, title, max_length, timeout)
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
 * * title - The title of the text input modal, shown on the top of the TGUI window.
 * * max_length - Specifies a max length for input.
 * * callback - The callback to be invoked when a choice is made.
 */
/proc/tgui_say_async(mob/user, title = "Text Input", max_length = MAX_MESSAGE_LEN, datum/callback/callback, timeout = 60 SECONDS)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	// Client does NOT have tgui_input on: Returns regular input
	if(!user.client.prefs.read_preference(/datum/preference/toggle/tgui_input))
		return stripped_input(user, title, max_length)

	var/datum/tgui_say/async/text_input = new(user, title, max_length, callback, timeout)
	text_input.ui_interact(user)

/**
 * # tgui_say
 *
 * Datum used for instantiating and using a TGUI-controlled text input that prompts the user with
 * a message and has an input for text entry.
 */
/datum/tgui_say
	/// Boolean field describing if the tgui_say was closed by the user.
	var/closed
	/// The default (or current) value, shown as a default.
	var/default
	/// The entry that the user has return_typed in.
	var/entry
	/// The maximum length for text entry
	var/max_length
	/// The time at which the text input was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the text input, after which the window will close and delete itself.
	var/timeout
	/// The title of the TGUI window
	var/title


/datum/tgui_say/New(mob/user, title, max_length, timeout)
	src.default = default
	src.max_length = max_length
	src.title = title
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_say/Destroy(force, ...)
	SStgui.close_uis(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_say's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_say/proc/wait()
	while (!entry && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_say/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TguiSay", title, FALSE)
		ui.open()

/datum/tgui_say/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_say/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_say/ui_static_data(mob/user)
	. = list()
	.["large_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_large)
	.["max_length"] = max_length
	.["swapped_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_swapped)
	.["title"] = title

/datum/tgui_say/ui_data(mob/user)
	. = list()
	if(timeout)
		.["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

/datum/tgui_say/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			if(max_length)
				if(length(params["entry"]) > max_length)
					CRASH("[usr] typed a text string longer than the max length")
				if(length(html_encode(params["entry"])) > max_length)
					to_chat(usr, span_notice("Input uses special characters, thus reducing the maximum length."))
			set_entry(params["entry"])
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

/datum/tgui_say/proc/set_entry(entry)
	if(!isnull(entry))
		var/converted_entry = html_encode(entry)
		src.entry = trim(converted_entry, max_length)

/**
 * # async tgui_say
 *
 * An asynchronous version of tgui_say to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_say/async
	// The callback to be invoked by the tgui_say upon having a choice made.
	var/datum/callback/callback

/datum/tgui_say/async/New(mob/user, title, max_length, callback, timeout)
	..(user, title, max_length, timeout)
	src.callback = callback

/datum/tgui_say/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

/datum/tgui_say/async/set_entry(entry)
	. = ..()
	if(!isnull(src.entry))
		var/eos = entry[length(entry)]
		if(eos != "." || eos != "!" || eos != "?")
			callback?.InvokeAsync(src.entry + ".")

/datum/tgui_say/async/wait()
	return
