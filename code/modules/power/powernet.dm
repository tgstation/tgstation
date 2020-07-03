/*
** This is a powernet edge.  Its a container that tells the powernet
** if a cable has been disconnected and it needs to rebuild
*/
/datum/graph_edge
	var/datum/value
	var/datum/graph_component/component = null
	var/list/verts = list()
	var/visited = FALSE   		// used in searching

/datum/graph_edge/New(W)
	value = W
	. = ..()

/datum/graph_edge/proc/visit()
	visited = TRUE
	var/datum/cable_edge/E
	for(var/i = 1; i <= verts.len; i++)
		if(!E.visited)
			E.visit()

/datum/graph_edge/proc/collect(list/connected)
	visited = TRUE
	connected[value] = src
	var/datum/cable_edge/E
	for(var/i = 1; i <= verts.len; i++)
		if(!E.visited)
			E.collect(connected)


/datum/graph_edge/Destroy()
	var/datum/cable_edge/E
	for(var/i = 1; i <= verts.len; i++)
		E = verts[i]
		E.verts -= src
	verts = null
	value = null
	component = null
	return ..()

/datum/graph_edge/proc/disconnect_all()
	var/datum/cable_edge/E
	for(var/i = 1; i <= verts.len; i++)
		E = verts[i]
		E.verts -= src
	verts = list()

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

/datum/graph/proc/refresh_components()
	clear_visited()
	graph_components = list()
	var/datum/graph_component/N
	var/datum/graph_edge/E
	for(var/key in edges)
		E = edges[key]
		if(!E.visited)
			N = new(G)
			E.collect(N.edges)
			graph_components += N

/*
** POWERNET DATUM
** only handles moving power from one device to another
** cable.dm, handles all connection and graphs
*/
/datum/powernet
	var/number					// unique id
	var/datum/graph_component/nodes

	var/load = 0				// the current load on the powernet, increased by each machine at processing
	var/newavail = 0			// what available power was gathered last tick, then becomes...
	var/avail = 0				//...the current available power in the powernet
	var/viewavail = 0			// the available power as it appears on the power console (gradually updated)
	var/viewload = 0			// the load as it appears on the power console (gradually updated)
	var/netexcess = 0			// excess power on the powernet (typically avail-load)///////
	var/delayedload = 0			// load applied to powernet between power ticks.

/datum/powernet/New()
	SSmachines.powernets += src

/datum/powernet/Destroy()
	ASSERT(nodes == null)	// nodes should of been nulled by cables before this qdelets!
	SSmachines.powernets -= src
	return ..()

/datum/powernet/proc/is_empty()
	return !cables.len && !nodes.len

//handles the power changes in the powernet
//called every ticks by the powernet controller
/datum/powernet/proc/reset()
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

/datum/powernet/proc/get_electrocute_damage()
	if(avail >= 1000)
		return clamp(20 + round(avail/25000), 20, 195) + rand(-5,5)
	else
		return 0
