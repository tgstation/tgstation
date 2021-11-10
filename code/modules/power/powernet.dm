////////////////////////////////////////////
// POWERNET DATUM
// each contiguous network of cables & nodes
/////////////////////////////////////
/datum/powernet
	var/number // unique id
	var/list/cables = list() // all cables & junctions
	var/list/nodes = list() // all connected machines

	var/load = 0 // the current load on the powernet, increased by each machine at processing
	var/newavail = 0 // what available power was gathered last tick, then becomes...
	var/avail = 0 //...the current available power in the powernet
	var/viewavail = 0 // the available power as it appears on the power console (gradually updated)
	var/viewload = 0 // the load as it appears on the power console (gradually updated)
	var/netexcess = 0 // excess power on the powernet (typically avail-load)///////
	var/delayedload = 0 // load applied to powernet between power ticks.

/datum/powernet/New()
	SSmachines.powernets += src

/datum/powernet/Destroy()
	//Go away references, you suck!
	for(var/obj/structure/cable/C in cables)
		cables -= C
		C.powernet = null
	for(var/obj/machinery/power/M in nodes)
		nodes -= M
		M.powernet = null

	SSmachines.powernets -= src
	return ..()

/datum/powernet/proc/is_empty()
	return !cables.len && !nodes.len

//remove a cable from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/remove_cable(obj/structure/cable/C)
	cables -= C
	C.powernet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it

//add a cable to the current powernet
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/add_cable(obj/structure/cable/C)
	if(C.powernet)// if C already has a powernet...
		if(C.powernet == src)
			return
		else
			C.powernet.remove_cable(C) //..remove it
	C.powernet = src
	cables +=C

//remove a power machine from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/remove_machine(obj/machinery/power/M)
	nodes -= M
	M.powernet = null
	SEND_SIGNAL(M, COMSIG_POWERNET_CABLE_DETACHED, src)
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it


//add a power machine to the current powernet
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/add_machine(obj/machinery/power/M)
	if(M.powernet)// if M already has a powernet...
		if(M.powernet == src)
			return
		else
			M.disconnect_from_network()//..remove it
	M.powernet = src
	nodes[M] = M
	SEND_SIGNAL(M, COMSIG_POWERNET_CABLE_ATTACHED, src)

/datum/powernet/proc/pre_reset()
	// See if there's a surplus of power remaining in the powernet.
	// If there is, we might be able to return it to suppliers such as the SMES.
	netexcess = avail - load

//handles the power changes in the powernet
//called every ticks by the powernet controller
/datum/powernet/proc/reset()
	// Providers always supply the maximum amount of power they can, and reduce any storage by this amount.
	// To avoid energy being burned where it doesn't make sense to, any unused energy is refunded to
	// power nodes that have registered for the COMSIG_POWERNET_DO_REFUND signal at the start of the next power tick.
	// This means that SMES units don't deplete as rapidly as they can.

	// If we had excess power in the last cycle...
	if(netexcess > 100)
		// Ask all entities capable of handling refunds to retake some of the power that was used
		SEND_SIGNAL(src, COMSIG_POWERNET_DO_REFUND)

	// Update power consoles/multi-inspection/etc. These are slowly moving averages for player presentation.
	viewavail = round(0.8 * viewavail + 0.2 * avail)
	viewload = round(0.8 * viewload + 0.2 * load)

	// Finally, reset the powernet for the next power tick
	load = delayedload
	delayedload = 0
	avail = newavail
	newavail = 0

/datum/powernet/proc/get_electrocute_damage()
	if(avail >= 1000)
		return clamp(20 + round(avail/25000), 20, 195) + rand(-5,5)
	else
		return 0
