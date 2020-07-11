/*
** POWERNET DATUM
** only handles moving power from one device to another
** cable.dm, handles all connection and graphs
** powernets are ONLY qdel in cables.dm
*/
/datum/powernet
	var/number					// unique id

	var/list/consumers = list()	// list of devices that need power
	var/list/producers = list() // list of devices that create power
	var/list/cables = list()

	var/load = 0				// the current load on the powernet, increased by each machine at processing
	var/newavail = 0			// what available power was gathered last tick, then becomes...
	var/avail = 0				//...the current available power in the powernet
	var/viewavail = 0			// the available power as it appears on the power console (gradually updated)
	var/viewload = 0			// the load as it appears on the power console (gradually updated)
	var/netexcess = 0			// excess power on the powernet (typically avail-load)///////
	var/delayedload = 0			// load applied to powernet between power ticks.

/datum/powernet/Destroy()
	if(consumers.len)
		CRASH("We still have consumer machines in the powernet")
	if(producers.len)
		CRASH("We still have producers machines in the powernet")
	if(cables.len)
		CRASH("We still have cables in the powernet")
	CRASH("you shouldn't delete powernets!")
	return ..()


/datum/powernet/proc/merge(datum/powernet/M)
	ASSERT(M != src)
	var/i
	var/obj/machinery/power/P
	for(i=1;i < M.consumers.len; i++)
		P = M.consumers[i]
		P.powernet = src
	for(i=1;i < M.producers.len; i++)
		P = M.producers[i]
		P.powernet = src
	// cables are associated lists
	for(var/obj/structure/cable/C in M.cables)
		M.cables[C] = src
	// merge all lists
	consumers += M.consumers
	producers += M.producers
	cables += M.cables
	M.consumers.Cut()
	M.producers.Cut()
	M.cables.Cut()
	// Didn't do this before, is this good or bad
	// to combine all the loads
	load += M.load
	newavail += M.newavail
	avail += M.avail
	viewavail += M.viewavail
	viewload += M.viewload
	netexcess += M.netexcess
	delayedload  += M.delayedload
	SSmachines.release_powernet(M)



// disconnect_machine and connect may be slow
/datum/powernet/proc/disconnect_machine(obj/machinery/power/M)
	ASSERT(M.powernet == src)
	if(M.power_flags & POWER_MACHINE_CONSUMER)
		consumers -= M
	if(M.power_flags & POWER_MACHINE_PRODUCER)
		producers -= M
	if(M.power_flags & POWER_MACHINE_NEEDS_TERMINAL)
		if(M.terminal)
			consumers -= M.terminal
	M.powernet = null

/datum/powernet/proc/connect_machine(obj/machinery/power/M)
	ASSERT(M.powernet == null || M.powernet == src)
	M.powernet = src
	if(M.power_flags & POWER_MACHINE_CONSUMER)
		consumers |= M
	if(M.power_flags & POWER_MACHINE_PRODUCER)
		producers |= M
	if(M.power_flags & POWER_MACHINE_NEEDS_TERMINAL)
		if(M.terminal)
			consumers |= M.terminal


//handles the power changes in the powernet
//called every ticks by the powernet controller
/datum/powernet/proc/reset()
	//see if there's a surplus of power remaining in the powernet and stores unused power in the SMES
	netexcess = avail - load

	if(netexcess > 100 && consumers && consumers.len)		// if there was excess power last cycle
		for(var/obj/machinery/power/smes/S in consumers)	// find the SMESes in the network
			S.restore()				// and restore some of the power that was used

	// update power consoles
	viewavail = round(0.8 * viewavail + 0.2 * avail)
	viewload = round(0.8 * viewload + 0.2 * load)

	// reset the powernet
	load = delayedload
	delayedload = 0
	avail = newavail
	newavail = 0

/datum/powernet/proc/get_electrocute_damage()
	if(avail >= 1000)
		return clamp(20 + round(avail/25000), 20, 195) + rand(-5,5)
	else
		return 0

// So you cut a cable, run this after you remove from
// the powernet.
/proc/split_powernet(datum/powernet/PN)
	var/list/queue = list()
	// got to null that visitor flag
	var/obj/structure/cable/C = null
	var/obj/structure/cable/CI = null
	var/datum/powernet/current = null
	for(var/k in PN.cables)
		PN.cables[k].visited = FALSE
				PN.cables[k].visited = FALSE

	for(var/k in PN.cables)
		C = PN.cables[k]
		if(C && !C.visited)
			current = SSmachines.aquire_powernet()
			queue += C
			while(queue.len > 0)
				C = queue[queue.len--]
				PN.cables[C] = null // first one is free
				C.powernet = current
				C.powernet.cables[C] = current
				C.visited = TRUE
				if(C.cables.len > 0)
					for(var/i in 1 to C.cables.len)
						if(istype(C.cables[i], /obj/machinery/power))
							var/obj/machinery/power/M = C.cables[i]
							if(M.powernet != current)
								M.powernet.disconnect_machine(M)
								current.connect_machine(M)
						else if(istype(C.cables[i], /obj/structure/cable))
							CI = C.cables[i]
							if(!CI.visited)
								queue += CI
	ASSERT(PN.cables.len == 0)
	// PN should be empty so release it
	SSmachines.release_powernet(PN)


