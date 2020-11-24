/proc/tguialert(mob/user, message, title, list/buttons, timeout = 60 SECONDS)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client/))
			var/client/C = user
			user = C.mob
		else
			return
	var/datum/tgui_modal/alert = new(user, message, title, buttons, timeout)
	alert.wait()
	return alert?.choice

/datum/tgui_modal
	var/title
	var/message
	var/list/buttons
	var/choice
	var/datum/tgui/parent_ui

/datum/tgui_modal/New(mob/user, message, title, list/buttons, timeout)
	src.title = title
	src.message = message
	src.buttons = buttons.Copy()
	ui_interact(user)
	if (timeout)
		QDEL_IN(src, timeout)

/datum/tgui_modal/Destroy(force, ...)
	title = null
	message = null
	parent_ui.close()
	parent_ui = null
	QDEL_NULL(buttons)
	. = ..()

/datum/tgui_modal/proc/wait()
	while (!choice)
		stoplag(1)

/datum/tgui_modal/ui_interact(mob/user, datum/tgui/ui)
	parent_ui = SStgui.try_update_ui(user, src, ui)
	if(!parent_ui)
		parent_ui = new(user, src, "AlertModal")
		parent_ui.open()

/datum/tgui_modal/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_modal/ui_data(mob/user)
	. = list(
		"title" = title,
		"message" = message,
		"buttons" = buttons
	)

/datum/tgui_modal/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("choose")
			if (!(params["choice"] in buttons))
				return
			choice = params["choice"]
			parent_ui.close()
			return TRUE

/datum/tgui_modal/async
	var/datum/callback/callback

/datum/tgui_modal/async/New(mob/user, message, title, list/buttons, callback, timeout)
	..(user, title, message, buttons, timeout)
	src.callback = callback

/datum/tgui_modal/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

/datum/tgui_modal/async/ui_act(action, list/params)
	. = ..()
	if (.)
		if (choice != null)
			callback.InvokeAsync(choice)
			qdel(src)
		return
