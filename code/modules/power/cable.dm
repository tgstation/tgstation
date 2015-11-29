///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)


  9   1   5
	\ | /
  8 - 0 - 4
	/ | \
  10  2   6

If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

#define CABLE_PINK "#CA00B6"
#define CABLE_ORANGE "#CA6900"


/obj/structure/cable
	level = 1								// is underfloor
	anchored =1
	var/datum/powernet/powernet
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer"
	icon = 'icons/obj/power_cond_white.dmi'
	icon_state = "0-1"
	var/d1 = 0								// cable direction 1 (see above)
	var/d2 = 1								// cable direction 2 (see above)
	layer = 2.44							// just below unary stuff, which is at 2.45 and above pipes, which are at 2.4
	var/obj/item/device/powersink/attached	// holding this here for qdel
	var/_color = "red"

	//For rebuilding powernets from scratch
	var/build_status = 0 //1 means it needs rebuilding during the next tick or on usage
	var/oldavail = 0
	var/oldnewavail = 0
	var/oldload = 0

/obj/structure/cable/yellow
	_color = "yellow"

/obj/structure/cable/green
	_color = "green"

/obj/structure/cable/blue
	_color = "blue"

/obj/structure/cable/pink
	_color = "pink"

/obj/structure/cable/orange
	_color = "orange"

/obj/structure/cable/cyan
	_color = "cyan"

/obj/structure/cable/white
	_color = "white"

// the power cable object
/obj/structure/cable/New(loc)
	..(loc)

	cableColor(_color)

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num(copytext(icon_state, 1, dash))
	d2 = text2num(copytext(icon_state, dash + 1))

	var/turf/T = src.loc	// hide if turf is not intact
	var/obj/structure/catwalk/Catwalk = (locate(/obj/structure/catwalk) in get_turf(T))
	if(!istype(T))
		if(!Catwalk)
			return //It's just space, abort
	if(level == 1)
		hide(T.intact)

	cable_list += src		//add it to the global cable list

/obj/structure/cable/Destroy()			// called when a cable is deleted
	if(powernet)
		powernet.set_to_build()	// update the powernets

	cable_list -= src

	if(istype(attached))
		attached.set_light(0)
		attached.icon_state = "powersink0"
		attached.mode = 0
		processing_objects.Remove(attached)
		attached.anchored = 0
		attached.attached = null

	attached = null
	..()								// then go ahead and delete the cable

/obj/structure/cable/forceMove()
	.=..()

	if(powernet)
		powernet.set_to_build() // update the powernets

/obj/structure/cable/shuttle_rotate(angle)
	if(d1)
		d1 = turn(d1, -angle)
	if(d2)
		d2 = turn(d2, -angle)

	if(d1 > d2) //Cable icon states start with the lesser number. For example, there's no "8-4" icon state, but there is a "4-8".
		var/oldD2 = d2
		d2 = d1
		d1 = oldD2

	update_icon()

///////////////////////////////////
// General procedures
///////////////////////////////////

// if underfloor, hide the cable
/obj/structure/cable/hide(i)

	if(level == 1 && isturf(loc))
		invisibility = i ? 101 : 0

	update_icon()

/obj/structure/cable/update_icon()
	if(invisibility)
		icon_state = "[d1]-[d2]-f"
	else
		icon_state = "[d1]-[d2]"

//Provides sanity for cases in which there may not be a powernet
//Not necessary for checking powernet during process() of power_machines as it is guaranteed to have a powernet at that time
/obj/structure/cable/proc/get_powernet()
	check_rebuild()
	return powernet

// telekinesis has no effect on a cable
/obj/structure/cable/attack_tk(mob/user)
	return

// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Cable coil : merge cables
//   - Multitool : get the power currently passing through the cable
/obj/structure/cable/attackby(obj/item/W, mob/user)
	var/turf/T = src.loc

	if(T.intact)
		return

	if(istype(W, /obj/item/weapon/wirecutters))
		if(shock(user, 50))
			return

		if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			getFromPool(/obj/item/stack/cable_coil, T, 2, light_color)
		else
			getFromPool(/obj/item/stack/cable_coil, T, 1, light_color)

		user.visible_message("<span class='warning'>[user] cuts the cable.</span>", "<span class='info'>You cut the cable.</span>")

		//investigate_log("was cut by [key_name(usr, usr.client)] in [user.loc.loc]","wires")

		var/message = "A wire has been cut "
		var/atom/A = user

		if(A)
			var/turf/Z = get_turf(A)
			var/area/my_area = get_area(Z)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\\\power\cable.dm:104: message += " in [my_area.name]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</A>)"
			message += {"in [my_area.name]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</A>) (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>)"}
			// END AUTOFIX

			var/mob/M = get(A, /mob)

			if(M)
				message += " - Cut By: [M.real_name] ([M.key]) (<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)"
				log_game("[M.real_name] ([M.key]) cut a wire in [my_area.name] ([T.x],[T.y],[T.z])")

		message_admins(message, 0, 1)

		returnToPool(src)
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		coil.cable_join(src, user)
	else if(istype(W, /obj/item/weapon/rcl))
		var/obj/item/weapon/rcl/R = W
		if(R.loaded)
			R.loaded.cable_join(src, user)
			R.is_empty()
	else if(istype(W, /obj/item/device/multitool))
		if((powernet) && (powernet.avail > 0))		// is it powered?
			to_chat(user, "<SPAN CLASS='warning'>[powernet.avail]W in power network.</SPAN>")
		else
			to_chat(user, "<SPAN CLASS='notice'>The cable is not powered.</SPAN>")

		shock(user, 5, 0.2)
	else
		if(W.is_conductor())
			shock(user, 50, 0.7)

	src.add_fingerprint(user)

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1.0)
	if((get_powernet()) && (powernet.avail > 1000))
		if(!prob(prb))
			return 0

		if(electrocute_mob(user, powernet, src, siemens_coeff))
			var/datum/effect/effect/system/spark_spread/s = new
			s.set_up(5,1,src)
			s.start()
			return 1

	return 0

// explosion handling
/obj/structure/cable/ex_act(severity)
	switch(severity)
		if(1.0)
			returnToPool(src)
		if(2.0)
			if(prob(50))
				getFromPool(/obj/item/stack/cable_coil,  src.loc, src.d1 ? 2 : 1, light_color)
				returnToPool(src)

		if(3.0)
			if(prob(25))
				getFromPool(/obj/item/stack/cable_coil, src.loc, src.d1 ? 2 : 1, light_color)
				returnToPool(src)
	return

/obj/structure/cable/proc/cableColor(var/colorC = "red")
	light_color = colorC
	switch(colorC)
		if("pink")
			color = CABLE_PINK
		if("orange")
			color = CABLE_ORANGE
		else
			color = colorC

////////////////////////////////////////////
// Power related
///////////////////////////////////////////

/obj/structure/cable/proc/add_avail(var/amount)
	if(get_powernet())
		powernet.newavail += amount

/obj/structure/cable/proc/add_load(var/amount)
	if(get_powernet())
		powernet.load += amount

/obj/structure/cable/proc/surplus()
	if(get_powernet())
		return powernet.avail-powernet.load
	else
		return 0

/obj/structure/cable/proc/avail()
	if(get_powernet())
		return powernet.avail
	else
		return 0

/obj/structure/cable/proc/check_rebuild()
	if(!build_status)
		return
	rebuild_from()

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////

// handles merging diagonally matching cables
// for info : direction ^ 3 is flipping horizontally, direction ^ 12 is flipping vertically
/obj/structure/cable/proc/mergeDiagonalsNetworks(var/direction)
	// search for and merge diagonally matching cables from the first direction component (north / south)
	var/turf/T = get_step(src, direction & 3) // go north / south

	for(var/obj/structure/cable/C in T)
		if(!C)
			continue
		if(src == C)
			continue
		if(C.d1 == (direction ^ 3) || C.d2 == (direction ^ 3)) // we've got a diagonally matching cable
			if(!C.powernet) // if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = getFromPool(/datum/powernet/)
				newPN.add_cable(C)
			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

	// the same from the second direction component (east / west)
	T = get_step(src, direction & 12) // go east / west

	for(var/obj/structure/cable/C in T)
		if(!C)
			continue
		if(src == C)
			continue
		if(C.d1 == (direction ^ 12) || C.d2 == (direction ^ 12)) // we've got a diagonally matching cable
			if(!C.powernet) // if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = getFromPool(/datum/powernet/)
				newPN.add_cable(C)
			if(powernet) // if we already have a powernet, then merge the two powernets
				merge_powernets(powernet, C.powernet)
			else
				C.powernet.add_cable(src) // else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the given direction
/obj/structure/cable/proc/mergeConnectedNetworks(var/direction)
	var/fdir = (!direction) ? 0 : turn(direction, 180) // flip the direction, to match with the source position on its turf

	if(!(d1 == direction || d2 == direction)) // if the cable is not pointed in this direction, do nothing
		return

	var/turf/TB = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)
		if(!C)
			continue
		if(src == C)
			continue
		if(C.d1 == fdir || C.d2 == fdir) // we've got a matching cable in the neighbor turf
			if(!C.powernet) // if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = getFromPool(/datum/powernet/)
				newPN.add_cable(C)
			if(powernet) // if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) // else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the source turf
/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()
	var/list/connections = list()

	if(!powernet) // if we somehow have no powernet, make one (should not happen for cables)
		var/datum/powernet/newPN = getFromPool(/datum/powernet/)
		newPN.add_cable(src)

	// first let's add turf cables to our powernet
	// then we'll connect machines on turf with a node cable is present

	for(var/datum/power_connection/C in get_turf(src))
		if(C.powernet == powernet)
			continue
		connections += C //we'll connect the machines after all cables are merged

	for(var/AM in loc)
		if(istype(AM, /obj/structure/cable))
			var/obj/structure/cable/C = AM
			//if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2) // only connected if they have a common direction // uncomment if you don't want + wiring
			if(C.powernet == powernet)
				continue
			if(C.powernet)
				merge_powernets(powernet, C.powernet)
			else
				powernet.add_cable(C) // the cable was powernetless, let's just add it to our powernet

		else if(istype(AM, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)
				continue // APC are connected through their terminal
			if(N.terminal.powernet == powernet)
				continue
			to_connect += N.terminal // we'll connect the machines after all cables are merged

		else if(istype(AM, /obj/machinery/power)) // other power machines
			var/obj/machinery/power/M = AM
			if(M.powernet == powernet)
				continue
			to_connect += M //we'll connect the machines after all cables are merged

	// now that cables are done, let's connect found machines
	for(var/obj/machinery/power/PM in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network() // if we somehow can't connect the machine to the new powernet, remove it from the old nonetheless
	for(var/datum/power_connection/PC in connections)
		if(!PC.connect())
			PC.disconnect() // if we somehow can't connect the machine to the new powernet, remove it from the old nonetheless

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

// if powernetless_only = 1, will only get connections without powernet
/obj/structure/cable/proc/get_connections(powernetless_only = 0)
	. = list() // this will be a list of all connected power objects without a powernet
	var/turf/T

	// get matching cables from the first direction
	if(d1) // if not a node cable
		T = get_step(src, d1)
		if(T)
			. += power_list(T, src, turn(d1, 180), powernetless_only) // get adjacents matching cables

	if(d1 & (d1 - 1)) // diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src, d1 & 3) // go north / south
		if(T)
			. += power_list(T, src, d1 ^ 3, powernetless_only) // get diagonally matching cables
		T = get_step(src,d1 & 12) // go east / west
		if(T)
			. += power_list(T, src, d1 ^ 12, powernetless_only) // get diagonally matching cables

	. += power_list(loc, src, d1, powernetless_only) // get on turf matching cables

	// do the same on the second direction (which can't be 0)
	T = get_step(src, d2)

	if(T)
		. += power_list(T, src, turn(d2, 180), powernetless_only) // get adjacents matching cables

	if(d2 & (d2 - 1)) // diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src, d2 & 3) // go north / south
		if(T)
			. += power_list(T, src, d2 ^ 3, powernetless_only) // get diagonally matching cables
		T = get_step(src, d2 & 12) // go east / west
		if(T)
			. += power_list(T, src, d2 ^ 12, powernetless_only) // get diagonally matching cables

	. += power_list(loc, src, d2, powernetless_only) //get on turf matching cables

// should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
// needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/proc/denode()
	var/turf/T1 = loc

	if(!T1)
		return

	var/list/powerlist = power_list(T1, src, 0, 0) // find the other cables that ended in the centre of the turf, with or without a powernet

	if(powerlist.len>0)
		var/datum/powernet/PN = getFromPool(/datum/powernet/)
		propagate_network(powerlist[1], PN) // propagates the new powernet beginning at the source cable

		if(PN.is_empty()) // can happen with machines made nodeless when smoothing cables
			returnToPool(PN) //powernets do not get qdelled
