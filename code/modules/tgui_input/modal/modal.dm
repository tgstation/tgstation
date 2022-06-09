#define NULL_CLIENTMOB "Tgui modal loaded on a null client/mob"

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
	sleep(3 SECONDS)
	window.initialize(
			strict_mode = TRUE,
			fancy = TRUE,
			inline_css = file("tgui/public/tgui-modal.bundle.css"),
			inline_js = file("tgui/public/tgui-modal.bundle.js"),
	);

/**
 * Creates a JSON encoded message to open TGUI modals properly.
 *
 * Arguments:
 * channel - The channel to open the modal in.
 * Returns:
 * string - A JSON encoded message to open the modal.
 */
/client/proc/tgui_modal_create_open_command(channel)
	var/message = TGUI_CREATE_MESSAGE("open", list(
		channel = channel,
	))
	return "\".output tgui_modal.browser:update [message]\""

/**
 * Ensures nothing funny is going on window load.
 * Minimizes the winddow, sets max length, closes all
 * typing and thinking indicators.
 */
/datum/tgui_modal/proc/load()
	if(!client || !client.mob)
		CRASH(NULL_CLIENTMOB)
	window_open = FALSE
	winset(client, "tgui_modal", "is-visible=false")
	/// Sanity check in case the server ever changes MAX_LEN_MESSAGE
	window.send_message("maxLength", list(
		maxLength = max_length,
	))
	is_thinking(FALSE)
	return TRUE

/**
 * Sets the window as "opened" server side, though it is already
 * visible to the user. We do this to set local vars &&
 * start typing (if enabled and in an IC channel). Logs the event.
 *
 * Arguments:
 * payload - A list containing the channel the window was opened in.
 */
/datum/tgui_modal/proc/open(payload)
	if(!client || !client.mob)
		CRASH(NULL_CLIENTMOB)
	if(!payload || !payload["channel"])
		CRASH("No channel provided to open TGUI modal")
	window_open = TRUE
	if(payload["channel"] == OOC_CHANNEL || payload["channel"] == ME_CHANNEL)
		return TRUE
	is_thinking(TRUE)
	if(client.typing_indicators)
		log_speech_indicators("[key_name(client)] started typing at [loc_name(client.mob)], indicators enabled.")
	else
		log_speech_indicators("[key_name(client)] started typing at [loc_name(client.mob)], indicators DISABLED.")
	return TRUE

/**
 * Closes the window serverside. Closes any open chat bubbles
 * regardless of preference. Logs the event.
 */
/datum/tgui_modal/proc/close()
	if(!client || !client.mob)
		CRASH(NULL_CLIENTMOB)
	window_open = FALSE
	is_thinking(FALSE)
	if(client.typing_indicators)
		log_speech_indicators("[key_name(client)] stopped typing at [loc_name(client.mob)], indicators enabled.")
	else
		log_speech_indicators("[key_name(client)] stopped typing at [loc_name(client.mob)], indicators DISABLED.")

/**
 * The equivalent of ui_act, this waits on messages from the window
 * and delegates actions.
 */
/datum/tgui_modal/proc/on_message(type, payload)
	if(type == "ready")
		load()
		return TRUE
	if (type == "open")
		open(payload)
		return TRUE
	if (type == "close")
		close()
		return TRUE
	if (type == "thinking")
		is_thinking(payload["mode"])
		return TRUE
	if (type == "typing")
		is_typing()
		return TRUE
	if (type == "entry" || type == "force")
		handle_entry(type, payload)
		return TRUE
	return FALSE

#undef NULL_CLIENTMOB
