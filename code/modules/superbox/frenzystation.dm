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

		if (on_station && !not_on_station)
			A.parallax_movedir = dir

	qdel(src)

// ----------------------------------------------------------------------------
// Cryo cell which also acts as arrivals
/obj/machinery/latejoin_cryo
	name = "cryostasis pod"
	desc = "A special deep-sleep pod for ship personnel."
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "pod-on"
	dir = 4
	layer = ABOVE_WINDOW_LAYER
	density = TRUE
	anchored = TRUE
	var/state = S_IDLE
	var/obj/machinery/latejoin_cryo_computer/computer

	var/const/S_IDLE = 1
	var/const/S_CHARGING = 2
	var/const/S_OPEN = 3
	var/const/S_OCCUPIED = 4

/obj/machinery/latejoin_cryo/proc/emplace(mob/living/target, severity)
	if (severity > state)
		return FALSE

	if (occupant)
		awaken(occupant, TRUE)

	state = S_OCCUPIED
	close_machine(target)
	target.SetSleeping(60 SECONDS)
	addtimer(CALLBACK(src, .proc/awaken, target, FALSE), 5 SECONDS, TIMER_UNIQUE)
	return TRUE

/obj/machinery/latejoin_cryo/proc/awaken(mob/living/target, forced)
	if (!forced && (occupant != target || state != S_OCCUPIED))
		return FALSE

	var/turf/T = get_turf(src)
	playsound(T, 'sound/machines/cryo_warning.ogg', 100)
	state = S_OPEN
	open_machine()

	// bump the once-occupant and any dropped items outwards
	target.SetSleeping(10)
	target.Knockdown(10)
	for (var/atom/movable/AM in T.contents)
		if (!AM.anchored)
			step(AM, SOUTH)

	close_machine()
	if (!forced)
		addtimer(CALLBACK(src, .proc/cooled_off), 5 SECONDS, TIMER_UNIQUE)
	return TRUE

/obj/machinery/latejoin_cryo/proc/cooled_off()
	if (state != S_OPEN)
		return
	state = S_CHARGING
	update_icon()
	addtimer(CALLBACK(src, .proc/idle), 5 SECONDS, TIMER_UNIQUE)

/obj/machinery/latejoin_cryo/proc/idle()
	if (state != S_CHARGING)
		return
	state = S_IDLE
	update_icon()

/obj/machinery/latejoin_cryo/open_machine()
	for(var/mob/M in contents) //only drop mobs
		M.forceMove(get_turf(src))
		if(isliving(M))
			var/mob/living/L = M
			L.update_canmove()
	occupant = null
	update_icon()

/obj/machinery/latejoin_cryo/update_icon(by_computer=FALSE)
	// if the computer is dead, look visibly dead
	cut_overlays()
	if (!computer)
		icon_state = "pod-off"
		add_overlay("cover-off")
		return

	// otherwise look like a cryo tube
	if (!by_computer)
		computer.update_icon()
	switch (state)
		if (S_IDLE, S_OCCUPIED)
			var/image/occupant_overlay
			if (ishuman(occupant))
				occupant_overlay = image(occupant.icon, occupant.icon_state)
				occupant_overlay.copy_overlays(occupant)
			else
				occupant_overlay = image('icons/obj/cryo_mobs.dmi', "generic")
			occupant_overlay.dir = SOUTH
			occupant_overlay.pixel_y = 22

			icon_state = "pod-on"
			add_overlay(occupant_overlay)
			add_overlay("cover-on")

		if (S_OPEN)
			icon_state = "pod-open"

		if (S_CHARGING)
			icon_state = "pod-off"
			add_overlay("cover-on")

// control computer for the above
/obj/machinery/latejoin_cryo_computer
	name = "cryostasis console"
	desc = "A console monitoring the status of the deep-sleep pods."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_boxp0"
	density = TRUE
	anchored = TRUE
	var/list/cells

/obj/machinery/latejoin_cryo_computer/Initialize()
	. = ..()
	SSjob.latejoin_trackers += src
	cells = list()
	for (var/obj/machinery/latejoin_cryo/cell in view(7, get_turf(src)))
		cells += cell
		cell.computer = src
		cell.update_icon(TRUE)

/obj/machinery/latejoin_cryo_computer/Destroy()
	..()
	SSjob.latejoin_trackers -= src
	for (var/C in cells)
		var/obj/machinery/latejoin_cryo/cell = C
		cell.computer = null

/obj/machinery/latejoin_cryo_computer/proc/emplace(mob/living/target)
	var/list/shuffled = shuffle(cells)

	// try at the severities in order
	for (var/severity = 1; severity <= 4; ++severity)
		for (var/C in shuffled)
			var/obj/machinery/latejoin_cryo/cell = C
			if (cell.emplace(target, severity))
				return TRUE

	return FALSE  // fall back to default behavior

/obj/machinery/latejoin_cryo_computer/update_icon()
	var/total = 0
	for (var/C in cells)
		var/obj/machinery/latejoin_cryo/cell = C
		if (cell.state != 1)
			total++
	if (total == 0)
		icon_state = "control_boxp0"
	else if (total <= 3)
		icon_state = "control_boxp1"
	else
		icon_state = "control_boxp3"

/datum/controller/subsystem/job/SendToAtom(mob/M, atom/A, buckle)
	var/obj/machinery/latejoin_cryo_computer/C = A
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

// ----------------------------------------------------------------------------
// A spiffy signpost for our lobby

/obj/structure/sign/frenzy
	name = "\proper the NSS Frenzy logo"
	desc = "Try not to forget what ship you're on."
	icon = 'icons/obj/nss-frenzy.dmi'
	icon_state = "nss0"
	buildable_sign = FALSE
