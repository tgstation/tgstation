///Mining Base////

#define BAD_ZLEVEL	1
#define BAD_AREA	2
#define ZONE_SET	3

/area/shuttle/auxillary_base
	name = "Auxillary Base"
	luminosity = 0 //Lighting gets lost when it lands anyway


/obj/machinery/computer/auxillary_base
	name = "auxillary base management console"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	var/shuttleId = "colony_drop"
	desc = "Allows a deployable expedition base to be dropped from the station to a designated mining location. It can also \
interface with the mining shuttle at the landing site if a mobile beacon is also deployed."
	var/launch_warning = TRUE
	var/list/turrets = list() //List of connected turrets

	req_one_access = list(access_cargo, access_construction, access_heads)
	var/possible_destinations
	clockwork = TRUE
	var/obj/item/device/gps/internal/base/locator
	circuit = /obj/item/weapon/circuitboard/computer/auxillary_base

/obj/machinery/computer/auxillary_base/New(location, obj/item/weapon/circuitboard/computer/shuttle/C)
	..()
	locator = new /obj/item/device/gps/internal/base(src)


/obj/machinery/computer/auxillary_base/attack_hand(mob/user)
	if(..(user))
		return
	add_fingerprint(usr)

	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "[z == ZLEVEL_STATION ? "Docking clamps engaged. Standing by." : "Mining Shuttle Uplink: [M ? M.getStatusText() : "*OFFLINE*"]"]<br>"
	if(M)
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S))
				continue
			destination_found = 1
			dat += "<A href='?src=\ref[src];move=[S.id]'>Send to [S.name]</A><br>"
		if(!destination_found && z == ZLEVEL_STATION) //Only available if miners are lazy and did not set an LZ using the remote.
			dat += "<A href='?src=\ref[src];random=1'>Prepare for blind drop? (Dangerous)</A><br>"
	if(LAZYLEN(turrets))
		dat += "<br><b>Perimeter Defense System:</b> <A href='?src=\ref[src];turrets_power=on'>Enable All</A> / <A href='?src=\ref[src];turrets_power=off'>Disable All</A><br> \
		Units connected: [LAZYLEN(turrets)]<br>\
		Unit | Condition | Status | Direction | Distance<br>"
		for(var/PDT in turrets)
			var/obj/machinery/porta_turret/aux_base/T = PDT
			var/integrity = max((T.obj_integrity-T.integrity_failure)/(T.max_integrity-T.integrity_failure)*100, 0)
			var/status
			if(T.stat & BROKEN)
				status = "<span class='bad'>ERROR</span>"
			else if(!T.on)
				status = "Disabled"
			else if(T.raised)
				status = "<span class='average'><b>Firing</b></span>"
			else
				status = "<span class='good'>All Clear</span>"
			dat += "[T.name] | [integrity]% | [status] | [dir2text(get_dir(src, T))] | [get_dist(src, T)]m <A href='?src=\ref[src];single_turret_power=\ref[T]'>Toggle Power</A><br>"


	dat += "<a href='?src=\ref[user];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", "base management", 550, 300) //width, height
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()


/obj/machinery/computer/auxillary_base/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(!allowed(usr))
		usr << "<span class='danger'>Access denied.</span>"
		return

	if(href_list["move"])
		if(z != ZLEVEL_STATION && shuttleId == "colony_drop")
			usr << "<span class='warning'>You can't move the base again!</span>"
			return
		var/shuttle_error = SSshuttle.moveShuttle(shuttleId, href_list["move"], 1)
		if(launch_warning)
			say("<span class='danger'>Launch sequence activated! Prepare for drop!!</span>")
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 70, 0)
			launch_warning = FALSE
		else if(!shuttle_error)
			say("Shuttle request uploaded. Please stand away from the doors.")
		else
			say("Shuttle interface failed.")

	if(href_list["random"] && !possible_destinations)
		usr.changeNext_move(CLICK_CD_RAPID) //Anti-spam
		var/turf/LZ = safepick(Z_TURFS(ZLEVEL_MINING)) //Pick a random mining Z-level turf
		if(!istype(LZ, /turf/closed/mineral) && !istype(LZ, /turf/open/floor/plating/asteroid))
		//Find a suitable mining turf. Reduces chance of landing in a bad area
			usr << "<span class='warning'>Landing zone scan failed. Please try again.</span>"
			updateUsrDialog()
			return
		if(set_landing_zone(LZ, usr) != ZONE_SET)
			usr << "<span class='warning'>Landing zone unsuitable. Please recalculate.</span>"
			updateUsrDialog()
			return


	if(LAZYLEN(turrets))
		if(href_list["turrets_power"])
			for(var/obj/machinery/porta_turret/aux_base/T in turrets)
				if(href_list["turrets_power"] == "on")
					T.on = TRUE
				else
					T.on = FALSE
		if(href_list["single_turret_power"])
			var/obj/machinery/porta_turret/aux_base/T = locate(href_list["single_turret_power"]) in turrets
			if(istype(T))
				T.on = !T.on

	updateUsrDialog()


/obj/machinery/computer/auxillary_base/onShuttleMove(turf/T1, rotation)
	..()
	if(z == ZLEVEL_MINING) //Avoids double logging and landing on other Z-levels due to badminnery
		feedback_add_details("colonies_dropped", "[x]|[y]|[z]") //Number of times a base has been dropped!

/obj/machinery/computer/auxillary_base/proc/set_mining_mode()
	if(z == ZLEVEL_MINING) //The console switches to controlling the mining shuttle once landed.
		req_one_access = list()
		shuttleId = "mining" //The base can only be dropped once, so this gives the console a new purpose.
		possible_destinations = "mining_home;mining_away;landing_zone_dock;mining_public"

/obj/machinery/computer/auxillary_base/proc/set_landing_zone(turf/T, mob/user, var/no_restrictions)

	var/obj/docking_port/mobile/auxillary_base/base_dock = locate(/obj/docking_port/mobile/auxillary_base) in SSshuttle.mobile
	if(!base_dock) //Not all maps have an Aux base. This object is useless in that case.
		user << "<span class='warning'>This station is not equipped with an auxillary base. Please contact your Nanotrasen contractor.</span>"
		return
	if(!no_restrictions)
		if(T.z != ZLEVEL_MINING)
			return BAD_ZLEVEL
		var/colony_radius = max(base_dock.width, base_dock.height)*0.5
		var/list/area_counter = get_areas_in_range(colony_radius, T)
		if(area_counter.len > 1) //Avoid smashing ruins unless you are inside a really big one
			return BAD_AREA


	var/area/A = get_area(T)

	var/obj/docking_port/stationary/landing_zone = new /obj/docking_port/stationary(T)
	landing_zone.id = "colony_drop(\ref[src])"
	landing_zone.name = "Landing Zone ([T.x], [T.y])"
	landing_zone.dwidth = base_dock.dwidth
	landing_zone.dheight = base_dock.dheight
	landing_zone.width = base_dock.width
	landing_zone.height = base_dock.height
	landing_zone.setDir(base_dock.dir)
	landing_zone.turf_type = T.type
	landing_zone.area_type = A.type

	possible_destinations += "[landing_zone.id];"

//Serves as a nice mechanic to people get ready for the launch.
	minor_announce("Auxiliary base landing zone coordinates locked in for [A]. Launch command now available!")
	user << "<span class='notice'>Landing zone set.</span>"
	return ZONE_SET


/obj/item/device/assault_pod/mining
	name = "Landing Field Designator"
	icon_state = "gangtool-purple"
	item_state = "electronic"
	icon = 'icons/obj/device.dmi'
	desc = "Deploy to designate the landing zone of the auxillary base."
	w_class = WEIGHT_CLASS_SMALL
	shuttle_id = "colony_drop"
	var/setting = FALSE
	var/no_restrictions = FALSE //Badmin variable to let you drop the colony ANYWHERE.

/obj/item/device/assault_pod/mining/attack_self(mob/living/user)
	if(setting)
		return

	user << "<span class='notice'>You begin setting the landing zone parameters...</span>"
	setting = TRUE
	if(!do_after(user, 50, target = user)) //You get a few seconds to cancel if you do not want to drop there.
		setting = FALSE
		return

	var/turf/T = get_turf(user)
	var/obj/machinery/computer/auxillary_base/AB

	for (var/obj/machinery/computer/auxillary_base/A in machines)
		if(A.z == ZLEVEL_STATION)
			AB = A
			break
	if(!AB)
		user << "<span class='warning'>No auxillary base console detected.</span>"
		return

	switch(AB.set_landing_zone(T, user, no_restrictions))
		if(BAD_ZLEVEL)
			user << "<span class='warning'>This uplink can only be used in a designed mining zone.</span>"
		if(BAD_AREA)
			user << "<span class='warning'>Unable to acquire a targeting lock. Find an area clear of stuctures or entirely within one.</span>"
		if(ZONE_SET)
			qdel(src)

/obj/item/device/assault_pod/mining/unrestricted
	name = "omni-locational landing field designator"
	desc = "Allows the deployment of the mining base ANYWHERE. Use with caution."
	no_restrictions = TRUE


/obj/docking_port/mobile/auxillary_base
	name = "auxillary base"
	id = "colony_drop"
	//Reminder to map-makers to set these values equal to the size of your base.
	dheight = 4
	dwidth = 4
	width = 9
	height = 9

obj/docking_port/stationary/public_mining_dock
	name = "public mining base dock"
	id = "disabled" //The Aux Base has to leave before this can be used as a dock.
	//Should be checked on the map to ensure it matchs the mining shuttle dimensions.
	dwidth = 3
	width = 7
	height = 5

obj/docking_port/stationary/public_mining_dock/onShuttleMove()
	id = "mining_public" //It will not move with the base, but will become enabled as a docking point.
	return 0


/obj/structure/mining_shuttle_beacon
	name = "mining shuttle beacon"
	desc = "A bluespace beacon calibrated to mark a landing spot for the mining shuttle when deployed near the auxillary mining base."
	anchored = 0
	density = 0
	var/shuttle_ID = "landing_zone_dock"
	icon = 'icons/obj/objects.dmi'
	icon_state = "miningbeacon"
	var/obj/docking_port/stationary/Mport //Linked docking port for the mining shuttle
	pressure_resistance = 200 //So it does not get blown into lava.
	var/anti_spam_cd = 0 //The linking process might be a bit intensive, so this here to prevent over use.
	var/console_range = 15 //Wifi range of the beacon to find the aux base console

/obj/structure/mining_shuttle_beacon/attack_hand(mob/user)
	if(anchored)
		user << "<span class='warning'>Landing zone already set.</span>"
		return

	if(anti_spam_cd)
		user << "<span class='warning'>[src] is currently recalibrating. Please wait.</span>"
		return

	anti_spam_cd = 1
	addtimer(CALLBACK(src, .proc/clear_cooldown), 50)

	var/turf/landing_spot = get_turf(src)

	if(landing_spot.z != ZLEVEL_MINING)
		user << "<span class='warning'>This device is only to be used in a mining zone.</span>"
		return
	var/obj/machinery/computer/auxillary_base/aux_base_console = locate(/obj/machinery/computer/auxillary_base) in machines
	if(!aux_base_console || get_dist(landing_spot, aux_base_console) > console_range)
		user << "<span class='warning'>The auxillary base's console must be within [console_range] meters in order to interface.</span>"
		return //Needs to be near the base to serve as its dock and configure it to control the mining shuttle.

//Mining shuttles may not be created equal, so we find the map's shuttle dock and size accordingly.


	for(var/S in SSshuttle.stationary)
		var/obj/docking_port/stationary/SM = S //SM is declared outside so it can be checked for null
		if(SM.id == "mining_home" || SM.id == "mining_away")

			var/area/A = get_area(landing_spot)

			Mport = new(landing_spot)
			Mport.id = "landing_zone_dock"
			Mport.name = "auxillary base landing site"
			Mport.dwidth = SM.dwidth
			Mport.dheight = SM.dheight
			Mport.width = SM.width
			Mport.height = SM.height
			Mport.setDir(dir)
			Mport.turf_type = landing_spot.type
			Mport.area_type = A.type

			break
	if(!Mport)
		user << "<span class='warning'>This station is not equipped with an approprite mining shuttle. Please contact Nanotrasen Support.</span>"
		return
	var/search_radius = max(Mport.width, Mport.height)*0.5
	var/list/landing_areas = get_areas_in_range(search_radius, landing_spot)
	for(var/area/shuttle/auxillary_base/AB in landing_areas) //You land NEAR the base, not IN it.
		user << "<span class='warning'>The mining shuttle must not land within the mining base itself.</span>"
		SSshuttle.stationary.Remove(Mport)
		qdel(Mport)
		return
	var/obj/docking_port/mobile/mining_shuttle
	for(var/S in SSshuttle.mobile)
		var/obj/docking_port/mobile/MS = S
		if(MS.id != "mining")
			continue
		mining_shuttle = MS

	if(!mining_shuttle) //Not having a mining shuttle is a map issue
		user << "<span class='warning'>No mining shuttle signal detected. Please contact Nanotrasen Support.</span>"
		SSshuttle.stationary.Remove(Mport)
		qdel(Mport)
		return

	if(!mining_shuttle.canDock(Mport))
		user << "<span class='warning'>Unable to secure a valid docking zone. Please try again in an open area near, but not within the aux. mining base.</span>"
		SSshuttle.stationary.Remove(Mport)
		qdel(Mport)
		return

	aux_base_console.set_mining_mode() //Lets the colony park the shuttle there, now that it has a dock.
	user << "<span class='notice'>Mining shuttle calibration successful! Shuttle interface available at base console.</span>"
	anchored = 1 //Locks in place to mark the landing zone.
	playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)

/obj/structure/mining_shuttle_beacon/proc/clear_cooldown()
	anti_spam_cd = 0

/obj/structure/mining_shuttle_beacon/attack_robot(mob/user)
	return attack_hand(user) //So borgies can help

#undef BAD_ZLEVEL
#undef BAD_AREA
#undef ZONE_SET