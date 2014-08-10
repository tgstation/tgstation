/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.
*/

/datum/protolathe_queue_item
	var/key
	var/datum/design/thing

	New(var/K,var/datum/design/D)
		key=K
		thing=D

/obj/machinery/r_n_d/protolathe
	name = "Protolathe"
	icon_state = "protolathe"
	flags = OPENCONTAINER

	var/max_material_storage = 100000 //All this could probably be done better with a list but meh.
	var/list/production_queue = list()
	var/list/datum/material/materials = list()
	var/stopped=1
	var/obj/output=null

	l_color = "#7BF9FF"

	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			SetLuminosity(2)
		else
			SetLuminosity(0)

/obj/machinery/r_n_d/protolathe/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/protolathe,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/beaker
	)

	RefreshParts()

	for(var/oredata in typesof(/datum/material) - /datum/material)
		var/datum/material/ore_datum = new oredata
		materials[ore_datum.id]=ore_datum

	// Define initial output.
	output=src
	for(var/direction in cardinal)
		var/O = locate(/obj/machinery/mineral/output, get_step(src, dir))
		if(O)
			output=O
			break

/obj/machinery/r_n_d/protolathe/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	var/total=0
	for(var/id in materials)
		var/datum/material/material=materials[id]
		total += material.stored
	return total

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		T += G.reagents.maximum_volume

	create_reagents(T) // Holder for the reagents used as materials.
	T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_storage = T * 75000

/obj/machinery/r_n_d/protolathe/proc/enqueue(var/key, var/datum/design/thing_to_build)
	production_queue.Add(new /datum/protolathe_queue_item(key,thing_to_build))
	//stopped=0

/obj/machinery/r_n_d/protolathe/proc/queue_pop()
	var/datum/protolathe_queue_item/I = production_queue[1]
	production_queue.Remove(I)
	return I

/obj/machinery/r_n_d/protolathe/process()
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

/obj/machinery/r_n_d/protolathe/proc/build_thing(var/datum/protolathe_queue_item/I)
	var/key=I.key
	var/datum/design/being_built=I.thing
	flick("protolathe_n",src)
	for(var/M in being_built.materials)
		if(!check_mat(being_built, M))
			src.visible_message("<font color='blue'>The [src.name] beeps, \"Not enough materials to complete prototype.\"</font>")
			stopped=1
			return 0
		if(copytext(M,1,2) == "$")
			var/matID=copytext(M,2)
			var/datum/material/material=materials[matID]
			material.stored = max(0, (material.stored-being_built.materials[M]))
			materials[matID]=material
		else
			reagents.remove_reagent(M, being_built.materials[M])

	if(being_built.build_path)
		var/obj/new_item = new being_built.build_path(src)
		if( new_item.type == /obj/item/weapon/storage/backpack/holding )
			new_item.investigate_log("built by [key]","singulo")
		new_item.reliability = being_built.reliability
		if(hacked)
			being_built.reliability = max((reliability / 2), 0)
		if(being_built.locked)
			var/obj/item/weapon/storage/lockbox/L = new/obj/item/weapon/storage/lockbox(output.loc)
			new_item.loc = L
			L.name += " ([new_item.name])"
		else
			new_item.loc = output.loc
		return 1
	return 0

/obj/machinery/r_n_d/protolathe/proc/check_mat(var/datum/design/being_built, var/M, var/num_requested=1)
	if(copytext(M,1,2) == "$")
		var/matID=copytext(M,2)
		var/datum/material/material=materials[matID]
		for(var/n=num_requested,n>=1,n--)
			if ((material.stored-(being_built.materials[M]*n)) >= 0)
				return n
	else
		for(var/n=num_requested,n>=1,n--)
			if (reagents.has_reagent(M, being_built.materials[M]))
				return n
	return 0


/obj/machinery/r_n_d/protolathe/update_icon()
	overlays.Cut()
	if(linked_console)
		overlays += "protolathe_link"

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
			for(var/id in materials)
				var/datum/material/material=materials[id]
				if(material.stored >= material.cc_per_sheet)
					var/obj/item/stack/sheet/S=new material.sheettype(src.loc)
					S.amount = round(material.stored / material.cc_per_sheet)
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
		var/found=0
		for(var/matID in materials)
			var/datum/material/M = materials[matID]
			if(M.sheettype==O.type)
				found=1
		if(!found)
			user << "\red The protolathe rejects \the [O]."
			return 1
		var/obj/item/stack/sheet/S = O
		if (TotalMaterials() + S.perunit > max_material_storage)
			user << "\red The protolathe's material bin is full. Please remove material before adding more."
			return 1

		var/obj/item/stack/sheet/stack = O
		var/amount = round(input("How many sheets do you want to add?") as num)//No decimals
		if(!O)
			return
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
		var/stacktype = stack.type
		stack.use(amount)
		if (do_after(user, 16))
			user << "\blue You add [amount] sheets to the [src.name]."
			icon_state = "protolathe"
			for(var/id in materials)
				var/datum/material/material=materials[id]
				if(stacktype == material.sheettype)
					material.stored += (amount * material.cc_per_sheet)
					materials[id]=material
		else
			new stacktype(src.loc, amount)
		busy = 0
		src.updateUsrDialog()
		return 1
	return 0