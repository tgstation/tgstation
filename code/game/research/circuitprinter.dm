/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/r_n_d/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "circuit_imprinter"
	flags = OPENCONTAINER
	var
		g_amount = 0
		max_g_amount = 75000.0

	New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/circuitboard/circuit_imprinter(src)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/micro_manipulator(src)
		component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
		component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
		RefreshParts()

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
		max_g_amount = T * 75000.0


	blob_act()
		if (prob(50))
			del(src)

	meteorhit()
		del(src)
		return

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (disabled)
			return
		if (shocked)
			shock(user,50)
		if (istype(O, /obj/item/weapon/screwdriver))
			if (!opened)
				opened = 1
				if(linked_console)
					linked_console.linked_imprinter = null
					linked_console = null
				icon_state = "circuit_imprinter_t"
				user << "You open the maintenance hatch of [src]."
			else
				opened = 0
				icon_state = "circuit_imprinter"
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
			user << "\The [name] must be linked to an R&D console first!"
			return 1
		if (O.is_open_container())
			return 1
		if (!istype(O, /obj/item/stack/sheet/glass))
			user << "\red You cannot insert this item into the [name]!"
			return 1
		if (stat)
			return 1
		if (busy)
			user << "\red The [name] is busy. Please wait for completion of previous operation."
			return 1
		if (src.g_amount + O.g_amt > max_g_amount)
			user << "\red The [name] is full. Please remove glass from the protolathe in order to insert more."
			return 1

		var/amount = 1
		var/obj/item/stack/sheet/glass/stack
		var/g_amt = O.g_amt
		stack = O
		amount = stack.amount
		if (g_amt)
			amount = min(amount, round((max_g_amount-src.g_amount)/g_amt))
		stack.use(amount)
		busy = 1
		use_power(max(1000, (g_amt)*amount/10))
		spawn(16)
			src.g_amount += g_amt * amount
			if (O && O.loc == src)
				del(O)
			busy = 0
			src.updateUsrDialog()
			return
