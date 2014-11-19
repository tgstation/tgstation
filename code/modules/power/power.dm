/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'

	anchored = 1.0
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0

	var/datum/powernet/powernet

	// By default, power machines are connected by a cable in a neighbouring turf.
	// If set to 0, requires a 0-X cable on this turf.
	var/directwired = 1

/obj/machinery/power/Destroy()
	disconnect_from_network()
	..()

/*
 * Common helper procs for all power machines.
 */
/obj/machinery/power/proc/add_avail(const/amount)
	if (powernet)
		powernet.newavail += amount

/obj/machinery/power/proc/add_load(const/amount)
	if (powernet)
		powernet.newload += amount

/obj/machinery/power/proc/surplus()
	if (powernet)
		return powernet.avail-powernet.load

	return 0

/obj/machinery/power/proc/avail()
	if (powernet)
		return powernet.avail

	return 0

/*
 * Returns true if the area has power on given channel (or doesn't require power).
 * Defaults to power_channel.
 */
/obj/machinery/proc/powered(chan = power_channel)
	if (!src.loc)
		return 0

	if (!use_power)
		return 1

	if (isnull(areaMaster))
		return 0 // If not, then not powered.

	return areaMaster.powered(chan) // Return power status of the area.

/*
 * Increment the power usage stats for an area.
 * Defaults to power_channel.
 */
/obj/machinery/proc/use_power(const/amount, chan = power_channel)
	if (!src.loc)
		return 0

	if (isnull(areaMaster))
		return

	areaMaster.use_power(amount, chan)

/*
 * Called whenever the power settings of the containing area change.
 * By default, check equipment channel & set flag.
 * Can override if needed.
 */
/obj/machinery/proc/power_change()
	switch (powered(power_channel))
		if (1)
			stat &= ~NOPOWER
		if (0)
			stat |= NOPOWER

// the powernet datum
// each contiguous network of cables & nodes


// rebuild all power networks from scratch

/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		del(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in cable_list)
		if(!PC.powernet)
			PC.powernet = new()
//			if(Debug)	world.log << "Starting mpn at [PC.x],[PC.y] ([PC.d1]/[PC.d2])"
			powernet_nextlink(PC,PC.powernet)

//	if(Debug) world.log << "[powernets.len] powernets found"

	for(var/obj/structure/cable/C in cable_list)
		if(!C.powernet)	continue
		C.powernet.cables += C

	for(var/obj/machinery/power/M in machines)
		if(!M.powernet)	continue	// APCs have powernet=0 so they don't count as network nodes directly
		M.powernet.nodes.Add(M)


// returns a list of all power-related objects (nodes, cable, junctions) in turf,
// excluding source, that match the direction d
// if unmarked==1, only return those with no powernet
/proc/power_list(var/turf/T, var/source, var/d, var/unmarked=0)
	. = list()
	var/fdir = (!d)? 0 : turn(d, 180)			// the opposite direction to d (or 0 if d==0)
//	world.log << "d=[d] fdir=[fdir]"
	for(var/AM in T)
		if(AM == source)	continue			//we don't want to return source

		if(istype(AM,/obj/machinery/power))
			var/obj/machinery/power/P = AM
			if(P.powernet == 0)	continue		// exclude APCs which have powernet=0

			if(!unmarked || !P.powernet)		//if unmarked=1 we only return things with no powernet
				if(P.directwired || (d == 0))
					. += P

		else if(istype(AM,/obj/structure/cable))
			var/obj/structure/cable/C = AM

			if(!unmarked || !C.powernet)
				if(C.d1 == fdir || C.d2 == fdir)
					. += C
				else if(C.d1 == turn(C.d2, 180))
					. += C
	return .


/obj/structure/cable/proc/get_connections()
	. = list()	// this will be a list of all connected power objects
	var/turf/T = loc

	if(d1)	T = get_step(src, d1)
	if(T)	. += power_list(T, src, d1, 1)

	T = get_step(src, d2)
	if(T)	. += power_list(T, src, d2, 1)

	return .


/obj/machinery/power/proc/get_connections()

	. = list()

	if(!directwired)
		return get_indirect_connections()

	var/cdir

	for(var/card in cardinal)
		var/turf/T = get_step(loc,card)
		cdir = get_dir(T,loc)

		for(var/obj/structure/cable/C in T)
			if(C.powernet)	continue
			if(C.d1 == cdir || C.d2 == cdir)
				. += C
	return .

/obj/machinery/power/proc/get_indirect_connections()
	. = list()
	for(var/obj/structure/cable/C in loc)
		if(C.powernet)	continue
		if(C.d1 == 0)
			. += C
	return .


/proc/powernet_nextlink(var/obj/O, var/datum/powernet/PN)
	var/list/P

	while(1)
		if( istype(O,/obj/structure/cable) )
			var/obj/structure/cable/C = O
			C.powernet = PN
			P = C.get_connections()

		else if(O.anchored && istype(O,/obj/machinery/power))
			var/obj/machinery/power/M = O
			M.powernet = PN
			P = M.get_connections()

		else
			return

		if(P.len == 0)	return

		O = P[1]

		for(var/L = 2 to P.len)
			powernet_nextlink(P[L], PN)


// cut a powernet at this cable object
/datum/powernet/proc/cut_cable(var/obj/structure/cable/C)
	var/turf/T1 = C.loc
	if(!T1)	return
	var/node = 0
	if(C.d1 == 0)
		node = 1

	var/turf/T2
	if(C.d2)	T2 = get_step(T1, C.d2)
	if(C.d1)	T1 = get_step(T1, C.d1)


	var/list/P1 = power_list(T1, C, C.d1)	// what joins on to cut cable in dir1
	var/list/P2 = power_list(T2, C, C.d2)	// what joins on to cut cable in dir2

//	if(Debug)
//		for(var/obj/O in P1)
//			world.log << "P1: [O] at [O.x] [O.y] : [istype(O, /obj/structure/cable) ? "[O:d1]/[O:d2]" : null] "
//		for(var/obj/O in P2)
//			world.log << "P2: [O] at [O.x] [O.y] : [istype(O, /obj/structure/cable) ? "[O:d1]/[O:d2]" : null] "


	if(P1.len == 0 || P2.len == 0)//if nothing in either list, then the cable was an endpoint no need to rebuild the powernet,
		cables -= C				//just remove cut cable from the list
//		if(Debug) world.log << "Was end of cable"
		return

	//null the powernet reference of all cables & nodes in this powernet
	var/i=1
	while(i<=cables.len)
		var/obj/structure/cable/Cable = cables[i]
		if(Cable)
			Cable.powernet = null
			if(Cable == C)
				cables.Cut(i,i+1)
				continue
		i++
	i=1
	while(i<=nodes.len)
		var/obj/machinery/power/Node = nodes[i]
		if(Node)
			Node.powernet = null
		i++

	// remove the cut cable from the network
//	C.netnum = -1

	C.loc = null

	powernet_nextlink(P1[1], src)		// propagate network from 1st side of cable, using current netnum	//TODO?

	// now test to see if propagation reached to the other side
	// if so, then there's a loop in the network
	var/notlooped = 0
	for(var/O in P2)
		if( istype(O, /obj/machinery/power) )
			var/obj/machinery/power/Machine = O
			if(Machine.powernet != src)
				notlooped = 1
				break
		else if( istype(O, /obj/structure/cable) )
			var/obj/structure/cable/Cable = O
			if(Cable.powernet != src)
				notlooped = 1
				break

	if(notlooped)
		// not looped, so make a new powernet
		var/datum/powernet/PN = new()

//		if(Debug) world.log << "Was not looped: spliting PN#[number] ([cables.len];[nodes.len])"

		i=1
		while(i<=cables.len)
			var/obj/structure/cable/Cable = cables[i]
			if(Cable && !Cable.powernet)	// non-connected cables will have powernet=null, since they weren't reached by propagation
				Cable.powernet = PN
				cables.Cut(i,i+1)	// remove from old network & add to new one
				PN.cables += Cable
				continue
			i++

		i=1
		while(i<=nodes.len)
			var/obj/machinery/power/Node = nodes[i]
			if(Node && !Node.powernet)
				Node.powernet = PN
				nodes.Cut(i,i+1)
				PN.nodes.Add(Node)
				continue
			i++

	// Disconnect machines connected to nodes
	if(node)
		for(var/obj/machinery/power/P in T1)
			if(P.powernet && !P.powernet.nodes.Find(src))
				P.disconnect_from_network()
//		if(Debug)
//			world.log << "Old PN#[number] : ([cables.len];[nodes.len])"
//			world.log << "New PN#[PN.number] : ([PN.cables.len];[PN.nodes.len])"
//
//	else
//		if(Debug)
//			world.log << "Was looped."
//		//there is a loop, so nothing to be done
//		return



/datum/powernet/proc/reset()
	load = newload
	newload = 0
	avail = newavail
	newavail = 0


	viewload = 0.8*viewload + 0.2*load

	viewload = round(viewload)

	var/numapc = 0

	if(nodes && nodes.len) // Added to fix a bad list bug -- TLE
		for(var/obj/machinery/power/terminal/term in nodes)
			if( istype( term.master, /obj/machinery/power/apc ) )
				numapc++

	if(numapc)
		perapc = avail/numapc

	netexcess = avail - load

	if( netexcess > 100)		// if there was excess power last cycle
		if(nodes && nodes.len)
			for(var/obj/machinery/power/smes/S in nodes)	// find the SMESes in the network
				if(S.powernet == src)
					S.restore()				// and restore some of the power that was used
				else
					error("[S.name] (\ref[S]) had a [S.powernet ? "different (\ref[S.powernet])" : "null"] powernet to our powernet (\ref[src]).")
					nodes.Remove(S)

/datum/powernet/proc/get_electrocute_damage()
	switch(avail)/*
		if (1300000 to INFINITY)
			return min(rand(70,150),rand(70,150))
		if (750000 to 1300000)
			return min(rand(50,115),rand(50,115))
		if (100000 to 750000-1)
			return min(rand(35,101),rand(35,101))
		if (75000 to 100000-1)
			return min(rand(30,95),rand(30,95))
		if (50000 to 75000-1)
			return min(rand(25,80),rand(25,80))
		if (25000 to 50000-1)
			return min(rand(20,70),rand(20,70))
		if (10000 to 25000-1)
			return min(rand(20,65),rand(20,65))
		if (1000 to 10000-1)
			return min(rand(10,20),rand(10,20))*/
		if (5000000 to INFINITY)
			return min(rand(100,180),rand(100,180))
		if (4500000 to 5000000)
			return min(rand(80,160),rand(80,160))
		if (1000000 to 4500000)
			return min(rand(50,140),rand(50,140))
		if (200000 to 1000000)
			return min(rand(25,80),rand(25,80))
		if (100000 to 200000)//Ave powernet
			return min(rand(20,60),rand(20,60))
		if (50000 to 100000)
			return min(rand(15,40),rand(15,40))
		if (1000 to 50000)
			return min(rand(10,20),rand(10,20))
		else
			return 0

//The powernet that calls this proc will consume the other powernet - Rockdtben
//TODO: rewrite so the larger net absorbs the smaller net
/proc/merge_powernets(var/datum/powernet/net1, var/datum/powernet/net2)
	if(!net1 || !net2)	return
	if(net1 == net2)	return

	//We assume net1 is larger. If net2 is in fact larger we are just going to make them switch places to reduce on code.
	if(net1.cables.len < net2.cables.len)	//net2 is larger than net1. Let's switch them around
		var/temp = net1
		net1 = net2
		net2 = temp

	for(var/obj/machinery/power/node in net2.nodes)
		if(node)
			net2.nodes -= node
			node.powernet = net1
			net1.nodes += node

	for(var/obj/structure/cable/cable in net2.cables)
		if(cable)
			net2.cables -= cable
			cable.powernet = net1
			net1.cables += cable

	net2.Destroy()
	return net1

/obj/machinery/power/proc/connect_to_network()
	var/turf/T = src.loc
	var/obj/structure/cable/C = T.get_cable_node()
	if(!C || !C.powernet)	return 0
//	makepowernets() //TODO: find fast way	//EWWWW what are you doing!?
	powernet = C.powernet
	powernet.nodes.Add(src)
	return 1

/obj/machinery/power/proc/disconnect_from_network()
	if(!powernet)
		//world << " no powernet"
		return 0
	powernet.nodes -= src
	powernet = null
	//world << "powernet null"
	return 1

/turf/proc/get_cable_node()
	if(!istype(src, /turf/simulated/floor))
		return null
	for(var/obj/structure/cable/C in src)
		if(C.d1 == 0)
			return C
	return null

/area/proc/get_apc()
	for(var/area/RA in src.related)
		var/obj/machinery/power/apc/FINDME = locate() in RA
		if (FINDME)
			return FINDME


//Determines how strong could be shock, deals damage to mob, uses power.
//M is a mob who touched wire/whatever
//power_source is a source of electricity, can be powercell, area, apc, cable, powernet or null
//source is an object caused electrocuting (airlock, grille, etc)
//No animations will be performed by this proc.
/proc/electrocute_mob(mob/living/carbon/M as mob, var/power_source, var/obj/source, var/siemens_coeff = 1.0)
	if(istype(M.loc,/obj/mecha))	return 0	//feckin mechs are dumb
	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.siemens_coefficient == 0)	return 0		//to avoid spamming with insulated glvoes on

	var/area/source_area
	if(istype(power_source,/area))
		source_area = power_source
		power_source = source_area.get_apc()
	if(istype(power_source,/obj/structure/cable))
		var/obj/structure/cable/Cable = power_source
		power_source = Cable.powernet

	var/datum/powernet/PN
	var/obj/item/weapon/cell/cell

	if(istype(power_source,/datum/powernet))
		PN = power_source
	else if(istype(power_source,/obj/item/weapon/cell))
		cell = power_source
	else if(istype(power_source,/obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = power_source
		cell = apc.cell
		if (apc.terminal)
			PN = apc.terminal.powernet
	else if (!power_source)
		return 0
	else
		log_admin("ERROR: /proc/electrocute_mob([M], [power_source], [source]): wrong power_source")
		return 0
	if (!cell && !PN)
		return 0
	var/PN_damage = 0
	var/cell_damage = 0
	if (PN)
		PN_damage = PN.get_electrocute_damage()
	if (cell)
		cell_damage = cell.get_electrocute_damage()
	var/shock_damage = 0
	if (PN_damage>=cell_damage)
		power_source = PN
		shock_damage = PN_damage
	else
		power_source = cell
		shock_damage = cell_damage
	var/drained_hp = M.electrocute_act(shock_damage, source, siemens_coeff) //zzzzzzap!
	var/drained_energy = drained_hp*20

	if (source_area)
		source_area.use_power(drained_energy/CELLRATE)
	else if (istype(power_source,/datum/powernet))
		var/drained_power = drained_energy/CELLRATE //convert from "joules" to "watts"
		PN.newload+=drained_power
	else if (istype(power_source, /obj/item/weapon/cell))
		cell.use(drained_energy)
	return drained_energy

/datum/powernet/New()
	..()
	powernets += src

/datum/powernet/Destroy()
	for(var/obj/machinery/power/node in nodes)
		node.powernet = null

	for(var/obj/structure/cable/cable in cables)
		cable.powernet = null

	powernets -= src
