/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/rnd/circuit_imprinter
	name = "circuit imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	container_type = OPENCONTAINER_1
	circuit = /obj/item/circuitboard/machine/circuit_imprinter

	var/efficiency_coeff
	var/console_link = TRUE			//can this link to a console?
	var/requires_console = TRUE

	var/datum/component/material_container/materials	//Store for hyper speed!

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

/obj/machinery/rnd/circuit_imprinter/Initialize()
	materials = AddComponent(/datum/component/material_container, list(MAT_GLASS, MAT_GOLD, MAT_DIAMOND, MAT_METAL, MAT_BLUESPACE),
		FALSE, list(/obj/item/stack, /obj/item/ore/bluespace_crystal), CALLBACK(src, .proc/is_insertion_ready), CALLBACK(src, .proc/AfterMaterialInsert))
	materials.precise_insertion = TRUE
	create_reagents(0)
	return ..()

/obj/machinery/rnd/circuit_imprinter/RefreshParts()
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

/obj/machinery/rnd/circuit_imprinter/blob_act(obj/structure/blob/B)
	if (prob(50))
		qdel(src)

/obj/machinery/rnd/circuit_imprinter/proc/check_mat(datum/design/being_built, M)	// now returns how many times the item can be built with the material
	var/list/all_materials = being_built.reagents_list + being_built.materials

	GET_COMPONENT(materials, /datum/component/material_container)
	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)

	return round(A / max(1, (all_materials[M]/efficiency_coeff)))

//we eject the materials upon deconstruction.
/obj/machinery/rnd/circuit_imprinter/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()
	..()


/obj/machinery/rnd/circuit_imprinter/disconnect_console()
	linked_console.linked_imprinter = null
	..()

/obj/machinery/rnd/circuit_imprinter/proc/user_try_print_id(id)
	if((!linked_console && requires_console) || !id)
		return FALSE
	var/datum/design/D = (linked_console || requires_console)? linked_console.stored_research.researched_designs[id] : get_techweb_design_by_id(id)
	if(!istype(D))
		return FALSE

	var/power = 1000
	for(var/M in D.materials)
		power += round(D.materials[M] / 5)
	power = max(4000, power)
	use_power(power)

	var/list/efficient_mats = list()
	for(var/MAT in D.materials)
		efficient_mats[MAT] = D.materials[MAT]/efficiency_coeff

	if(!materials.has_materials(efficient_mats))
		say("Not enough materials to complete prototype.")
		return FALSE
	for(var/R in D.reagents_list)
		if(!reagents.has_reagent(R, D.reagents_list[R]/efficiency_coeff))
			say("Not enough reagents to complete prototype.")
			return FALSE

	busy = TRUE
	flick("circuit_imprinter_ani", src)
	materials.use_amount(efficient_mats)
	for(var/R in D.reagents_list)
		reagents.remove_reagent(R, D.reagents_list[R]/efficiency_coeff)

	var/P = D.build_path
	addtimer(CALLBACK(src, .proc/reset_busy), 16)
	addtimer(CALLBACK(src, .proc/do_print, P, efficient_mats, D.dangerous_construction), 16)
	return TRUE

/obj/machinery/rnd/circuit_imprinter/proc/do_print(path, list/matlist, notify_admins)
	if(notify_admins && usr)
		investigate_log("[key_name(usr)] built [path] at a circuit imprinter.", INVESTIGATE_RESEARCH)
		message_admins("[ADMIN_LOOKUPFLW(usr)] has built [path] at a circuit imprinter.")
	var/obj/item/I = new path(get_turf(src))
	I.materials = matlist.Copy()
	SSblackbox.record_feedback("nested_tally", "circuit_printed", 1, list("[type]", "[path]"))
