/obj/machinery/shuttle_manipulator
	name = "shuttle manipulator"
	desc = "I shall be telling this with a sigh\n\
		Somewhere ages and ages hence:\n\
		Two roads diverged in a wood, and I,\n\
		I took the one less traveled by,\n\
		And that has made all the difference."

	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator-blue"

	// UI state variables
	var/datum/map_template/shuttle/selected
	var/obj/docking_port/mobile/existing_shuttle

	var/obj/docking_port/mobile/preview_shuttle
	var/preview_shuttle_id

/obj/machinery/shuttle_manipulator/process()
	return

/obj/machinery/shuttle_manipulator/ui_interact(mob/user, ui_key = "main", \
	datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, \
	datum/ui_state/state = admin_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "shuttle_manipulator", name, 800, 600, \
			master_ui, state)
		ui.open()

/proc/shuttlemode2str(mode)
	switch(mode)
		if(SHUTTLE_IDLE)
			. = "idle"
		if(SHUTTLE_RECALL)
			. = "recalled"
		if(SHUTTLE_CALL)
			. = "called"
		if(SHUTTLE_DOCKED)
			. = "docked"
		if(SHUTTLE_STRANDED)
			. = "stranded"
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

	for(var/shuttle_id in shuttle_templates)
		var/datum/map_template/shuttle/S = shuttle_templates[shuttle_id]

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

		if(selected && (selected.shuttle_id == S.shuttle_id))
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
		L["mode"] = capitalize(shuttlemode2str(M.mode))
		L["status"] = M.getStatusText()
		if(selected && selected.port_id == M.id)
			existing_shuttle = M
			data["existing_shuttle"] = L
		data["shuttles"] += list(L)

	return data

/obj/machinery/shuttle_manipulator/ui_act(action, params)
	if(..())
		return

	var/mob/user = usr

	switch(action)
		if("select_template")
			var/shuttle_id = params["shuttle_id"]

			var/datum/map_template/shuttle/S = shuttle_templates[shuttle_id]
			if(S)
				selected = S
				. = TRUE
		if("jump_to")
			if(params["type"] == "mobile")
				for(var/i in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = i
					if(M.id == params["id"])
						user.forceMove(get_turf(M))
		if("preview")
			var/shuttle_id = params["id"]
			var/datum/map_template/shuttle/S = shuttle_templates[shuttle_id]
			if(S)
				if(preview_shuttle)
					preview_shuttle.jumpToNullSpace()
				load_template(S)
				if(preview_shuttle)
					preview_shuttle_id = shuttle_id
					user.forceMove(get_turf(preview_shuttle))
		if("load")
			var/shuttle_id = params["id"]
			var/datum/map_template/shuttle/S = shuttle_templates[shuttle_id]
			if(S)
				if(!preview_shuttle || (S.shuttle_id != preview_shuttle_id))
					if(preview_shuttle)
						preview_shuttle.jumpToNullSpace()
					load_template(S)
					preview_shuttle_id = shuttle_id
				// get the existing shuttle information, if any
				var/timer
				var/mode = SHUTTLE_IDLE
				var/obj/docking_port/stationary/D
				if(existing_shuttle)
					timer = existing_shuttle.timer
					mode = existing_shuttle.mode
					D = existing_shuttle.get_docked()

				if(!D)
					var/msg1 = "[existing_shuttle] is not currently at a \
						valid dock, the import will not continue."
					abort_import(msg1)
					return

				if(preview_shuttle.canDock(D))
					// truthy value means that it cannot dock for some reason
					var/msg3 = "Unsuccessful dock of [preview_shuttle], \
						removing."
					abort_import(msg3)
					return

				// Destroy the old shuttle
				existing_shuttle.jumpToNullSpace()
				// Unflub the ID
				var/new_id = replacetext(preview_shuttle.id, "(preview)", "")
				preview_shuttle.id = new_id

				preview_shuttle.dock(D)
				preview_shuttle.timer = timer
				preview_shuttle.mode = mode
				// Register with the shuttle subsystem
				preview_shuttle.register()
				. = TRUE

				preview_shuttle = null
				preview_shuttle_id = null
				existing_shuttle = null
				selected = null

	update_icon()


/obj/machinery/shuttle_manipulator/proc/load_template(
	datum/map_template/shuttle/S)
	// load shuttle template, centred at shuttle import landmark,
	var/turf/landmark_turf = get_turf(locate("landmark*Shuttle Import"))
	S.load(landmark_turf, centered = TRUE)

	var/affected = S.get_affected_turfs(landmark_turf, centered=TRUE)

	var/found = 0
	for(var/T in affected)
		for(var/obj/docking_port/P in T)
			if(istype(P, /obj/docking_port/mobile))
				found++
				if(found > 1)
					qdel(P, force=TRUE)
					world.log << "Map warning: Shuttle Template [S.mappath] \
						has multiple mobile docking ports."
				else
					// Change the id so the shuttle system doesn't grab the
					// loaded ship until we want it to
					P.id = "(preview)[P.id]"
					preview_shuttle = P
			if(istype(P, /obj/docking_port/stationary))
				world.log << "Map warning: Shuttle Template [S.mappath] has a \
					stationary docking port."
	if(!found)
		var/msg = "load_template(): Shuttle Template [S.mappath] has no \
			mobile docking port. Aborting import."
		for(var/T in affected)
			var/turf/T0 = T
			T0.empty()

		message_admins(msg)
		throw EXCEPTION(msg)

/obj/machinery/shuttle_manipulator/proc/abort_import(msg)
	message_admins(msg)
	WARNING(msg)
	if(preview_shuttle)
		preview_shuttle.jumpToNullSpace()
	preview_shuttle_id = null
	selected = null
