/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/datum/circuitimprinter_queue_item
	var/key
	var/datum/design/thing

	New(var/K,var/datum/design/D)
		key=K
		thing=D

#define IMPRINTER_MAX_Q_LEN 30
/obj/machinery/r_n_d/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "circuit_imprinter"
	flags = OPENCONTAINER

	var/max_material_amount = 75000.0

	var/list/datum/circuitimprinter_queue_item/production_queue = list()
	var/datum/materials/materials
	var/stopped=1
	var/obj/output=null
	var/allowed_materials=list(
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/stack/sheet/mineral/uranium,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/mineral/pharosium,
		/obj/item/stack/sheet/mineral/char,
		/obj/item/stack/sheet/mineral/claretine,
		/obj/item/stack/sheet/mineral/bohrum,
		/obj/item/stack/sheet/mineral/syreline,
		/obj/item/stack/sheet/mineral/erebite,
		/obj/item/stack/sheet/mineral/cytine,
		/obj/item/stack/sheet/mineral/telecrystal,
		/obj/item/stack/sheet/mineral/mauxite,
		/obj/item/stack/sheet/mineral/cobryl,
		/obj/item/stack/sheet/mineral/cerenkite,
		/obj/item/stack/sheet/mineral/molitz,
		/obj/item/stack/sheet/mineral/uqill
	)

/obj/machinery/r_n_d/circuit_imprinter/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/circuit_imprinter,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/beaker
	)

	RefreshParts()

	materials = new

	// Define initial output.
	output=src
	for(var/direction in cardinal)
		var/O = locate(/obj/machinery/mineral/output, get_step(src, dir))
		if(O)
			output=O
			break

/obj/machinery/r_n_d/circuit_imprinter/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	var/total=0
	for(var/id in materials.storage)
		total += materials.getAmount(id)
	return total

/obj/machinery/r_n_d/circuit_imprinter/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		T += G.reagents.maximum_volume

	create_reagents(T) // Holder for the reagents used as materials.
	T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_amount = T * 75000.0

/obj/machinery/r_n_d/circuit_imprinter/update_icon()
	overlays.Cut()
	if(linked_console)
		overlays += "circuit_imprinter_link"

/obj/machinery/r_n_d/circuit_imprinter/blob_act()
	if (prob(50))
		del(src)

/obj/machinery/r_n_d/circuit_imprinter/meteorhit()
	del(src)
	return

/obj/machinery/r_n_d/circuit_imprinter/proc/check_mat(var/datum/design/being_built, var/M, var/num_requested=1)
	if(copytext(M,1,2) == "$")
		var/matID=copytext(M,2)
		var/matAmount=materials.getAmount(matID)
		for(var/n=num_requested,n>=1,n--)
			if ((matAmount-(being_built.materials[M]*n)) >= 0)
				return n
	else
		for(var/n=num_requested,n>=1,n--)
			if (reagents.has_reagent(M, being_built.materials[M]))
				return n
	return 0

/obj/machinery/r_n_d/circuit_imprinter/attackby(var/obj/item/O as obj, var/mob/user as mob)
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
	if (istype(O, /obj/item/device/multitool))
		if(!opened)
			var/result = input("Set your location as output?") in list("Yes","No","Machine Location")
			switch(result)
				if("Yes")
					var/found=0
					for(var/direction in cardinal)
						if(locate(user) in get_step(src,direction))
							found=1
					if(!found)
						user << "\red Cannot set this as the output location; You're too far away."
						return
					if(istype(output,/obj/machinery/mineral/output))
						del(output)
					output=new /obj/machinery/mineral/output(usr.loc)
					user << "\blue Output set."
				if("No")
					return
				if("Machine Location")
					if(istype(output,/obj/machinery/mineral/output))
						del(output)
					output=src
					user << "\blue Output set."
		return
	if (opened)
		if(istype(O, /obj/item/weapon/crowbar))
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				if(istype(I, /obj/item/weapon/reagent_containers/glass/beaker))
					reagents.trans_to(I, reagents.total_volume)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			for(var/id in materials.storage)
				var/datum/material/material=materials.getMaterial(id)
				if(material.stored >= material.cc_per_sheet)
					var/obj/item/stack/sheet/S=new material.sheettype(src.loc)
					S.amount = round(material.stored / material.cc_per_sheet)
			del(src)
			return 1
		else
			user << "\red You can't load the [src.name] while it's opened."
			return 1
	if (disabled)
		user << "\The [name] appears to not be working!"
		return
	if (!linked_console)
		user << "\The [name] must be linked to an R&D console first!"
		return 1
	if (O.is_open_container())
		return 0
	if (!(O.type in allowed_materials))
		user << "\red You cannot insert this item into the [name]!"
		return 1
	if (stat)
		return 1
	if (busy)
		user << "\red The [name] is busy. Please wait for completion of previous operation."
		return 1
	var/obj/item/stack/sheet/stack = O
	if ((TotalMaterials() + stack.perunit) > max_material_amount)
		user << "\red The [name] is full. Please remove glass from \the [name] in order to insert more."
		return 1

	var/amount = round(input("How many sheets do you want to add?") as num)
	if(amount < 0)
		amount = 0
	if(amount == 0)
		return
	if(amount > stack.amount)
		amount = min(stack.amount, round((max_material_amount-TotalMaterials())/stack.perunit))

	busy = 1
	use_power(max(1000, (3750*amount/10)))
	var/stacktype = stack.type
	stack.use(amount)
	if (do_after(user, 16))
		user << "\blue You add [amount] sheets to the [src.name]."
		for(var/id in materials.storage)
			var/datum/material/material=materials.getMaterial(id)
			if(stacktype == material.sheettype)
				materials.addAmount(id, amount * material.cc_per_sheet)
	else
		new stacktype(src.loc, amount)
	busy = 0
	src.updateUsrDialog()

/obj/machinery/r_n_d/circuit_imprinter/proc/enqueue(var/key, var/datum/design/thing_to_build)
	if(production_queue.len>=IMPRINTER_MAX_Q_LEN)
		return 0
	production_queue.Add(new /datum/circuitimprinter_queue_item(key,thing_to_build))
	//stopped=1
	return 1

/obj/machinery/r_n_d/circuit_imprinter/proc/queue_pop()
	var/datum/circuitimprinter_queue_item/I = production_queue[1]
	production_queue.Remove(I)
	return I

/obj/machinery/r_n_d/circuit_imprinter/process()
	if(busy || stopped)
		return
	if(production_queue.len==0)
		stopped=1
		return
	busy=1
	spawn(0)
		var/datum/protolathe_queue_item/I = queue_pop()
		if(!build_thing(I))
			production_queue.Add(I)
		busy=0

/obj/machinery/r_n_d/circuit_imprinter/proc/build_thing(var/datum/circuitimprinter_queue_item/I)
	//var/key=I.key
	var/datum/design/being_built=I.thing
	busy=1
	flick("circuit_imprinter_ani",src)
	spawn(16)
		for(var/M in being_built.materials)
			if(!check_mat(being_built,M,1))
				src.visible_message("<font color='blue'>The [src.name] beeps, \"Not enough materials to complete circuit board.\"</font>")
				stopped=1
				return 0
			if(copytext(M,1,2) == "$")
				var/matID=copytext(M,2)
				materials.removeAmount(matID, being_built.materials[M])
			else
				reagents.remove_reagent(M, being_built.materials[M])
		if(being_built.build_path)
			var/obj/new_item = new being_built.build_path(src)
			new_item.reliability = being_built.reliability
			if(hacked)
				being_built.reliability = max((reliability / 2), 0)
			busy=0
			new_item.loc=output.loc
	return 1
