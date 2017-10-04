/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/r_n_d/circuit_imprinter
	name = "circuit imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	container_type = OPENCONTAINER_1
	circuit = /obj/item/circuitboard/machine/circuit_imprinter

	var/efficiency_coeff

	var/list/categories = list(
								"AI Modules",
								"Computer Boards",
								"Teleportation Machinery",
								"Medical Machinery",
								"Engineering Machinery",
								"Exosuit Modules",
								"Hydroponics Machinery",
								"Subspace Telecomms",
								"Research Machinery",
								"Misc. Machinery",
								"Computer Parts"
								)

/obj/machinery/r_n_d/circuit_imprinter/Initialize()
	AddComponent(/datum/component/material_container, list(MAT_GLASS, MAT_GOLD, MAT_DIAMOND, MAT_METAL, MAT_BLUESPACE),
		FALSE, list(/obj/item/stack, /obj/item/ore/bluespace_crystal), CALLBACK(src, .proc/is_insertion_ready))
	create_reagents(0)
	return ..()

/obj/machinery/r_n_d/circuit_imprinter/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)

	GET_COMPONENT(materials, /datum/component/material_container)
	materials.max_amount = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		materials.max_amount += M.rating * 75000

	var/T = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T += M.rating
	efficiency_coeff = 2 ** (T - 1) //Only 1 manipulator here, you're making runtimes Razharas

/obj/machinery/r_n_d/circuit_imprinter/blob_act(obj/structure/blob/B)
	if (prob(50))
		qdel(src)

/obj/machinery/r_n_d/circuit_imprinter/proc/check_mat(datum/design/being_built, M)	// now returns how many times the item can be built with the material
	var/list/all_materials = being_built.reagents_list + being_built.materials

	GET_COMPONENT(materials, /datum/component/material_container)
	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)

	return round(A / max(1, (all_materials[M]/efficiency_coeff)))

//we eject the materials upon deconstruction.
/obj/machinery/r_n_d/circuit_imprinter/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()
	..()


/obj/machinery/r_n_d/circuit_imprinter/disconnect_console()
	linked_console.linked_imprinter = null
	..()

/obj/machinery/r_n_d/circuit_imprinter/ComponentActivated(datum/component/C)
	..()
	if(istype(C, /datum/component/material_container))
		var/datum/component/material_container/M = C
		if(!M.last_insert_success)
			return
		var/lit = M.last_inserted_type
		var/stack_name
		if(ispath(lit, /obj/item/ore/bluespace_crystal))
			stack_name = "bluespace"
			use_power(MINERAL_MATERIAL_AMOUNT / 10)
		else
			var/obj/item/stack/S = lit
			stack_name = initial(S.name)
			use_power(max(1000, (MINERAL_MATERIAL_AMOUNT * M.last_amount_inserted / 10)))
		add_overlay("protolathe_[stack_name]")
		addtimer(CALLBACK(src, /atom/proc/cut_overlay, "protolathe_[stack_name]"), 10)
