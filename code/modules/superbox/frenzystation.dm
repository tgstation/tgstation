// Code for the very-low-pop FrenzyStation map

/obj/effect/mapping_helpers
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "syndballoon"
	layer = POINT_LAYER

// ----------------------------------------------------------------------------
// Helper which marks the entire station as parallax in the given dir
/obj/effect/mapping_helpers/station_parallax
	name = "station parallax"
	dir = 1

/obj/effect/mapping_helpers/station_parallax/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/mapping_helpers/station_parallax/LateInitialize()
	var/turf/loc = get_turf(src)
	var/z = loc.z

	for (var/area/A in GLOB.sortedAreas)
		if (A.type == /area/space) // but nearstation is fine
			continue

		var/on_station = FALSE
		var/not_on_station = FALSE
		for (var/turf/T in A)
			if (T.z == z)
				on_station = TRUE
			else
				not_on_station = TRUE

		if (on_station == not_on_station)
			message_admins("[A] ([A.type]), on_station=[on_station], not_on_station=[not_on_station]")
		if (on_station)
			A.parallax_movedir = dir

	qdel(src)

// ----------------------------------------------------------------------------
// Cryo cell which also acts as arrivals
/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin
	var/occupant_is_latejoiner = FALSE

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/Initialize()
	. = ..()
	SSjob.latejoin_trackers += src

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/Destroy()
	..()
	SSjob.latejoin_trackers -= src

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/open_machine()
	occupant_is_latejoiner = FALSE
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/process()
	if (occupant_is_latejoiner)
		return 1  // they'll be ejected by the timer, appear on until then
	else
		return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/proc/emplace(mob/living/target)
	if (occupant && !awaken(occupant) && !istype(target))
		return FALSE

	occupant_is_latejoiner = TRUE
	state_open = TRUE
	panel_open = FALSE
	on = TRUE
	close_machine(target)
	addtimer(CALLBACK(src, .proc/awaken, target), 10 SECONDS)
	return TRUE

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/proc/awaken(mob/living/target)
	if (occupant != target || !occupant_is_latejoiner)
		return FALSE

	var/turf/T = get_turf(src)
	playsound(T, 'sound/machines/cryo_warning.ogg', volume)
	open_machine()
	target.Knockdown(10)
	return TRUE

/datum/controller/subsystem/job/SendToAtom(mob/M, atom/A, buckle)
	var/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/C = A
	if (!istype(C) || !C.emplace(M))
		..()

// ----------------------------------------------------------------------------
// Cargo computer which uses a nearby teleporter instead of a shuttle
/obj/machinery/computer/cargo/frenzy
	desc = "Used to order supplies, approve requests, and control the teleporter."
	var/obj/item/device/radio/beacon/current_beacon = null
	var/list/queued_crates = null

/obj/machinery/computer/cargo/frenzy/ui_data()
	. = ..()
	.["loan"] = FALSE

	if (!findBeacon())
		.["docked"] = FALSE
		.["location"] = "Beacon missing"
	else if (queued_crates && queued_crates.len)
		.["docked"] = FALSE
		.["location"] = "Shipment in progress"
	else
		.["docked"] = TRUE
		.["location"] = "Ready for shipment"

/obj/machinery/computer/cargo/frenzy/ui_act(action, params, datum/tgui/ui)
	// can't loan out the shuttle
	if (action == "loan")
		return TRUE

	// all other actions are the same
	if (action != "send")
		return ..()

	// sending the shuttle insta-sells, insta-buys, and begins queueing delivery
	var/obj/item/device/radio/beacon/B = findBeacon()
	if (!B)
		return TRUE

	SSshuttle.supply.sell()
	var/list/before = everything()
	SSshuttle.supply.buy()
	queued_crates = everything()
	queued_crates -= before
	addtimer(CALLBACK(src, .proc/deliver), 3 SECONDS)
	return TRUE

/obj/machinery/computer/cargo/frenzy/proc/findBeacon()
	var/area/me = get_area(src)
	if (!current_beacon || get_area(current_beacon) != me)
		current_beacon = null
		for (var/obj/item/device/radio/beacon/B in GLOB.teleportbeacons)
			if (get_area(B) == me)
				current_beacon = B
				break
	return current_beacon

/obj/machinery/computer/cargo/frenzy/proc/everything()
	var/list/result = list()
	for (var/_A in SSshuttle.supply.shuttle_areas)
		var/area/shuttle/A = _A
		for (var/turf/open/floor/T in A)
			for(var/atom/movable/AM in T) // only top-level contents
				result += AM
	return result

/obj/machinery/computer/cargo/frenzy/proc/deliver()
	if (queued_crates && queued_crates.len)
		var/atom/movable/top = queued_crates[1]
		if (deliverOne(top))
			queued_crates -= top
		if (queued_crates.len)
			addtimer(CALLBACK(src, .proc/deliver), 1 SECONDS)
		else
			say("Shipment complete.")
			queued_crates = null
	else
		queued_crates = null

/obj/machinery/computer/cargo/frenzy/proc/deliverOne(atom/movable/it)
	if (it.anchored)
		if (it.can_be_unanchored)
			it.anchored = FALSE
		else
			return TRUE // probably like a decal or something, ignore it

	var/obj/item/device/radio/beacon/B = findBeacon()
	if (!B)
		return FALSE // failure! try again soon
	var/turf/T = get_turf(B)
	if(!T || !(T.z in GLOB.station_z_levels))
		return FALSE
	if (is_blocked_turf(T))
		return FALSE // blocked, try again soon

	return do_teleport(it, T)

// ----------------------------------------------------------------------------
// Teleporter computer which allows export to the cargo shuttle
GLOBAL_VAR(frenzy_exports)

/obj/effect/landmark/frenzy_exports
	name = "Frenzy export teleporter marker"

/obj/effect/landmark/frenzy_exports/Initialize()
	. = ..()
	GLOB.frenzy_exports = src

/obj/effect/landmark/frenzy_exports/Destroy()
	if (GLOB.frenzy_exports == src)
		GLOB.frenzy_exports = null
	..()

/obj/machinery/computer/teleporter/proc/can_teleport(atom/movable/AM)
	return TRUE

/obj/machinery/computer/teleporter/frenzy
	var/is_export_locked = FALSE
	var/complain_timer = 0

/obj/machinery/computer/teleporter/frenzy/can_teleport(atom/movable/AM)
	if (!is_export_locked)
		return ..()
	for (var/a in AM.GetAllContents())
		if (is_type_in_typecache(a, GLOB.blacklisted_cargo_types))
			if (complain_timer + 10 SECONDS < world.time)
				complain_timer = world.time
				say("For safety reasons, the export teleporter cannot transport live organisms, classified nuclear weaponry or homing beacons.")
			return FALSE
	return TRUE

/obj/machinery/computer/teleporter/frenzy/set_target(mob/user)
	var/list/L = list()
	var/list/areaindex = list()
	if(regime_set != "Teleporter")
		return ..()

	// Copypaste from parent
	for(var/obj/item/device/radio/beacon/R in GLOB.teleportbeacons)
		var/turf/T = get_turf(R)
		if(!T)
			continue
		if(T.z == ZLEVEL_CENTCOM || T.z > ZLEVEL_SPACEMAX)
			continue
		L[avoid_assoc_duplicate_keys(T.loc.name, areaindex)] = R

	for(var/obj/item/implant/tracking/I in GLOB.tracked_implants)
		if(!I.imp_in || !ismob(I.loc))
			continue
		else
			var/mob/M = I.loc
			if(M.stat == DEAD)
				if(M.timeofdeath + 6000 < world.time)
					continue
			var/turf/T = get_turf(M)
			if(!T)
				continue
			if(T.z == ZLEVEL_CENTCOM)
				continue
			L[avoid_assoc_duplicate_keys(M.real_name, areaindex)] = I

	if (GLOB.frenzy_exports)
		L["Supply Shuttle"] = GLOB.frenzy_exports

	var/desc = input("Please select a location to lock in.", "Locking Computer") as null|anything in L
	target = L[desc]
	is_export_locked = (desc == "Supply Shuttle")

// DRAGnet shall flatly deny Cargo exports
/obj/effect/nettingportal/pop(teletarget)
	if (istype(teletarget, /obj/effect/landmark/frenzy_exports))
		teletarget = null
	return ..(teletarget)

// Hand tele and the hub itself use the Cargo blacklist
/obj/machinery/teleport/hub/CollidedWith(atom/movable/AM)
	var/obj/machinery/computer/teleporter/com = power_station.teleporter_console
	if (is_ready() && com.can_teleport(AM))
		return ..()
