/**
 * Creates a TGUI alert window and returns the user's response.
 *
 * This proc should be used to create alerts that the caller will wait for a response from.
 * Arguments:
 * * user - The user to show the alert to.
 * * message - The content of the alert, shown in the body of the TGUI window.
 * * title - The of the alert modal, shown on the top of the TGUI window.
 * * buttons - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * timeout - The timeout of the alert, after which the modal will close and qdel itself. Set to zero for no timeout.
 * * autofocus - The bool that controls if this alert should grab window focus.
 */
/proc/tgui_alert(mob/user, message = "", title, list/buttons = list("Ok"), timeout = 0, autofocus = TRUE)
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
		if(length(buttons) == 2)
			return alert(user, message, title, buttons[1], buttons[2])
		if(length(buttons) == 3)
			return alert(user, message, title, buttons[1], buttons[2], buttons[3])
	var/datum/tgui_alert/alert = new(user, message, title, buttons, timeout, autofocus)
	alert.ui_interact(user)
	alert.wait()
	if (alert)
		. = alert.choice
		qdel(alert)

/**
 * Creates an asynchronous TGUI alert window with an associated callback.
 *
 * This proc should be used to create alerts that invoke a callback with the user's chosen option.
 * Arguments:
 * * user - The user to show the alert to.
 * * message - The content of the alert, shown in the body of the TGUI window.
 * * title - The of the alert modal, shown on the top of the TGUI window.
 * * buttons - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the alert, after which the modal will close and qdel itself. Disabled by default, can be set to seconds otherwise.
 * * autofocus - The bool that controls if this alert should grab window focus.
 */
/proc/tgui_alert_async(mob/user, message = "", title, list/buttons = list("Ok"), datum/callback/callback, timeout = 0, autofocus = TRUE)
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
		if(length(buttons) == 2)
			return alert(user, message, title, buttons[1], buttons[2])
		if(length(buttons) == 3)
			return alert(user, message, title, buttons[1], buttons[2], buttons[3])
	var/datum/tgui_alert/async/alert = new(user, message, title, buttons, callback, timeout, autofocus)
	alert.ui_interact(user)

/**
 * # tgui_alert
 *
 * Datum used for instantiating and using a TGUI-controlled modal that prompts the user with
 * a message and has buttons for responses.
 */
/datum/tgui_alert
	/// The title of the TGUI window
	var/title
	/// The textual body of the TGUI window
	var/message
	/// The list of buttons (responses) provided on the TGUI window
	var/list/buttons
	/// The button that the user has pressed, null if no selection has been made
	var/choice
	/// The time at which the tgui_alert was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_alert, after which the window will close and delete itself.
	var/timeout
	/// The bool that controls if this modal should grab window focus
	var/autofocus
	/// Boolean field describing if the tgui_alert was closed by the user.
	var/closed

/datum/tgui_alert/New(mob/user, message, title, list/buttons, timeout, autofocus)
	src.autofocus = autofocus
	src.buttons = buttons.Copy()
	src.message = message
	src.title = title
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_alert/Destroy(force, ...)
	SStgui.close_uis(src)
	QDEL_NULL(buttons)
	. = ..()

/**
 * Waits for a user's response to the tgui_alert's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_alert/proc/wait()
	while (!choice && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AlertModal")
		ui.open()

/datum/tgui_alert/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_alert/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_alert/ui_static_data(mob/user)
	. = list()
	.["autofocus"] = autofocus
	.["buttons"] = buttons
	.["message"] = message
	.["large_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_large)
	.["swapped_buttons"] = user.client.prefs.read_preference(/datum/preference/toggle/tgui_input_swapped)
	.["title"] = title

/datum/tgui_alert/ui_data(mob/user)
	. = list()
	if(timeout)
		.["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

/datum/tgui_alert/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("choose")
			if (!(params["choice"] in buttons))
				CRASH("[usr] entered a non-existent button choice: [params["choice"]]")
			set_choice(params["choice"])
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

/datum/tgui_alert/proc/set_choice(choice)
	src.choice = choice

/**
 * # async tgui_alert
 *
 * An asynchronous version of tgui_alert to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_alert/async
	/// The callback to be invoked by the tgui_alert upon having a choice made.
	var/datum/callback/callback

/datum/tgui_alert/async/New(mob/user, message, title, list/buttons, callback, timeout, autofocus)
	..(user, message, title, buttons, timeout, autofocus)
	src.callback = callback

/datum/tgui_alert/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

/datum/tgui_alert/async/set_choice(choice)
	. = ..()
	if(!isnull(src.choice))
		callback?.InvokeAsync(src.choice)

/datum/tgui_alert/async/wait()
	return
