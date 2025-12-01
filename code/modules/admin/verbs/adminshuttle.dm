ADMIN_VERB(change_shuttle_events, R_ADMIN|R_FUN, "Change Shuttle Events", "Change the events on a shuttle.", ADMIN_CATEGORY_SHUTTLE)
	//At least for now, just letting admins modify the emergency shuttle is fine
	var/obj/docking_port/mobile/port = SSshuttle.emergency

	if(!port)
		to_chat(user, span_admin("Uh oh, couldn't find the escape shuttle!"))

	var/list/options = list("Clear"="Clear")

	//Grab the active events so we know which ones we can Add or Remove
	var/list/active = list()
	for(var/datum/shuttle_event/event in port.event_list)
		active[event.type] = event

	for(var/datum/shuttle_event/event as anything in subtypesof(/datum/shuttle_event))
		options[((event in active) ? "(Remove)" : "(Add)") + initial(event.name)] = event

	//Throw up an ugly menu with the shuttle events and the options to add or remove them, or clear them all
	var/result = input(user, "Choose an event to add/remove", "Shuttle Events") as null|anything in sort_list(options)

	if(result == "Clear")
		port.event_list.Cut()
		message_admins("[key_name_admin(user)] has cleared the shuttle events on: [port]")
	else if(options[result])
		var/typepath = options[result]
		if(typepath in active)
			port.event_list.Remove(active[options[result]])
			message_admins("[key_name_admin(user)] has removed '[active[result]]' from [port].")
		else
			message_admins("[key_name_admin(user)] has added '[typepath]' to [port].")
			port.add_shuttle_event(typepath)

ADMIN_VERB(call_shuttle, R_ADMIN, "Call Shuttle", "Force a shuttle call with additional modifiers.", ADMIN_CATEGORY_SHUTTLE)
	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	var/confirm = tgui_alert(user, "You sure?", "Confirm", list("Yes", "Yes (No Recall)", "No"))
	switch(confirm)
		if(null, "No")
			return
		if("Yes (No Recall)")
			SSshuttle.admin_emergency_no_recall = TRUE
			SSshuttle.emergency.mode = SHUTTLE_IDLE

	SSshuttle.emergency.request()
	BLACKBOX_LOG_ADMIN_VERB("Call Shuttle")
	log_admin("[key_name(user)] admin-called the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(user)] admin-called the emergency shuttle[confirm == "Yes (No Recall)" ? " (non-recallable)" : ""]."))

ADMIN_VERB(cancel_shuttle, R_ADMIN, "Cancel Shuttle", "Recall the shuttle, regardless of circumstances.", ADMIN_CATEGORY_SHUTTLE)
	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(tgui_alert(user, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return
	SSshuttle.admin_emergency_no_recall = FALSE
	SSshuttle.emergency.cancel()
	BLACKBOX_LOG_ADMIN_VERB("Cancel Shuttle")
	log_admin("[key_name(user)] admin-recalled the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(user)] admin-recalled the emergency shuttle."))

ADMIN_VERB(disable_shuttle, R_ADMIN, "Disable Shuttle", "Those fuckers aren't getting out.", ADMIN_CATEGORY_SHUTTLE)
	if(SSshuttle.emergency.mode == SHUTTLE_DISABLED)
		to_chat(user, span_warning("Error, shuttle is already disabled."))
		return

	if(tgui_alert(user, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	message_admins(span_adminnotice("[key_name_admin(user)] disabled the shuttle."))

	SSshuttle.last_mode = SSshuttle.emergency.mode
	SSshuttle.last_call_time = SSshuttle.emergency.timeLeft(1)
	SSshuttle.admin_emergency_no_recall = TRUE
	SSshuttle.emergency.setTimer(0)
	SSshuttle.emergency.mode = SHUTTLE_DISABLED
	priority_announce(
		text = "Emergency Shuttle uplink failure, shuttle disabled until further notice.",
		title = "Uplink Failure",
		sound = 'sound/announcer/announcement/announce_dig.ogg',
		sender_override = "Emergency Shuttle Uplink Alert",
		color_override = "grey",
	)

ADMIN_VERB(enable_shuttle, R_ADMIN, "Enable Shuttle", "Those fuckers ARE getting out.", ADMIN_CATEGORY_SHUTTLE)
	if(SSshuttle.emergency.mode != SHUTTLE_DISABLED)
		to_chat(user, span_warning("Error, shuttle not disabled."))
		return

	if(tgui_alert(user, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	message_admins(span_adminnotice("[key_name_admin(user)] enabled the emergency shuttle."))
	SSshuttle.admin_emergency_no_recall = FALSE
	SSshuttle.emergency_no_recall = FALSE
	if(SSshuttle.last_mode == SHUTTLE_DISABLED) //If everything goes to shit, fix it.
		SSshuttle.last_mode = SHUTTLE_IDLE

	SSshuttle.emergency.mode = SSshuttle.last_mode
	if(SSshuttle.last_call_time < 10 SECONDS && SSshuttle.last_mode != SHUTTLE_IDLE)
		SSshuttle.last_call_time = 10 SECONDS //Make sure no insta departures.
	SSshuttle.emergency.setTimer(SSshuttle.last_call_time)
	priority_announce(
		text = "Emergency Shuttle uplink reestablished, shuttle enabled.",
		title = "Uplink Restored",
		sound = 'sound/announcer/announcement/announce_dig.ogg',
		sender_override = "Emergency Shuttle Uplink Alert",
		color_override = "green",
	)

ADMIN_VERB(hostile_environment, R_ADMIN, "Hostile Environment", "Disable the shuttle, naturally.", ADMIN_CATEGORY_SHUTTLE)
	switch(tgui_alert(user, "Select an Option", "Hostile Environment Manager", list("Enable", "Disable", "Clear All")))
		if("Enable")
			if (SSshuttle.hostile_environments["Admin"] == TRUE)
				to_chat(user, span_warning("Error, admin hostile environment already enabled."))
			else
				message_admins(span_adminnotice("[key_name_admin(user)] Enabled an admin hostile environment"))
				SSshuttle.registerHostileEnvironment("Admin")
		if("Disable")
			if (!SSshuttle.hostile_environments["Admin"])
				to_chat(user, span_warning("Error, no admin hostile environment found."))
			else
				message_admins(span_adminnotice("[key_name_admin(user)] Disabled the admin hostile environment"))
				SSshuttle.clearHostileEnvironment("Admin")
		if("Clear All")
			message_admins(span_adminnotice("[key_name_admin(user)] Disabled all current hostile environment sources"))
			SSshuttle.hostile_environments.Cut()
			SSshuttle.checkHostileEnvironment()

ADMIN_VERB(shuttle_panel, R_ADMIN, "Shuttle Manipulator", "Opens the shuttle manipulator UI.", ADMIN_CATEGORY_SHUTTLE)
	SSshuttle.ui_interact(user.mob)

/obj/docking_port/mobile/proc/admin_fly_shuttle(mob/user)
	var/list/options = list()

	for(var/port in SSshuttle.stationary_docking_ports)
		if (istype(port, /obj/docking_port/stationary/transit))
			continue  // please don't do this
		var/obj/docking_port/stationary/S = port
		if (canDock(S) == SHUTTLE_CAN_DOCK)
			options[S.name || S.shuttle_id] = S

	options += "--------"
	options += "Infinite Transit"
	options += "Delete Shuttle"
	options += "Into The Sunset (delete & greentext 'escape')"

	var/selection = tgui_input_list(user, "Select where to fly [name || shuttle_id]:", "Fly Shuttle", options)
	if(isnull(selection))
		return

	switch(selection)
		if("Infinite Transit")
			destination = null
			mode = SHUTTLE_IGNITING
			setTimer(ignitionTime)

		if("Delete Shuttle")
			if(tgui_alert(user, "Really delete [name || shuttle_id]?", "Delete Shuttle", list("Cancel", "Really!")) != "Really!")
				return
			jumpToNullSpace()

		if("Into The Sunset (delete & greentext 'escape')")
			if(tgui_alert(user, "Really delete [name || shuttle_id] and greentext escape objectives?", "Delete Shuttle", list("Cancel", "Really!")) != "Really!")
				return
			intoTheSunset()

		else
			if(options[selection])
				request(options[selection])

/obj/docking_port/mobile/emergency/admin_fly_shuttle(mob/user)
	return  // use the existing verbs for this

/obj/docking_port/mobile/arrivals/admin_fly_shuttle(mob/user)
	switch(tgui_alert(user, "Would you like to fly the arrivals shuttle once or change its destination?", "Fly Shuttle", list("Fly", "Retarget", "Cancel")))
		if("Cancel")
			return
		if("Fly")
			return ..()

	var/list/options = list()

	for(var/port in SSshuttle.stationary_docking_ports)
		if (istype(port, /obj/docking_port/stationary/transit))
			continue  // please don't do this
		var/obj/docking_port/stationary/S = port
		if (canDock(S) == SHUTTLE_CAN_DOCK)
			options[S.name || S.shuttle_id] = S

	var/selection = tgui_input_list(user, "New arrivals destination", "Fly Shuttle", options)
	if(isnull(selection))
		return
	target_dock = options[selection]
	if(!QDELETED(target_dock))
		destination = target_dock
