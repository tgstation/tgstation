/mob/dead/observer/verb/show_notificationprefs()
	set category = "Ghost"
	set name = "Notification preferences"
	set desc = "Notification preferences"

	var/datum/notificationpanel/panel = new(usr)

	panel.ui_interact(usr)

/datum/notificationpanel
	var/client/user

/datum/notificationpanel/New(user)
	if (ismob(user))
		var/mob/M = user
		if (!M.client)
			CRASH("Ghost role notification panel attempted to open to a mob without a client")
		src.user = M.client
	else
		src.user = user

/datum/notificationpanel/ui_state(mob/user)
	return GLOB.observer_state

/datum/notificationpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NotificationPreferences")
		ui.open()

/datum/notificationpanel/ui_data(mob/user)
	. = list()
	.["ignore"] = list()
	for(var/key in GLOB.poll_ignore_desc)
		.["ignore"] += list(list(
			"key" = key,
			"enabled" = (user.ckey in GLOB.poll_ignore[key]),
			"desc" = GLOB.poll_ignore_desc[key]
		))

/datum/notificationpanel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch (action)
		if ("toggle_ignore")
			var/key = params["key"]
			if (key && islist(GLOB.poll_ignore[key]))
				GLOB.poll_ignore[key] ^= list(user.ckey)
	. = TRUE
