/obj/machinery/computer/teleporter
	name = "teleporter control console"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	light_color = LIGHT_COLOR_BLUE
	circuit = /obj/item/circuitboard/computer/teleporter
	var/obj/item/gps/locked
	var/regime_set = "Teleporter"
	var/id
	var/obj/machinery/teleport/station/power_station
	var/calibrating
	var/turf/target //Used for one-time-use teleport cards (such as clown planet coordinates.)
					//Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.

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
			break
	return power_station

/obj/machinery/computer/teleporter/attackby(obj/I, mob/living/user, params)
	if(istype(I, /obj/item/gps))
		var/obj/item/gps/L = I
		if(L.locked_location && !(stat & (NOPOWER|BROKEN)))
			if(!user.transferItemToLoc(L, src))
				to_chat(user, "<span class='warning'>\the [I] is stuck to your hand, you cannot put it in \the [src]!</span>")
				return
			locked = L
			to_chat(user, "<span class='caution'>You insert the GPS device into the [name]'s slot.</span>")
	else
		return ..()

/obj/machinery/computer/teleporter/ui_interact(mob/user)
	. = ..()
	var/data = "<h3>Teleporter Status</h3>"
	if(!power_station)
		data += "<div class='statusDisplay'>No power station linked.</div>"
	else if(!power_station.teleporter_hub)
		data += "<div class='statusDisplay'>No hub linked.</div>"
	else
		data += "<div class='statusDisplay'>Current regime: [regime_set]<BR>"
		data += "Current target: [(!target) ? "None" : "[get_area(target)] [(regime_set != "Gate") ? "" : "Teleporter"]"]<BR>"
		if(calibrating)
			data += "Calibration: <font color='yellow'>In Progress</font>"
		else if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accurate >= 3)
			data += "Calibration: <font color='green'>Optimal</font>"
		else
			data += "Calibration: <font color='red'>Sub-Optimal</font>"
		data += "</div><BR>"

		data += "<A href='?src=[REF(src)];regimeset=1'>Change regime</A><BR>"
		data += "<A href='?src=[REF(src)];settarget=1'>Set target</A><BR>"
		if(locked)
			data += "<BR><A href='?src=[REF(src)];locked=1'>Get target from memory</A><BR>"
			data += "<A href='?src=[REF(src)];eject=1'>Eject GPS device</A><BR>"
		else
			data += "<BR><span class='linkOff'>Get target from memory</span><BR>"
			data += "<span class='linkOff'>Eject GPS device</span><BR>"

		data += "<BR><A href='?src=[REF(src)];calibrate=1'>Calibrate Hub</A>"

	var/datum/browser/popup = new(user, "teleporter", name, 400, 400)
	popup.set_content(data)
	popup.open()

/obj/machinery/computer/teleporter/Topic(href, href_list)
	if(..())
		return

	if(href_list["eject"])
		eject()
		updateDialog()
		return

	if(!check_hub_connection())
		say("Error: Unable to detect hub.")
		return
	if(calibrating)
		say("Error: Calibration in progress. Stand by.")
		return

	if(href_list["regimeset"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		reset_regime()
	if(href_list["settarget"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		set_target(usr)
	if(href_list["locked"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		target = get_turf(locked.locked_location)
	if(href_list["calibrate"])
		if(!target)
			say("Error: No target set to calibrate to.")
			return
		if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accurate >= 3)
			say("Hub is already calibrated!")
			return
		say("Processing hub calibration to target...")

		calibrating = 1
		spawn(50 * (3 - power_station.teleporter_hub.accurate)) //Better parts mean faster calibration
			calibrating = 0
			if(check_hub_connection())
				power_station.teleporter_hub.calibrated = 1
				say("Calibration complete.")
			else
				say("Error: Unable to detect hub.")
			updateDialog()

	updateDialog()

/obj/machinery/computer/teleporter/proc/check_hub_connection()
	if(!power_station)
		return FALSE
	if(!power_station.teleporter_hub)
		return FALSE
	return TRUE

/obj/machinery/computer/teleporter/proc/reset_regime()
	target = null
	if(regime_set == "Teleporter")
		regime_set = "Gate"
	else
		regime_set = "Teleporter"

/obj/machinery/computer/teleporter/proc/eject()
	if(locked)
		locked.forceMove(get_turf(src))
		locked = null

/obj/machinery/computer/teleporter/proc/set_target(mob/user)
	var/list/L = list()
	var/list/areaindex = list()
	if(regime_set == "Teleporter")
		for(var/obj/item/beacon/R in GLOB.teleportbeacons)
			if(is_eligible(R))
				var/area/A = get_area(R)
				L[avoid_assoc_duplicate_keys(A.name, areaindex)] = R

		for(var/obj/item/implant/tracking/I in GLOB.tracked_implants)
			if(!I.imp_in || !isliving(I.loc))
				continue
			else
				var/mob/living/M = I.loc
				if(M.stat == DEAD)
					if(M.timeofdeath + 6000 < world.time)
						continue
				if(is_eligible(I))
					L[avoid_assoc_duplicate_keys(M.real_name, areaindex)] = I

		var/desc = input("Please select a location to lock in.", "Locking Computer") as null|anything in L
		target = L[desc]
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
		var/desc = input("Please select a station to lock in.", "Locking Computer") as null|anything in L
		var/obj/machinery/teleport/station/target_station = L[desc]
		if(!target_station || !target_station.teleporter_hub)
			return
		var/turf/T = get_turf(target_station)
		log_game("[key_name(user)] has set the teleporter target to [target_station] at [AREACOORD(T)]")
		target = target_station.teleporter_hub
		target_station.linked_stations |= power_station
		target_station.stat &= ~NOPOWER
		if(target_station.teleporter_hub)
			target_station.teleporter_hub.stat &= ~NOPOWER
			target_station.teleporter_hub.update_icon()
		if(target_station.teleporter_console)
			target_station.teleporter_console.stat &= ~NOPOWER
			target_station.teleporter_console.update_icon()

/obj/machinery/computer/teleporter/proc/is_eligible(atom/movable/AM)
	var/turf/T = get_turf(AM)
	if(!T)
		return FALSE
	if(is_centcom_level(T.z) || is_away_level(T.z))
		return FALSE
	var/area/A = get_area(T)
	if(!A || A.noteleport)
		return FALSE
	return TRUE
