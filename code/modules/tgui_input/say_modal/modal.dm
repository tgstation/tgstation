/** Assigned say modal of the client */
/client/var/datum/tgui_say/tgui_say

/**
 * Creates a JSON encoded message to open TGUI say modals properly.
 *
 * Arguments:
 * channel - The channel to open the modal in.
 * Returns:
 * string - A JSON encoded message to open the modal.
 */
/client/proc/tgui_say_create_open_command(channel)
	var/message = TGUI_CREATE_MESSAGE("open", list(
		channel = channel,
	))
	return "\".output tgui_say.browser:update [message]\""

/**
 * The tgui say modal. This initializes an input window which hides until
 * the user presses one of the speech hotkeys. Once something is entered, it will
 * delegate the speech to the proper channel.
 */
/datum/tgui_say
	/// The user who opened the window
	var/client/client
	/// Injury phrases to blurt out
	var/list/hurt_phrases = list("GACK!", "GLORF!", "OOF!", "AUGH!", "OW!", "URGH!", "HRNK!")
	/// Max message length
	var/max_length = MAX_MESSAGE_LEN
	/// The modal window
	var/datum/tgui_window/window
	/// Boolean for whether the tgui_say was opened by the user.
	var/window_open

/** Creates the new input window to exist in the background. */
/datum/tgui_say/New(client/client, id)
	src.client = client
	window = new(client, id)
	window.subscribe(src, PROC_REF(on_message))
	window.is_browser = TRUE

/**
 * After a brief period, injects the scripts into
 * the window to listen for open commands.
 */
/datum/tgui_say/proc/initialize()
	set waitfor = FALSE
	// Sleep to defer initialization to after client constructor
	sleep(3 SECONDS)
	window.initialize(
			strict_mode = TRUE,
			fancy = TRUE,
			inline_css = file("tgui/public/tgui-say.bundle.css"),
			inline_js = file("tgui/public/tgui-say.bundle.js"),
	);


/client/proc/center_window(id, window_width, window_height)
	//Center the window on the main window
	var/mainwindow_data = params2list(winget(src, "mainwindow", "pos;outer-size;size;inner-size;is-maximized"))
	var/mainwindow_pos = splittext(mainwindow_data["pos"], ",")
	var/mainwindow_size = splittext(mainwindow_data["size"], "x")
	var/mainwindow_innersize = splittext(mainwindow_data["inner-size"], "x")
	var/mainwindow_outersize = splittext(mainwindow_data["outer-size"], "x")

	var/maximized = (mainwindow_data["is-maximized"] == "true")

	if(!maximized)
		//If the window is anchored (for example win+right), is-maximized is false but pos is no longer reliable
		//In that case, compare inner-size and size to guess if it's actually anchored
		maximized = text2num(mainwindow_size[1]) != text2num(mainwindow_innersize[1])\
			|| abs(text2num(mainwindow_size[2]) - text2num(mainwindow_innersize[2])) > 30

	var/target_x
	var/target_y

	// If the window is maximized or anchored, pos is the last position when the window was free-floating
	if(maximized)
		target_x = text2num(mainwindow_outersize[1])/2-window_width/2
		target_y = text2num(mainwindow_outersize[2])/2-window_height/2
	else
		target_x = text2num(mainwindow_pos[1])+text2num(mainwindow_outersize[1])/2-window_width/2
		target_y = text2num(mainwindow_pos[2])+text2num(mainwindow_outersize[2])/2-window_height/2

	winset(src, id, "pos=[target_x],[target_y]")

/**
 * Ensures nothing funny is going on window load.
 * Minimizes the window, sets max length, closes all
 * typing and thinking indicators. This is triggered
 * as soon as the window sends the "ready" message.
 */
/datum/tgui_say/proc/load()
	window_open = FALSE
	client.center_window("tgui_say", 231, 30)
	winshow(client, "tgui_say", FALSE)
	window.send_message("props", list(
		lightMode = client.prefs?.read_preference(/datum/preference/toggle/tgui_say_light_mode),
		maxLength = max_length,
	))
	stop_thinking()
	return TRUE

/**
 * Sets the window as "opened" server side, though it is already
 * visible to the user. We do this to set local vars &
 * start typing (if enabled and in an IC channel). Logs the event.
 *
 * Arguments:
 * payload - A list containing the channel the window was opened in.
 */
/datum/tgui_say/proc/open(payload)
	if(!payload?["channel"])
		CRASH("No channel provided to an open TGUI-Say")
	window_open = TRUE
	if(payload["channel"] != OOC_CHANNEL && payload["channel"] != ADMIN_CHANNEL)
		start_thinking()
	if(client.typing_indicators)
		log_speech_indicators("[key_name(client)] started typing at [loc_name(client.mob)], indicators enabled.")
	else
		log_speech_indicators("[key_name(client)] started typing at [loc_name(client.mob)], indicators DISABLED.")
	return TRUE

/**
 * Closes the window serverside. Closes any open chat bubbles
 * regardless of preference. Logs the event.
 */
/datum/tgui_say/proc/close()
	window_open = FALSE
	stop_thinking()
	if(client.typing_indicators)
		log_speech_indicators("[key_name(client)] stopped typing at [loc_name(client.mob)], indicators enabled.")
	else
		log_speech_indicators("[key_name(client)] stopped typing at [loc_name(client.mob)], indicators DISABLED.")

/**
 * The equivalent of ui_act, this waits on messages from the window
 * and delegates actions.
 */
/datum/tgui_say/proc/on_message(type, payload)
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
		if(payload["visible"] == TRUE)
			start_thinking()
			return TRUE
		if(payload["visible"] == FALSE)
			stop_thinking()
			return TRUE
		return FALSE
	if (type == "typing")
		start_typing()
		return TRUE
	if (type == "entry" || type == "force")
		handle_entry(type, payload)
		return TRUE
	return FALSE
