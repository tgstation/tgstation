/**
 * The tgui speech modal. This initializes an input window which hides until
 * the user presses one of the speech hotkeys. Once an entry is set, it will
 * delegate the speech to the speech manager.
 */
/datum/tgui_modal
	/// The channel to broadcast in
	var/channel = SAY_CHAN
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
/datum/tgui_modal/New(client/client, id)
	src.client = client
	window = new(client, id)
	window.subscribe(src, .proc/on_message)

/**
 * Injects the scripts and styling into the window,
 * then feeds it props for the chat channel and max message length.
 */
/datum/tgui_modal/proc/initialize()
	set waitfor = FALSE
	// Minimal sleep to defer initialization to after client constructor
	sleep(1)
	window.initialize(
			strict_mode = TRUE,
			fancy = TRUE,
			inline_css = file("tgui/public/tgui-modal.bundle.css"),
			inline_js = file("tgui/public/tgui-modal.bundle.js"),
	);
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
	if (type == "ready")
		// NOT functional at the moment. JS never receives these
		window.send_message("modal_props", list(
			"channel" = channel,
			"maxLength" = max_length,
		))
		return TRUE
	if (type == "close")
		close()
		return TRUE
	if (type == "entry")
		if(!payload || !payload["channel"] || !payload["entry"])
			return FALSE
		if(length(payload["entry"]) > max_length)
			CRASH("[usr] has entered more characters than allowed")
		delegate_speech(payload["entry"], payload["channel"])
		close()
		return TRUE
	if (type == "forced")
		if(!payload || !payload["entry"])
			return FALSE
		var/entry = copytext_char(payload["entry"], 0, 12)
		entry += pick("GACK", "GLORF", "OOF", "AUGH", "OW", "URGH")
		delegate_speech(entry, SAY_CHAN)
		return TRUE
	return TRUE

/**
 * Delegates the speech to the proper channel.
 */
/datum/tgui_modal/proc/delegate_speech(entry, channel)
	if(!client)
		return FALSE
	if(channel == OOC_CHAN)
		client.ooc(entry)
		return TRUE
	if(!client.mob)
		return FALSE
	if(channel == RADIO_CHAN)
		entry = ";" + entry
	if(channel == ME_CHAN)
		client.mob.me_verb(entry)
	if(channel == SAY_CHAN)
		client.mob.say_verb(entry)
	return TRUE

