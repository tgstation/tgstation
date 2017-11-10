PROCESSING_SUBSYSTEM_DEF(circuit)
	name = "Circuit"
	stat_tag = "CIR"
	var/list/all_exonet_connections = list()				//Address = connection datum.
	var/list/all_integrated_circuits = list()
	var/list/obj/machinery/exonet_node/all_exonet_nodes = list()
	var/cipherkey
	init_order = INIT_ORDER_CIRCUIT
	flags = NONE

/datum/controller/subsystem/processing/circuit/Initialize(start_timeofday)
	SScircuit.cipherkey = random_string(2000+rand(0,10), GLOB.alphabet)
	initialize_integrated_circuits_list()
	return ..()

/datum/controller/subsystem/processing/circuit/proc/initialize_integrated_circuits_list()
	all_integrated_circuits = list()
	for(var/thing in typesof(/obj/item/integrated_circuit))
		all_integrated_circuits += new thing()

/datum/controller/subsystem/processing/circuit/proc/get_exonet_node()
	for(var/obj/machinery/exonet_node/E in all_exonet_nodes)
		if(E.is_operating())
			return E

/datum/controller/subsystem/processing/circuit/proc/get_exonet_address(addr)
	return all_exonet_connections[addr]

/datum/controller/subsystem/processing/circuit/proc/return_all_exonet_connections()
	. = list()
	for(var/i in all_exonet_connections)
		. += all_exonet_connections[i]
