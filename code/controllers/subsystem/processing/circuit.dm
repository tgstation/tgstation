PROCESSING_SUBSYSTEM_DEF(circuit)
	name = "Circuit"
	stat_tag = "CIR"
	var/list/all_exonet_connections = list()
	var/list/all_integrated_circuits = list()
	var/cipherkey
	init_order = INIT_ORDER_CIRCUIT
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING

/datum/controller/subsystem/processing/circuit/Initialize(start_timeofday)
	SScircuit.cipherkey = random_string(20, GLOB.alphabet)
	initialize_integrated_circuits_list()
	return ..()

/datum/controller/subsystem/processing/circuit/proc/initialize_integrated_circuits_list()
	all_integrated_circuits = list()
	for(var/thing in typesof(/obj/item/integrated_circuit))
		all_integrated_circuits += new thing()

/datum/controller/subsystem/processing/circuit/proc/get_exonet_node()
	for(var/obj/machinery/exonet_node/E in GLOB.machines)
		if(E.on)
			return E