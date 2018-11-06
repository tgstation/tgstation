////////////////////////////////////////////
// POWERNET DATUM
// each contiguous network of cables & nodes
/////////////////////////////////////
/datum/cablenet/power
	var/list/obj/machinery/power/machines = list()		// all connected machines

	var/load = 0				// the current load on the powernet, increased by each machine at processing
	var/newavail = 0			// what available power was gathered last tick, then becomes...
	var/avail = 0				//...the current available power in the powernet
	var/viewavail = 0			// the available power as it appears on the power console (gradually updated)
	var/viewload = 0			// the load as it appears on the power console (gradually updated)
	var/netexcess = 0			// excess power on the powernet (typically avail-load)///////
	var/delayedload = 0			// load applied to powernet between power ticks.

/datum/cablenet/power/New()
	SSmachines.powernets += src

/datum/cablenet/power/Destroy()
	//Go away references, you suck!
	for(var/obj/machinery/power/M in machines)
		M.powernet = null
	machines.Cut()
	SSmachines.powernets -= src
	return ..()

/datum/cablenet/power/is_empty()
	return ..() && !machines.len

/datum/cablenet/power/propagate_network()
	. = ..()

/datum/cablenet/power/merge_cost()
	return ..() + 0.5 * machines.len			//Machines, in theory, will cost more/less. In theory.

//remove a power machine from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the machine exists
/datum/cablenet/power/proc/remove_machine(obj/machinery/power/M)
	nodes -=M
	M.powernet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it

//add a power machine to the current powernet
//Warning : this proc DON'T check if the machine exists
/datum/cablenet/power/proc/add_machine(obj/machinery/power/M)
	if(M.powernet)// if M already has a powernet...
		if(M.powernet == src)
			return
		else
			M.disconnect_from_network()//..remove it
	M.powernet = src
	nodes[M] = M

//handles the power changes in the powernet
//called every ticks by the powernet controller
/datum/cablenet/power/proc/reset()
	//see if there's a surplus of power remaining in the powernet and stores unused power in the SMES
	netexcess = avail - load

	if(netexcess > 100 && nodes && nodes.len)		// if there was excess power last cycle
		for(var/obj/machinery/power/smes/S in nodes)	// find the SMESes in the network
			S.restore()				// and restore some of the power that was used

	// update power consoles
	viewavail = round(0.8 * viewavail + 0.2 * avail)
	viewload = round(0.8 * viewload + 0.2 * load)

	// reset the powernet
	load = delayedload
	delayedload = 0
	avail = newavail
	newavail = 0

/datum/cablenet/power/proc/get_electrocute_damage()
	if(avail >= 1000)
		return CLAMP(20 + round(avail/25000), 20, 195) + rand(-5,5)
	else
		return 0
