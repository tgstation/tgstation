

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

/datum/tgui_modal/New(title, max_length)
	src.title = title
	src.max_length = max_length

/datum/tgui_modal/proc/open(mob/user)
	window = new(user.client, "modal", FALSE)
	window.initialize(
			strict_mode = TRUE,
			fancy = user.client.prefs.read_preference(/datum/preference/toggle/tgui_fancy),
			inline_js = file2text('tgui/public/tgui-modal.bundle.js'),
			inline_css = file2text('tgui/public/tgui-modal.bundle.css'),
		)
	window.subscribe(src, .proc/on_message)

/datum/tgui_modal/proc/close(mob/user)
	closed = TRUE
	window.close()

/datum/tgui_modal/proc/wait()
	while(!closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_modal/proc/on_message(type, payload)
	if (type == "button")
		close()
	return TRUE
