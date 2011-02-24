/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.

Note: Must be placed west/left of and R&D console to function.

*/
/obj/machinery/r_n_d/protolathe
	name = "Protolathe"
	icon_state = "protolathe"
	flags = OPENCONTAINER
	var
		max_material_storage = 100000 //All this could probably be done better with a list but meh.
		m_amount = 0.0
		g_amount = 0.0
		gold_amount = 0.0
		silver_amount = 0.0
		plasma_amount = 0.0
		uranium_amount = 0.0
		diamond_amount = 0.0
		clown_amount = 0.0


	New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/circuitboard/protolathe(src)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/micro_manipulator(src)
		component_parts += new /obj/item/weapon/stock_parts/micro_manipulator(src)
		component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
		component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
		RefreshParts()

	proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
		return m_amount + g_amount + gold_amount + silver_amount + plasma_amount + uranium_amount + diamond_amount + clown_amount

	RefreshParts()
		var/T = 0
		for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
			T += G.reagents.maximum_volume
		var/datum/reagents/R = new/datum/reagents(T)		//Holder for the reagents used as materials.
		reagents = R
		R.my_atom = src
		T = 0
		for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
			T += M.rating
		max_material_storage = T * 75000

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (disabled)
			return
		if (shocked)
			shock(user,50)
		if (O.is_open_container())
			return 1
		if (istype(O, /obj/item/weapon/screwdriver))
			if (!opened)
				opened = 1
				if(linked_console)
					linked_console.linked_lathe = null
					linked_console = null
				icon_state = "protolathe_t"
				user << "You open the maintenance hatch of [src]."
			else
				opened = 0
				icon_state = "protolathe"
				user << "You close the maintenance hatch of [src]."
			return
		if (opened)
			if(istype(O, /obj/item/weapon/crowbar))
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 2
				M.icon_state = "box_1"
				for(var/obj/I in component_parts)
					I.loc = src.loc
				del(src)
				return 1
			else
				user << "\red You can't load the [src.name] while it's opened."
				return 1
		if (!linked_console)
			user << "\The protolathe must be linked to an R&D console first!"
			return 1
		if (busy)
			user << "\red The protolathe is busy. Please wait for completion of previous operation."
			return 1
		if (!istype(O, /obj/item/stack/sheet))
			user << "\red You cannot insert this item into the protolathe!"
			return 1
		if (stat)
			return 1
		if (TotalMaterials() + 3750 > max_material_storage)
			user << "\red The protolathe's material bin is full. Please remove material before adding more."
			return 1

		var/obj/item/stack/stack = O
		var/amount = 1
		var/title = "[stack.name]: [stack.amount] sheet\s left"
		switch(alert(title, "How many sheets do you want to load?", "one", "max", "cancel", null))
			if("one")
				amount = 1
			if("max")
				amount = min(stack.amount, round((max_material_storage-TotalMaterials())/3750))
			else
				return 1

		if(istype(O, /obj/item/stack/sheet/glass))
			flick("protolathe_r",src)//plays glass insertion animation
		else
			flick("protolathe_o",src)//plays metal insertion animation

		icon_state = "protolathe"
		busy = 1
		use_power(max(1000, (3750*amount/10)))
		spawn(16)
			icon_state = "protolathe"
			flick("protolathe_o",src)
			if(istype(stack, /obj/item/stack/sheet/metal))
				m_amount += amount * 3750
			else if(istype(stack, /obj/item/stack/sheet/glass))
				g_amount += amount * 3750
			else if(istype(stack, /obj/item/stack/sheet/gold))
				gold_amount += amount * 3750
			else if(istype(stack, /obj/item/stack/sheet/silver))
				silver_amount += amount * 3750
			else if(istype(stack, /obj/item/stack/sheet/plasma))
				plasma_amount += amount * 3750
			else if(istype(stack, /obj/item/stack/sheet/uranium))
				uranium_amount += amount * 3750
			else if(istype(stack, /obj/item/stack/sheet/diamond))
				diamond_amount += amount * 3750
			else if(istype(stack, /obj/item/stack/sheet/clown))
				clown_amount += amount * 3750
			stack.use(amount)
			busy = 0
			src.updateUsrDialog()
		return