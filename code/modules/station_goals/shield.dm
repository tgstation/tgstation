//Station Shield
// A chain of satellites encircles the station
// Satellites be actived to generate a shield that will block unorganic matter from passing it.
/datum/station_goal/station_shield
	name = "Station Shield"

/datum/station_goal/station_shield/get_report()
	return {"The station is located in a zone full of space debris.
			 We have a prototype shielding system you will deploy to reduce collision related accidents.

			 You can order the satellites and control systems through cargo shuttle.
			 "}


/datum/station_goal/station_shield/on_report()
	//Unlock 
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/misc/shield_sat]
	P.special_enabled = TRUE

	P = SSshuttle.supply_packs[/datum/supply_pack/misc/shield_sat_control]
	P.special_enabled = TRUE

/datum/station_goal/station_shield/check_completion()
	var/list/x_coords = list()
	var/list/y_coords = list()
	var/list/obj/machinery/shield_sat/sats = list()
	for(var/obj/machinery/shield_sat/S in machines)
		if(S.z == ZLEVEL_STATION)
			if(!S.shields.len)
				return FALSE
			sats += S
	sortTim(sats,/proc/cmp_coords_ccw)
	var/obj/machinery/shield_sat/F = sats[1]
	for(var/V in 1 to sats.len)
		x_coords += F.x
		y_coords += F.y
		F = F.next
	var/area_v = 0
	var/j = sats.len
	for(var/i in 1 to sats.len)
		area_v += (x_coords[i]+x_coords[j]) * (y_coords[j]-y_coords[i])
		j = i
	area_v /= 2
	if(area_v < world.maxx * world.maxy * 0.5) //change this to use station_state %
		return TRUE
	return FALSE


/obj/effect/meteor_shield
	desc = "Shield that blocks all unorganic matter from passing through."
	name = "Meteor Shield"
	icon_state = "shield-red"
	anchored = 1
	opacity = 0
	density = 1
	unacidable = 1

/obj/effect/meteor_shield/CanPass(atom/mover)
	if(!isliving(mover))
		return ..()
	return TRUE

/obj/effect/meteor_shield/ex_act(power)
	return


/obj/machinery/shield_sat
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	name = "Shield Satelitte"
	desc = "Eat this space rocks."
	var/sat_range = 14
	var/obj/machinery/shield_sat/next
	var/obj/machinery/shield_sat/prev
	var/list/shields = list()
	var/static/id = 0 //So linking these is bit less of a pain.
	density = 1

/obj/machinery/shield_sat/New()
	..()
	id++
	name = "[initial(name)] [id]"

//link manually
/obj/machinery/shield_sat/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		if(shields.len)
			user << "<span class='warning'>Satellite needs to be offline before modyfing it's parameters.</span>"
			return
		var/obj/item/device/multitool/M = W
		if(M.buffer)
			if(prev)
				user << "<span class='warning'>[src] is already linked with [prev]!</span>"
				return
			if(istype(M.buffer,/obj/machinery/shield_sat))
				var/obj/machinery/shield_sat/source = M.buffer
				if(source == src)
					user << "<span class='warning'>ERROR: Invalid link detected. Multitool buffer flushed.</span>"
					M.buffer = null
					return
				if(source.shields.len)
					user << "<span class='warning'>[source] needs to be offline before you can link it with another.</span>"
					return
				if(source.next)
					user << "<span class='notice'>You unlink [source] from [source.next]</span>"
					var/obj/machinery/shield_sat/S = source.next
					S.prev = null
					source.next = null
				prev = source
				source.next = src
				user << "<span class='notice'>You link [source] with [src].</span>"
				M.buffer = null
		else
			user << "<span class='notice'>You store [src] identifier in \the [M]</span>"
			M.buffer = src
	else
		..()

/obj/machinery/shield_sat/proc/unlink()
	if(prev)
		prev.deactivate_shields()
		prev.next = null
		prev = null
	if(next)
		deactivate_shields()
		next.prev = null



/obj/machinery/shield_sat/proc/deactivate_shields()
	for(var/obj/effect/meteor_shield/M in shields)
		qdel(M)

/obj/machinery/shield_sat/proc/space_los(atom/A,atom/B)
	for(var/turf/T in getline(A,B))
		if(!istype(T, /turf/open/space))
			return FALSE
	return TRUE

/proc/cmp_coords_ccw(atom/A,atom/B)
	if(A.x == B.x)
		return B.y - A.y
	else
		return A.x - B.x

/obj/machinery/shield_sat/proc/activate()
	if(!next || next.prev != src)
		return FALSE
	if(get_dist(src,next) > sat_range)
		return FALSE
	if(!space_los(src,next))
		return FALSE
	for(var/turf/T in getline(get_step_towards(src,next),get_step_towards(next,src)))
		shields += new /obj/effect/meteor_shield(T)
	return TRUE


/obj/item/weapon/circuitboard/machine/computer/shield_control
	name = "circuit board (Shield Satellite Network Control)"
	build_path = /obj/machinery/computer/shield_sat_control
	origin_tech = "engineering=3"

/obj/machinery/computer/shield_sat_control
	name = "Shield Satellite control"
	desc = "Used to control the shield satellite network."
	circuit = /obj/item/weapon/circuitboard/machine/computer/shield_control
	var/notice

/obj/machinery/computer/shield_sat_control/proc/sat_number()
	. = 0
	for(var/obj/machinery/shield_sat/S in machines)
		if(S.z == z)
			.++

/obj/machinery/computer/shield_sat_control/proc/sats_active()
	for(var/obj/machinery/shield_sat/S in machines)
		if(S.z == z)
			if(S.shields.len)
				return TRUE
			else
				return FALSE
	return FALSE

/obj/machinery/computer/shield_sat_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "shield_sat", name, 400, 305, master_ui, state)
		ui.open()

/obj/machinery/computer/shield_sat_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("activate")
			activate()
			. = TRUE
		if("deactivate")
			deactivate()
			. = TRUE

/obj/machinery/computer/shield_sat_control/ui_data()
	var/list/data = list()
	data["sats"] = sat_number()
	data["active"] = sats_active()
	data["notice"] = notice
	return data


/obj/machinery/computer/shield_sat_control/proc/activate()
	var/list/sats = list()
	for(var/obj/machinery/shield_sat/S in machines)
		if(S.z != z)
			continue
		//stat check
		sats += S
	sortTim(sats,/proc/cmp_coords_ccw)
	if(!sats.len || sats.len < 3)
		notice = "Satellites not detected."
		return FALSE 
	var/obj/machinery/shield_sat/S = sats[1]
	for(var/V in 1 to sats.len)
		if(!S.activate())
			notice = "Network activation failed."
			deactivate()
			return FALSE
		S = S.next
	notice = "Network activation sucessful!"

/obj/machinery/computer/shield_sat_control/proc/deactivate()
	for(var/obj/machinery/shield_sat/S in machines)
		if(S.z != z)
			continue
		S.deactivate_shields()