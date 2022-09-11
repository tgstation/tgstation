/obj/machinery/computer/shuttle
	name = "shuttle console"
	desc = "A shuttle control computer."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list()
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_SET_MACHINE
	/// ID of the attached shuttle
	var/shuttleId
	/// Possible destinations of the attached shuttle
	var/possible_destinations = ""
	/// Variable dictating if the attached shuttle requires authorization from the admin staff to move
	var/admin_controlled = FALSE
	/// Variable dictating if the attached shuttle is forbidden to change destinations mid-flight
	var/no_destination_swap = FALSE
	/// ID of the currently selected destination of the attached shuttle
	var/destination
	/// If the console controls are locked
	var/locked = FALSE
	/// List of head revs who have already clicked through the warning about not using the console
	var/static/list/dumb_rev_heads = list()
	/// Authorization request cooldown to prevent request spam to admin staff
	COOLDOWN_DECLARE(request_cooldown)

/obj/machinery/computer/shuttle/Initialize(mapload)
	. = ..()
	connect_to_shuttle(mapload, SSshuttle.get_containing_shuttle(src))

/obj/machinery/computer/shuttle/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(is_station_level(user.z) && user.mind && IS_HEAD_REVOLUTIONARY(user) && !(user.mind in dumb_rev_heads))
		to_chat(user, span_warning("You get a feeling that leaving the station might be a REALLY dumb idea..."))
		dumb_rev_heads += user.mind
		return
	if (HAS_TRAIT(user, TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION) && !is_station_level(user.z))
		to_chat(user, span_warning("You get the feeling you shouldn't mess with this."))
		return
	if(!user.can_read(src, check_for_light = FALSE))
		to_chat(user, span_warning("You start mashing buttons at random!"))
		if(do_after(user, 10 SECONDS, target = src))
			var/obj/docking_port/mobile/mobile_docking_port = SSshuttle.getShuttle(shuttleId)
			if(no_destination_swap)
				if(mobile_docking_port.mode == SHUTTLE_RECHARGING)
					to_chat(usr, span_warning("Shuttle engines are not ready for use."))
					return
				if(mobile_docking_port.mode != SHUTTLE_IDLE)
					to_chat(usr, span_warning("Shuttle already in transit."))
					return
			var/list/destination = pick(get_valid_destinations())
			switch(SSshuttle.moveShuttle(shuttleId, destination["id"], 1))
				if(0)
					say("Shuttle departing. Please stand away from the doors.")
					log_shuttle("[key_name(usr)] has sent shuttle \"[mobile_docking_port]\" towards \"[destination["name"]]\", using [src].")
					return TRUE
				if(1)
					to_chat(usr, span_warning("Invalid shuttle requested."))
				else
					to_chat(usr, span_warning("Unable to comply."))

		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleConsole", name)
		ui.open()

/obj/machinery/computer/shuttle/ui_data(mob/user)
	var/list/data = list()
	var/obj/docking_port/mobile/mobile_docking_port = SSshuttle.getShuttle(shuttleId)
	data["docked_location"] = mobile_docking_port ? mobile_docking_port.get_status_text_tgui() : "Unknown"
	data["locations"] = list()
	data["locked"] = locked
	data["authorization_required"] = admin_controlled
	data["timer_str"] = mobile_docking_port ? mobile_docking_port.getTimerStr() : "00:00"
	data["destination"] = destination
	if(!mobile_docking_port)
		data["status"] = "Missing"
		return data
	if(admin_controlled)
		data["status"] = "Unauthorized Access"
	else if(locked)
		data["status"] = "Locked"
	else
		switch(mobile_docking_port.mode)
			if(SHUTTLE_IGNITING)
				data["status"] = "Igniting"
			if(SHUTTLE_IDLE)
				data["status"] = "Idle"
			if(SHUTTLE_RECHARGING)
				data["status"] = "Recharging"
			else
				data["status"] = "In Transit"
	data["locations"] = get_valid_destinations()
	if(length(data["locations"]) == 1)
		for(var/location in data["locations"])
			destination = location["id"]
			data["destination"] = destination
	if(!length(data["locations"]))
		data["locked"] = TRUE
		data["status"] = "Locked"
	return data

/**
 * Checks if we are allowed to launch the shuttle, for special cases
 *
 * Arguments:
 * * user - The mob trying to initiate the launch
 */
/obj/machinery/computer/shuttle/proc/launch_check(mob/user)
	return TRUE

/obj/machinery/computer/shuttle/proc/get_valid_destinations()
	var/list/destination_list = params2list(possible_destinations)
	var/obj/docking_port/mobile/mobile_docking_port = SSshuttle.getShuttle(shuttleId)
	var/list/valid_destinations = list()
	for(var/obj/docking_port/stationary/stationary_docking_port in SSshuttle.stationary_docking_ports)
		if(!destination_list.Find(stationary_docking_port.port_destinations))
			continue
		if(!mobile_docking_port.check_dock(stationary_docking_port, silent = TRUE))
			continue
		var/list/location_data = list(
			id = stationary_docking_port.shuttle_id,
			name = stationary_docking_port.name
		)
		valid_destinations += list(location_data)
	return valid_destinations

/obj/machinery/computer/shuttle/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, span_danger("Access denied."))
		return

	switch(action)
		if("move")
			if(!launch_check(usr))
				return
			var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
			if(M.launch_status == ENDGAME_LAUNCHED)
				to_chat(usr, span_warning("You've already escaped. Never going back to that place again!"))
				return
			if(no_destination_swap)
				if(M.mode == SHUTTLE_RECHARGING)
					to_chat(usr, span_warning("Shuttle engines are not ready for use."))
					return
				if(M.mode != SHUTTLE_IDLE)
					to_chat(usr, span_warning("Shuttle already in transit."))
					return
			var/list/options = params2list(possible_destinations)
			var/obj/docking_port/stationary/S = SSshuttle.getDock(params["shuttle_id"])
			if(!(S.port_destinations in options))
				log_admin("[usr] attempted to href dock exploit on [src] with target location \"[params["shuttle_id"]]\"")
				message_admins("[usr] just attempted to href dock exploit on [src] with target location \"[params["shuttle_id"]]\"")
				return
			switch(SSshuttle.moveShuttle(shuttleId, params["shuttle_id"], 1))
				if(0)
					say("Shuttle departing. Please stand away from the doors.")
					log_shuttle("[key_name(usr)] has sent shuttle \"[M]\" towards \"[params["shuttle_id"]]\", using [src].")
					return TRUE
				if(1)
					to_chat(usr, span_warning("Invalid shuttle requested."))
				else
					to_chat(usr, span_warning("Unable to comply."))
		if("set_destination")
			var/target_destination = params["destination"]
			if(target_destination)
				destination = target_destination
				return TRUE
		if("request")
			if(!COOLDOWN_FINISHED(src, request_cooldown))
				to_chat(usr, span_warning("CentCom is still processing last authorization request!"))
				return
			COOLDOWN_START(src, request_cooldown, 1 MINUTES)
			to_chat(usr, span_notice("Your request has been received by CentCom."))
			to_chat(GLOB.admins, "<b>SHUTTLE: <font color='#3d5bc3'>[ADMIN_LOOKUPFLW(usr)] (<A HREF='?_src_=holder;[HrefToken()];move_shuttle=[shuttleId]'>Move Shuttle</a>)(<A HREF='?_src_=holder;[HrefToken()];unlock_shuttle=[REF(src)]'>Lock/Unlock Shuttle</a>)</b> is requesting to move or unlock the shuttle.</font>")
			return TRUE

/obj/machinery/computer/shuttle/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	req_access = list()
	obj_flags |= EMAGGED
	to_chat(user, span_notice("You fried the consoles ID checking system."))

/obj/machinery/computer/shuttle/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	if(!mapload)
		return
	if(!port)
		return
	//Remove old custom port id and ";;"
	var/find_old = findtextEx(possible_destinations, "[shuttleId]_custom")
	if(find_old)
		possible_destinations = replacetext(replacetextEx(possible_destinations, "[shuttleId]_custom", ""), ";;", ";")
	shuttleId = port.shuttle_id
	possible_destinations += ";[port.shuttle_id]_custom"
