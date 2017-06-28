/obj/machinery/shuttle_manipulator
	name = "shuttle manipulator"
	desc = "I shall be telling this with a sigh\n\
		Somewhere ages and ages hence:\n\
		Two roads diverged in a wood, and I,\n\
		I took the one less traveled by,\n\
		And that has made all the difference."

	icon = 'icons/obj/machines/shuttle_manipulator.dmi'
	icon_state = "holograph_on"

	anchored = TRUE
	density = TRUE

	// UI state variables
	var/datum/map_template/shuttle/selected

	var/obj/docking_port/mobile/existing_shuttle

	var/obj/docking_port/mobile/preview_shuttle
	var/datum/map_template/shuttle/preview_template

/obj/machinery/shuttle_manipulator/Initialize()
	. = ..()
	update_icon()

/obj/machinery/shuttle_manipulator/update_icon()
	cut_overlays()
	var/mutable_appearance/hologram_projection = mutable_appearance(icon, "hologram_on")
	hologram_projection.pixel_y = 22
	var/mutable_appearance/hologram_ship = mutable_appearance(icon, "hologram_whiteship")
	hologram_ship.pixel_y = 27
	add_overlay(hologram_projection)
	add_overlay(hologram_ship)

/obj/machinery/shuttle_manipulator/ui_interact(mob/user, ui_key = "main", \
	datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, \
	datum/ui_state/state = GLOB.admin_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "shuttle_manipulator", name, 800, 600, \
			master_ui, state)
		ui.open()

/proc/shuttlemode2str(mode)
	switch(mode)
		if(SHUTTLE_IDLE)
			. = "idle"
		if(SHUTTLE_IGNITING)
			. = "engines charging"
		if(SHUTTLE_RECALL)
			. = "recalled"
		if(SHUTTLE_CALL)
			. = "called"
		if(SHUTTLE_DOCKED)
			. = "docked"
		if(SHUTTLE_STRANDED)
			. = "stranded"
		if(SHUTTLE_ESCAPE)
			. = "escape"
		if(SHUTTLE_ENDGAME)
			. = "endgame"
	if(!.)
		throw EXCEPTION("shuttlemode2str(): invalid mode [mode]")


/obj/machinery/shuttle_manipulator/ui_data(mob/user)
	var/list/data = list()
	data["tabs"] = list("Status", "Templates", "Modification")

	// Templates panel
	data["templates"] = list()
	var/list/templates = data["templates"]
	data["templates_tabs"] = list()
	data["selected"] = list()

	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]

		if(!templates[S.port_id])
			data["templates_tabs"] += S.port_id
			templates[S.port_id] = list(
				"port_id" = S.port_id,
				"templates" = list())

		var/list/L = list()
		L["name"] = S.name
		L["shuttle_id"] = S.shuttle_id
		L["port_id"] = S.port_id
		L["description"] = S.description
		L["admin_notes"] = S.admin_notes

		if(selected == S)
			data["selected"] = L

		templates[S.port_id]["templates"] += list(L)

	data["templates_tabs"] = sortList(data["templates_tabs"])

	data["existing_shuttle"] = null

	// Status panel
	data["shuttles"] = list()
	for(var/i in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = i
		var/list/L = list()
		L["name"] = M.name
		L["id"] = M.id
		L["timer"] = M.timer
		L["timeleft"] = M.getTimerStr()
		var/can_fast_travel = FALSE
		if(M.timer && M.timeLeft() >= 50)
			can_fast_travel = TRUE
		L["can_fast_travel"] = can_fast_travel
		L["mode"] = capitalize(shuttlemode2str(M.mode))
		L["status"] = M.getStatusText()
		if(M == existing_shuttle)
			data["existing_shuttle"] = L

		data["shuttles"] += list(L)

	return data

/obj/machinery/shuttle_manipulator/ui_act(action, params)
	if(..())
		return

	var/mob/user = usr

	// Preload some common parameters
	var/shuttle_id = params["shuttle_id"]
	var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]

	switch(action)
		if("select_template")
			if(S)
				existing_shuttle = SSshuttle.getShuttle(S.port_id)
				selected = S
				. = TRUE
		if("jump_to")
			if(params["type"] == "mobile")
				for(var/i in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = i
					if(M.id == params["id"])
						user.forceMove(get_turf(M))
						. = TRUE
						break
		if("fast_travel")
			for(var/i in SSshuttle.mobile)
				var/obj/docking_port/mobile/M = i
				if(M.id == params["id"] && M.timer && M.timeLeft() >= 50)
					M.setTimer(50)
					. = TRUE
					message_admins("[key_name_admin(usr)] fast travelled \
						[M]")
					log_admin("[key_name(usr)] fast travelled [M]")
					SSblackbox.add_details("shuttle_fasttravel", M.name)
					break

		if("preview")
			if(S)
				. = TRUE
				unload_preview()
				load_template(S)
				if(preview_shuttle)
					preview_template = S
					user.forceMove(get_turf(preview_shuttle))
		if("load")
			if(existing_shuttle == SSshuttle.backup_shuttle)
				// TODO make the load button disabled
				WARNING("The shuttle that the selected shuttle will replace \
					is the backup shuttle. Backup shuttle is required to be \
					intact for round sanity.")
			else if(S)
				. = TRUE
				// If successful, returns the mobile docking port
				var/obj/docking_port/mobile/mdp = action_load(S)
				if(mdp)
					user.forceMove(get_turf(mdp))
					message_admins("[key_name_admin(usr)] loaded [mdp] \
						with the shuttle manipulator.")
					log_admin("[key_name(usr)] loaded [mdp] with the \
						shuttle manipulator.</span>")
					SSblackbox.add_details("shuttle_manipulator", mdp.name)

	update_icon()

/obj/machinery/shuttle_manipulator/proc/action_load(
	datum/map_template/shuttle/loading_template)
	// Check for an existing preview
	if(preview_shuttle && (loading_template != preview_template))
		preview_shuttle.jumpToNullSpace()
		preview_shuttle = null
		preview_template = null

	if(!preview_shuttle)
		load_template(loading_template)
		preview_template = loading_template

	// get the existing shuttle information, if any
	var/timer = 0
	var/mode = SHUTTLE_IDLE
	var/obj/docking_port/stationary/D

	if(existing_shuttle)
		timer = existing_shuttle.timer
		mode = existing_shuttle.mode
		D = existing_shuttle.get_docked()
	else
		D = preview_shuttle.findRoundstartDock()

	if(!D)
		var/m = "No dock found for preview shuttle, aborting."
		WARNING(m)
		throw EXCEPTION(m)

	var/result = preview_shuttle.canDock(D)
	// truthy value means that it cannot dock for some reason
	// but we can ignore the someone else docked error because we'll
	// be moving into their place shortly
	if((result != SHUTTLE_CAN_DOCK) && (result != SHUTTLE_SOMEONE_ELSE_DOCKED))
		var/m = "Unsuccessful dock of [preview_shuttle] ([result])."
		WARNING(m)
		return

	existing_shuttle.jumpToNullSpace()

	preview_shuttle.dock(D)
	. = preview_shuttle

	// Shuttle state involves a mode and a timer based on world.time, so
	// plugging the existing shuttles old values in works fine.
	preview_shuttle.timer = timer
	preview_shuttle.mode = mode

	preview_shuttle.register()

	// TODO indicate to the user that success happened, rather than just
	// blanking the modification tab
	preview_shuttle = null
	preview_template = null
	existing_shuttle = null
	selected = null

/obj/machinery/shuttle_manipulator/proc/load_template(
	datum/map_template/shuttle/S)
	// load shuttle template, centred at shuttle import landmark,
	var/turf/landmark_turf = get_turf(locate("landmark*Shuttle Import"))
	S.load(landmark_turf, centered = TRUE)

	var/affected = S.get_affected_turfs(landmark_turf, centered=TRUE)

	var/found = 0
	// Search the turfs for docking ports
	// - We need to find the mobile docking port because that is the heart of
	//   the shuttle.
	// - We need to check that no additional ports have slipped in from the
	//   template, because that causes unintended behaviour.
	for(var/T in affected)
		for(var/obj/docking_port/P in T)
			if(istype(P, /obj/docking_port/mobile))
				var/obj/docking_port/mobile/M = P
				found++
				if(found > 1)
					qdel(P, force=TRUE)
					log_world("Map warning: Shuttle Template [S.mappath] has multiple mobile docking ports.")
				else if(!M.timid)
					// The shuttle template we loaded isn't "timid" which means
					// it's already registered with the shuttles subsystem.
					// This is a bad thing.
					var/m = "Template [S] is non-timid! Unloading."
					WARNING(m)
					M.jumpToNullSpace()
					return
				else
					preview_shuttle = P
			if(istype(P, /obj/docking_port/stationary))
				log_world("Map warning: Shuttle Template [S.mappath] has a stationary docking port.")
	if(!found)
		var/msg = "load_template(): Shuttle Template [S.mappath] has no	mobile docking port. Aborting import."
		for(var/T in affected)
			var/turf/T0 = T
			T0.empty()

		message_admins(msg)
		WARNING(msg)
		return
	//Everything fine
	S.on_bought()

/obj/machinery/shuttle_manipulator/proc/unload_preview()
	if(preview_shuttle)
		preview_shuttle.jumpToNullSpace()
	preview_shuttle = null
