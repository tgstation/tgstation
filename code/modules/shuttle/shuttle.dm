//use this define to highlight docking port bounding boxes (ONLY FOR DEBUG USE)
//#define DOCKING_PORT_HIGHLIGHT

//NORTH default dir
/obj/docking_port
	invisibility = 101
	icon = 'icons/obj/device.dmi'
	//icon = 'icons/dirsquare.dmi'
	icon_state = "pinonfar"

	unacidable = 1
	anchored = 1

	var/id
	dir = NORTH		//this should point -away- from the dockingport door, ie towards the ship
	var/width = 0	//size of covered area, perpendicular to dir
	var/height = 0	//size of covered area, paralell to dir
	var/dwidth = 0	//position relative to covered area, perpendicular to dir
	var/dheight = 0	//position relative to covered area, parallel to dir

	//these objects are indestructable
/obj/docking_port/Destroy()
	return QDEL_HINT_LETMELIVE


//returns a list(x0,y0, x1,y1) where points 0 and 1 are bounding corners of the projected rectangle
/obj/docking_port/proc/return_coords(_x, _y, _dir)
	if(!_dir)
		_dir = dir
	if(!_x)
		_x = x
	if(!_y)
		_y = y

	//byond's sin and cos functions are inaccurate. This is faster and perfectly accurate
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	return list(
		_x + (-dwidth*cos) - (-dheight*sin),
		_y + (-dwidth*sin) + (-dheight*cos),
		_x + (-dwidth+width-1)*cos - (-dheight+height-1)*sin,
		_y + (-dwidth+width-1)*sin + (-dheight+height-1)*cos
		)


//returns turfs within our projected rectangle in a specific order.
//this ensures that turfs are copied over in the same order, regardless of any rotation
/obj/docking_port/proc/return_ordered_turfs(_x, _y, _z, _dir, area/A)
	if(!_dir)
		_dir = dir
	if(!_x)
		_x = x
	if(!_y)
		_y = y
	if(!_z)
		_z = z
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	. = list()

	var/xi
	var/yi
	for(var/dx=0, dx<width, ++dx)
		for(var/dy=0, dy<height, ++dy)
			xi = _x + (dx-dwidth)*cos - (dy-dheight)*sin
			yi = _y + (dy-dheight)*cos + (dx-dwidth)*sin
			var/turf/T = locate(xi, yi, _z)
			if(A)
				if(get_area(T) == A)
					. += T
				else
					. += null
			else
				. += T

#ifdef DOCKING_PORT_HIGHLIGHT
//Debug proc used to highlight bounding area
/obj/docking_port/proc/highlight(_color)
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1],L[2],z)
	var/turf/T1 = locate(L[3],L[4],z)
	for(var/turf/T in block(T0,T1))
		T.color = _color
		T.maptext = null
	if(_color)
		var/turf/T = locate(L[1], L[2], z)
		T.color = "#0f0"
		T = locate(L[3], L[4], z)
		T.color = "#00f"
#endif

//return first-found touching dockingport
/obj/docking_port/proc/get_docked()
	return locate(/obj/docking_port/stationary) in loc

/obj/docking_port/proc/getDockedId()
	var/obj/docking_port/P = get_docked()
	if(P) return P.id

/obj/docking_port/stationary
	name = "dock"

	var/turf_type = /turf/space
	var/area_type = /area/space

/obj/docking_port/stationary/New()
	..()
	SSshuttle.stationary += src
	if(!id)
		id = "[SSshuttle.stationary.len]"
	if(name == "dock")
		name = "dock[SSshuttle.stationary.len]"

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#f00")
	#endif

//returns first-found touching shuttleport
/obj/docking_port/stationary/get_docked()
	return locate(/obj/docking_port/mobile) in loc
	/*
	for(var/turf/T in return_ordered_turfs())
		. = locate(/obj/docking_port/mobile) in loc
		if(.)
			return .
	*/

/obj/docking_port/stationary/transit
	name = "In Transit"
	turf_type = /turf/space/transit

/obj/docking_port/stationary/transit/New()
	..()
	SSshuttle.transit += src


/obj/docking_port/mobile
	icon_state = "mobile"
	name = "shuttle"
	icon_state = "pinonclose"

	var/area/shuttle/areaInstance

	var/timer						//used as a timer (if you want time left to complete move, use timeLeft proc)
	var/mode = SHUTTLE_IDLE			//current shuttle mode (see global defines)
	var/callTime = 50				//time spent in transit (deciseconds)

	var/travelDir = 0			//direction the shuttle would travel in

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous

/obj/docking_port/mobile/New()
	..()
	SSshuttle.mobile += src

	var/area/A = get_area(src)
	if(istype(A, /area/shuttle))
		areaInstance = A

	if(!id)
		id = "[SSshuttle.mobile.len]"
	if(name == "shuttle")
		name = "shuttle[SSshuttle.mobile.len]"

	if(!areaInstance)
		areaInstance = new()
		areaInstance.name = name
		areaInstance.contents += return_ordered_turfs()

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#0f0")
	#endif

//this is a hook for custom behaviour. Maybe at some point we could add checks to see if engines are intact
/obj/docking_port/mobile/proc/canMove()
	return 0	//0 means we can move

//this is to check if this shuttle can physically dock at dock S
/obj/docking_port/mobile/proc/canDock(obj/docking_port/stationary/S)
	if(!istype(S))
		return 1
	if(istype(S, /obj/docking_port/stationary/transit))
		return 0
	//check dock is big enough to contain us
	if(dwidth > S.dwidth)
		return 2
	if(width-dwidth > S.width-S.dwidth)
		return 3
	if(dheight > S.dheight)
		return 4
	if(height-dheight > S.height-S.dheight)
		return 5
	//check the dock isn't occupied
	if(S.get_docked())
		return 6
	return 0	//0 means we can dock

//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S)
	if(canDock(S))
		ERROR("[type](\"[name]\") cannot dock at [S]\")")
		return 1	//we can't dock at S

	switch(mode)
		if(SHUTTLE_CALL)
			if(S == destination)
				if(world.time <= timer)
					timer = world.time
			else
				destination = S
				timer = world.time
		if(SHUTTLE_RECALL)
			if(S == destination)
				timer = world.time - timeLeft(1)
			else
				destination = S
				timer = world.time
			mode = SHUTTLE_CALL
		else
			destination = S
			mode = SHUTTLE_CALL
			timer = world.time
			enterTransit()		//hyperspace

//recall the shuttle to where it was previously
/obj/docking_port/mobile/proc/cancel()
	if(mode != SHUTTLE_CALL)
		return

	timer = world.time - timeLeft(1)
	mode = SHUTTLE_RECALL

/obj/docking_port/mobile/proc/enterTransit()
	previous = null
//		if(!destination)
//			return
	var/obj/docking_port/stationary/S0 = get_docked()
	var/obj/docking_port/stationary/S1 = findTransitDock()
	if(S1)
		if(dock(S1))
			WARNING("shuttle \"[id]\" could not enter transit space. Docked at [S0 ? S0.id : "null"]. Transit dock [S1 ? S1.id : "null"].")
		else
			previous = S0
	else
		WARNING("shuttle \"[id]\" could not enter transit space. S0=[S0 ? S0.id : "null"] S1=[S1 ? S1.id : "null"]")

//this is the main proc. It instantly moves our mobile port to stationary port S1
//it handles all the generic behaviour, such as sanity checks, closing doors on the shuttle, stunning mobs, etc
/obj/docking_port/mobile/proc/dock(obj/docking_port/stationary/S1)
	. = canDock(S1)
	if(.)
		ERROR("[type](\"[name]\") cannot dock at [S1]")
		return .

	if(canMove())
		return -1

	closePortDoors()

//		//rotate transit docking ports, so we don't need zillions of variants
//		if(istype(S1, /obj/docking_port/stationary/transit))
//			S1.dir = turn(NORTH, -travelDir)

	var/obj/docking_port/stationary/S0 = get_docked()
	var/turf_type = /turf/space
	var/area_type = /area/space
	if(S0)
		if(S0.turf_type)
			turf_type = S0.turf_type
		if(S0.area_type)
			area_type = S0.area_type

	var/list/L0 = return_ordered_turfs(x, y, z, dir, areaInstance)
	var/list/L1 = return_ordered_turfs(S1.x, S1.y, S1.z, S1.dir)

	//remove area surrounding docking port
	if(areaInstance.contents.len)
		var/area/A0 = locate("[area_type]")
		if(!A0)
			A0 = new area_type(null)
		for(var/turf/T0 in L0)
			A0.contents += T0

	//move or squish anything in the way ship at destination
	roadkill(L1, S1.dir)

	for(var/i=1, i<=L0.len, ++i)
		var/turf/T0 = L0[i]
		if(!T0)
			continue
		var/turf/T1 = L1[i]
		if(!T1)
			continue

		T0.copyTurf(T1)
		areaInstance.contents += T1

		//copy over air
		if(istype(T1, /turf/simulated))
			var/turf/simulated/Ts1 = T1
			Ts1.copy_air_with_tile(T0)

		//move mobile to new location
		loc = S1.loc
		dir = S1.dir

		//move all objects
		for(var/obj/O in T0)
			if(O.invisibility >= 101)
				continue
			if(O == T0.lighting_object)
				continue
			O.loc = T1

			//close open doors
			if(istype(O, /obj/machinery/door))
				var/obj/machinery/door/Door = O
				spawn(-1)
					if(Door)
						Door.close()

		for(var/mob/M in T0)
			if(!M.move_on_shuttle)
				continue
			M.loc = T1

			//docking turbulence
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 2, 1) // turn it down a bit come on
					else
						shake_camera(M, 7, 1)
			if(istype(M, /mob/living/carbon))
				if(!M.buckled)
					M.Weaken(3)

		T0.ChangeTurf(turf_type)

	//air system updates
	for(var/turf/T1 in L1)
		T1.redraw_lighting()
		SSair.remove_from_active(T1)
		T1.CalculateAdjacentTurfs()
		SSair.add_to_active(T1,1)

	for(var/turf/T0 in L0)
		T0.redraw_lighting()
		SSair.remove_from_active(T0)
		T0.CalculateAdjacentTurfs()
		SSair.add_to_active(T0,1)

/*
	if(istype(S1, /obj/docking_port/stationary/transit))
		var/d = turn(dir, 180 + travelDir)
		for(var/turf/space/transit/T in S1.return_ordered_turfs())
			T.pushdirection = d
			T.update_icon()
*/

/obj/docking_port/mobile/proc/findTransitDock()
	var/obj/docking_port/stationary/transit/T = SSshuttle.getDock("[id]_transit")
	if(T && !canDock(T))
		return T
/*	commented out due to issues with rotation
	for(var/obj/docking_port/stationary/transit/S in SSshuttle.transit)
		if(S.id)
			continue
		if(!canDock(S))
			return S
*/


//shuttle-door closing is handled in the dock() proc whilst looping through turfs
//this one closes the door where we are docked at, if there is one there.
/obj/docking_port/mobile/proc/closePortDoors()
	var/turf/T = get_step(loc, turn(dir,180))
	if(T)
		var/obj/machinery/door/Door = locate() in T
		if(Door)
			spawn(-1)
				Door.close()

/obj/docking_port/mobile/proc/roadkill(list/L, dir, x, y)
	for(var/turf/T in L)
		for(var/atom/movable/AM in T)
			if(ismob(AM))
				if(istype(AM, /mob/living))
					var/mob/living/M = AM
					M.Paralyse(10)
					M.take_organ_damage(80)
					M.anchored = 0
				else
					continue

			if(!AM.anchored)
				step(AM, dir)
			else
				qdel(AM)
/*
//used to check if atom/A is within the shuttle's bounding box
/obj/docking_port/mobile/proc/onShuttleCheck(atom/A)
	var/turf/T = get_turf(A)
	if(!T)
		return 0

	var/list/L = return_coords()
	if(L[1] > L[3])
		L.Swap(1,3)
	if(L[2] > L[4])
		L.Swap(2,4)

	if(L[1] <= T.x && T.x <= L[3])
		if(L[2] <= T.y && T.y <= L[4])
			return 1
	return 0
*/
//used by shuttle subsystem to check timers
/obj/docking_port/mobile/proc/check()
	var/timeLeft = timeLeft(1)
	if(timeLeft <= 0)
		switch(mode)
			if(SHUTTLE_CALL)
				if(dock(destination))
					setTimer(20)	//can't dock for some reason, try again in 2 seconds
					return
			if(SHUTTLE_RECALL)
				if(dock(previous))
					setTimer(20)	//can't dock for some reason, try again in 2 seconds
					return
		mode = SHUTTLE_IDLE
		timer = 0
		destination = null


/obj/docking_port/mobile/proc/setTimer(wait)
	if(timer <= 0)
		timer = world.time
	timer += wait - timeLeft(1)

//returns timeLeft
/obj/docking_port/mobile/proc/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10
	if(!timer)
		return round(callTime/divisor, 1)
	return max( round((timer+callTime-world.time)/divisor,1), 0 )

/obj/docking_port/mobile/proc/getStatusText()
	var/obj/docking_port/stationary/dockedAt = get_docked()
	. = (dockedAt && dockedAt.name) ? dockedAt.name : "unknown"
	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		var/obj/docking_port/stationary/dst
		if(mode == SHUTTLE_RECALL)
			dst = previous
		else
			dst = destination
		. += " towards [dst ? dst.name : "unknown location"] ([timeLeft(600)]mins)"

/obj/machinery/computer/shuttle
	name = "Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = list( )
	circuit = /obj/item/weapon/circuitboard/shuttle
	var/shuttleId
	var/possible_destinations = ""
	var/admin_controlled

/obj/machinery/computer/shuttle/New(location, obj/item/weapon/circuitboard/shuttle/C)
	..()
	if(istype(C))
		possible_destinations = C.possible_destinations
		shuttleId = C.shuttleId

/obj/machinery/computer/shuttle/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)

	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(M.canDock(S))
				continue
			destination_found = 1
			dat += "<A href='?src=\ref[src];move=[S.id]'>Send to [S.name]</A><br>"
		if(!destination_found)
			dat += "<B>Shuttle Locked</B><br>"
			if(admin_controlled)
				dat += "Authorized personnel only<br>"
				dat += "<A href='?src=\ref[src];request=1]'>Request Authorization</A><br>"
	dat += "<a href='?src=\ref[user];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/shuttle/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(!allowed(usr))
		usr << "<span class='danger'>Access denied.</span>"
		return

	if(href_list["move"])
		switch(SSshuttle.moveShuttle(shuttleId, href_list["move"], 1))
			if(0)	usr << "<span class='notice'>Shuttle received message and will be sent shortly.</span>"
			if(1)	usr << "<span class='warning'>Invalid shuttle requested.</span>"
			else	usr << "<span class='notice'>Unable to comply.</span>"

/obj/machinery/computer/shuttle/emag_act(mob/user as mob)
	if(!emagged)
		src.req_access = list()
		emagged = 1
		user << "<span class='notice'> You fried the consoles ID checking system.</span>"

/obj/machinery/computer/shuttle/ferry
	name = "transport ferry console"
	circuit = /obj/item/weapon/circuitboard/ferry
	shuttleId = "ferry"
	possible_destinations = "ferry_home;ferry_away"


/obj/machinery/computer/shuttle/ferry/request
	name = "ferry console"
	circuit = /obj/item/weapon/circuitboard/ferry/request
	var/cooldown //prevents spamming admins
	possible_destinations = "ferry_home"
	admin_controlled = 1

/obj/machinery/computer/shuttle/ferry/request/Topic(href, href_list)
	..()
	if(href_list["request"])
		if(cooldown)
			return
		cooldown = 1
		usr << "<span class='notice'>Your request has been recieved by Centcom.</span>"
		admins << "<b>FERRY: <font color='blue'>[key_name_admin(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) (<A HREF='?_src_=holder;secretsadmin=moveferry'>Move Ferry</a>)</b> is requesting to move the transport ferry to Centcom.</font>"
		spawn(600) //One minute cooldown
			cooldown = 0


#undef DOCKING_PORT_HIGHLIGHT


/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		var/obj/O
		if(underlays.len)	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays.Add(T)
		T = new type(T)
		if(underlays.len)
			T.underlays = O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	return T