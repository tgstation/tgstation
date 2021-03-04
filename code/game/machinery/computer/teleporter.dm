/obj/machinery/computer/teleporter
	name = "teleporter control console"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	light_color = LIGHT_COLOR_BLUE
	circuit = /obj/item/circuitboard/computer/teleporter

	var/regime_set = "Teleporter"
	var/id
	var/obj/machinery/teleport/station/power_station
	var/calibrating
	var/turf/target

/obj/machinery/computer/teleporter/Initialize()
	. = ..()
	id = "[rand(1000, 9999)]"
	link_power_station()

/obj/machinery/computer/teleporter/Destroy()
	if (power_station)
		power_station.teleporter_console = null
		power_station = null
	return ..()

/obj/machinery/computer/teleporter/proc/link_power_station()
	if(power_station)
		return
	for(var/direction in GLOB.cardinals)
		power_station = locate(/obj/machinery/teleport/station, get_step(src, direction))
		if(power_station)
			power_station.link_console_and_hub()
			break
	return power_station

/obj/machinery/computer/teleporter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Teleporter", name)
		ui.open()

/obj/machinery/computer/teleporter/ui_data(mob/user)
	var/list/data = list()
	data["power_station"] = power_station ? TRUE : FALSE
	data["teleporter_hub"] = power_station?.teleporter_hub ? TRUE : FALSE
	data["regime_set"] = regime_set
	data["target"] = !target ? "None" : "[get_area(target)] [(regime_set != "Gate") ? "" : "Teleporter"]"
	data["calibrating"] = calibrating

	if(power_station?.teleporter_hub?.calibrated || power_station?.teleporter_hub?.accuracy >= 3)
		data["calibrated"] = TRUE
	else
		data["calibrated"] = FALSE

	return data

/obj/machinery/computer/teleporter/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(!check_hub_connection())
		say("Error: Unable to detect hub.")
		return
	if(calibrating)
		say("Error: Calibration in progress. Stand by.")
		return

	switch(action)
		if("regimeset")
			power_station.engaged = FALSE
			power_station.teleporter_hub.update_appearance()
			power_station.teleporter_hub.calibrated = FALSE
			reset_regime()
			. = TRUE
		if("settarget")
			power_station.engaged = FALSE
			power_station.teleporter_hub.update_appearance()
			power_station.teleporter_hub.calibrated = FALSE
			set_target(usr)
			. = TRUE
		if("calibrate")
			if(!target)
				say("Error: No target set to calibrate to.")
				return
			if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accuracy >= 3)
				say("Hub is already calibrated!")
				return

			say("Processing hub calibration to target...")
			calibrating = TRUE
			power_station.update_appearance()
			addtimer(CALLBACK(src, .proc/finish_calibration), 50 * (3 - power_station.teleporter_hub.accuracy)) //Better parts mean faster calibration
			. = TRUE

/obj/machinery/computer/teleporter/proc/set_teleport_target(new_target)
	if (target == new_target)
		return
	SEND_SIGNAL(src, COMSIG_TELEPORTER_NEW_TARGET, new_target)
	target = new_target

/obj/machinery/computer/teleporter/proc/finish_calibration()
	calibrating = FALSE
	if(check_hub_connection())
		power_station.teleporter_hub.calibrated = TRUE
		say("Calibration complete.")
	else
		say("Error: Unable to detect hub.")
	power_station.update_appearance()

/obj/machinery/computer/teleporter/proc/check_hub_connection()
	if(!power_station)
		return FALSE
	if(!power_station.teleporter_hub)
		return FALSE
	return TRUE

/obj/machinery/computer/teleporter/proc/reset_regime()
	set_teleport_target(null)
	if(regime_set == "Teleporter")
		regime_set = "Gate"
	else
		regime_set = "Teleporter"

/obj/machinery/computer/teleporter/proc/set_target(mob/user)
	var/list/L = list()
	var/list/areaindex = list()
	if(regime_set == "Teleporter")
		for(var/obj/item/beacon/R in GLOB.teleportbeacons)
			if(is_eligible(R))
				if(R.renamed)
					L[avoid_assoc_duplicate_keys("[R.name] ([get_area(R)])", areaindex)] = R
				else
					var/area/A = get_area(R)
					L[avoid_assoc_duplicate_keys(A.name, areaindex)] = R

		for(var/obj/item/implant/tracking/I in GLOB.tracked_implants)
			if(!I.imp_in || !isliving(I.loc) || !I.allow_teleport)
				continue
			else
				var/mob/living/M = I.loc
				if(M.stat == DEAD)
					if(M.timeofdeath + I.lifespan_postmortem < world.time)
						continue
				if(is_eligible(I))
					L[avoid_assoc_duplicate_keys("[M.real_name] ([get_area(M)])", areaindex)] = I

		var/desc = input("Please select a location to lock in.", "Locking Computer") as null|anything in sortList(L)
		set_teleport_target(L[desc])
		var/turf/T = get_turf(target)
		log_game("[key_name(user)] has set the teleporter target to [target] at [AREACOORD(T)]")

	else
		var/list/S = power_station.linked_stations
		for(var/obj/machinery/teleport/station/R in S)
			if(is_eligible(R) && R.teleporter_hub)
				var/area/A = get_area(R)
				L[avoid_assoc_duplicate_keys(A.name, areaindex)] = R
		if(!L.len)
			to_chat(user, "<span class='alert'>No active connected stations located.</span>")
			return
		var/desc = input("Please select a station to lock in.", "Locking Computer") as null|anything in sortList(L)
		var/obj/machinery/teleport/station/target_station = L[desc]
		if(!target_station || !target_station.teleporter_hub)
			return
		var/turf/T = get_turf(target_station)
		log_game("[key_name(user)] has set the teleporter target to [target_station] at [AREACOORD(T)]")
		set_teleport_target(target_station.teleporter_hub)
		target_station.linked_stations |= power_station
		target_station.set_machine_stat(target_station.machine_stat & ~NOPOWER)
		if(target_station.teleporter_hub)
			target_station.teleporter_hub.set_machine_stat(target_station.teleporter_hub.machine_stat & ~NOPOWER)
			target_station.teleporter_hub.update_appearance()
		if(target_station.teleporter_console)
			target_station.teleporter_console.set_machine_stat(target_station.teleporter_console.machine_stat & ~NOPOWER)
			target_station.teleporter_console.update_appearance()

/obj/machinery/computer/teleporter/proc/is_eligible(atom/movable/AM)
	var/turf/T = get_turf(AM)
	if(!T)
		return FALSE
	if(is_centcom_level(T.z) || is_away_level(T.z))
		return FALSE
	var/area/A = get_area(T)
	if(!A ||(A.area_flags & NOTELEPORT))
		return FALSE
	return TRUE
