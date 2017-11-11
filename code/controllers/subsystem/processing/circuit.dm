PROCESSING_SUBSYSTEM_DEF(circuit)
	name = "Circuit"
	stat_tag = "CIR"
	var/list/all_exonet_connections = list()				//Address = connection datum.
	var/list/all_integrated_circuits = list()
	var/list/obj/machinery/exonet_node/all_exonet_nodes = list()
	var/cipherkey
	var/list/circuit_fabricator_recipe_list = list()
	init_order = INIT_ORDER_CIRCUIT
	flags = NONE

/datum/controller/subsystem/processing/circuit/Initialize(start_timeofday)
	SScircuit.cipherkey = random_string(2000+rand(0,10), GLOB.alphabet)
	initialize_integrated_circuits_list()
	initialize_circuit_fabricator_recipes()
	return ..()

/datum/controller/subsystem/processing/circuit/proc/initialize_integrated_circuits_list()
	all_integrated_circuits = list()
	for(var/thing in typesof(/obj/item/integrated_circuit))
		all_integrated_circuits += new thing()

/datum/controller/subsystem/processing/circuit/proc/initialize_circuit_fabricator_recipes()
		// First loop is to seperate the actual circuits from base circuits.
	var/list/circuits_to_use = list()
	for(var/obj/item/integrated_circuit/IC in SScircuit.all_integrated_circuits)
		if((IC.spawn_flags & IC_SPAWN_DEFAULT) || (IC.spawn_flags & IC_SPAWN_RESEARCH))
			circuits_to_use.Add(IC)
		// Second loop is to find all categories.
	var/list/found_categories = list()
	for(var/obj/item/integrated_circuit/IC in circuits_to_use)
		if(!(IC.category_text in found_categories))
			found_categories.Add(IC.category_text)
		// Third loop is to initialize lists by category names, then put circuits matching the category inside.
	for(var/category in found_categories)
		circuit_fabricator_recipe_list[category] = list()
		var/list/current_list = circuit_fabricator_recipe_list[category]
		for(var/obj/item/integrated_circuit/IC in circuits_to_use)
			if(IC.category_text == category)
				current_list.Add(IC)
		// Now for non-circuit things.
	var/list/assembly_list = list()
	assembly_list.Add(
		new /obj/item/device/electronic_assembly(null),
		new /obj/item/device/electronic_assembly/medium(null),
		new /obj/item/device/electronic_assembly/large(null),
		new /obj/item/device/electronic_assembly/drone(null),
		//new /obj/item/weapon/implant/integrated_circuit(null),
		//new /obj/item/device/assembly/electronic_assembly(null)
	)
	circuit_fabricator_recipe_list["Assemblies"] = assembly_list
	var/list/tools_list = list()
	tools_list.Add(
		new /obj/item/device/integrated_electronics/wirer(null),
		new /obj/item/device/integrated_electronics/debugger(null),
		new /obj/item/device/integrated_electronics/analyzer(null)
		)
	circuit_fabricator_recipe_list["Tools"] = tools_list

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