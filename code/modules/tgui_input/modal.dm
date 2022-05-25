/**
 * Opens a small tgui window that takes input and returns the user response.
 *
 * Arguments:
 ** title - String displayed at the top of the window.
 ** max_length - Cuts the user off after this amount of characters.
 */
/proc/tgui_modal(mob/user, title = "Modal", max_length = MAX_MESSAGE_LEN)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return null
	var/datum/tgui_modal/modal = new(user, title, max_length)
	modal.open(user)
	modal.wait()

/datum/tgui_modal
	/// Boolean field describing if the tgui_modal was closed by the user.
	var/closed
	/// The title of the TGUI window
	var/title
	/// Max message length
	var/max_length
	/// The modal window
	var/datum/tgui_window/window

/datum/tgui_modal/New(user, title, max_length)
	src.title = title
	src.max_length = max_length

/**
 * Opens the window for the tgui modal and inlines the bundle.
 */
/datum/tgui_modal/proc/open(mob/user)
	window = new(user.client, "modal", FALSE)
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
	closed = TRUE
	window.close()

/**
 * Pauses the interface while waiting for user input.
 */
/datum/tgui_modal/proc/wait()
	while(!closed && !QDELETED(src))
		stoplag(1)

/**
 * The equivalent of ui_act, this waits on messages from the window
 * and delegates actions.
 */
/datum/tgui_modal/proc/on_message(type, payload)
	if (type == "close")
		close()
	return TRUE
