/**
 * The tgui speech modal. This initializes an input window which hides until
 * the user presses one of the speech hotkeys. Once an entry is set, it will
 * delegate the speech to the proper channel.
 */
/datum/tgui_modal
	/// The user who opened the window
	var/client/client
	/// Injury phrases to blurt out
	var/list/hurt_phrases = list("GACK!", "GLORF!", "OOF!", "AUGH!", "OW!", "URGH!", "HRNK!")
	/// Max message length
	var/max_length = MAX_MESSAGE_LEN
	/// The modal window
	var/datum/tgui_window/window
	/// Boolean for whether the tgui_modal was opened by the user.
	var/window_open

/** Assigned window to the client */
/client/var/datum/tgui_modal/tgui_modal

/** Creates the new input window to exist in the background. */
/datum/tgui_modal/New(client/client, id)
	src.client = client
	window = new(client, id)
	window.subscribe(src, .proc/on_message)
	window.is_browser = TRUE

/**
 * Injects the scripts and styling into the window,
 * then feeds it props for the chat channel and max message length.
 */
/datum/tgui_modal/proc/initialize()
	set waitfor = FALSE
	// Sleep to defer initialization to after client constructor
	sleep(5 SECONDS)
	window.initialize(
			strict_mode = TRUE,
			fancy = TRUE,
			inline_css = file("tgui/public/tgui-modal.bundle.css"),
			inline_js = file("tgui/public/tgui-modal.bundle.js"),
	);

/** Creates a JSON encoded message to open TGUI modals properly */
/client/proc/tgui_modal_create_open_command(channel)
	var/message = TGUI_CREATE_MESSAGE("open", list(
		channel = channel,
	))
	return "\".output tgui_modal.browser:update [message]\""

/**
 * Sets the window as "opened" server side, though it is already
 * visible to the user. We do this to set local vars &&
 * start typing (if enabled). Logs the event.
 */
/datum/tgui_modal/proc/open()
	window_open = TRUE
	if(!client?.mob)
		return
	client?.mob.start_thinking()
	if(client?.typing_indicators)
		log_speech_indicators("[key_name(client)] started typing at [loc_name(client?.mob)], indicators enabled.")
	else
		log_speech_indicators("[key_name(client)] started typing at [loc_name(client?.mob)], indicators DISABLED.")

/**
 * Closes the window serverside. Closes any open chat bubbles
 * regardless of preference. Logs the event.
 */
/datum/tgui_modal/proc/close()
	window_open = FALSE
	if(!client?.mob)
		return
	client?.mob.cancel_thinking()
	if(client?.typing_indicators)
		log_speech_indicators("[key_name(client)] stopped typing at [loc_name(client?.mob)], indicators enabled.")
	else
		log_speech_indicators("[key_name(client)] stopped typing at [loc_name(client?.mob)], indicators DISABLED.")

/**
 * The equivalent of ui_act, this waits on messages from the window
 * and delegates actions.
 */
/datum/tgui_modal/proc/on_message(type, payload)
	if(type == "ready")
		/// Sanity check in case the server ever changes MAX_LEN_MESSAGE
		window.send_message("maxLength", list(
			maxLength = max_length,
		))
		return TRUE
	if (type == "open")
		open()
		return TRUE
	if (type == "close")
		close()
		return TRUE
	if (type == "typing")
		init_typing()
		return TRUE
	if (type == "entry" || type == "force")
		if(!payload || !payload["channel"] || !payload["entry"])
			return FALSE
		if(length(payload["entry"]) > max_length)
			CRASH("[usr] has entered more characters than allowed")
		if(type == "force")
			delegate_speech(alter_entry(payload), SAY_CHAN)
		if(type == "entry")
			delegate_speech(payload["entry"], payload["channel"])
		return TRUE
	return TRUE


