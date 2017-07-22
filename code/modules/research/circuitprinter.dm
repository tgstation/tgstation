/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/rnd/circuit_imprinter
	name = "circuit imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	container_type = OPENCONTAINER

	var/datum/material_container/materials
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

/obj/machinery/rnd/circuit_imprinter/Initialize()
	. = ..()
	materials = new(src, list(MAT_GLASS, MAT_GOLD, MAT_DIAMOND, MAT_METAL, MAT_BLUESPACE))
	create_reagents(0)
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/circuit_imprinter(null)
	B.apply_default_parts(src)

/obj/machinery/rnd/circuit_imprinter/Destroy()
	qdel(materials)
	return ..()

/obj/item/weapon/circuitboard/machine/circuit_imprinter
	name = "Circuit Imprinter (Machine Board)"
	build_path = /obj/machinery/rnd/circuit_imprinter
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/reagent_containers/glass/beaker = 2)

/obj/machinery/rnd/circuit_imprinter/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)

	materials.max_amount = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		materials.max_amount += M.rating * 75000

	var/T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating
	efficiency_coeff = 2 ** (T - 1) //Only 1 manipulator here, you're making runtimes Razharas

/obj/machinery/rnd/circuit_imprinter/blob_act(obj/structure/blob/B)
	if (prob(50))
		qdel(src)

/obj/machinery/rnd/circuit_imprinter/proc/check_mat(datum/design/being_built, M)	// now returns how many times the item can be built with the material
	var/list/all_materials = being_built.reagents_list + being_built.materials

	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)

	return round(A / max(1, (all_materials[M]/efficiency_coeff)))

//we eject the materials upon deconstruction.
/obj/machinery/rnd/circuit_imprinter/on_deconstruction()
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	materials.retrieve_all()
	..()


/obj/machinery/rnd/circuit_imprinter/disconnect_console()
	linked_console.linked_imprinter = null
	..()

/obj/machinery/rnd/circuit_imprinter/Insert_Item(obj/item/O, mob/user)

	if(istype(O, /obj/item/stack/sheet))
		. = 1
		if(!is_insertion_ready(user))
			return
		var/sheet_material = materials.get_item_material_amount(O)
		if(!sheet_material)
			return

		if(!materials.has_space(sheet_material))
			to_chat(user, "<span class='warning'>The [src.name]'s material bin is full! Please remove material before adding more.</span>")
			return 1

		var/obj/item/stack/sheet/stack = O
		var/amount = round(input("How many sheets do you want to add?") as num)//No decimals
		if(!in_range(src, stack) || !user.Adjacent(src))
			return
		var/amount_inserted = materials.insert_stack(O,amount)
		if(!amount_inserted)
			return 1
		else
			use_power(max(1000, (MINERAL_MATERIAL_AMOUNT*amount_inserted/10)))
			to_chat(user, "<span class='notice'>You add [amount_inserted] sheets to the [src.name].</span>")
		updateUsrDialog()

	else if(istype(O, /obj/item/weapon/ore/bluespace_crystal)) //Bluespace crystals can be either a stack or an item
		. = 1
		if(!is_insertion_ready(user))
			return
		var/bs_material = materials.get_item_material_amount(O)
		if(!bs_material)
			return

		if(!materials.has_space(bs_material))
			to_chat(user, "<span class='warning'>The [src.name]'s material bin is full! Please remove material before adding more.</span>")
			return 1

		materials.insert_item(O)
		use_power(MINERAL_MATERIAL_AMOUNT/10)
		to_chat(user, "<span class='notice'>You add [O] to the [src.name].</span>")
		qdel(O)
		updateUsrDialog()

	else if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>You cannot insert this item into the [name]!</span>")
		return 1
	else
		return 0

/obj/machinery/rnd/circuit_imprinter/proc/user_try_print_id(id)
	if(!linked_console || !id)
		return FALSE
	var/datum/design/D = linked_console.stored_research.researched_designs[id]
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
	addtimer(CALLBACK(src, .proc/do_print, P, efficient_mats), 16)

/obj/machinery/rnd/circuit_imprinter/proc/do_print(path, list/matlist)
	if(QDELETED(src))
		return FALSE
	var/obj/item/I = new path(get_turf(src))
	I.materials = matlist.Copy()
	SSblackbox.add_details("circuit_printed","[path]")
