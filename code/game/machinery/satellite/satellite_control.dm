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

/obj/machinery/computer/sat_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			toggle(text2num(params["id"]))
			. = TRUE

/obj/machinery/computer/sat_control/proc/toggle(toggled_id)
	var/turf/current_turf = get_turf(src)
	for(var/obj/machinery/satellite/satellite as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/satellite))
		if(satellite.id != toggled_id)
			continue
		if(satellite.obj_flags & EMAGGED)
			to_chat(usr, span_warning("The satellite doesn't seem to respond...?"))
			return
		if(is_valid_z_level(get_turf(satellite), current_turf))
			satellite.toggle()

/obj/machinery/computer/sat_control/ui_data()
	var/list/data = list()

	data["satellites"] = list()
	for(var/obj/machinery/satellite/sat as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/satellite))
		data["satellites"] += list(list(
			"id" = sat.id,
			"active" = sat.active,
			"mode" = sat.mode
		))
	data["notice"] = notice

	var/datum/station_goal/station_shield/goal = SSstation.get_station_goal(/datum/station_goal/station_shield)
	if(!isnull(goal))
		data["meteor_shield"] = TRUE
		data["meteor_shield_coverage"] = goal.get_coverage()
		data["meteor_shield_coverage_max"] = goal.coverage_goal
	return data
