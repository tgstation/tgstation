/datum/admins/proc/open_areatool(area/target in GLOB.sortedAreas)
	set category = "Admin"
	set name = "Show area tool"
	set desc = "Show area tool"

	if(!check_rights(R_ADMIN))
		return

	var/datum/areatool/areatool = new(usr, target)

	areatool.ui_interact(usr)



/datum/areatool
	var/mob/user
	var/area/target
	var/static/list/areabooleans = list("requires_power", "always_unpowered", "blob_allowed", "outdoors", "has_gravity", "noteleport", "safe", "hidden")

/datum/areatool/New(user, area/target)

	if (istype(user, /mob))
		src.user = user
	else
		var/client/C = user
		if (!C.mob)
			CRASH("Area tool attempted to open to a client without a mob")
		src.user = C.mob
	if(!isarea(target))
		var/area/userarea = get_area(user)
		if (userarea)
			src.target = userarea
	else
		src.target = target

/datum/areatool/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "areatool", "Area Tool", 700, 700, master_ui, state)
		ui.open()

/datum/areatool/ui_data(mob/user)
	. = list()
	.["area"] = list(
		"ref" = REF(target),
		"name" = "[target]",
		"type" = "[target.type]"
	)
	.["booleans"] = list()
	for (var/setting in areabooleans)
		.["booleans"] += list(list("name" = setting, "setting" = target.vars[setting]))


/datum/areatool/ui_act(action, params)
	if(..())
		return
	switch (action)
		if ("toggle_boolean")
			var/boolean = params["setting"]
			if (boolean in areabooleans)
				target.vars[boolean] = !target.vars[boolean]
		if ("init_skipover")
			var/leavepath = text2path(params["leavepath"])
			for (var/turf/T in target)
				if (!islist(T.baseturfs))
					T.baseturfs = list(T.baseturfs)
				var/current = T.baseturfs.Find(/turf/baseturf_skipover/shuttle)
				if (current)
					T.baseturfs.Cut(current, current+1)
				var/spess = T.baseturfs.Find(/turf/open/space)
				if (leavepath == /turf/open/space)
					T.baseturfs.Insert(spess, /turf/baseturf_skipover/shuttle)
				else
					T.baseturfs.Insert(spess, /turf/baseturf_skipover/shuttle, leavepath)
		if ("spawn_ports")
			var/loc = get_turf(user)
			warning("spawning docking ports under [user] in [loc]")
			var/obj/docking_port/mobile/mobileport = new(loc)
			mobileport.id = "areatoolshuttle"
			SSshuttle.mobile |= mobileport
			mobileport.area_type = target.type
			mobileport.shuttle_areas += target
			new /obj/docking_port/stationary(loc)
		if ("spawn_shuttleconsole")
			var/loc = get_turf(user)
			warning("spawning shuttle console under [user] in [loc]")
			var/obj/machinery/computer/shuttle/shuttlecontrol = new(loc)
			var/obj/docking_port/mobile/mobile = locate(/obj/docking_port/mobile) in target
			if (mobile)
				shuttlecontrol.shuttleId = mobile.id
			else
				shuttlecontrol.shuttleId = "areatoolshuttle"
			var/list/possible = list()
			var/obj/machinery/computer/camera_advanced/shuttle_docker/docker = locate(/obj/machinery/computer/camera_advanced/shuttle_docker) in target
			if (docker)
				possible += docker.shuttlePortId
			var/obj/docking_port/stationary/stationary = locate(/obj/docking_port/stationary) in target
			if (stationary)
				possible += stationary.id
			shuttlecontrol.possible_destinations = possible.Join(";")
		if ("spawn_navcomputer")
			var/loc = get_turf(user)
			warning("spawning nav computer under [user] in [loc]")
			var/obj/machinery/computer/camera_advanced/shuttle_docker/docker = new(loc)
			var/obj/docking_port/mobile/mobile = locate(/obj/docking_port/mobile) in target
			if (mobile)
				docker.shuttleId = mobile.id
			else
				docker.shuttleId = "areatoolshuttle"
			docker.shuttlePortName = "Special Location"
			docker.shuttlePortId = "areatoolnav"
		if ("rename")
			var/new_name = stripped_input(user,"What would you like to rename this area to?","Input a name",target.name,MAX_NAME_LEN)
			if(!new_name)
				return
			message_admins("[key_name_admin(user)] renamed [ADMIN_LOOKUPFLW(target)] to [new_name].")
			log_admin("[key_name(user)] renamed [key_name(target)] to [new_name].")
			target.name = new_name

	. = TRUE
