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

/obj/machinery/teleport/station/attack_ai()
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


/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	var/accurate = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000

/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	spawn()
		if (src.icon_state == "tele1")
			teleport(M)
			use_power(5000)
	return

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj)
	var/atom/l = src.loc
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	if (!com)
		return
	if (!com.locked)
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='warning'>Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if (istype(M, /atom/movable))
		if(prob(10) && !accurate) //oh dear a problem
			do_teleport(M, com.locked)
			if(ishuman(M))//don't remove people from the round randomly you jerks
				var/mob/living/carbon/human/human = M
				if(human.dna && !human.dna.mutantrace)
					M  << "<span class='danger'>You hear a buzzing in your ears.</span>"
					human.dna.mutantrace = "fly"
					human.update_body()
					human.update_hair()
				human.apply_effect((rand(90, 150)), IRRADIATE, 0)
				randmutb(human)
				domutcheck(human, null)
		else
			do_teleport(M, com.locked) //dead-on precision
			if(prob(30) && accurate)//the gate will need recalibration after some use.
				for(var/mob/B in hearers(src, null))
					B.show_message("<span class='warning'>[src] has become uncalibrated.</span>")
				accurate = 0
				playsound(src.loc, 'sound/effects/EMPulse.ogg', 30, 0)


		if(com.one_time_use) //Make one-time-use cards only usable one time!
			com.one_time_use = 0
			com.locked = null
	else
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		for(var/mob/B in hearers(src, null))
			B.show_message("<span class='notice'>Test fire completed.</span>")
			accurate = 1
	return

/obj/machinery/teleport/hub/examine()
	set src in view()
	..()
	if(accurate)
		usr << "<span class='notice'>[src] is fully calibrated.</span>"
	else
		usr << "<span class='warning'>[src] is uncalibrated!</span>"
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
		if (istype(O, /obj/item/weapon/storage))
			for (var/obj/OO in O.contents)
				if (istype(OO, /obj/item/weapon/storage))
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
		if (istype(O, /obj/item/weapon/storage))
			for (var/obj/OO in O.contents)
				if (istype(OO, /obj/item/weapon/storage))
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
	desc = "The power control station for a bluespace teleporter. Used for toggling power, and can activate a test-fire to prevent malfunctions."
	icon_state = "controller"
	var/active = 0
	var/engaged = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000

/obj/machinery/teleport/station/attackby(var/obj/item/weapon/W)
	src.attack_hand()

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

	var/atom/l = src.loc
	var/atom/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com)
		com.icon_state = "tele1"
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
		com.icon_state = "tele0"
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
