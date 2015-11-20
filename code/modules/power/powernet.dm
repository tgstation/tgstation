//Powernets
/datum/powernet
	var/list/obj/structure/cable/cables = list()	// all cables & junctions
	var/list/obj/machinery/power/nodes = list()		// all connected machines
	var/list/datum/power_connection/components = list()		// all connected components
	var/load = 0				// the current load on the powernet, increased by each machine at processing
	var/newavail = 0			// what available power was gathered last tick, then becomes...
	var/avail = 0				// ...the current available power in the powernet
	var/viewload = 0			// the load as it appears on the power console (gradually updated)
	var/number = 0
	var/netexcess = 0			// excess power on the powernet (typically avail-load)

////////////////////////////////////////////
// POWERNET DATUM PROCS
// each contiguous network of cables & nodes
////////////////////////////////////////////

/*
Powernet procs :
/datum/powernet/New()
/datum/powernet/Del()
/datum/powernet/Destroy()
/datum/powernet/resetVariables()
/datum/powernet/proc/remove_cable(var/obj/structure/cable/C)
/datum/powernet/proc/add_cable(var/obj/structure/cable/C)
/datum/powernet/proc/remove_machine(var/obj/machinery/power/M)
/datum/powernet/proc/add_machine(var/obj/machinery/power/M)
/datum/powernet/proc/reset()
/datum/powernet/proc/get_electrocute_damage()
/datum/powernet/proc/set_to_build()
/obj/structure/cable/proc/rebuild_from()
*/

/datum/powernet/New()
	powernets |= src

/datum/powernet/Del()
	powernets -= src
	..()

/datum/powernet/Destroy()
	for(var/obj/structure/cable/C in cables)
		C.powernet = null
	for(var/obj/machinery/power/P in nodes)
		P.powernet = null
	// Power components
	for(var/datum/power_connection/C in components)
		C.powernet = null
	cables = null
	nodes = null
	components = null

/datum/powernet/resetVariables()
	..("cables","nodes")
	cables = list()
	nodes = list()
	components = list()

/datum/powernet/proc/is_empty()
	return !cables.len && !nodes.len && !components.len

// helper proc for removing cables from the current powernet
// warning : this proc doesn't check if the cable exists, but don't worry a runtime should tell you if it doesn't
/datum/powernet/proc/remove_cable(obj/structure/cable/C)
	cables -= C
	C.powernet = null
	if(is_empty())
		returnToPool(src)

// helper proc for removing a power machine from the current powernet
// warning : this proc doesn't check if the machine exists, but don't worry a runtime should tell you if it doesn't
/datum/powernet/proc/remove_machine(obj/machinery/power/M)
	nodes -= M
	M.powernet = null
	if(is_empty())
		returnToPool(src)

// helper proc for removing a power machine from the current powernet
// warning : this proc doesn't check if the machine exists, but don't worry a runtime should tell you if it doesn't
/datum/powernet/proc/remove_component(var/datum/power_connection/C)
	components -= C
	C.powernet = null
	if(is_empty())
		returnToPool(src)

// add a cable to the current powernet
/datum/powernet/proc/add_cable(obj/structure/cable/C)
	if(C.powernet)						// if C already has a powernet...
		if(C.powernet == src)
			return
		else
			C.powernet.remove_cable(C)	// ..remove it
	C.build_status = 0 //Resetting build status because it has been added to a powernet
	C.powernet = src
	cables += C

// add a power machine to the current powernet
/datum/powernet/proc/add_machine(var/obj/machinery/power/M)
	if(M.powernet)							// if M already has a powernet...
		if(M.powernet == src)
			return
		else
			M.disconnect_from_network()		// ..remove it
	M.build_status = 0 //Resetting build status because it has been added to a powernet
	M.powernet = src
	nodes += M

/datum/powernet/proc/add_component(var/datum/power_connection/C)
	if(C.powernet)							// if M already has a powernet...
		if(C.powernet == src)
			return
		else
			C.disconnect()		// ..remove it
	C.build_status = 0 //Resetting build status because it has been added to a powernet
	C.powernet = src
	components += C

// handles the power changes in the powernet
// called every ticks by the powernet controller
// all powernets will have been rebuilt by the time this is called
/datum/powernet/proc/reset()
	// see if there's a surplus of power remaining in the powernet and stores unused power in the SMES
	netexcess = avail - load

	if(netexcess > 100 && nodes && nodes.len) // if there was excess power last cycle
		for(var/obj/machinery/power/battery/B in nodes) // find the SMESes in the network
			B.restore() // and restore some of the power that was used
		for(var/obj/machinery/power/battery_port/BP in nodes) //Since portable batteries aren't in our nodes, we pass ourselves to restore them via their connectors
			if(BP.connected)
				BP.connected.restore()
	if(netexcess > 100 && components && components.len) // Same deal as above, but with components.
		for(var/datum/power_connection/C in components)
			C.excess(netexcess)

	// updates the viewed load (as seen on power computers)
	viewload = 0.8 * viewload + 0.2 * load
	viewload = round(viewload)

	// reset the powernet
	load = 0
	avail = newavail
	newavail = 0

/datum/powernet/proc/get_electrocute_damage()
	// cube root of power times 1,5 to 2 in increments of 10^-1
	// for instance, gives an average of 38 damage for 10k W, 81 damage for 100k W and 175 for 1M W
	// best you're getting with BYOND's mathematical funcs. Not even a fucking exponential or neperian logarithm
	return round(avail ** (1 / 3) * (rand(100, 125) / 100))

/datum/powernet/proc/set_to_build()
	for(var/obj/structure/cable/C in cables)
		C.build_status = 1
		C.oldload = load
		C.oldavail = avail
		C.oldnewavail = newavail
	for(var/obj/machinery/power/P in nodes)
		P.build_status = 1
	for(var/datum/power_connection/C in components)
		C.build_status = 1
	returnToPool(src)

//Hopefully this will never ever have to be used
var/global/powernets_broke = 0

//This will rebuild a powernet properly during the new tick cycle
/obj/structure/cable/proc/rebuild_from()
	if(!powernet)
		var/datum/powernet/NewPN = getFromPool(/datum/powernet)
		NewPN.add_cable(src)
		propagate_network(src, src.powernet)
		NewPN.load = oldload
		NewPN.avail = oldavail
		NewPN.newavail = oldnewavail //Ha
		for(var/obj/structure/cable/C in NewPN.cables)
			C.oldload = 0
			C.oldavail = 0
			C.oldnewavail = 0
			C.build_status = 0
		for(var/obj/machinery/power/P in NewPN.nodes)
			P.build_status = 0
		for(var/datum/power_connection/C in NewPN.components)
			C.build_status = 0
		return 1
	return 0

///////////////////////////////////////////
// GLOBAL PROCS for powernets handling
//////////////////////////////////////////

// returns a list of all power-related objects (nodes, cable, junctions) in turf,
// excluding source, that match the direction d
// if unmarked==1, only return those with no powernet
/proc/power_list(var/turf/T, var/source, var/d, var/unmarked=0, var/cable_only = 0)
	. = list()
	//var/fdir = (!d) ? 0 : turn(d, 180)			// the opposite direction to d (or 0 if d==0)

	if(!T)
		return

	if(!cable_only)
		for(var/datum/power_connection/C in T.power_connections)
			if(!unmarked || !C.powernet)		// if unmarked=1 we only return things with no powernet
				if(d == 0)
					. += C


	for(var/AM in T)
		if(AM == source)						// we don't want to return source
			continue

		if(!cable_only && istype(AM, /obj/machinery/power))
			var/obj/machinery/power/P = AM
			if(P.powernet == 0)					// exclude APCs which have powernet = 0
				continue
			if(!unmarked || !P.powernet)		// if unmarked=1 we only return things with no powernet
				if(d == 0)
					. += P

		else if(istype(AM,/obj/structure/cable))
			var/obj/structure/cable/C = AM
			if(!unmarked || !C.powernet)
				if(C.d1 == d || C.d2 == d)
					. += C

// rebuild all power networks from scratch - only called at world creation or by the admin verb
/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		PN.set_to_build()
		powernets = list()

	for(var/obj/structure/cable/C in cable_list)
		C.rebuild_from()

// remove the old powernet and replace it with a new one throughout the network.
/proc/propagate_network(var/obj/O, var/datum/powernet/PN)
	//world.log << "propagating new network"
	var/list/worklist = list()
	var/list/found_machines = list()
	var/list/found_connections = list()
	var/index = 1
	var/obj/P = null

	worklist += O									// start propagating from the passed object

	while(index <= worklist.len)					//until we've exhausted all power objects
		P = worklist[index]							//get the next power object found
		index++

		if(istype(P, /obj/structure/cable))
			var/obj/structure/cable/C = P
			if(C.powernet != PN)					// add it to the powernet, if it isn't already there
				PN.add_cable(C)
			worklist |= C.get_connections()	//get adjacents power objects, with or without a powernet

		if(istype(P, /datum/power_connection))
			var/datum/power_connection/C = P
			found_connections |= C				    // we wait until the powernet is fully propagates to connect the machines

		else if(P.anchored && istype(P, /obj/machinery/power))
			var/obj/machinery/power/M = P
			found_machines |= M						// we wait until the powernet is fully propagates to connect the machines

		else
			continue

	// now that the powernet is set, connect found machines to it
	for(var/obj/machinery/power/PM in found_machines)
		if(!PM.connect_to_network())				// couldn't find a node on its turf...
			PM.disconnect_from_network()			//... so disconnect if already on a powernet
	for(var/datum/power_connection/PC in found_connections)
		if(!PC.connect())		    // couldn't find a node on its turf...
			PC.disconnect()			//... so disconnect if already on a powernet

// merge two powernets, the bigger (in cable length term) absorbing the other
/proc/merge_powernets(datum/powernet/net1, datum/powernet/net2)
	if(!net1 || !net2)									// if one of the powernet doesn't exist, return
		return

	if(net1 == net2)									// don't merge same powernets
		return

	// we assume net1 is larger. If net2 is in fact larger we are just going to make them switch places to reduce on code.
	if(net1.cables.len < net2.cables.len)				//net2 is larger than net1. Let's switch them around
		var/temp = net1
		net1 = net2
		net2 = temp

	// merge net2 into net1
	for(var/obj/structure/cable/Cable in net2.cables) // merge cables
		net1.add_cable(Cable)

	if(net2) // not nulled, there are still nodes need to be merged
		for(var/obj/machinery/power/Node in net2.nodes) // merge power machines
			if(!Node.connect_to_network())
				Node.disconnect_from_network() // if somehow we can't connect the machine to the new powernet, disconnect it from the old nonetheless
		for(var/datum/power_connection/PC in net2.components)
			if(!PC.connect())		    // couldn't find a node on its turf...
				PC.disconnect()			//... so disconnect if already on a powernet

	return net1

// determines how strong could be shock, deals damage to mob, uses power.
// M is a mob who touched wire/whatever
// power_source is a source of electricity, can be powercell, area, apc, cable, powernet or null
// source is an object caused electrocuting (airlock, grille, etc)
// no animations will be performed by this proc.
/proc/electrocute_mob(mob/living/carbon/M, power_source, obj/source, siemens_coeff = 1.0)
	if(istype(M.loc, /obj/mecha))											// feckin mechs are dumb
		return 0

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M

		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves

			if(G.siemens_coefficient == 0)									// to avoid spamming with insulated glvoes on
				return 0

	var/area/source_area

	if(isarea(power_source))
		source_area = power_source
		power_source = source_area.areaapc

	if(istype(power_source, /obj/structure/cable))
		var/obj/structure/cable/Cable = power_source
		power_source = Cable.get_powernet()

	var/datum/powernet/PN
	var/obj/item/weapon/cell/cell

	if(istype(power_source, /datum/powernet))
		PN = power_source
	else if(istype(power_source, /obj/item/weapon/cell))
		cell = power_source
	else if(istype(power_source, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = power_source
		cell = apc.cell

		if(apc.terminal)
			PN = apc.terminal.powernet
	else if(!power_source)
		return 0
	else
		log_admin("ERROR: /proc/electrocute_mob([M], [power_source], [source]): wrong power_source")
		return 0

	if(!cell && !PN)
		return 0

	var/PN_damage = 0
	var/cell_damage = 0

	if(PN)
		PN_damage = PN.get_electrocute_damage()

	if(cell)
		cell_damage = cell.get_electrocute_damage()

	var/shock_damage = 0

	if(PN_damage >= cell_damage)
		power_source = PN
		shock_damage = PN_damage
	else
		power_source = cell
		shock_damage = cell_damage

	var/drained_hp = M.electrocute_act(shock_damage, source, siemens_coeff)	//zzzzzzap!
	var/drained_energy = drained_hp * 20

	if(source_area)
		source_area.use_power(drained_energy / CELLRATE)
	else if(istype(power_source, /datum/powernet))
		var/drained_power = drained_energy / CELLRATE						// convert from "joules" to "watts"
		PN.load += drained_power
	else if(istype(power_source, /obj/item/weapon/cell))
		cell.use(drained_energy)

	return drained_energy
