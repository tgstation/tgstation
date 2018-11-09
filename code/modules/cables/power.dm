GLOBAL_LIST_EMPTY(power_cable_list)

/obj/structure/cable/power
	name = "power cable"
	desc = "A flexible, superconducting insulated cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond/cables.dmi'
	icon_state = "0-1"
	cable_item_type = /obj/item/stack/cable_coil/power/power
	network_type = /datum/cablenet/power
	cable_color = "red"
	color = "#ff0000"
	var/datum/cablenet/power/powernet

/obj/structure/cable/power/yellow
	cable_color = "yellow"
	color = "#ffff00"

/obj/structure/cable/power/green
	cable_color = "green"
	color = "#00aa00"

/obj/structure/cable/power/blue
	cable_color = "blue"
	color = "#1919c8"

/obj/structure/cable/power/pink
	cable_color = "pink"
	color = "#ff3cc8"

/obj/structure/cable/power/orange
	cable_color = "orange"
	color = "#ff8000"

/obj/structure/cable/power/cyan
	cable_color = "cyan"
	color = "#00ffff"

/obj/structure/cable/power/white
	cable_color = "white"
	color = "#ffffff"

// the power cable object
/obj/structure/cable/power/Initialize(mapload, param_color)
	. = ..()
	GLOB.power_cable_list += src //add it to the global cable list

/obj/structure/cable/power/Destroy()					// called when a cable is deleted
	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	GLOB.power_cable_list -= src							//remove it from global cable list
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/power/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(powernet && (powernet.avail > 0))		// is it powered?
			to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
		else
			to_chat(user, "<span class='danger'>The cable is not powered.</span>")
		shock(user, 5, 0.2)
		add_fingerprint(user)
	else
		return ..()

/obj/structure/cable/power/on_network_connect(datum/cablenet/power/P)
	if(!istype(P))
		stack_trace("Power cable at [COORD(src)] connected to non power cablenet")
		return FALSE
	. = ..()

// shock the user with probability prb
/obj/structure/cable/power/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, TRUE, src)
		return 1
	else
		return 0

/obj/structure/cable/power/proc/get_machines()
	if(!is_node())
		return list()
	. = list()
	for(var/i in loc)
		if(!istype(i, /obj/machinery/power))
			continue
		var/obj/machinery/power/P = i



/obj/structure/cable/power/proc/powernet()
	return network






























/*
///////////////////////////////////////////
// GLOBAL PROCS for powernets handling
//////////////////////////////////////////


// returns a list of all power-related objects (nodes, cable, junctions) in turf,
// excluding source, that match the direction d
// if unmarked==1, only return those with no powernet
/proc/power_list(turf/T, source, d, unmarked=0, cable_only = 0)
	. = list()

	for(var/AM in T)
		if(AM == source)
			continue			//we don't want to return source

		if(!cable_only && istype(AM, /obj/machinery/power))
			var/obj/machinery/power/P = AM
			if(P.powernet == 0)
				continue		// exclude APCs which have powernet=0

			if(!unmarked || !P.powernet)		//if unmarked=1 we only return things with no powernet
				if(d == 0)
					. += P

		else if(istype(AM, /obj/structure/cable/power))
			var/obj/structure/cable/power/C = AM

			if(!unmarked || !C.powernet)
				if(C.d1 == d || C.d2 == d)
					. += C
	return .




//remove the old powernet and replace it with a new one throughout the network.
/proc/propagate_network(obj/O, datum/cablenet/power/PN)
	var/list/worklist = list()
	var/list/found_machines = list()
	var/index = 1
	var/obj/P = null

	worklist+=O //start propagating from the passed object

	while(index<=worklist.len) //until we've exhausted all power objects
		P = worklist[index] //get the next power object found
		index++

		if( istype(P, /obj/structure/cable/power))
			var/obj/structure/cable/power/C = P
			if(C.powernet != PN) //add it to the powernet, if it isn't already there
				PN.add_cable(C)
			worklist |= C.get_connections() //get adjacents power objects, with or without a powernet

		else if(P.anchored && istype(P, /obj/machinery/power))
			var/obj/machinery/power/M = P
			found_machines |= M //we wait until the powernet is fully propagates to connect the machines

		else
			continue

	//now that the powernet is set, connect found machines to it
	for(var/obj/machinery/power/PM in found_machines)
		if(!PM.connect_to_network()) //couldn't find a node on its turf...
			PM.disconnect_from_network() //... so disconnect if already on a powernet


//Merge two powernets, the bigger (in cable length term) absorbing the other
/proc/merge_powernets(datum/cablenet/power/net1, datum/cablenet/power/net2)
	if(!net1 || !net2) //if one of the powernet doesn't exist, return
		return

	if(net1 == net2) //don't merge same powernets
		return

	//We assume net1 is larger. If net2 is in fact larger we are just going to make them switch places to reduce on code.
	if(net1.cables.len < net2.cables.len)	//net2 is larger than net1. Let's switch them around
		var/temp = net1
		net1 = net2
		net2 = temp

	//merge net2 into net1
	for(var/obj/structure/cable/power/Cable in net2.cables) //merge cables
		net1.add_cable(Cable)

	for(var/obj/machinery/power/Node in net2.nodes) //merge power machines
		if(!Node.connect_to_network())
			Node.disconnect_from_network() //if somehow we can't connect the machine to the new powernet, disconnect it from the old nonetheless

	return net1

//handles merging diagonally matching cables
//for info : direction^3 is flipping horizontally, direction^12 is flipping vertically
/obj/structure/cable/power/proc/mergeDiagonalsNetworks(direction)

	//search for and merge diagonally matching cables from the first direction component (north/south)
	var/turf/T  = get_step(src, direction&3)//go north/south

	for(var/obj/structure/cable/power/C in T)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == (direction^3) || C.d2 == (direction^3)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/cablenet/power/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

	//the same from the second direction component (east/west)
	T  = get_step(src, direction&12)//go east/west

	for(var/obj/structure/cable/power/C in T)

		if(!C)
			continue

		if(src == C)
			continue
		if(C.d1 == (direction^12) || C.d2 == (direction^12)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/cablenet/power/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the given direction
/obj/structure/cable/power/proc/mergeConnectedNetworks(direction)

	var/fdir = (!direction)? 0 : turn(direction, 180) //flip the direction, to match with the source position on its turf

	if(!(d1 == direction || d2 == direction)) //if the cable is not pointed in this direction, do nothing
		return

	var/turf/TB  = get_step(src, direction)

	for(var/obj/structure/cable/power/C in TB)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == fdir || C.d2 == fdir) //we've got a matching cable in the neighbor turf
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/cablenet/power/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the source turf
/obj/structure/cable/power/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()

	if(!powernet) //if we somehow have no powernet, make one (should not happen for cables)
		var/datum/cablenet/power/newPN = new()
		newPN.add_cable(src)

	//first let's add turf cables to our powernet
	//then we'll connect machines on turf with a node cable is present
	for(var/AM in loc)
		if(istype(AM, /obj/structure/cable/power))
			var/obj/structure/cable/power/C = AM
			if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2) //only connected if they have a common direction
				if(C.powernet == powernet)
					continue
				if(C.powernet)
					merge_powernets(powernet, C.powernet)
				else
					powernet.add_cable(C) //the cable was powernetless, let's just add it to our powernet

		else if(istype(AM, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)
				continue // APC are connected through their terminal

			if(N.terminal.powernet == powernet)
				continue

			to_connect += N.terminal //we'll connect the machines after all cables are merged

		else if(istype(AM, /obj/machinery/power)) //other power machines
			var/obj/machinery/power/M = AM

			if(M.powernet == powernet)
				continue

			to_connect += M //we'll connect the machines after all cables are merged

	//now that cables are done, let's connect found machines
	for(var/obj/machinery/power/PM in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network() //if we somehow can't connect the machine to the new powernet, remove it from the old nonetheless

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

//if powernetless_only = 1, will only get connections without powernet
/obj/structure/cable/power/proc/get_connections(powernetless_only = 0)
	. = list()	// this will be a list of all connected power objects
	var/turf/T

	//get matching cables from the first direction
	if(d1) //if not a node cable
		T = get_step(src, d1)
		if(T)
			. += power_list(T, src, turn(d1, 180), powernetless_only) //get adjacents matching cables

	if(d1&(d1-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d1&3) // go north/south
		if(T)
			. += power_list(T, src, d1 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step(src,d1&12) // go east/west
		if(T)
			. += power_list(T, src, d1 ^ 12, powernetless_only) //get diagonally matching cables

	. += power_list(loc, src, d1, powernetless_only) //get on turf matching cables

	//do the same on the second direction (which can't be 0)
	T = get_step(src, d2)
	if(T)
		. += power_list(T, src, turn(d2, 180), powernetless_only) //get adjacents matching cables

	if(d2&(d2-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d2&3) // go north/south
		if(T)
			. += power_list(T, src, d2 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step(src,d2&12) // go east/west
		if(T)
			. += power_list(T, src, d2 ^ 12, powernetless_only) //get diagonally matching cables
	. += power_list(loc, src, d2, powernetless_only) //get on turf matching cables

	return .

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/power/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = power_list(T1,src,0,0) //find the other cables that ended in the centre of the turf, with or without a powernet
	if(powerlist.len>0)
		var/datum/cablenet/power/PN = new()
		propagate_network(powerlist[1],PN) //propagates the new powernet beginning at the source cable

		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

/obj/structure/cable/power/proc/auto_propogate_cut_cable(obj/O)
	if(O && !QDELETED(O))
		var/datum/cablenet/power/newPN = new()// creates a new powernet...
		propagate_network(O, newPN)//... and propagates it to the other side of the cable

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/power/proc/cut_cable_from_powernet(remove=TRUE)
	var/turf/T1 = loc
	var/list/P_list
	if(!T1)
		return
	if(d1)
		T1 = get_step(T1, d1)
		P_list = power_list(T1, src, turn(d1,180),0,cable_only = 1)	// what adjacently joins on to cut cable...

	P_list += power_list(loc, src, d1, 0, cable_only = 1)//... and on turf


	if(P_list.len == 0)//if nothing in both list, then the cable was a lone cable, just delete it and its powernet
		powernet.remove_cable(src)

		for(var/obj/machinery/power/P in T1)//check if it was powering a machine
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network (and delete powernet)
		return

	var/obj/O = P_list[1]
	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	if(remove)
		moveToNullspace()
	powernet.remove_cable(src) //remove the cut cable from its powernet

	addtimer(CALLBACK(O, .proc/auto_propogate_cut_cable, O), 0) //so we don't rebuild the network X times when singulo/explosion destroys a line of X cables

	// Disconnect machines connected to nodes
	if(d1 == 0) // if we cut a node (O-X) cable
		for(var/obj/machinery/power/P in T1)
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network

*/


////////////////////////////////////////////
// Power related
///////////////////////////////////////////

// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

/obj/structure/cable/power/proc/add_avail(amount)
	var/datum/cablenet/power/powernet = network
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/power/proc/add_load(amount)
	var/datum/cablenet/power/powernet = network
	if(powernet)
		powernet.load += amount

/obj/structure/cable/power/proc/surplus()
	var/datum/cablenet/power/powernet = network
	if(powernet)
		return CLAMP(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/structure/cable/power/proc/avail()
	var/datum/cablenet/power/powernet = network
	if(powernet)
		return powernet.avail
	else
		return 0

/obj/structure/cable/power/proc/add_delayedload(amount)
	var/datum/cablenet/power/powernet = network
	if(powernet)
		powernet.delayedload += amount

/obj/structure/cable/power/proc/delayed_surplus()
	var/datum/cablenet/power/powernet = network
	if(powernet)
		return CLAMP(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/structure/cable/power/proc/newavail()
	var/datum/cablenet/power/powernet = network
	if(powernet)
		return powernet.newavail
	else
		return 0

///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////


/obj/item/stack/cable_coil/power
	merge_type = /obj/item/stack/cable_coil/power/power
	desc = "A coil of insulated power cable."
	cable_path = /obj/structure/cable/power

/obj/item/stack/cable_coil/power/cyborg
	is_cyborg = TRUE
	materials = list()
	can_change_color = TRUE
	cost = 1

//you can use wires to heal robotics
/obj/item/stack/cable_coil/power/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting && affecting.status == BODYPART_ROBOTIC)
		if(user == H)
			user.visible_message("<span class='notice'>[user] starts to fix some of the wires in [H]'s [affecting.name].</span>", "<span class='notice'>You start fixing some of the wires in [H]'s [affecting.name].</span>")
			if(!do_mob(user, H, 50))
				return
		if(item_heal_robotic(H, user, 0, 15))
			use(1)
		return
	else
		return ..()

/obj/item/stack/cable_coil/power/red
	item_color = "red"
	color = "#ff0000"

/obj/item/stack/cable_coil/power/yellow
	item_color = "yellow"
	color = "#ffff00"

/obj/item/stack/cable_coil/power/blue
	item_color = "blue"
	color = "#1919c8"

/obj/item/stack/cable_coil/power/green
	item_color = "green"
	color = "#00aa00"

/obj/item/stack/cable_coil/power/pink
	item_color = "pink"
	color = "#ff3ccd"

/obj/item/stack/cable_coil/power/orange
	item_color = "orange"
	color = "#ff8000"

/obj/item/stack/cable_coil/power/cyan
	item_color = "cyan"
	color = "#00ffff"

/obj/item/stack/cable_coil/power/white
	item_color = "white"

/obj/item/stack/cable_coil/power/random
	item_color = null
	color = "#ffffff"


/obj/item/stack/cable_coil/power/random/five
	amount = 5

/obj/item/stack/cable_coil/power/cut
	amount = null
	icon_state = "coil2"

/obj/item/stack/cable_coil/power/cut/Initialize(mapload)
	. = ..()
	if(!amount)
		amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()

/obj/item/stack/cable_coil/power/cut/red
	item_color = "red"
	color = "#ff0000"

/obj/item/stack/cable_coil/power/cut/yellow
	item_color = "yellow"
	color = "#ffff00"

/obj/item/stack/cable_coil/power/cut/blue
	item_color = "blue"
	color = "#1919c8"

/obj/item/stack/cable_coil/power/cut/green
	item_color = "green"
	color = "#00aa00"

/obj/item/stack/cable_coil/power/cut/pink
	item_color = "pink"
	color = "#ff3ccd"

/obj/item/stack/cable_coil/power/cut/orange
	item_color = "orange"
	color = "#ff8000"

/obj/item/stack/cable_coil/power/cut/cyan
	item_color = "cyan"
	color = "#00ffff"

/obj/item/stack/cable_coil/power/cut/white
	item_color = "white"

/obj/item/stack/cable_coil/power/cut/random
	item_color = null
	color = "#ffffff"