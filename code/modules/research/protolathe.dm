/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.

Note: Must be placed west/left of and R&D console to function.

*/
/obj/machinery/r_n_d/protolathe
	name = "Protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	flags = OPENCONTAINER

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
								"Firing Pins"
								)

	reagents = new()


/obj/machinery/r_n_d/protolathe/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/protolathe(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
	materials = new(src, list(MAT_METAL=1, MAT_GLASS=1, MAT_SILVER=1, MAT_GOLD=1, MAT_DIAMOND=1, MAT_PLASMA=1, MAT_URANIUM=1, MAT_BANANIUM=1))
	RefreshParts()

	reagents.my_atom = src

/obj/machinery/r_n_d/protolathe/Destroy()
	qdel(materials)
	return ..()

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	materials.max_amount = T * 75000
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += (M.rating/3)
	efficiency_coeff = max(T, 1)

/obj/machinery/r_n_d/protolathe/proc/check_mat(datum/design/being_built, M)	// now returns how many times the item can be built with the material
	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)
		A = A / max(1, (being_built.reagents[M]))
	else
		A = A / max(1, (being_built.materials[M]))
	return A

/obj/machinery/r_n_d/protolathe/attackby(obj/item/O, mob/user, params)
	if (shocked)
		shock(user,50)
	if (default_deconstruction_screwdriver(user, "protolathe_t", "protolathe", O))
		if(linked_console)
			linked_console.linked_lathe = null
			linked_console = null
		return

	if(exchange_parts(user, O))
		return

	if (panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
				reagents.trans_to(G, G.reagents.maximum_volume)
			materials.retrieve_all()
			default_deconstruction_crowbar(O)
			return 1
		else
			user << "<span class='warning'>You can't load the [src.name] while it's opened!</span>"
			return 1
	if (disabled)
		return
	if (!linked_console)
		user << "<span class='warning'>The [src.name] must be linked to an R&D console first!</span>"
		return 1
	if (busy)
		user << "<span class='warning'>The [src.name] is busy! Please wait for completion of previous operation.</span>"
		return 1
	if (O.is_open_container())
		return
	if (stat)
		return 1
	if(!istype(O,/obj/item/stack/sheet))
		return 1

	if(!materials.has_space( materials.get_item_material_amount(O) ))
		user << "<span class='warning'>The [src.name]'s material bin is full! Please remove material before adding more.</span>"
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
		busy = 1
		use_power(max(1000, (MINERAL_MATERIAL_AMOUNT*amount_inserted/10)))
		user << "<span class='notice'>You add [amount_inserted] sheets to the [src.name].</span>"
		overlays += "protolathe_[stack_name]"
		sleep(10)
		overlays -= "protolathe_[stack_name]"
		busy = 0
	updateUsrDialog()
