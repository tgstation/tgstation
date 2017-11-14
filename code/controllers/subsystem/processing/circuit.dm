PROCESSING_SUBSYSTEM_DEF(circuit)
	name = "Circuit"
	stat_tag = "CIR"
	init_order = INIT_ORDER_CIRCUIT
	flags = NONE

	var/cipherkey

	var/list/all_exonet_connections = list()						//Address = connection datum.
	var/list/obj/machinery/exonet_node/all_exonet_nodes = list()

	var/list/all_circuits = list()									// Associative list of [circuit_name]:[circuit_path] pairs
	var/list/circuit_fabricator_recipe_list = list()				// Associative list of [category_name]:[list_of_circuit_paths] pairs

/datum/controller/subsystem/processing/circuit/Initialize(start_timeofday)
	SScircuit.cipherkey = random_string(2000+rand(0,10), GLOB.alphabet)
	circuits_init()
	return ..()

/datum/controller/subsystem/processing/circuit/proc/circuits_init()
	//Cached lists for free performance
	var/list/all_circuits = src.all_circuits
	var/list/circuit_fabricator_recipe_list = src.circuit_fabricator_recipe_list
	for(var/path in typesof(/obj/item/integrated_circuit))
		var/obj/item/integrated_circuit/IC = path
		var/name = initial(IC.name)
		all_circuits[name] = IC // Populating the complete list

		if(!(initial(IC.spawn_flags) & (IC_SPAWN_DEFAULT | IC_SPAWN_RESEARCH)))
			continue

		var/category = initial(IC.category_text)
		if(!circuit_fabricator_recipe_list[category])
			circuit_fabricator_recipe_list[category] = list()
		var/list/category_list = circuit_fabricator_recipe_list[category]
		category_list += IC // Populating the fabricator categories

	circuit_fabricator_recipe_list["Assemblies"] = list(
		/obj/item/device/electronic_assembly,
		/obj/item/device/electronic_assembly/medium,
		/obj/item/device/electronic_assembly/large,
		/obj/item/device/electronic_assembly/drone
		//new /obj/item/weapon/implant/integrated_circuit,
		//new /obj/item/device/assembly/electronic_assembly
		)

	circuit_fabricator_recipe_list["Tools"] = list(
		/obj/item/device/integrated_electronics/wirer,
		/obj/item/device/integrated_electronics/debugger,
		/obj/item/device/integrated_electronics/analyzer
		)

/datum/controller/subsystem/processing/circuit/proc/get_exonet_node()
	for(var/i in 1 to all_exonet_nodes.len)
		var/obj/machinery/exonet_node/E = all_exonet_nodes[i]
		if(E.is_operating())
			return E

/datum/controller/subsystem/processing/circuit/proc/get_exonet_address(addr)
	return all_exonet_connections[addr]


// Proc: get_atom_from_address()
// Parameters: 1 (target_address - the desired address to find)
// Description: Searches an address for the atom it is attached for, otherwise returns null.

/datum/controller/subsystem/processing/circuit/proc/get_atom_from_address(var/target_address)
	var/datum/exonet_protocol/exonet = SScircuit.get_exonet_address(target_address)
	if(exonet)
		return exonet.holder