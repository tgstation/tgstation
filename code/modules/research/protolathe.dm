/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.

Note: Must be placed west/left of and R&D console to function.

*/
/obj/machinery/r_n_d/protolathe
	name = "protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	container_type = OPENCONTAINER_1
	circuit = /obj/item/circuitboard/machine/protolathe

	var/datum/material_container/materials
	var/efficiency_coeff

	var/list/categories = list(
								"Power Designs",
								"Medical Designs",
								"Bluespace Designs",
								"Stock Parts",
								"Equipment",
								"Mining Designs",
								"Electronics",
								"Weapons",
								"Ammo",
								"Firing Pins",
								"Computer Parts"
								)


/obj/machinery/r_n_d/protolathe/Initialize()
	create_reagents(0)
	materials = new(src, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE))
	return ..()

/obj/machinery/r_n_d/protolathe/Destroy()
	QDEL_NULL(materials)
	return ..()

/obj/machinery/r_n_d/protolathe/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)

	materials.max_amount = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		materials.max_amount += M.rating * 75000

	var/T = 1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T -= M.rating/10
	efficiency_coeff = min(max(0, T), 1)

/obj/machinery/r_n_d/protolathe/proc/check_mat(datum/design/being_built, M)	// now returns how many times the item can be built with the material
	var/list/all_materials = being_built.reagents_list + being_built.materials

	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)

	return round(A / max(1, (all_materials[M]*efficiency_coeff)))

//we eject the materials upon deconstruction.
/obj/machinery/r_n_d/protolathe/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	materials.retrieve_all()
	..()


/obj/machinery/r_n_d/protolathe/disconnect_console()
	linked_console.linked_lathe = null
	..()

/obj/machinery/r_n_d/protolathe/Insert_Item(obj/item/O, mob/user)

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
			var/stack_name = stack.name
			busy = TRUE
			use_power(max(1000, (MINERAL_MATERIAL_AMOUNT*amount_inserted/10)))
			to_chat(user, "<span class='notice'>You add [amount_inserted] sheets to the [src.name].</span>")
			add_overlay("protolathe_[stack_name]")
			sleep(10)
			cut_overlay("protolathe_[stack_name]")
			busy = FALSE
		updateUsrDialog()

	else if(istype(O, /obj/item/ore/bluespace_crystal)) //Bluespace crystals can be either a stack or an item
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
		busy = TRUE
		use_power(MINERAL_MATERIAL_AMOUNT/10)
		to_chat(user, "<span class='notice'>You add [O] to the [src.name].</span>")
		qdel(O)
		add_overlay("protolathe_bluespace")
		sleep(10)
		cut_overlay("protolathe_bluespace")
		busy = FALSE
		updateUsrDialog()

	else if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>You cannot insert this item into the [name]!</span>")
		return 1
	else
		return 0
