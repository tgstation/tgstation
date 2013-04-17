/obj/machinery/computer/teleporter
	name = "teleporter control console"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/teleporter"
	var/obj/item/locked = null
	var/id = null
	var/one_time_use = 0 //Used for one-time-use teleport cards (such as clown planet coordinates.)
						 //Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.

/obj/machinery/computer/teleporter/New()
	src.id = "[rand(1000, 9999)]"
	..()
	return


/obj/machinery/computer/teleporter/attackby(I as obj, mob/living/user as mob)
	if(istype(I, /obj/item/weapon/card/data/))
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
			src.locked = L
			one_time_use = 1

			usr << "You insert the coordinates into the machine."
			usr << "A message flashes across the screen reminding the traveller that the nuclear authentication disk is to remain on the station at all times."
			user.drop_item()
			del(I)

			for(var/mob/O in hearers(src, null))
				O.show_message("\blue Locked In", 2)
			src.add_fingerprint(usr)
	else
		..()

	return

/obj/machinery/computer/teleporter/attack_paw()
	src.attack_hand()

/obj/machinery/computer/teleporter/attack_hand()
	if(stat & (NOPOWER|BROKEN))
		return

	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/device/radio/beacon/R in world)
		var/turf/T = get_turf(R)
		if (!T)
			continue
		if(T.z == 2 || T.z > 7)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	for (var/obj/item/weapon/implant/tracking/I in world)
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

	var/desc = input("Please select a location to lock in.", "Locking Computer") in L
	src.locked = L[desc]
	for(var/mob/O in hearers(src, null))
		O.show_message("\blue Locked In", 2)
	src.add_fingerprint(usr)
	return

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

/proc/find_loc(obj/R as obj)
	if (!R)	return null
	var/turf/T = R.loc
	while(!istype(T, /turf))
		T = T.loc
		if(!T || istype(T, /area))	return null
	return T

/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	anchored = 1.0
	var/lockeddown = 0
	var/construct_op = 0


/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	var/accurate = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/teleport/station/stati = 0
	var/obj/machinery/computer/teleporter/com

/obj/machinery/teleport/hub/New() //adds the parts to its components_parts variable
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/teleporter/hub(src)
	component_parts += new /obj/item/weapon/stock_parts/subspace/transmitter(src)
	component_parts += new /obj/item/weapon/stock_parts/subspace/transmitter(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/ultra(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/ultra(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/ultra(src)
	RefreshParts()
	connect()

/obj/machinery/teleport/hub/attackby(var/obj/item/P as obj, var/mob/user as mob)
	switch(construct_op)
		if(0)
			if(istype(P, /obj/item/weapon/screwdriver))
				user << "You unfasten the bolts."
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				disconnect()
				stat |= BROKEN // make sure the machine won't work during deconstruction.
				construct_op ++
		if(1)
			if(istype(P, /obj/item/weapon/screwdriver))
				user << "You fasten the bolts."
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				construct_op --
			if(istype(P, /obj/item/weapon/wrench))
				user << "You dislodge the external plating."
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				stat &= ~BROKEN
				construct_op ++
		if(2)
			if(istype(P, /obj/item/weapon/wrench))
				user << "You secure the external plating."
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				construct_op --
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user << "You remove the cables."
				construct_op ++
				var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( user.loc )
				A.amount = 5
		if(3)
			if(istype(P, /obj/item/weapon/cable_coil))
				var/obj/item/weapon/cable_coil/A = P
				if(A.amount >= 5)
					user << "You insert the cables."
					A.amount -= 5
					if(A.amount <= 0)
						user.drop_item()
						del(A)
					construct_op --
			if(istype(P, /obj/item/weapon/crowbar))
				user << "You begin prying out the circuit board other components..."
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				if(do_after(user,60))
					user << "You finish prying out the components."

					// Drop all the component stuff
					for(var/obj/x in src)
						x.loc = user.loc
					var/obj/machinery/constructable_frame/machine_frame/F = new
					F.loc = src.loc
					del(src)

/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	spawn()
		if (src.icon_state == "tele1")
			teleport(M)
			use_power(5000)
	return

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj)
	connect()
	if (!com)
		return
	if (!com.locked)
		for(var/mob/O in hearers(src, null))
			O.show_message("\red Failure: Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.")
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
		for(var/mob/B in hearers(src, null))
			B.show_message("\blue Test fire completed.")
	return

/obj/machinery/teleport/hub/verb/connect()
	set name = "Connect"
	set category = "Object"
	set src in oview(1)
	var/sta = 0

	for(dir in cardinal)
		sta = get_step(src,dir)
		stati = locate(/obj/machinery/teleport/station, get_step(src,dir))
		com = locate(/obj/machinery/computer/teleporter, get_step(sta, dir))
		if ((com) && (stati))
			break
	return

/obj/machinery/teleport/hub/verb/disconnect()
	set name = "Disconnect"
	set category = "Object"
	com = null
	icon_state = "tele0"
	if (stati)
		stati.engaged = 0
	return
/*
/proc/do_teleport(atom/movable/M as mob|obj, atom/destination, precision)
	if(istype(M, /obj/effect))
		del(M)
		return
	if (istype(M, /obj/item/weapon/disk/nuclear)) // Don't let nuke disks get teleported --NeoFite
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>The [] bounces off of the portal!</B>", M.name), 1)
		return
	if (istype(M, /mob/living))
		var/mob/living/MM = M
		if(MM.check_contents_for(/obj/item/weapon/disk/nuclear))
			MM << "\red Something you are carrying seems to be unable to pass through the portal. Better drop it if you want to go through."
			return
	var/disky = 0
	for (var/atom/O in M.contents) //I'm pretty sure this accounts for the maximum amount of container in container stacking. --NeoFite
		if (istype(O, /obj/item/weapon/storage) || istype(O, /obj/item/weapon/gift))
			for (var/obj/OO in O.contents)
				if (istype(OO, /obj/item/weapon/storage) || istype(OO, /obj/item/weapon/gift))
					for (var/obj/OOO in OO.contents)
						if (istype(OOO, /obj/item/weapon/disk/nuclear))
							disky = 1
				if (istype(OO, /obj/item/weapon/disk/nuclear))
					disky = 1
		if (istype(O, /obj/item/weapon/disk/nuclear))
			disky = 1
		if (istype(O, /mob/living))
			var/mob/living/MM = O
			if(MM.check_contents_for(/obj/item/weapon/disk/nuclear))
				disky = 1
	if (disky)
		for(var/mob/P in viewers(M, null))
			P.show_message(text("\red <B>The [] bounces off of the portal!</B>", M.name), 1)
		return

//Bags of Holding cause bluespace teleportation to go funky. --NeoFite
	if (istype(M, /mob/living))
		var/mob/living/MM = M
		if(MM.check_contents_for(/obj/item/weapon/storage/backpack/holding))
			MM << "\red The Bluespace interface on your Bag of Holding interferes with the teleport!"
			precision = rand(1,100)
	if (istype(M, /obj/item/weapon/storage/backpack/holding))
		precision = rand(1,100)
	for (var/atom/O in M.contents) //I'm pretty sure this accounts for the maximum amount of container in container stacking. --NeoFite
		if (istype(O, /obj/item/weapon/storage) || istype(O, /obj/item/weapon/gift))
			for (var/obj/OO in O.contents)
				if (istype(OO, /obj/item/weapon/storage) || istype(OO, /obj/item/weapon/gift))
					for (var/obj/OOO in OO.contents)
						if (istype(OOO, /obj/item/weapon/storage/backpack/holding))
							precision = rand(1,100)
				if (istype(OO, /obj/item/weapon/storage/backpack/holding))
					precision = rand(1,100)
		if (istype(O, /obj/item/weapon/storage/backpack/holding))
			precision = rand(1,100)
		if (istype(O, /mob/living))
			var/mob/living/MM = O
			if(MM.check_contents_for(/obj/item/weapon/storage/backpack/holding))
				precision = rand(1,100)


	var/turf/destturf = get_turf(destination)

	var/tx = destturf.x + rand(precision * -1, precision)
	var/ty = destturf.y + rand(precision * -1, precision)

	var/tmploc

	if (ismob(destination.loc)) //If this is an implant.
		tmploc = locate(tx, ty, destturf.z)
	else
		tmploc = locate(tx, ty, destination.z)

	if(tx == destturf.x && ty == destturf.y && (istype(destination.loc, /obj/structure/closet) || istype(destination.loc, /obj/structure/closet/secure_closet)))
		tmploc = destination.loc

	if(tmploc==null)
		return

	M.loc = tmploc
	sleep(2)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, M)
	s.start()
	return
*/

/obj/machinery/teleport/station
	name = "station"
	desc = "It's the station thingy of a teleport thingy." //seriously, wtf.
	icon_state = "controller"
	var/active = 0
	var/engaged = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/teleport/hub/hub = 0

/obj/machinery/teleport/station/New() //adds the parts to its components_parts variable
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/teleporter/station(src)
	component_parts += new /obj/item/weapon/stock_parts/subspace/transmitter(src)
	component_parts += new /obj/item/weapon/stock_parts/subspace/transmitter(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module/phasic(src)
	RefreshParts()
	connect()

/obj/machinery/teleport/station/attackby(var/obj/item/P as obj, var/mob/user as mob)
	switch(construct_op)
		if(0)
			if(istype(P, /obj/item/weapon/screwdriver))
				if (engaged)
					src.disengage()
				disconnect()
				user << "You unfasten the bolts."
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				stat |= BROKEN //prevents it from working while being deconstructed
				construct_op ++
		if(1)
			if(istype(P, /obj/item/weapon/screwdriver))
				user << "You fasten the bolts."
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				construct_op --
			if(istype(P, /obj/item/weapon/wrench))
				user << "You dislodge the external plating."
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				stat &= ~BROKEN // the machine's not borked anymore!
				construct_op ++
		if(2)
			if(istype(P, /obj/item/weapon/wrench))
				user << "You secure the external plating."
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				construct_op --
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user << "You remove the cables."
				construct_op ++
				var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( user.loc )
				A.amount = 5
		if(3)
			if(istype(P, /obj/item/weapon/cable_coil))
				var/obj/item/weapon/cable_coil/A = P
				if(A.amount >= 5)
					user << "You insert the cables."
					A.amount -= 5
					if(A.amount <= 0)
						user.drop_item()
						del(A)
					construct_op --
			if(istype(P, /obj/item/weapon/crowbar))
				user << "You begin prying out the circuit boards other components..."
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				if(do_after(user,60))
					user << "You finish prying out the components."

					// Drop all the component stuff
					for(var/obj/x in src)
						x.loc = user.loc
					var/obj/machinery/constructable_frame/machine_frame/F = new
					F.loc = src.loc
					del(src)

/obj/machinery/teleport/station/attack_paw()
	src.attack_hand()

/obj/machinery/teleport/station/attack_ai()
	src.attack_hand()

/obj/machinery/teleport/station/attack_hand()
	if(engaged)
		src.disengage()
	else
		src.engage()

/obj/machinery/teleport/station/proc/engage()
	if(stat & (BROKEN|NOPOWER))
		return
	connect()
	if (hub)
		hub.icon_state = "tele1"
		use_power(5000)
		for(var/mob/O in hearers(src, null))
			O.show_message("\blue Teleporter engaged!", 2)
	src.add_fingerprint(usr)
	src.engaged = 1
	return

/obj/machinery/teleport/station/proc/disengage()
	if(stat & (BROKEN|NOPOWER))
		return

	connect()

	if (hub)
		hub.icon_state = "tele0"
		for(var/mob/O in hearers(src, null))
			O.show_message("\blue Teleporter disengaged!", 2)
	src.add_fingerprint(usr)
	src.engaged = 0
	return

/obj/machinery/teleport/station/verb/testfire()
	set name = "Test Fire Teleporter"
	set category = "Object"
	set src in oview(1)

	if(stat & (BROKEN|NOPOWER) || !istype(usr,/mob/living))
		return

	connect()

	if (hub && !active)
		active = 1
		for(var/mob/O in hearers(src, null))
			O.show_message("\blue Test firing!", 2)
		hub.teleport()
		use_power(5000)

		spawn(30)
			active=0

	src.add_fingerprint(usr)
	return

/obj/machinery/teleport/station/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "controller-p"
		connect()
		if(hub)
			hub.icon_state = "tele0"
	else
		icon_state = "controller"

/obj/machinery/teleport/station/verb/connect()
	set name = "Connect"
	set category = "Object"
	set src in oview(1)
	for (dir in cardinal)
		hub = locate(/obj/machinery/teleport/hub, get_step(src, dir))
		if (hub)
			break
	return

/obj/machinery/teleport/station/verb/disconnect()
	set name = "Disconnect"
	set category = "Object"
	hub = null
	active = 0
	return

/obj/effect/laser/Bump()
	src.range--
	return

/obj/effect/laser/Move()
	src.range--
	return

/atom/proc/laserhit(L as obj)
	return 1
