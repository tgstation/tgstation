/proc/tgui_alert(mob/user, message, title, list/buttons, timeout = 60 SECONDS)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client/))
			var/client/C = user
			user = C.mob
		else
			return
	var/datum/tgui_modal/alert = new(user, message, title, buttons, timeout)
	alert.ui_interact(user)
	alert.wait()
	if (alert)
		. = alert.choice
		qdel(alert)

/proc/tgui_alert_async(mob/user, message, title, list/buttons, datum/callback/callback, timeout = 60 SECONDS)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client/))
			var/client/C = user
			user = C.mob
		else
			return
	var/datum/tgui_modal/async/alert = new(user, message, title, buttons, callback, timeout)
	alert.ui_interact(user)

/datum/tgui_modal
	var/title
	var/message
	var/list/buttons
	var/choice
	var/start_time
	var/timeout
	var/closed

/datum/tgui_modal/New(mob/user, message, title, list/buttons, timeout)
	src.title = title
	src.message = message
	src.buttons = buttons.Copy()
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_modal/Destroy(force, ...)
	SStgui.close_uis(src)
	title = null
	message = null
	QDEL_NULL(buttons)
	choice = null
	. = ..()

/datum/tgui_modal/proc/wait()
	while (!choice && !closed)
		stoplag(1)

/datum/tgui_modal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AlertModal")
		ui.open()

/datum/tgui_modal/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_modal/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_modal/ui_data(mob/user)
	. = list(
		"title" = title,
		"message" = message,
		"buttons" = buttons
	)

	if(timeout)
		.["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

/datum/tgui_modal/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("choose")
			if (!(params["choice"] in buttons))
				return
			choice = params["choice"]
			SStgui.close_uis(src)
			return TRUE

/datum/tgui_modal/async
	var/datum/callback/callback

/datum/tgui_modal/async/New(mob/user, message, title, list/buttons, callback, timeout)
	..(user, title, message, buttons, timeout)
	src.callback = callback

/datum/tgui_modal/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

/datum/tgui_modal/async/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/tgui_modal/async/ui_act(action, list/params)
	. = ..()
	if (.)
		if (choice != null)
			callback.InvokeAsync(choice)
			qdel(src)
		return

/datum/tgui_modal/async/wait()
	return
