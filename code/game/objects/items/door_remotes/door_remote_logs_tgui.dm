/obj/item/door_remote/proc/check_logs(mob/user)
	if(!user)
		return
	if(locked_down)
		notify_lockdown()
		return NONE
	ui_interact(user)

/obj/item/door_remote/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "DoorRemoteRecords")
		ui.open()

/obj/item/door_remote/ui_data(mob/user)
	var/list/records = SSdoor_remote_routing.door_remote_records[src]
	var/list/actions = records["ACTIONS"]
	var/list/blocked = records["BLOCKED"]
	var/list/denied = records["DENIED"]

	var/list/data = list()
	data["Actions"] = actions
	data["Blocked"] = blocked
	data["Denied"] = denied
	return data

/obj/item/door_remote/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/ui_state)
	. = ..()
	if(.)
		return

	switch(action)
		if("refresh")
			update_static_data(usr, ui)
			return TRUE

	return
