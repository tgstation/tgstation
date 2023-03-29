/obj/machinery/computer/sat_control
	name = "satellite control"
	desc = "Used to control the satellite network."
	circuit = /obj/item/circuitboard/computer/sat_control
	var/notice

/obj/machinery/computer/sat_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SatelliteControl", name)
		ui.open()

/obj/machinery/computer/sat_control/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			toggle(text2num(params["id"]))
			. = TRUE

/obj/machinery/computer/sat_control/proc/toggle(toggled_id)
	var/turf/current_turf = get_turf(src)
	for(var/obj/machinery/satellite/satellite in GLOB.machines)
		if(satellite.id == toggled_id && is_valid_z_level(get_turf(satellite), current_turf))
			satellite.toggle()

/obj/machinery/computer/sat_control/ui_data()
	var/list/data = list()

	data["satellites"] = list()
	for(var/obj/machinery/satellite/S in GLOB.machines)
		data["satellites"] += list(list(
			"id" = S.id,
			"active" = S.active,
			"mode" = S.mode
		))
	data["notice"] = notice


	var/datum/station_goal/station_shield/G = locate() in GLOB.station_goals
	if(G)
		data["meteor_shield"] = 1
		data["meteor_shield_coverage"] = G.get_coverage()
		data["meteor_shield_coverage_max"] = G.coverage_goal
	return data
