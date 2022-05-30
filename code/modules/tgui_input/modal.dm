/**
 * The tgui speech modal. This initializes an input window which hides until
 * the user presses one of the speech hotkeys. Once an entry is set, it will
 * delegate the speech to the speech manager.
 */
/datum/tgui_modal
	/// The channel to broadcast in
	var/channel = "say"
	/// The user who opened the window
	var/client/client
	/// Boolean for whether the tgui_modal was closed by the user.
	var/closed
	/// The typed user input
	var/entry
	/// Max message length
	var/max_length = MAX_MESSAGE_LEN
	/// The modal window
	var/datum/tgui_window/window

/** Creates the new input window to exist in the background. */
/datum/tgui_modal/New(client/client)
	src.client = client
	window = new(client, "tgui_modal")
	window.subscribe(src, .proc/on_message)

/**
 * Injects the scripts and styling into the window
 */
/datum/tgui_modal/proc/initialize()
	window.initialize(
			fancy = TRUE,
			inline_css = file2text("tgui/public/tgui-modal.bundle.css"),
			inline_js = file2text("tgui/public/tgui-modal.bundle.js"),
	)
	close()

/**
 * Closes the window and hides it from view.
 */
/datum/tgui_modal/proc/close()
	winset(client, "tgui_modal", "is-visible=false")
	closed = TRUE

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
