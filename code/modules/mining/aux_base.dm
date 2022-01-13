///Mining Base////

#define ZONE_SET 0
#define BAD_ZLEVEL 1
#define BAD_AREA 2
#define BAD_COORDS 3
#define BAD_TURF 4

/area/shuttle/auxiliary_base
	name = "Auxiliary Base"
	luminosity = 0 //Lighting gets lost when it lands anyway

/obj/machinery/computer/auxiliary_base
	name = "auxiliary base management console"
	desc = "Allows a deployable expedition base to be dropped from the station to a designated mining location. It can also \
	interface with the mining shuttle at the landing site if a mobile beacon is also deployed."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	icon_keyboard = null
	req_one_access = list(ACCESS_AUX_BASE, ACCESS_HEADS)
	circuit = /obj/item/circuitboard/computer/auxiliary_base
	/// Shuttle ID of the base
	var/shuttleId = "colony_drop"
	/// If we give warnings before base is launched
	var/launch_warning = TRUE
	/// List of connected turrets
	var/list/datum/weakref/turrets
	/// List of all possible destinations
	var/possible_destinations
	/// ID of the currently selected destination of the attached base
	var/destination
	/// If blind drop option is available
	var/blind_drop_ready = TRUE

	density = FALSE //this is a wallmount

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/auxiliary_base, 32)

/obj/machinery/computer/auxiliary_base/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "NT_AUX")

/obj/machinery/computer/auxiliary_base/Destroy() // Shouldn't be destroyable... but just in case
	LAZYCLEARLIST(turrets)
	return ..()

/obj/machinery/computer/auxiliary_base/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AuxBaseConsole", name)
		ui.open()

/obj/machinery/computer/auxiliary_base/ui_data(mob/user)
	var/list/data = list()
	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	data["type"] = shuttleId == "colony_drop" ? "base" : "shuttle"
	data["docked_location"] = M ? M.get_status_text_tgui() : "Unknown"
	data["locations"] = list()
	data["locked"] = FALSE
	data["timer_str"] = M ? M.getTimerStr() : "00:00"
	data["destination"] = destination
	data["blind_drop"] = blind_drop_ready
	data["turrets"] = list()
	for(var/datum/weakref/turret_ref as anything in turrets)
		var/obj/machinery/porta_turret/aux_base/base_turret = turret_ref.resolve()
		if(!istype(base_turret)) // null or invalid in turrets list? axe it
			LAZYREMOVE(turrets, turret_ref)
			continue

		var/turret_integrity = max((base_turret.get_integrity() - base_turret.integrity_failure * base_turret.max_integrity) / (base_turret.max_integrity - base_turret.integrity_failure * max_integrity) * 100, 0)
		var/turret_status
		if(base_turret.machine_stat & BROKEN)
			turret_status = "ERROR"
		else if(!base_turret.on)
			turret_status = "Disabled"
		else if(base_turret.raised)
			turret_status = "Firing"
		else
			turret_status = "All Clear"
		var/list/turret_data = list(
			name = base_turret.name,
			integrity = turret_integrity,
			status = turret_status,
			direction = dir2text(get_dir(src, base_turret)),
			distance = get_dist(src, base_turret),
			ref = REF(base_turret)
		)
		data["turrets"] += list(turret_data)
	if(!M)
		data["status"] = "Missing"
		return data
	switch(M.mode)
		if(SHUTTLE_IGNITING)
			data["status"] = "Igniting"
		if(SHUTTLE_IDLE)
			data["status"] = "Idle"
		if(SHUTTLE_RECHARGING)
			data["status"] = "Recharging"
		else
			data["status"] = "In Transit"
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary_docking_ports)
		if(!options.Find(S.port_destinations))
			continue
		if(!M.check_dock(S, silent = TRUE))
			continue
		var/list/location_data = list(
			id = S.id,
			name = S.name
		)
		data["locations"] += list(location_data)
	if(length(data["locations"]) == 1)
		for(var/location in data["locations"])
			destination = location["id"]
			data["destination"] = destination
	if(!length(data["locations"]))
		data["locked"] = TRUE
		data["status"] = "Locked"
	return data

/**
 * Checks if we are allowed to launch the base
 *
 * Arguments:
 * * user - The mob trying to initiate the launch
 */
/obj/machinery/computer/auxiliary_base/proc/launch_check(mob/user)
	if(!is_station_level(z) && shuttleId == "colony_drop")
		to_chat(user, span_warning("You can't move the base again!"))
		return FALSE
	return TRUE

/obj/machinery/computer/auxiliary_base/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, span_danger("Access denied."))
		return

	switch(action)
		if("move")
			if(!launch_check(usr))
				return
			var/shuttle_error = SSshuttle.moveShuttle(shuttleId, params["shuttle_id"], 1)
			if(launch_warning)
				say(span_danger("Launch sequence activated! Prepare for drop!!"))
				playsound(loc, 'sound/machines/warning-buzzer.ogg', 70, FALSE)
				launch_warning = FALSE
				blind_drop_ready = FALSE
				log_shuttle("[key_name(usr)] has launched the auxiliary base.")
				return TRUE
			else if(!shuttle_error)
				say("Shuttle request uploaded. Please stand away from the doors.")
			else
				say("Shuttle interface failed.")
		if("random")
			if(possible_destinations)
				return
			usr.changeNext_move(CLICK_CD_RAPID) //Anti-spam
			var/list/all_mining_turfs = list()
			for(var/z_level in SSmapping.levels_by_trait(ZTRAIT_MINING))
				all_mining_turfs += Z_TURFS(z_level)
			var/turf/LZ = pick(all_mining_turfs) //Pick a random mining Z-level turf
			if(!ismineralturf(LZ) && !istype(LZ, /turf/open/floor/plating/asteroid))
			//Find a suitable mining turf. Reduces chance of landing in a bad area
				to_chat(usr, span_warning("Landing zone scan failed. Please try again."))
				return
			if(set_landing_zone(LZ, usr) != ZONE_SET)
				to_chat(usr, span_warning("Landing zone unsuitable. Please recalculate."))
				return
			blind_drop_ready = FALSE
			return TRUE
		if("set_destination")
			var/target_destination = params["destination"]
			if(!target_destination)
				return
			destination = target_destination
			return TRUE
		if("turrets_power")
			for(var/datum/weakref/turret_ref as anything in turrets)
				var/obj/machinery/porta_turret/aux_base/base_turret = turret_ref.resolve()
				if(!istype(base_turret)) // null or invalid in turrets list
					LAZYREMOVE(turrets, turret_ref)
					continue

				base_turret.toggle_on()
			return TRUE
		if("single_turret_power")
			var/obj/machinery/porta_turret/aux_base/base_turret = locate(params["single_turret_power"])
			if(!istype(base_turret) || !(WEAKREF(base_turret) in turrets))
				return

			base_turret.toggle_on()
			return TRUE

/obj/machinery/computer/auxiliary_base/proc/set_mining_mode()
	if(is_mining_level(z)) //The console switches to controlling the mining shuttle once landed.
		req_one_access = list()
		shuttleId = "mining" //The base can only be dropped once, so this gives the console a new purpose.
		possible_destinations = "mining_home;mining_away;landing_zone_dock;mining_public"

/obj/machinery/computer/auxiliary_base/proc/set_landing_zone(turf/T, mob/user, no_restrictions)
	var/obj/docking_port/mobile/auxiliary_base/base_dock = locate(/obj/docking_port/mobile/auxiliary_base) in SSshuttle.mobile_docking_ports
	if(!base_dock) //Not all maps have an Aux base. This object is useless in that case.
		to_chat(user, span_warning("This station is not equipped with an auxiliary base. Please contact your Nanotrasen contractor."))
		return
	if(!no_restrictions)
		var/static/list/disallowed_turf_types = typecacheof(list(
			/turf/closed,
			/turf/open/lava,
			/turf/open/indestructible,
			)) - typecacheof(list(
			/turf/closed/mineral,
			))

		if(!is_mining_level(T.z))
			return BAD_ZLEVEL


		var/list/colony_turfs = base_dock.return_ordered_turfs(T.x,T.y,T.z,base_dock.dir)
		for(var/i in 1 to colony_turfs.len)
			CHECK_TICK
			var/turf/place = colony_turfs[i]
			if(!place)
				return BAD_COORDS
			if(!istype(place.loc, /area/lavaland/surface))
				return BAD_AREA
			if(disallowed_turf_types[place.type])
				return BAD_TURF


	var/area/A = get_area(T)

	var/obj/docking_port/stationary/landing_zone = new /obj/docking_port/stationary(T)
	landing_zone.id = "colony_drop([REF(src)])"
	landing_zone.port_destinations = "colony_drop([REF(src)])"
	landing_zone.name = "Landing Zone ([T.x], [T.y])"
	landing_zone.dwidth = base_dock.dwidth
	landing_zone.dheight = base_dock.dheight
	landing_zone.width = base_dock.width
	landing_zone.height = base_dock.height
	landing_zone.setDir(base_dock.dir)
	landing_zone.area_type = A.type

	possible_destinations += "[landing_zone.id];"

//Serves as a nice mechanic to people get ready for the launch.
	minor_announce("Auxiliary base landing zone coordinates locked in for [A]. Launch command now available!")
	to_chat(user, span_notice("Landing zone set."))
	return ZONE_SET

/obj/item/assault_pod/mining
	name = "Landing Field Designator"
	icon_state = "gangtool-purple"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	desc = "Deploy to designate the landing zone of the auxiliary base."
	w_class = WEIGHT_CLASS_SMALL
	shuttle_id = "colony_drop"
	var/setting = FALSE
	var/no_restrictions = FALSE //Badmin variable to let you drop the colony ANYWHERE.

/obj/item/assault_pod/mining/attack_self(mob/living/user)
	if(setting)
		return

	to_chat(user, span_notice("You begin setting the landing zone parameters..."))
	setting = TRUE
	if(!do_after(user, 50, target = user)) //You get a few seconds to cancel if you do not want to drop there.
		setting = FALSE
		return
	setting = FALSE

	var/turf/T = get_turf(user)
	var/obj/machinery/computer/auxiliary_base/AB

	for (var/obj/machinery/computer/auxiliary_base/A in GLOB.machines)
		if(is_station_level(A.z))
			AB = A
			break
	if(!AB)
		to_chat(user, span_warning("No auxiliary base console detected."))
		return

	switch(AB.set_landing_zone(T, user, no_restrictions))
		if(ZONE_SET)
			qdel(src)
		if(BAD_ZLEVEL)
			to_chat(user, span_warning("This uplink can only be used in a designed mining zone."))
		if(BAD_AREA)
			to_chat(user, span_warning("Unable to acquire a targeting lock. Find an area clear of structures or entirely within one."))
		if(BAD_COORDS)
			to_chat(user, span_warning("Location is too close to the edge of the station's scanning range. Move several paces away and try again."))
		if(BAD_TURF)
			to_chat(user, span_warning("The landing zone contains turfs unsuitable for a base. Make sure you've removed all walls and dangerous terrain from the landing zone."))

/obj/item/assault_pod/mining/unrestricted
	name = "omni-locational landing field designator"
	desc = "Allows the deployment of the mining base ANYWHERE. Use with caution."
	no_restrictions = TRUE


/obj/docking_port/mobile/auxiliary_base
	name = "auxiliary base"
	id = "colony_drop"
	//Reminder to map-makers to set these values equal to the size of your base.
	dheight = 4
	dwidth = 4
	width = 9
	height = 9

/obj/docking_port/mobile/auxiliary_base/takeoff(list/old_turfs, list/new_turfs, list/moved_atoms, rotation, movement_direction, old_dock, area/underlying_old_area)
	for(var/i in new_turfs)
		var/turf/place = i
		if(istype(place, /turf/closed/mineral))
			place.ScrapeAway()
	return ..()

/obj/docking_port/stationary/public_mining_dock
	name = "public mining base dock"
	id = "disabled" //The Aux Base has to leave before this can be used as a dock.
	//Should be checked on the map to ensure it matchs the mining shuttle dimensions.
	dwidth = 3
	width = 7
	height = 5
	area_type = /area/construction/mining/aux_base

/obj/structure/mining_shuttle_beacon
	name = "mining shuttle beacon"
	desc = "A bluespace beacon calibrated to mark a landing spot for the mining shuttle when deployed near the auxiliary mining base."
	anchored = FALSE
	density = FALSE
	var/shuttle_ID = "landing_zone_dock"
	icon = 'icons/obj/objects.dmi'
	icon_state = "miningbeacon"
	var/obj/docking_port/stationary/Mport //Linked docking port for the mining shuttle
	pressure_resistance = 200 //So it does not get blown into lava.
	var/anti_spam_cd = 0 //The linking process might be a bit intensive, so this here to prevent over use.
	var/console_range = 15 //Wifi range of the beacon to find the aux base console

/obj/structure/mining_shuttle_beacon/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(anchored)
		to_chat(user, span_warning("Landing zone already set."))
		return

	if(anti_spam_cd)
		to_chat(user, span_warning("[src] is currently recalibrating. Please wait."))
		return

	anti_spam_cd = 1
	addtimer(CALLBACK(src, .proc/clear_cooldown), 50)

	var/turf/landing_spot = get_turf(src)

	if(!is_mining_level(landing_spot.z))
		to_chat(user, span_warning("This device is only to be used in a mining zone."))
		return
	var/obj/machinery/computer/auxiliary_base/aux_base_console
	for(var/obj/machinery/computer/auxiliary_base/ABC in GLOB.machines)
		if(get_dist(landing_spot, ABC) <= console_range)
			aux_base_console = ABC
			break
	if(!aux_base_console) //Needs to be near the base to serve as its dock and configure it to control the mining shuttle.
		to_chat(user, span_warning("The auxiliary base's console must be within [console_range] meters in order to interface."))
		return

//Mining shuttles may not be created equal, so we find the map's shuttle dock and size accordingly.
	for(var/S in SSshuttle.stationary_docking_ports)
		var/obj/docking_port/stationary/SM = S //SM is declared outside so it can be checked for null
		if(SM.id == "mining_home" || SM.id == "mining_away")

			var/area/A = get_area(landing_spot)

			Mport = new(landing_spot)
			Mport.id = "landing_zone_dock"
			Mport.port_destinations = "landing_zone_dock"
			Mport.name = "auxiliary base landing site"
			Mport.dwidth = SM.dwidth
			Mport.dheight = SM.dheight
			Mport.width = SM.width
			Mport.height = SM.height
			Mport.setDir(dir)
			Mport.area_type = A.type

			break
	if(!Mport)
		to_chat(user, span_warning("This station is not equipped with an appropriate mining shuttle. Please contact Nanotrasen Support."))
		return

	var/obj/docking_port/mobile/mining_shuttle
	var/list/landing_turfs = list() //List of turfs where the mining shuttle may land.
	for(var/S in SSshuttle.mobile_docking_ports)
		var/obj/docking_port/mobile/MS = S
		if(MS.id != "mining")
			continue
		mining_shuttle = MS
		landing_turfs = mining_shuttle.return_ordered_turfs(x,y,z,dir)
		break

	if(!mining_shuttle) //Not having a mining shuttle is a map issue
		to_chat(user, span_warning("No mining shuttle signal detected. Please contact Nanotrasen Support."))
		SSshuttle.stationary_docking_ports.Remove(Mport)
		qdel(Mport)
		return

	for(var/i in 1 to landing_turfs.len) //You land NEAR the base, not IN it.
		var/turf/L = landing_turfs[i]
		if(!L) //This happens at map edges
			to_chat(user, span_warning("Unable to secure a valid docking zone. Please try again in an open area near, but not within the auxiliary mining base."))
			SSshuttle.stationary_docking_ports.Remove(Mport)
			qdel(Mport)
			return
		if(istype(get_area(L), /area/shuttle/auxiliary_base))
			to_chat(user, span_warning("The mining shuttle must not land within the mining base itself."))
			SSshuttle.stationary_docking_ports.Remove(Mport)
			qdel(Mport)
			return

	if(mining_shuttle.canDock(Mport) != SHUTTLE_CAN_DOCK)
		to_chat(user, span_warning("Unable to secure a valid docking zone. Please try again in an open area near, but not within the auxiliary mining base."))
		SSshuttle.stationary_docking_ports.Remove(Mport)
		qdel(Mport)
		return

	aux_base_console.set_mining_mode() //Lets the colony park the shuttle there, now that it has a dock.
	to_chat(user, span_notice("Mining shuttle calibration successful! Shuttle interface available at base console."))
	set_anchored(TRUE) //Locks in place to mark the landing zone.
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	log_shuttle("[key_name(usr)] has registered the mining shuttle beacon at [COORD(landing_spot)].")

/obj/structure/mining_shuttle_beacon/proc/clear_cooldown()
	anti_spam_cd = 0

/obj/structure/mining_shuttle_beacon/attack_robot(mob/user)
	return attack_hand(user) //So borgies can help

#undef ZONE_SET
#undef BAD_ZLEVEL
#undef BAD_AREA
#undef BAD_COORDS
#undef BAD_TURF
