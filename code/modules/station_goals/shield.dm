//Station Shield
// A chain of satellites encircles the station
// Satellites be actived to generate a shield that will block unorganic matter from passing it.
/datum/station_goal/station_shield
	name = "Station Shield"
	var/coverage_goal = 500

/datum/station_goal/station_shield/get_report()
	return {"The station is located in a zone full of space debris.
			 We have a prototype shielding system you must deploy to reduce collision-related accidents.

			 You can order the satellites and control systems at cargo.
			 "}


/datum/station_goal/station_shield/on_report()
	//Unlock
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/misc/shield_sat]
	P.special_enabled = TRUE

	P = SSshuttle.supply_packs[/datum/supply_pack/misc/shield_sat_control]
	P.special_enabled = TRUE

/datum/station_goal/station_shield/check_completion()
	if(..())
		return TRUE
	if(get_coverage() >= coverage_goal)
		return TRUE
	return FALSE

/datum/station_goal/proc/get_coverage()
	var/list/coverage = list()
	for(var/obj/machinery/satellite/meteor_shield/A in machines)
		if(!A.active || A.z != ZLEVEL_STATION)
			continue
		coverage |= view(A.kill_range,A)
	return coverage.len

/obj/item/weapon/circuitboard/machine/computer/sat_control
	name = "Satellite Network Control (Computer Board)"
	build_path = /obj/machinery/computer/sat_control
	origin_tech = "engineering=3"

/obj/machinery/computer/sat_control
	name = "Satellite control"
	desc = "Used to control the satellite network."
	circuit = /obj/item/weapon/circuitboard/machine/computer/sat_control
	var/notice

/obj/machinery/computer/sat_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "sat_control", name, 400, 305, master_ui, state)
		ui.open()

/obj/machinery/computer/sat_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle")
			toggle(text2num(params["id"]))
			. = TRUE

/obj/machinery/computer/sat_control/proc/toggle(id)
	for(var/obj/machinery/satellite/S in machines)
		if(S.id == id && S.z == z)
			S.toggle()

/obj/machinery/computer/sat_control/ui_data()
	var/list/data = list()

	data["satellites"] = list()
	for(var/obj/machinery/satellite/S in machines)
		data["satellites"] += list(list(
			"id" = S.id,
			"active" = S.active,
			"mode" = S.mode
		))
	data["notice"] = notice


	var/datum/station_goal/station_shield/G = locate() in ticker.mode.station_goals
	if(G)
		data["meteor_shield"] = 1
		data["meteor_shield_coverage"] = G.get_coverage()
		data["meteor_shield_coverage_max"] = G.coverage_goal
	return data


/obj/machinery/satellite
	name = "Defunct Satellite"
	desc = ""
	icon = 'icons/obj/machines/satellite.dmi'
	icon_state = "sat_inactive"
	var/mode = "NTPROBEV0.8"
	var/active = FALSE
	density = 1
	use_power = FALSE
	var/static/gid = 0
	var/id = 0

/obj/machinery/satellite/New()
	..()
	id = gid++

/obj/machinery/satellite/interact(mob/user)
	toggle(user)

/obj/machinery/satellite/proc/toggle(mob/user)
	if(!active && !isinspace())
		if(user)
			to_chat(user, "<span class='warning'>You can only active the [src] in space.</span>")
		return FALSE
	if(user)
		to_chat(user, "<span class='notice'>You [active ? "deactivate": "activate"] the [src]</span>")
	active = !active
	if(active)
		animate(src, pixel_y = 2, time = 10, loop = -1)
		anchored = 1
	else
		animate(src, pixel_y = 0, time = 10)
		anchored = 0
	update_icon()

/obj/machinery/satellite/update_icon()
	icon_state = active ? "sat_active" : "sat_inactive"

/obj/machinery/satellite/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/multitool))
		to_chat(user, "<span class='notice'>// NTSAT-[id] // Mode : [active ? "PRIMARY" : "STANDBY"] //[emagged ? "DEBUG_MODE //" : ""]</span>")
	else
		return ..()

/obj/machinery/satellite/meteor_shield
	name = "Meteor Shield Satellite"
	desc = "Meteor Point Defense Satellite"
	mode = "M-SHIELD"
	speed_process = TRUE
	var/kill_range = 14

/obj/machinery/satellite/meteor_shield/proc/space_los(meteor)
	for(var/turf/T in getline(src,meteor))
		if(!isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/satellite/meteor_shield/process()
	if(!active)
		return
	for(var/obj/effect/meteor/M in meteor_list)
		if(M.z != z)
			continue
		if(get_dist(M,src) > kill_range)
			continue
		if(!emagged && space_los(M))
			Beam(get_turf(M),icon_state="sat_beam",time=5,maxdistance=kill_range)
			qdel(M)

/obj/machinery/satellite/meteor_shield/toggle(user)
	if(!..(user))
		return FALSE
	if(emagged)
		if(active)
			change_meteor_chance(2)
		else
			change_meteor_chance(0.5)

/obj/machinery/satellite/meteor_shield/proc/change_meteor_chance(mod)
	var/datum/round_event_control/E = locate(/datum/round_event_control/meteor_wave) in SSevent.control
	if(E)
		E.weight *= mod

/obj/machinery/satellite/meteor_shield/Destroy()
	. = ..()
	if(active && emagged)
		change_meteor_chance(0.5)

/obj/machinery/satellite/meteor_shield/emag_act()
	if(!emagged)
		emagged = 1
		if(active)
			change_meteor_chance(2)
