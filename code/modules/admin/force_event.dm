///Allows an admin to force an event
/client/proc/forceEvent()
	set name = "Trigger Event"
	set category = "Admin.Events"

	if(!holder ||!check_rights(R_FUN))
		return

	holder.forceEvent()

///Opens up the Force Event Panel
/datum/admins/proc/forceEvent()
	if(!check_rights(R_FUN))
		return

	var/datum/force_event/ui = new(usr)
	ui.ui_interact(usr)

/// Force Event Panel
/datum/force_event

/datum/force_event/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ForceEvent")
		ui.open()

/datum/force_event/ui_state(mob/user)
	return GLOB.fun_state

/datum/force_event/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	for(var/datum/round_event_control/event_control in SSevents.control)
		if(!data["categories"][event_control.category])
			data["categories"][event_control.category] = list(
				"name" = event_control.category,
				"events" = list()
			)
		data["categories"][event_control.category]["events"] += list(list(
			"name" = event_control.name,
			"description" = event_control.description,
			"type" = event_control.type
		))
	return data

/datum/force_event/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(R_FUN))
		return
	switch(action)
		if("forceevent")
			var/announce_event = params["announce"]
			var/string_path = params["type"]
			if(!string_path)
				return
			var/event_to_run_type = text2path(string_path)
			if(!event_to_run_type)
				return
			var/datum/round_event_control/event = locate(event_to_run_type) in SSevents.control
			if(!event)
				return
			event.admin_setup(usr)
			var/always_announce_chance = 100
			var/no_announce_chance = 0
			event.runEvent(announce_chance_override = announce_event ? always_announce_chance : no_announce_chance, admin_forced = TRUE)
			message_admins("[key_name_admin(usr)] has triggered an event. ([event.name])")
			log_admin("[key_name(usr)] has triggered an event. ([event.name])")
