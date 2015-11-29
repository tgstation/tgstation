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
			to_chat(usr, "You insert the coordinates into the machine.")
			to_chat(usr, "A message flashes across the screen reminding the traveller that the nuclear authentication disk is to remain on the station at all times.")
			user.drop_item(I)
			qdel(I)

			/* FUCK YOU
			if(C.data == "Clown Land")
				//whoops
				for(var/mob/O in hearers(src, null))
					O.show_message("<span class='warning'>Incoming bluespace portal detected, unable to lock in.</span>", 2)

				for(var/obj/machinery/teleport/hub/H in range(1))
					var/amount = rand(2,5)
					for(var/i=0;i<amount;i++)
						new /mob/living/simple_animal/hostile/carp(get_turf(H))
				//
			else
			*/
			say("Locked in")
			src.locked = L
			one_time_use = 1

			src.add_fingerprint(usr)
	return

/obj/machinery/computer/teleporter/examine(var/mob/user)
	..()
	if(locked)
		var/area/locked_area = get_area(locked)
		to_chat(user, "The destination is set to \"[locked_area.name]\"")

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
	var/engaged = 0
	density = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY

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
/*
/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	spawn()
		if (src.engaged)
			teleport(M)
			use_power(5000)
	return
*/
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
		for(var/mob/B in hearers(src, null))
			B.show_message("<span class='notice'>Test fire completed.</span>")
	return
/*
/proc/do_teleport(atom/movable/M as mob|obj, atom/destination, precision)
	if(istype(M, /obj/effect))
		del(M)
		return
	if (istype(M, /obj/item/weapon/disk/nuclear)) // Don't let nuke disks get teleported --NeoFite
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class='danger'>The [] bounces off of the portal!</span>", M.name), 1)
		return
	if (istype(M, /mob/living))
		var/mob/living/MM = M
		if(MM.locked_to_z != 0 && destination.z != MM.locked_to_z)
			MM.visible_message("<span class='danger'>[MM] bounces off the portal!</span>","<span class='warning'>You're unable to go to that destination!</span>")
			return

		if(MM.check_contents_for(/obj/item/weapon/disk/nuclear))
			to_chat(MM, "<span class='warning'>Something you are carrying seems to be unable to pass through the portal. Better drop it if you want to go through.</span>")
			return
	var/disky = 0
	for (var/atom/O in M.contents) //I'm pretty sure this accounts for the maximum amount of container in container stacking. --NeoFite
		to_chat(world, "Checking [O]([O.type]) for teleport")
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
			if(MM.locked_to_z != 0 && destination.z != MM.locked_to_z)
				M.visible_message("<span class='danger'>[M] bounces off the portal!</span>")
				return
			if(MM.check_contents_for(/obj/item/weapon/disk/nuclear))
				disky = 1
	if (disky)
		for(var/mob/P in viewers(M, null))
			P.show_message(text("<span class='danger'>The [] bounces off of the portal!</span>", M.name), 1)
		return

//Bags of Holding cause bluespace teleportation to go funky. --NeoFite
	if (istype(M, /mob/living))
		var/mob/living/MM = M
		if(MM.locked_to_z != 0 && destination.z != MM.locked_to_z)
			MM.visible_message("<span class='danger'>[MM] bounces off the portal!</span>","<span class='warning'>You're unable to go to that destination!</span>")
			return

		if(MM.check_contents_for(/obj/item/weapon/storage/backpack/holding))
			to_chat(MM, "<span class='warning'>The Bluespace interface on your Bag of Holding interferes with the teleport!</span>")
			precision = rand(1,100)
	if (istype(M, /obj/item/weapon/storage/backpack/holding))
		precision = rand(1,100)
	for (var/atom/O in M.contents) //I'm pretty sure this accounts for the maximum amount of container in container stacking. --NeoFite
		to_chat(world, "Checking [O]([O.type]) for teleport")
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
			if(MM.locked_to_z != 0 && destination.z != MM.locked_to_z)
				M.visible_message("<span class='danger'>[M] bounces off the portal!</span>")
				return
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

	//M.loc = tmploc
	M.forceMove(tmploc)
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
	var/opened = 0.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000

	machine_flags = SCREWTOGGLE | CROWDESTROY


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
	var/atom/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com)
		var/obj/machinery/teleport/hub/H = com
		H.engaged = 1
		H.icon_state = "tele1"
		use_power(5000)
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='notice'>Teleporter engaged!</span>", 2)
	src.add_fingerprint(usr)
	src.engaged = 1
	return

/obj/machinery/teleport/station/proc/disengage()
	if(stat & (BROKEN|NOPOWER))
		return

	var/atom/l = src.loc
	var/atom/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com)
		var/obj/machinery/teleport/hub/H = com
		H.engaged = 0
		H.icon_state = "tele0"
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
	var/obj/machinery/teleport/hub/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com && !active)
		active = 1
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='notice'>Test firing!</span>", 2)
		com.teleport()
		use_power(5000)

		spawn(30)
			active=0

	src.add_fingerprint(usr)
	return

/obj/machinery/teleport/station/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "controller-p"
		var/obj/machinery/teleport/hub/com = locate(/obj/machinery/teleport/hub, locate(x + 1, y, z))
		if(com)
			com.icon_state = "tele0"
	else
		icon_state = "controller"


/obj/effect/laser/Bump()
	src.range--
	return

/obj/effect/laser/Move()
	src.range--
	return

/atom/proc/laserhit(L as obj)
	return 1
