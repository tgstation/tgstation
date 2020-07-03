/*
** This is a powernet edge.  Its a container that tells the powernet
** if a cable has been disconnected and it needs to rebuild
*/
/datum/graph_edge
	var/datum/value // What this edge is representing
	var/datum/graph_component/graph_component = null
	var/list/verts = list()
	var/visited = FALSE   		// used in searching

/datum/graph_edge/New(W)
	value = W
	. = ..()

/datum/graph_edge/proc/visit()
	visited = TRUE
	var/datum/graph_edge/E
	for(var/i = 1; i <= verts.len; i++)
		if(!E.visited)
			E.visit()

/datum/graph_edge/proc/collect(list/connected)
	visited = TRUE
	connected[value] = src
	var/datum/graph_edge/E
	for(var/i = 1; i <= verts.len; i++)
		if(!E.visited)
			E.collect(connected)


/datum/graph_edge/Destroy()
	disconnect_all()
	verts = null
	value = null
	graph_component = null
	return ..()

/datum/graph_edge/proc/disconnect_all()
	var/datum/graph_edge/E
	for(var/i = 1; i <= verts.len; i++)
		E = verts[i]
		E.verts -= src
	verts.Cut()

/datum/graph_component
	var/datum/graph
	var/list/edges
	var/count

/datum/graph_component/New(G, E)
	graph = G
	edges = list()
	count = 0

/datum/graph_component/Destroy()
	graph = null
	edges = null
	return ..()

/datum/graph
	var/list/edges = list()
	var/list/graph_components = list()


/datum/graph/proc/connect_edge(datum/graph_edge/A, datum/graph_edge/B)
	edges[A.value] = A
	edges[B.value] = B
	A.verts |= B
	B.verts |= A

/datum/graph/proc/disconnect_edge(datum/graph_edge/A, datum/graph_edge/B)
	edges[A.value] = null
	edges[B.value] = null
	A.verts -= B
	B.verts -= A

/datum/graph/proc/clear_visited()
	var/datum/graph_edge/E
	for(var/key in edges)
		E = edges[key]
		E.visited = FALSE

/datum/graph/proc/refresh_connected_components()
	clear_visited()
	. = list()
	var/datum/graph_component/N
	var/datum/graph_edge/E
	for(var/key in edges)
		E = edges[key]
		if(!E.visited)
			N = new(G)
			E.collect(N.edges)
			. += N


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

// So you cut a cable, run this after you remove from
// the powernet.  It will split the powernet on all
// connected cables
/proc/split_powernet(datum/powernet/PN)
	var/obj/structure/cable/C
	var/list/queue = list()
	// got to null that visitor flag
	for(var/obj/structure/cable/C in PN.cables)
		C.visited = FALSE

	for(var/obj/structure/cable/C in PN.cables)
		if(!C || C.visited)
			continue
		current = SSmachines.aquire_powernet()
		queue += C
		PN.cables[C] = null
		while(queue.len > 0)
			QC = queue[queue.len--]  // first one is free
			QC.powernet = current
			QC.powernet.cables[QC] = current
			QC.visited = TRUE
			var/obj/machinery/power/M
			var/obj/structure/cable/CDIR
			for(var/i = 1; i < CABLE_DIR_DOWN; i++)
				CDIR = QC.linked[i]
				if(CDIR && !CDIR.visited)
					queue += CDIR
				M = QC.linked[i]
				if(M && M.powernet != current)
					M.powernet.disconnect_machine(M)
					current.connect_machine(M)


// disconnect_machine and connect may be slow
/datum/powernet/proc/disconnect_machine(obj/machinery/power/M)
	ASSERT(M.powernet == src)
	if(M.power_flags & POWER_MACHINE_CONSUMER)
		powernet.consumers -= M
	if(M.power_flags & POWER_MACHINE_PRODUCER)
		powernet.producer -= M
	if(M.power_flags & POWER_MACHINE_NEEDS_TERMINAL)
		if(M.terminal)
			powernet.consumers -= M.terminal
	M.powernet = null

/datum/powernet/proc/connect_machine(obj/machinery/power/M)
	ASSERT(M.powernet == null || M.powernet == src)
	M.powernet = src
	if(M.power_flags & POWER_MACHINE_CONSUMER)
		powernet.consumers |= M
	if(M.power_flags & POWER_MACHINE_PRODUCER)
		powernet.producer |= M
	if(M.power_flags & POWER_MACHINE_NEEDS_TERMINAL)
		if(M.terminal)
			powernet.consumers |= M.terminal




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
