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
	var/netexcess = 0 // excess power on the powernet (typically avail-load)///////
	var/delayedload = 0 // load applied to powernet between power ticks.

	/// If a run of propagate_light_flicker is ongoing
	VAR_PRIVATE/flickering = FALSE

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
	SEND_SIGNAL(C, COMSIG_CABLE_REMOVED_FROM_POWERNET)
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
	SEND_SIGNAL(C, COMSIG_CABLE_ADDED_TO_POWERNET)

//remove a power machine from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/remove_machine(obj/machinery/power/M)
	nodes -=M
	M.powernet = null
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

//handles the power changes in the powernet
//called every ticks by the powernet controller
/datum/powernet/proc/reset()
	//see if there's a surplus of power remaining in the powernet and stores unused power in the SMES
	netexcess = avail - load

	if(netexcess > 100 && length(nodes)) // if there was excess power last cycle
		for(var/obj/machinery/power/smes/S in nodes) // find the SMESes in the network
			S.restore() // and restore some of the power that was used

	// reset the powernet
	load = delayedload
	delayedload = 0
	avail = newavail
	newavail = 0

/datum/powernet/proc/get_electrocute_damage()
	return ELECTROCUTE_DAMAGE(energy_to_power(avail)) // Assuming 1 second of contact.

// Mostly just a wrapper for sending the COMSIG_POWERNET_CIRCUIT_TRANSMISSION signal, but could be retooled in the future to give it other uses
/datum/powernet/proc/data_transmission(list/data, encryption_key, datum/weakref/port)
	SEND_SIGNAL(src, COMSIG_POWERNET_CIRCUIT_TRANSMISSION, list("data" = data, "enc_key" = encryption_key, "port" = port))

/**
 * Triggers lights connected to this powernet to flicker a few times
 *
 * * flicker_source - The center of the flicker. If null the whole powernet will flicker
 * * falloff_distance - Only relevant if you passed a source. Areas beyond this distance will be less and less likely to flicker.
 */
/datum/powernet/proc/propagate_light_flicker(atom/flicker_source, falloff_distance = 32)
	if(flickering || !length(nodes))
		return

	flickering = TRUE
	for(var/obj/machinery/power/terminal/terminal in nodes)
		if(!istype(terminal.master, /obj/machinery/power/apc))
			continue

		var/flicker_prob = 85
		if(!isnull(flicker_source))
			flicker_prob = 85 + min(3 * (falloff_distance - get_dist(flicker_source, terminal)), 0)

		if(!prob(flicker_prob))
			continue

		var/obj/machinery/power/apc/apc = terminal.master
		for(var/obj/machinery/light/light as anything in apc.get_lights())
			light.flicker(amount = 1)
			CHECK_TICK

	// don't let another flicker propagation until our slowest area is done (with some added leeway)
	addtimer(VARSET_CALLBACK(src, flickering, FALSE), 9 SECONDS)
