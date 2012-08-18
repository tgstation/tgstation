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

	var/max_material_storage = 100000 //All this could probably be done better with a list but meh.
	var/m_amount = 0.0
	var/g_amount = 0.0
	var/gold_amount = 0.0
	var/silver_amount = 0.0
	var/plasma_amount = 0.0
	var/uranium_amount = 0.0
	var/diamond_amount = 0.0
	var/clown_amount = 0.0
	var/adamantine_amount = 0.0


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
	RefreshParts()

/obj/machinery/r_n_d/protolathe/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	return m_amount + g_amount + gold_amount + silver_amount + plasma_amount + uranium_amount + diamond_amount + clown_amount

/obj/machinery/r_n_d/protolathe/RefreshParts()
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

/obj/machinery/r_n_d/protolathe/attackby(var/obj/item/O as obj, var/mob/user as mob)
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
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				if(istype(I, /obj/item/weapon/reagent_containers/glass/beaker))
					reagents.trans_to(I, reagents.total_volume)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			if(m_amount >= 3750)
				var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal(src.loc)
				G.amount = round(m_amount / G.perunit)
			if(g_amount >= 3750)
				var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
				G.amount = round(g_amount / G.perunit)
			if(plasma_amount >= 2000)
				var/obj/item/stack/sheet/plasma/G = new /obj/item/stack/sheet/plasma(src.loc)
				G.amount = round(plasma_amount / G.perunit)
			if(silver_amount >= 2000)
				var/obj/item/stack/sheet/silver/G = new /obj/item/stack/sheet/silver(src.loc)
				G.amount = round(silver_amount / G.perunit)
			if(gold_amount >= 2000)
				var/obj/item/stack/sheet/gold/G = new /obj/item/stack/sheet/gold(src.loc)
				G.amount = round(gold_amount / G.perunit)
			if(uranium_amount >= 2000)
				var/obj/item/stack/sheet/uranium/G = new /obj/item/stack/sheet/uranium(src.loc)
				G.amount = round(uranium_amount / G.perunit)
			if(diamond_amount >= 2000)
				var/obj/item/stack/sheet/diamond/G = new /obj/item/stack/sheet/diamond(src.loc)
				G.amount = round(diamond_amount / G.perunit)
			if(clown_amount >= 2000)
				var/obj/item/stack/sheet/clown/G = new /obj/item/stack/sheet/clown(src.loc)
				G.amount = round(clown_amount / G.perunit)
			if(adamantine_amount >= 2000)
				var/obj/item/stack/sheet/adamantine/G = new /obj/item/stack/sheet/adamantine(src.loc)
				G.amount = round(adamantine_amount / G.perunit)
			del(src)
			return 1
		else
			user << "\red You can't load the [src.name] while it's opened."
			return 1
	if (disabled)
		return
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
	if(istype(O,/obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = O
		if (TotalMaterials() + S.perunit > max_material_storage)
			user << "\red The protolathe's material bin is full. Please remove material before adding more."
			return 1

	var/obj/item/stack/sheet/stack = O
	var/amount = round(input("How many sheets do you want to add?") as num)//No decimals
	if(amount < 0)//No negative numbers
		amount = 0
	if(amount == 0)
		return
	if(amount > stack.amount)
		amount = stack.amount
	if(max_material_storage - TotalMaterials() < (amount*stack.perunit))//Can't overfill
		amount = min(stack.amount, round((max_material_storage-TotalMaterials())/stack.perunit))

	src.overlays += "protolathe_[stack.name]"
	sleep(10)
	src.overlays -= "protolathe_[stack.name]"

	icon_state = "protolathe"
	busy = 1
	use_power(max(1000, (3750*amount/10)))
	spawn(16)
		user << "\blue You add [amount] sheets to the [src.name]."
		icon_state = "protolathe"
		if(istype(stack, /obj/item/stack/sheet/metal))
			m_amount += amount * 3750
		else if(istype(stack, /obj/item/stack/sheet/glass))
			g_amount += amount * 3750
		else if(istype(stack, /obj/item/stack/sheet/gold))
			gold_amount += amount * 2000
		else if(istype(stack, /obj/item/stack/sheet/silver))
			silver_amount += amount * 2000
		else if(istype(stack, /obj/item/stack/sheet/plasma))
			plasma_amount += amount * 2000
		else if(istype(stack, /obj/item/stack/sheet/uranium))
			uranium_amount += amount * 2000
		else if(istype(stack, /obj/item/stack/sheet/diamond))
			diamond_amount += amount * 2000
		else if(istype(stack, /obj/item/stack/sheet/clown))
			clown_amount += amount * 2000
		else if(istype(stack, /obj/item/stack/sheet/adamantine))
			adamantine_amount += amount * 2000
		stack.use(amount)
		busy = 0
		src.updateUsrDialog()
	return