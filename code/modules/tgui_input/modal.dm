/**
 * Opens a small tgui window that takes input and returns the user response.
 * Like the traditional say, it does not html_encode the user input.
 *
 * Arguments:
 ** channel - Initial speech channel to open the window in.
 ** max_length - Cuts the user off after this amount of characters.
 */
/proc/tgui_modal(mob/user, channel = SAY_CHAN, max_length = MAX_MESSAGE_LEN)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return null
	var/datum/tgui_modal/modal = new(user, channel, max_length)
	modal.open(user)
	modal.wait()
	if(modal)
		. = list(modal.channel, modal.entry)
		qdel(modal)

/**
 * The tgui modal instantiation.
 */
/datum/tgui_modal
	/// The channel to broadcast in
	var/channel
	/// Boolean for whether the tgui_modal was closed by the user.
	var/closed
	/// The typed user input
	var/entry
	/// Max message length
	var/max_length
	/// The modal window
	var/datum/tgui_window/window

/datum/tgui_modal/New(user, channel, max_length)
	src.channel = channel
	src.max_length = max_length

/**
 * Opens the window for the tgui input and inlines the bundle.
 */
/datum/tgui_modal/proc/open(mob/user)
	window = new(user.client, "tgui_modal", FALSE)
	window.initialize(
			fancy = TRUE,
			inline_css = file2text("tgui/public/tgui-modal.bundle.css"),
			inline_js = file2text("tgui/public/tgui-modal.bundle.js"),
		)
	window.subscribe(src, .proc/on_message)

/**
 * Closes the window and marks it for deletion.
 */
/datum/tgui_modal/proc/close(mob/user)
	window.close()
	closed = TRUE

/**
 * Pauses the interface while waiting for user input.
 */
/datum/tgui_modal/proc/wait()
	while(!entry && !closed && !QDELETED(src))
		stoplag(1)

/**
 * The equivalent of ui_act, this waits on messages from the window
 * and delegates actions.
 */
/datum/tgui_modal/proc/on_message(type, payload)
	if (type == "close")
		close()
	if (type == "entry")
		if(!payload || !payload["channel"] || !payload["entry"])
			return FALSE
		if(length(payload["entry"]) > max_length)
			CRASH("[usr] has entered more characters than allowed")
		set_entry(payload)
		close()
	return TRUE

/**
 * Sets the return values for the tgui_modal proc.
 */
/datum/tgui_modal/proc/set_entry(payload)
	src.channel = payload["channel"]
	src.entry = payload["entry"]
	return TRUE
