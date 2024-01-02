#define JUMP_STATE_OFF 0
#define JUMP_STATE_CHARGING 1
#define JUMP_STATE_IONIZING 2
#define JUMP_STATE_FIRING 3
#define JUMP_STATE_FINALIZED 4
#define JUMP_CHARGE_DELAY (20 SECONDS)
#define JUMP_CHARGEUP_TIME (3 MINUTES)

/obj/machinery/computer/helm
	name = "helm control console"
	desc = "Used to view or control the ship."
	icon = 'voidcrew/modules/shuttle/icons/computer.dmi'
	icon_screen = "navigation"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/shuttle/helm
	light_color = LIGHT_COLOR_FLARE

	/// The ship we reside on for ease of access
	var/obj/structure/overmap/ship/current_ship //voidcrew todo: ship functionality
	/// All users currently using this
	var/list/concurrent_users = list()
	/// Is this console view only? I.E. cant dock/etc
	var/viewer = FALSE
	/// When are we allowed to jump
	var/jump_allowed
	/// Current state of our jump
	var/jump_state = JUMP_STATE_OFF
	///if we are calibrating the jump
	var/calibrating = FALSE
	///holding jump timer ID
	var/jump_timer

/obj/machinery/computer/helm/viewscreen
	name = "ship viewscreen"
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "telescreen"
	icon_keyboard = null
	icon_screen = null
	layer = SIGN_LAYER
	density = FALSE
	viewer = TRUE

/obj/machinery/computer/helm/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(!current_ship && !attempt_ship_connection(last_resort = TRUE))
		return FALSE

	ui = SStgui.try_update_ui(user, src, ui)
	current_ship.update_screen()

	if(!ui)
		current_ship.cam_screen.display_to(user)
		user.client.register_map_obj(current_ship.cam_screen)
		user.client.register_map_obj(current_ship.cam_background)

		ui = new(user, src, "HelmComputer", name)
		ui.open()

/obj/machinery/computer/helm/ui_close(mob/user)
	. = ..()
	current_ship.cam_screen.hide_from(user)
/*
/obj/machinery/computer/helm/ui_act(action, list/params)
	. = ..()

	switch(action)
		if ("north")
			current_ship.apply_thrust(y = 1)
		if ("northeast")
			current_ship.apply_thrust(x = 1, y = 1)
		if ("east")
			current_ship.apply_thrust(x = 1)
		if ("southeast")
			current_ship.apply_thrust(x = 1, y = -1)
		if ("south")
			current_ship.apply_thrust(y = -1)
		if ("southwest")
			current_ship.apply_thrust(x = -1, y = -1)
		if ("west")
			current_ship.apply_thrust(x = -1)
		if ("northwest")
			current_ship.apply_thrust(x = -1, y = 1)
		if ("reset")
			current_ship.reset_thrust()
*/
/obj/machinery/computer/helm/ui_data(mob/user)
	var/list/data = list()

	data["thrust"] = current_ship.calculate_thrust()
	data["integrity"] = current_ship.integrity
	data["calibrating"] = calibrating
	data["otherInfo"] = list()
	for (var/obj/structure/overmap/object as anything in current_ship.close_overmap_objects)
		var/list/other_data = list(
			name = object.name,
			integrity = object.integrity,
			ref = REF(object)
		)
		data["otherInfo"] += list(other_data)
	var/turf/T = get_turf(current_ship)
	data["x"] = T.x
	data["y"] = T.y
	data["state"] = current_ship.state
	data["docked"] = isturf(current_ship.loc) ? FALSE : TRUE
	data["heading"] = dir2text(current_ship.get_heading()) || "None"
	data["speed"] = current_ship.get_speed()
	data["eta"] = current_ship.get_eta()
	data["est_thrust"] = current_ship.est_thrust
	data["engineInfo"] = list()
	for(var/obj/machinery/power/shuttle_engine/ship/E in current_ship.shuttle.engine_list)
		var/list/engine_data
		if(!E.thruster_active)
			engine_data = list(
				name = E.name,
				fuel = 0,
				maxFuel = 100,
				enabled = E.enabled,
				ref = REF(E)
			)
		else
			engine_data = list(
				name = E.name,
				fuel = E.return_fuel(),
				maxFuel = E.return_fuel_cap(),
				enabled = E.enabled,
				ref = REF(E)
			)
		data["engineInfo"] += list(engine_data)

	return data

/obj/machinery/computer/helm/ui_static_data(mob/user)
	var/list/data = list()

	data["mapRef"] = current_ship.map_name
	data["isViewer"] = viewer
	data["mapRef"] = current_ship.map_name
	data["shipInfo"] = list(
		name = current_ship.display_name,
		class = current_ship.source_template?.name,
		mass = current_ship.mass,
		//sensor_range = current_ship.sensor_range
	)
	data["canFly"] = TRUE

	return data

/obj/machinery/computer/helm/LateInitialize()
	. = ..()
	attempt_ship_connection()

/obj/machinery/computer/helm/proc/calibrate_jump(inline = FALSE)
	if(jump_allowed < 0)
		say("Bluespace Jump Calibration offline. Please contact your system administrator.")
		return
	if(current_ship.state != OVERMAP_SHIP_FLYING)
		say("Bluespace Jump Calibration detected interference in the local area.")
		return
	if(world.time < jump_allowed)
		var/jump_wait = DisplayTimeText(jump_allowed - world.time)
		say("Bluespace Jump Calibration is currently recharging. ETA: [jump_wait].")
		return
	if(jump_state != JUMP_STATE_OFF && !inline)
		return // This exists to prefent Href exploits to call process_jump more than once by a client
	message_admins("[ADMIN_LOOKUPFLW(usr)] has initiated a bluespace jump in [ADMIN_VERBOSEJMP(src)]")
	jump_timer = addtimer(CALLBACK(src, PROC_REF(jump_sequence), TRUE), JUMP_CHARGEUP_TIME, TIMER_STOPPABLE)
	current_ship?.ship_announce("Bluespace jump calibration initialized. Calibration completion in [JUMP_CHARGEUP_TIME/600] minutes.")
	calibrating = TRUE
	return TRUE

/obj/machinery/computer/helm/proc/cancel_jump()
	current_ship?.ship_announce("Pylon Disengaged. Jump cancelled.", "Bluespace Pylon")
	calibrating = FALSE
	deltimer(jump_timer)

/obj/machinery/computer/helm/proc/jump_sequence()
	switch(jump_state)
		if(JUMP_STATE_OFF)
			jump_state = JUMP_STATE_CHARGING
			SStgui.close_uis(src)
		if(JUMP_STATE_CHARGING)
			jump_state = JUMP_STATE_IONIZING
			current_ship?.ship_announce("Bluespace Jump Calibration completed. Ionizing Bluespace Pylon.")
		if(JUMP_STATE_IONIZING)
			jump_state = JUMP_STATE_FIRING
			current_ship?.ship_announce("Bluespace Ionization finalized; preparing to fire Bluespace Pylon.")
		if(JUMP_STATE_FIRING)
			jump_state = JUMP_STATE_FINALIZED
			current_ship?.ship_announce("Bluespace Pylon launched.", sound='sound/magic/lightning_chargeup.ogg')
			addtimer(CALLBACK(src, PROC_REF(do_jump)), 10 SECONDS)
			return
	addtimer(CALLBACK(src, PROC_REF(jump_sequence), TRUE), JUMP_CHARGE_DELAY)

/obj/machinery/computer/helm/proc/do_jump()
	current_ship?.ship_announce("Bluespace Jump Initiated.")
	current_ship.destroy_ship(TRUE)

/obj/machinery/computer/helm/connect_to_shuttle(mapload, obj/docking_port/mobile/voidcrew/port, obj/docking_port/stationary/dock)
	if(!istype(port))
		return
	current_ship = port.current_ship

/**
 * This proc manually rechecks that the helm computer is connected to a proper ship
 */
/obj/machinery/computer/helm/proc/attempt_ship_connection(last_resort = FALSE)
	if(current_ship && current_ship.shuttle.z == z)
		return TRUE

	var/obj/docking_port/mobile/voidcrew/port = SSshuttle.get_containing_shuttle(src)
	if(!istype(port))
		port = null

	if(!port && last_resort) // todo: check for helm being constructed, damn those players
		stack_trace("Failed to connect a helm to its ship, this is almost certainly a bug!")

	current_ship = port?.current_ship
	return !!current_ship

/**
 * This proc manually rechecks that the helm computer is connected to a proper ship
 */
/obj/machinery/computer/helm/proc/reload_ship()
	var/obj/docking_port/mobile/voidcrew/port = SSshuttle.get_containing_shuttle(src)
	if(port?.current_ship)
		current_ship = port.current_ship
	return TRUE

/obj/machinery/computer/helm/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(viewer)
		return
	switch(action) // Universal topics
		if("rename_ship")
			var/new_name = params["newName"]
			var/old_name = current_ship.name
			if(!new_name)
				return
			new_name = trim(new_name)
			if (!length(new_name) || new_name == current_ship.name)
				return
			if(!reject_bad_text(new_name, MAX_CHARTER_LEN))
				say("Error: Replacement designation rejected by system.")
				return
			if(!current_ship.set_ship_name(new_name))
				say("Error: [COOLDOWN_TIMELEFT(current_ship, rename_cooldown)/10] seconds until ship designation can be changed..")
			else
				log_shuttle("[usr] changed shuttle [old_name] to [new_name]")
			update_static_data(usr, ui)
			return
			/*
		if("toggle_kos")
			current_ship.set_ship_faction("KOS")
			update_static_data(usr, ui)
			return
		if("return")
			current_ship.set_ship_faction("return")
			update_static_data(usr, ui)
			return
			*/
		if("reload_ship")
			reload_ship()
			update_static_data(usr, ui)
			return
		if("reload_engines")
			current_ship.refresh_engines()
			return

	switch(current_ship.state) // Ship state-limited topics
		if(OVERMAP_SHIP_FLYING)
			switch(action)
				if("act_overmap")
					var/obj/structure/overmap/to_act = locate(params["ship_to_act"])
					say(current_ship.overmap_object_act(usr, to_act))
					return
				if("toggle_engine")
					var/obj/machinery/power/shuttle_engine/ship/E = locate(params["engine"])
					E.enabled = !E.enabled
					current_ship.refresh_engines()
					return
				if("change_heading")
					//current_ship.current_autopilot_target = null
					current_ship.burn_engines(text2num(params["dir"]))
					return
				if("stop")
					//current_ship.current_autopilot_target = null
					current_ship.burn_engines()
					return
				if("bluespace_jump")
					if(calibrating)
						cancel_jump()
						return
					else
						if(tgui_alert(usr, "Do you want to bluespace jump? Your ship and everything on it will be removed from the round.", "Jump Confirmation", list("Yes", "No")) != "Yes")
							return
						calibrate_jump()
						return
				if("dock_empty")
					say(current_ship.dock_in_empty_space(usr))
					return
		if(OVERMAP_SHIP_IDLE)
			if(action == "undock")
				current_ship.calculate_avg_fuel()
				if(current_ship.avg_fuel_amnt < 25 && tgui_alert(usr, "Ship only has ~[round(current_ship.avg_fuel_amnt)]% fuel remaining! Are you sure you want to undock?", name, list("Yes", "No")) != "Yes")
					return
				say(current_ship.undock())
				return



#undef JUMP_STATE_OFF
#undef JUMP_STATE_CHARGING
#undef JUMP_STATE_IONIZING
#undef JUMP_STATE_FIRING
#undef JUMP_STATE_FINALIZED
#undef JUMP_CHARGE_DELAY
#undef JUMP_CHARGEUP_TIME
