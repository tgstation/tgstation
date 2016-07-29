/obj/machinery/computer/teleporter
<<<<<<< HEAD
	name = "Teleporter Control Console"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/weapon/circuitboard/computer/teleporter
	var/obj/item/device/gps/locked = null
	var/regime_set = "Teleporter"
	var/id = null
	var/obj/machinery/teleport/station/power_station
	var/calibrating
	var/turf/target //Used for one-time-use teleport cards (such as clown planet coordinates.)
						 //Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.

/obj/machinery/computer/teleporter/New()
	src.id = "[rand(1000, 9999)]"
	link_power_station()
	..()
	return

/obj/machinery/computer/teleporter/initialize()
	link_power_station()

/obj/machinery/computer/teleporter/Destroy()
	if (power_station)
		power_station.teleporter_console = null
		power_station = null
	return ..()

/obj/machinery/computer/teleporter/proc/link_power_station()
	if(power_station)
		return
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		power_station = locate(/obj/machinery/teleport/station, get_step(src, dir))
		if(power_station)
			break
	return power_station

/obj/machinery/computer/teleporter/attackby(obj/I, mob/living/user, params)
	if(istype(I, /obj/item/device/gps))
		var/obj/item/device/gps/L = I
		if(L.locked_location && !(stat & (NOPOWER|BROKEN)))
			if(!user.unEquip(L))
				user << "<span class='warning'>\the [I] is stuck to your hand, you cannot put it in \the [src]!</span>"
				return
			L.loc = src
			locked = L
			user << "<span class='caution'>You insert the GPS device into the [name]'s slot.</span>"
	else
		return ..()

/obj/machinery/computer/teleporter/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/teleporter/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/teleporter/interact(mob/user)
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

		data += "<A href='?src=\ref[src];regimeset=1'>Change regime</A><BR>"
		data += "<A href='?src=\ref[src];settarget=1'>Set target</A><BR>"
		if(locked)
			data += "<BR><A href='?src=\ref[src];locked=1'>Get target from memory</A><BR>"
			data += "<A href='?src=\ref[src];eject=1'>Eject GPS device</A><BR>"
		else
			data += "<BR><span class='linkOff'>Get target from memory</span><BR>"
			data += "<span class='linkOff'>Eject GPS device</span><BR>"

		data += "<BR><A href='?src=\ref[src];calibrate=1'>Calibrate Hub</A>"

	var/datum/browser/popup = new(user, "teleporter", name, 400, 400)
	popup.set_content(data)
	popup.open()
	return

/obj/machinery/computer/teleporter/Topic(href, href_list)
	if(..())
		return

	if(href_list["eject"])
		eject()
		updateDialog()
		return

	if(!check_hub_connection())
		say("<span class='warning'>Error: Unable to detect hub.</span>")
		return
	if(calibrating)
		say("<span class='warning'>Error: Calibration in progress. Stand by.</span>")
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
			say("<span class='danger'>Error: No target set to calibrate to.</span>")
			return
		if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accurate >= 3)
			say("<span class='warning'>Hub is already calibrated!</span>")
			return
		say("<span class='notice'>Processing hub calibration to target...</span>")

		calibrating = 1
		spawn(50 * (3 - power_station.teleporter_hub.accurate)) //Better parts mean faster calibration
			calibrating = 0
			if(check_hub_connection())
				power_station.teleporter_hub.calibrated = 1
				say("<span class='notice'>Calibration complete.</span>")
			else
				say("<span class='danger'>Error: Unable to detect hub.</span>")
			updateDialog()

	updateDialog()

/obj/machinery/computer/teleporter/proc/check_hub_connection()
	if(!power_station)
		return
	if(!power_station.teleporter_hub)
		return
	return 1

/obj/machinery/computer/teleporter/proc/reset_regime()
	target = null
	if(regime_set == "Teleporter")
		regime_set = "Gate"
	else
		regime_set = "Teleporter"

/obj/machinery/computer/teleporter/proc/eject()
	if(locked)
		locked.loc = loc
		locked = null

/obj/machinery/computer/teleporter/proc/set_target(mob/user)
	if(regime_set == "Teleporter")
		var/list/L = list()
		var/list/areaindex = list()

		for(var/obj/item/device/radio/beacon/R in world)
			var/turf/T = get_turf(R)
			if (!T)
				continue
			if(T.z == ZLEVEL_CENTCOM || T.z > ZLEVEL_SPACEMAX)
				continue
			var/tmpname = T.loc.name
=======
	name = "Teleporter"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/teleporter"
	var/obj/item/locked = null
	var/id = null
	var/one_time_use = 0 //Used for one-time-use teleport cards (such as clown planet coordinates.)
						 //Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.
	ghost_write=0

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/teleporter/New()
	. = ..()
	id = "[rand(1000, 9999)]"

/obj/machinery/computer/teleporter/attackby(I as obj, mob/living/user as mob)
	if(..())
		return 1
	else if(istype(I, /obj/item/weapon/card/data/))
		var/obj/item/weapon/card/data/C = I
		if(stat & (NOPOWER|BROKEN) & (C.function != "teleporter"))
			src.attack_hand()

		var/obj/L = null

		for(var/obj/effect/landmark/sloc in landmarks_list)
			if(sloc.name != C.data) continue
			if(locate(/mob/living) in sloc.loc) continue
			L = sloc
			break

		if(!L)
			L = locate("landmark*[C.data]") // use old stype


		if(istype(L, /obj/effect/landmark/) && istype(L.loc, /turf))
			if(!user.drop_item(I))
				user << "<span class='warning'>You can't let go of \the [I]!</span>"
				return

			to_chat(usr, "You insert the coordinates into the machine.")
			to_chat(usr, "A message flashes across the screen reminding the traveller that the nuclear authentication disk is to remain on the station at all times.")
			qdel(I)

			say("Locked in")
			src.locked = L
			one_time_use = 1

			src.add_fingerprint(usr)
	return

/obj/machinery/computer/teleporter/examine(var/mob/user)
	..()
	if(locked)
		var/area/locked_area = get_area(locked)
		to_chat(user, "The destination is set to \"[locked_area.name]\".")

/obj/machinery/computer/teleporter/attack_paw(var/mob/user)
	src.attack_hand(user)

/obj/machinery/teleport/station/attack_ai(var/mob/user)
	src.attack_hand(user)

/obj/machinery/computer/teleporter/attack_hand(var/mob/user)
	. = ..()
	if(.)
		user.unset_machine()
		return

	interact(user)

/obj/machinery/computer/teleporter/interact(var/mob/user)
	var/area/locked_area
	if(locked)
		locked_area = get_area(locked)
		if(!locked_area)
			locked = null

		if(locked) //If there's still a locked thing (incase it got cleared above)
			locked_area = get_area(locked)
			if(!locked_area)
				locked = null
			. = {"
			<b>Destination:</b> [sanitize(locked_area.name)]<br>
			<a href='?src=\ref[src];clear=1'>Clear destination</a><br>
			"}
	else
		. = {"
		<b>Destination unset!</b><br>
		"}

	. += {"
		<br><b>Available destinations:<b><br>
		<lu>
	"}

	var/list/dests = get_avail_dests()

	for(var/name in dests)
		. += {"
			<li><a href='?src=\ref[src];dest=[dests.Find(name)]'[dests[name] == locked ? " class='linkOn'" : ""]>[sanitize(name)]</a></li>
		"}

	. += "</lu>"

	var/datum/browser/popup = new(user, "teleporter_console", name, 250, 500, src)
	popup.set_content(.)
	popup.open()
	user.set_machine(src)

/obj/machinery/computer/teleporter/Topic(var/href, var/list/href_list)
	. = ..()
	if(.)
		return

	if(href_list["clear"])
		locked = null
		updateUsrDialog()
		return 1

	if(href_list["dest"])
		var/list/dests = get_avail_dests()
		var/idx = Clamp(text2num(href_list["dest"]), 1, dests.len)
		locked = dests[dests[idx]]
		say("Locked in")
		updateUsrDialog()
		return 1

/obj/machinery/computer/teleporter/proc/get_avail_dests()
	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/beacon/R in beacons)
		var/turf/T = get_turf(R)
		if (!T)
			continue
		if(T.z == CENTCOMM_Z || T.z > map.zLevels.len)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	for (var/obj/item/weapon/implant/tracking/I in tracking_implants)
		if (!I.implanted || !ismob(I.loc))
			continue
		else
			var/mob/M = I.loc
			if (M.stat == 2)
				if (M.timeofdeath + 6000 < world.time)
					continue
			var/turf/T = get_turf(M)
			if(T)	continue
			if(T.z == 2)	continue
			var/tmpname = M.real_name
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
<<<<<<< HEAD
			L[tmpname] = R

		for (var/obj/item/weapon/implant/tracking/I in tracked_implants)
			if (!I.implanted || !ismob(I.loc))
				continue
			else
				var/mob/M = I.loc
				if (M.stat == 2)
					if (M.timeofdeath + 6000 < world.time)
						continue
				var/turf/T = get_turf(M)
				if(!T)
					continue
				if(T.z == ZLEVEL_CENTCOM)
					continue
				var/tmpname = M.real_name
				if(areaindex[tmpname])
					tmpname = "[tmpname] ([++areaindex[tmpname]])"
				else
					areaindex[tmpname] = 1
				L[tmpname] = I

		var/desc = input("Please select a location to lock in.", "Locking Computer") in L
		target = L[desc]

	else
		var/list/L = list()
		var/list/areaindex = list()
		var/list/S = power_station.linked_stations
		if(!S.len)
			user << "<span class='alert'>No connected stations located.</span>"
			return
		for(var/obj/machinery/teleport/station/R in S)
			var/turf/T = get_turf(R)
			if (!T || !R.teleporter_hub || !R.teleporter_console)
				continue
			if(T.z == ZLEVEL_CENTCOM || T.z > ZLEVEL_SPACEMAX)
				continue
			var/tmpname = T.loc.name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R
		var/desc = input("Please select a station to lock in.", "Locking Computer") in L
		target = L[desc]
		if(target)
			var/obj/machinery/teleport/station/trg = target
			trg.linked_stations |= power_station
			trg.stat &= ~NOPOWER
			if(trg.teleporter_hub)
				trg.teleporter_hub.stat &= ~NOPOWER
				trg.teleporter_hub.update_icon()
			if(trg.teleporter_console)
				trg.teleporter_console.stat &= ~NOPOWER
				trg.teleporter_console.update_icon()
=======
			L[tmpname] = I

	. = L

/obj/machinery/computer/teleporter/verb/set_id(t as text)
	set category = "Object"
	set name = "Set teleporter ID"
	set src in oview(1)
	set desc = "ID Tag:"

	if(stat & (NOPOWER|BROKEN) || !istype(usr,/mob/living))
		return
	if (t)
		src.id = t
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return

/obj/machinery/teleport
	name = "teleport"
<<<<<<< HEAD
	icon = 'icons/obj/machines/teleporter.dmi'
	density = 1
	anchored = 1
=======
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	anchored = 1.0
	var/lockeddown = 0
	var/engaged = 0
	ghost_read=0 // #519
	ghost_write=0


>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	var/accurate = 0
<<<<<<< HEAD
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/teleport/station/power_station
	var/calibrated //Calibration prevents mutation

/obj/machinery/teleport/hub/New()
	..()
	link_power_station()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/teleporter_hub(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/teleporter_hub
	name = "circuit board (Teleporter Hub)"
	build_path = /obj/machinery/teleport/hub
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 3,
							/obj/item/weapon/stock_parts/matter_bin = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/machinery/teleport/hub/initialize()
	link_power_station()

/obj/machinery/teleport/hub/Destroy()
	if (power_station)
		power_station.teleporter_hub = null
		power_station = null
	return ..()

/obj/machinery/teleport/hub/RefreshParts()
	var/A = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		A += M.rating
	accurate = A

/obj/machinery/teleport/hub/proc/link_power_station()
	if(power_station)
		return
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		power_station = locate(/obj/machinery/teleport/station, get_step(src, dir))
		if(power_station)
			break
	return power_station

/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	if(z == ZLEVEL_CENTCOM)
		M << "You can't use this here."
	if(is_ready())
		teleport(M)
		use_power(5000)
	return

/obj/machinery/teleport/hub/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", W))
		if(power_station && power_station.engaged)
			power_station.engaged = 0 //hub with panel open is off, so the station must be informed.
			update_icon()
		return
	if(exchange_parts(user, W))
		return
	if(default_deconstruction_crowbar(W))
		return
	return ..()

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj, turf/T)
	var/obj/machinery/computer/teleporter/com = power_station.teleporter_console
	if (!com)
		return
	if (!com.target)
		visible_message("<span class='alert'>Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if (istype(M, /atom/movable))
		if(do_teleport(M, com.target))
			if(!calibrated && prob(30 - ((accurate) * 10))) //oh dear a problem
				if(ishuman(M))//don't remove people from the round randomly you jerks
					var/mob/living/carbon/human/human = M
					if(human.dna && human.dna.species.id == "human")
						M  << "<span class='italics'>You hear a buzzing in your ears.</span>"
						human.set_species(/datum/species/fly)

					human.apply_effect((rand(120 - accurate * 40, 180 - accurate * 60)), IRRADIATE, 0)
			calibrated = 0
	return

/obj/machinery/teleport/hub/update_icon()
	if(panel_open)
		icon_state = "tele-o"
	else if(is_ready())
		icon_state = "tele1"
	else
		icon_state = "tele0"

/obj/machinery/teleport/hub/power_change()
	..()
	update_icon()

/obj/machinery/teleport/hub/proc/is_ready()
	. = !panel_open && !(stat & (BROKEN|NOPOWER)) && power_station && power_station.engaged && !(power_station.stat & (BROKEN|NOPOWER))

/obj/machinery/teleport/hub/syndicate/New()
	..()
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	RefreshParts()
=======
	var/opened = 0.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	density = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY

/obj/machinery/teleport/hub/power_change()
	..()
	if(stat & (BROKEN|NOPOWER))
		engaged = 0
	update_icon()

/obj/machinery/teleport/hub/update_icon()
	if(stat & (BROKEN|NOPOWER) || !engaged)
		icon_state = "tele0"
	else
		icon_state = "tele1"

/obj/machinery/teleport/hub/attackby(obj/item/weapon/O as obj, mob/user as mob)
	return(..())

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/teleport/hub/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/telehub,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/capacitor/adv/super,
		/obj/item/weapon/stock_parts/capacitor/adv/super,
		/obj/item/weapon/stock_parts/capacitor/adv/super,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/subspace/treatment,
		/obj/item/weapon/stock_parts/subspace/crystal,
		/obj/item/weapon/stock_parts/subspace/crystal,
		/obj/item/weapon/stock_parts/subspace/transmitter,
		/obj/item/weapon/stock_parts/subspace/transmitter,
		/obj/item/weapon/stock_parts/subspace/transmitter,
		/obj/item/weapon/stock_parts/subspace/transmitter
	)

	RefreshParts()

/obj/machinery/teleport/hub/Crossed(AM as mob|obj)
	if(AM == src)	return//DUH
	if(istype(AM,/obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = AM
		B.wait = 1
	if(istype(AM,/obj/effect/beam))
		src.Bump(AM)
		return
	spawn()
		if (src.engaged)
			teleport(AM)
			use_power(5000)

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj)
	var/atom/l = src.loc
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	if (!com)
		return
	if (!com.locked)
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='warning'>Failure: Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if (istype(M, /atom/movable))
		if(prob(5) && !accurate) //oh dear a problem, put em in deep space
			do_teleport(M, locate(rand((2*TRANSITIONEDGE), world.maxx - (2*TRANSITIONEDGE)), rand((2*TRANSITIONEDGE), world.maxy - (2*TRANSITIONEDGE)), 3), 2)
		else
			do_teleport(M, com.locked) //dead-on precision

		if(com.one_time_use) //Make one-time-use cards only usable one time!
			com.one_time_use = 0
			com.locked = null
	else
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488


/obj/machinery/teleport/station
	name = "station"
<<<<<<< HEAD
	desc = "The power control station for a bluespace teleporter. Used for toggling power, and can activate a test-fire to prevent malfunctions."
	icon_state = "controller"
	var/engaged = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/computer/teleporter/teleporter_console
	var/obj/machinery/teleport/hub/teleporter_hub
	var/list/linked_stations = list()
	var/efficiency = 0

/obj/machinery/teleport/station/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/teleporter_station(null)
	B.apply_default_parts(src)
	link_console_and_hub()

/obj/item/weapon/circuitboard/machine/teleporter_station
	name = "circuit board (Teleporter Station)"
	build_path = /obj/machinery/teleport/station
	origin_tech = "programming=4;engineering=4;bluespace=4;plasmatech=3"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/machinery/teleport/station/initialize()
	link_console_and_hub()

/obj/machinery/teleport/station/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E - 1

/obj/machinery/teleport/station/proc/link_console_and_hub()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		teleporter_hub = locate(/obj/machinery/teleport/hub, get_step(src, dir))
		if(teleporter_hub)
			teleporter_hub.link_power_station()
			break
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		teleporter_console = locate(/obj/machinery/computer/teleporter, get_step(src, dir))
		if(teleporter_console)
			teleporter_console.link_power_station()
			break
	return teleporter_hub && teleporter_console


/obj/machinery/teleport/station/Destroy()
	if(teleporter_hub)
		teleporter_hub.power_station = null
		teleporter_hub.update_icon()
		teleporter_hub = null
	if (teleporter_console)
		teleporter_console.power_station = null
		teleporter_console = null
	return ..()

/obj/machinery/teleport/station/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		if(panel_open)
			M.buffer = src
			user << "<span class='caution'>You download the data to the [W.name]'s buffer.</span>"
		else
			if(M.buffer && istype(M.buffer, /obj/machinery/teleport/station) && M.buffer != src)
				if(linked_stations.len < efficiency)
					linked_stations.Add(M.buffer)
					M.buffer = null
					user << "<span class='caution'>You upload the data from the [W.name]'s buffer.</span>"
				else
					user << "<span class='alert'>This station can't hold more information, try to use better parts.</span>"
		return
	else if(default_deconstruction_screwdriver(user, "controller-o", "controller", W))
		update_icon()
		return

	else if(exchange_parts(user, W))
		return

	else if(default_deconstruction_crowbar(W))
		return

	else if(istype(W, /obj/item/weapon/wirecutters))
		if(panel_open)
			link_console_and_hub()
			user << "<span class='caution'>You reconnect the station to nearby machinery.</span>"
			return
	else
		return ..()

/obj/machinery/teleport/station/attack_paw()
	src.attack_hand()

/obj/machinery/teleport/station/attack_ai()
	src.attack_hand()

/obj/machinery/teleport/station/attack_hand(mob/user)
	if(!panel_open)
		toggle(user)

/obj/machinery/teleport/station/proc/toggle(mob/user)
	if(stat & (BROKEN|NOPOWER) || !teleporter_hub || !teleporter_console )
		return
	if (teleporter_console.target)
		if(teleporter_hub.panel_open || teleporter_hub.stat & (BROKEN|NOPOWER))
			visible_message("<span class='alert'>The teleporter hub isn't responding.</span>")
		else
			src.engaged = !src.engaged
			use_power(5000)
			visible_message("<span class='notice'>Teleporter [engaged ? "" : "dis"]engaged!</span>")
	else
		visible_message("<span class='alert'>No target detected.</span>")
		src.engaged = 0
	teleporter_hub.update_icon()
	src.add_fingerprint(user)
	return

/obj/machinery/teleport/station/power_change()
	..()
	update_icon()
	if(teleporter_hub)
		teleporter_hub.update_icon()

/obj/machinery/teleport/station/update_icon()
	if(panel_open)
		icon_state = "controller-o"
	else if(stat & (BROKEN|NOPOWER))
		icon_state = "controller-p"
	else
		icon_state = "controller"
=======
	desc = "It's the station thingy of a teleport thingy." //seriously, wtf.
	icon_state = "controller"
	var/opened = 0.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000

	machine_flags = SCREWTOGGLE | CROWDESTROY

/obj/machinery/teleport/station/power_change()
	..()
	if(stat & (BROKEN|NOPOWER))
		disengage()
	update_icon()

/obj/machinery/teleport/station/update_icon()
	if(stat & NOPOWER)
		icon_state = "controller-p"
	else
		icon_state = "controller"

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
obj/machinery/teleport/station/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/telestation,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/capacitor/adv/super,
		/obj/item/weapon/stock_parts/capacitor/adv/super,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/analyzer
	)

	RefreshParts()

/obj/machinery/teleport/station/attackby(var/obj/item/weapon/W, var/mob/user as mob)
	if (..())
		return 1
	else
		src.attack_hand()

/obj/machinery/teleport/station/attack_paw(var/mob/user)
	src.attack_hand(user)

/obj/machinery/teleport/station/attack_ai(var/mob/user)
	src.attack_hand(user)

/obj/machinery/teleport/station/attack_hand(var/mob/user)
	if(engaged)
		src.disengage()
	else
		src.engage()

/obj/machinery/teleport/station/proc/engage()
	if(stat & (BROKEN|NOPOWER))
		return

	var/atom/l = src.loc
	var/obj/machinery/teleport/hub/hub = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (hub)
		hub.engaged = 1
		hub.update_icon()
		use_power(5000)
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='notice'>Teleporter engaged!</span>", 2)
	src.add_fingerprint(usr)
	src.engaged = 1
	return

/obj/machinery/teleport/station/proc/disengage()
	var/atom/l = src.loc
	var/obj/machinery/teleport/hub/hub = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (hub)
		hub.engaged = 0
		hub.update_icon()
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='notice'>Teleporter disengaged!</span>", 2)
	src.add_fingerprint(usr)
	src.engaged = 0
	return

/obj/machinery/teleport/station/verb/testfire()
	set name = "Test Fire Teleporter"
	set category = "Object"
	set src in oview(1)

	if(stat & (BROKEN|NOPOWER) || !istype(usr,/mob/living))
		return

	var/atom/l = src.loc
	var/obj/machinery/teleport/hub/hub = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (hub)
		engaged = 1
		var/wasaccurate = hub.accurate //let's make sure if you have a mapped in accurate tele that it stays that way
		hub.accurate = 1
		hub.engaged = 1
		hub.update_icon()
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='notice'>Test firing! Teleporter temporarily calibrated to be more accurate.</span>", 2)
		hub.teleport()
		use_power(5000)

		spawn(30)
			hub.accurate = wasaccurate
			for(var/mob/B in hearers(src, null))
				B.show_message("<span class='notice'>Test fire completed.</span>", 2)

	src.add_fingerprint(usr)
	return


/obj/effect/laser/Bump()
	src.range--
	return

/obj/effect/laser/Move()
	src.range--
	return

/atom/proc/laserhit(L as obj)
	return 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
