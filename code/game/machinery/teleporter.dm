/obj/machinery/computer/teleporter/New()
	src.id = text("[]", rand(1000, 9999))
	..()
	return

/obj/machinery/computer/teleporter/attackby(obj/item/weapon/W)
	src.attack_hand()

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
		var/turf/T = find_loc(R)
		if (!T)	continue
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

/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	spawn( 0 )
		if (src.icon_state == "tele1")
			teleport(M)
			use_power(5000)
		return
	return

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj)
	var/atom/l = src.loc
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	if (!com)
		return
	if (!com.locked)
		for(var/mob/O in hearers(src, null))
			O.show_message("\red Failure: Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.")
		return
	if (istype(M, /atom/movable))
		if(prob(5)) //oh dear a problem, put em in deep space
			do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy - 5), 3), 2)
		else
			do_teleport(M, com.locked, 0) //dead-on precision
	else
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		for(var/mob/B in hearers(src, null))
			B.show_message("\blue Test fire completed.")
	return

/proc/do_teleport(atom/movable/M as mob|obj, atom/destination, precision)
	if(istype(M, /obj/effects))
		del(M)
		return

	var/turf/destturf = get_turf(destination)

	var/tx = destturf.x + rand(precision * -1, precision)
	var/ty = destturf.y + rand(precision * -1, precision)

	var/tmploc

	if (ismob(destination.loc)) //If this is an implant.
		tmploc = locate(tx, ty, destturf.z)
	else
		tmploc = locate(tx, ty, destination.z)

	if(tx == destturf.x && ty == destturf.y && (istype(destination.loc, /obj/closet) || istype(destination.loc, /obj/secure_closet)))
		tmploc = destination.loc

	if(tmploc==null)
		return

	M.loc = tmploc
	sleep(2)

	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(5, 1, M)
	s.start()
	return

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
			O.show_message("\blue Teleporter engaged!", 2)
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
			O.show_message("\blue Teleporter disengaged!", 2)
	src.add_fingerprint(usr)
	src.engaged = 0
	return

/obj/machinery/teleport/station/verb/testfire()
	set src in oview(1)

	if(stat & (BROKEN|NOPOWER) || !istype(usr,/mob/living))
		return

	var/atom/l = src.loc
	var/obj/machinery/teleport/hub/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com && !active)
		active = 1
		for(var/mob/O in hearers(src, null))
			O.show_message("\blue Test firing!", 2)
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


/obj/laser/Bump()
	src.range--
	return

/obj/laser/Move()
	src.range--
	return

/atom/proc/laserhit(L as obj)
	return 1

/obj/machinery/computer/data/weapon/log/New()
	..()
	src.topics["Super-heater"] = "This turns a can of semi-liquid plasma into a super-heated ball of plasma."
	src.topics["Amplifier"] = "This increases the intensity of a laser."
	src.topics["Class 11 Laser"] = "This creates a very slow laser that is capable of penetrating most objects."
	src.topics["Plasma Energizer"] = "This combines super-heated plasma with a laser beam."
	src.topics["Generator"] = "This controls the entire power grid."
	src.topics["Mirror"] = "this can reflect LOW power lasers. HIGH power goes through it!"
	src.topics["Targetting Prism"] = "This focuses a laser coming from any direction forward."
	return

/obj/machinery/computer/data/weapon/log/display()
	set src in oview(1)

	usr << "<B>Research Log:</B>"
	..()
	return

/obj/machinery/computer/data/weapon/info/New()
	..()
	src.topics["LOG(001)"] = "System: Deployment successful"
	src.topics["LOG(002)"] = "System: Safe orbit at inclination .003 established"
	src.topics["LOG(003)"] = "CenCom: Attempting test fire...ALERT(001)"
	src.topics["ALERT(001)"] = "System: Cannot attempt test fire"
	src.topics["LOG(004)"] = "System: Airlock accessed..."
	src.topics["LOG(005)"] = "System: System successfully reset...Generator engaged"
	src.topics["LOG(006)"] = "Physical: Super-heater (W005) added to power grid"
	src.topics["LOG(007)"] = "Physical: Amplifier (W007) added to power grid"
	src.topics["LOG(008)"] = "Physical: Plasma Energizer (W006) added to power grid"
	src.topics["LOG(009)"] = "Physical: Laser (W004) added to power grid"
	src.topics["LOG(010)"] = "Physical: Laser test firing"
	src.topics["LOG(011)"] = "Physical: Plasma added to Super-heater"
	src.topics["LOG(012)"] = "Physical: Orient N12.525,E22.124"
	src.topics["LOG(013)"] = "System: Location N12.525,E22.124"
	src.topics["LOG(014)"] = "Physical: Test fire...successful"
	src.topics["LOG(015)"] = "Physical: Airlock accessed..."
	src.topics["LOG(016)"] = "******: Disable locater systems"
	src.topics["LOG(017)"] = "System: Locater Beacon-Disengaged,CenCom link-Cut...ALERT(002)"
	src.topics["ALERT(002)"] = "System: Cannot seem to establish contact with Central Command"
	src.topics["LOG(018)"] = "******: Shutting down all systems...ALERT(003)"
	src.topics["ALERT(003)"] = "System: Power grid failure-Activating back-up power...ALERT(004)"
	src.topics["ALERT(004)"] = "System: Engine failure...All systems deactivated."
	return

/obj/machinery/computer/data/weapon/info/display()
	set src in oview(1)

	usr << "<B>Research Information:</B>"
	..()
	return

/obj/machinery/computer/data/verb/display()
	set src in oview(1)

	for(var/x in src.topics)
		usr << text("[], \...", x)
	usr << ""
	src.add_fingerprint(usr)
	return

/obj/machinery/computer/data/verb/read(topic as text)
	set src in oview(1)

	if (src.topics[text("[]", topic)])
		usr << text("<B>[]</B>\n\t []", topic, src.topics[text("[]", topic)])
	else
		usr << text("Unable to find- []", topic)
	src.add_fingerprint(usr)
	return