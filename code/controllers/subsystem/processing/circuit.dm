PROCESSING_SUBSYSTEM_DEF(circuit)
	name = "Circuit"
	stat_tag = "CIR"
	init_order = INIT_ORDER_CIRCUIT
	flags = NONE

	var/cipherkey

	var/list/all_components = list()								// Associative list of [component_name]:[component_path] pairs
	var/list/cached_components = list()								// Associative list of [component_path]:[component] pairs
	var/list/all_assemblies = list()								// Associative list of [assembly_name]:[assembly_path] pairs
	var/list/cached_assemblies = list()								// Associative list of [assembly_path]:[assembly] pairs
	var/list/all_circuits = list()									// Associative list of [circuit_name]:[circuit_path] pairs
	var/list/circuit_fabricator_recipe_list = list()				// Associative list of [category_name]:[list_of_circuit_paths] pairs
	var/cost_multiplier = MINERAL_MATERIAL_AMOUNT / 10 // Each circuit cost unit is 200cm3

/datum/controller/subsystem/processing/circuit/Initialize(start_timeofday)
	SScircuit.cipherkey = uppertext(random_string(2000+rand(0,10), GLOB.alphabet))
	circuits_init()
	return ..()

/datum/controller/subsystem/processing/circuit/proc/circuits_init()
	//Cached lists for free performance
	for(var/path in typesof(/obj/item/integrated_circuit))
		var/obj/item/integrated_circuit/IC = path
		var/name = initial(IC.name)
		all_components[name] = path // Populating the component lists
		cached_components[IC] = new path

		if(!(initial(IC.spawn_flags) & (IC_SPAWN_DEFAULT | IC_SPAWN_RESEARCH)))
			continue

		var/category = initial(IC.category_text)
		if(!circuit_fabricator_recipe_list[category])
			circuit_fabricator_recipe_list[category] = list()
		var/list/category_list = circuit_fabricator_recipe_list[category]
		category_list += IC // Populating the fabricator categories

	for(var/path in typesof(/obj/item/electronic_assembly))
		var/obj/item/electronic_assembly/A = path
		var/name = initial(A.name)
		all_assemblies[name] = path
		cached_assemblies[A] = new path


	circuit_fabricator_recipe_list["Assemblies"] = list(
		/obj/item/electronic_assembly/default,
		/obj/item/electronic_assembly/calc,
		/obj/item/electronic_assembly/clam,
		/obj/item/electronic_assembly/simple,
		/obj/item/electronic_assembly/hook,
		/obj/item/electronic_assembly/pda,
		/obj/item/electronic_assembly/small/default,
		/obj/item/electronic_assembly/small/cylinder,
		/obj/item/electronic_assembly/small/scanner,
		/obj/item/electronic_assembly/small/hook,
		/obj/item/electronic_assembly/small/box,
		/obj/item/electronic_assembly/medium/default,
		/obj/item/electronic_assembly/medium/box,
		/obj/item/electronic_assembly/medium/clam,
		/obj/item/electronic_assembly/medium/medical,
		/obj/item/electronic_assembly/medium/gun,
		/obj/item/electronic_assembly/medium/radio,
		/obj/item/electronic_assembly/large/default,
		/obj/item/electronic_assembly/large/scope,
		/obj/item/electronic_assembly/large/terminal,
		/obj/item/electronic_assembly/large/arm,
		/obj/item/electronic_assembly/large/tall,
		/obj/item/electronic_assembly/large/industrial,
		/obj/item/electronic_assembly/drone/default,
		/obj/item/electronic_assembly/drone/arms,
		/obj/item/electronic_assembly/drone/secbot,
		/obj/item/electronic_assembly/drone/medbot,
		/obj/item/electronic_assembly/drone/genbot,
		/obj/item/electronic_assembly/drone/android,
		/obj/item/electronic_assembly/wallmount/tiny,
		/obj/item/electronic_assembly/wallmount/light,
		/obj/item/electronic_assembly/wallmount,
		/obj/item/electronic_assembly/wallmount/heavy
		///obj/item/weapon/implant/integrated_circuit
		)

	circuit_fabricator_recipe_list["Tools"] = list(
		/obj/item/integrated_electronics/wirer,
		/obj/item/integrated_electronics/debugger,
		/obj/item/integrated_electronics/analyzer,
		/obj/item/integrated_electronics/detailer,
		/obj/item/card/data,
		/obj/item/card/data/full_color,
		/obj/item/card/data/disk
		)
		
