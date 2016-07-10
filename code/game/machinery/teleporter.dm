/obj/machinery/computer/teleporter
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
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
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
	return

/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	anchored = 1.0
	var/lockeddown = 0
	var/engaged = 0
	ghost_read=0 // #519
	ghost_write=0



/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	var/accurate = 0
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



/obj/machinery/teleport/station
	name = "station"
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
