<<<<<<< HEAD
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.


/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = 1
	anchored = 1
	use_power = 1
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/obj/machinery/computer/rdconsole/linked_console
	var/obj/item/loaded_item = null //the item loaded inside the machine (currently only used by experimentor and destructive analyzer)

/obj/machinery/r_n_d/New()
	..()
	wires = new /datum/wires/r_n_d(src)

/obj/machinery/r_n_d/Destroy()
	qdel(wires)
	wires = null
	return ..()

/obj/machinery/r_n_d/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/r_n_d/attack_hand(mob/user)
	if(shocked)
		if(shock(user,50))
			return
	if(panel_open)
		wires.interact(user)



/obj/machinery/r_n_d/attackby(obj/item/O, mob/user, params)
	if (shocked)
		if(shock(user,50))
			return 1
	if (default_deconstruction_screwdriver(user, "[initial(icon_state)]_t", initial(icon_state), O))
		if(linked_console)
			disconnect_console()
		return
	if(exchange_parts(user, O))
		return
	if(default_deconstruction_crowbar(O))
		return
	if((flags & OPENCONTAINER) && O.is_open_container())
		return 0 //inserting reagents into the machine
	if(Insert_Item(O, user))
		return 1
	else
		return ..()

//to disconnect the machine from the r&d console it's linked to
/obj/machinery/r_n_d/proc/disconnect_console()
	linked_console = null

//proc used to handle inserting items or reagents into r_n_d machines
/obj/machinery/r_n_d/proc/Insert_Item(obj/item/I, mob/user)
	return

//whether the machine can have an item inserted in its current state.
/obj/machinery/r_n_d/proc/is_insertion_ready(mob/user)
	if(panel_open)
		user << "<span class='warning'>You can't load the [src.name] while it's opened!</span>"
		return
	if (disabled)
		return
	if (!linked_console) // Try to auto-connect to new RnD consoles nearby.
		for(var/obj/machinery/computer/rdconsole/console in oview(3, src))
			if(console.first_use)
				console.SyncRDevices()

		if(!linked_console)
			user << "<span class='warning'>The [name] must be linked to an R&D console first!</span>"
			return
	if (busy)
		user << "<span class='warning'>The [src.name] is busy right now.</span>"
		return
	if(stat & BROKEN)
		user << "<span class='warning'>The [src.name] is broken.</span>"
		return
	if(stat & NOPOWER)
		user << "<span class='warning'>The [src.name] has no power.</span>"
		return
	if(loaded_item)
		user << "<span class='warning'>The [src] is already loaded.</span>"
		return
	return 1


//we eject the loaded item when deconstructing the machine
/obj/machinery/r_n_d/deconstruction()
	if(loaded_item)
		loaded_item.loc = loc
	..()
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33
var/global/list/rnd_machines = list()
//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.
/obj/machinery/r_n_d
	name			= "R&D Device"
	icon			= 'icons/obj/machines/research.dmi'
	density			= 1
	anchored		= 1
	use_power		= 1
	var/busy		= 0
	var/hacked		= 0
	var/disabled	= 0
	var/shocked		= 0
	var/obj/machinery/computer/rdconsole/linked_console
	var/output_dir	= 0 // Direction used to output to (for things like fabs), set to 0 for loc.
	var/stopped		= 0
	var/base_state	= ""
	var/build_time	= 0

	machine_flags	= SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/nano_file	= ""

	var/max_material_storage = 0
	var/list/allowed_materials[0] //list of material IDs we take, if we whitelist

	var/research_flags //see setup.dm for details of these

	var/datum/wires/rnd/wires = null

/obj/machinery/r_n_d/New()
	rnd_machines |= src
	..()

	wires = new(src)

	base_state = icon_state
	icon_state_open = "[base_state]_t"

	if(research_flags & TAKESMATIN && !materials)
		materials = getFromPool(/datum/materials, src)

	if(ticker) initialize()

// Define initial output.
/obj/machinery/r_n_d/initialize()
	..()
	if(research_flags &HASOUTPUT)
		for(var/direction in cardinal)
			if(locate(/obj/machinery/mineral/output, get_step(get_turf(src), direction)))
				output_dir = direction
				break

/obj/machinery/r_n_d/Destroy()
	if(linked_console)
		linked_console.linked_machines -= src
		linked_console = null

	rnd_machines -= src
	wires = null
	..()

/obj/machinery/r_n_d/process()
	..()
	if(shocked>0)
		shocked--

/obj/machinery/r_n_d/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSMACHINE))
		return 1
	return ..()

/obj/machinery/r_n_d/update_icon()
	overlays.len = 0
	if(linked_console)
		overlays += image(icon = icon, icon_state = "[base_state]_link")

/obj/machinery/r_n_d/blob_act()
	if (prob(50))
		qdel(src)

/obj/machinery/r_n_d/attack_hand(mob/user as mob)
	if (shocked)
		shock(user,50)
	if(panel_open)
		wires.Interact(user)
	else if (research_flags & NANOTOUCH)
		ui_interact(user)
	return


/obj/machinery/r_n_d/Topic(href, href_list)
	if(..())
		return
	if(href_list["close"])
		if(usr.machine == src) usr.unset_machine()
		return 1
	usr.set_machine(src)
	src.add_fingerprint(usr)
	src.updateUsrDialog()

//Called when the hack wire is toggled in some way
/obj/machinery/r_n_d/proc/update_hacked()
	return

/obj/machinery/r_n_d/togglePanelOpen(var/item/toggleitem, mob/user)
	if(..())
		if (panel_open && linked_console)
			linked_console.linked_machines -= src
			switch(src.type)
				if(/obj/machinery/r_n_d/fabricator/protolathe)
					linked_console.linked_lathe = null
				if(/obj/machinery/r_n_d/destructive_analyzer)
					linked_console.linked_destroy = null
				if(/obj/machinery/r_n_d/fabricator/circuit_imprinter)
					linked_console.linked_imprinter = null
			linked_console = null
			overlays -= image(icon = icon, icon_state = "[base_state]_link")
		return 1

/obj/machinery/r_n_d/crowbarDestroy(mob/user)
	if(..() == 1)
		if (materials)
			for(var/matID in materials.storage)
				var/datum/material/M = materials.getMaterial(matID)
				var/obj/item/stack/sheet/sheet = new M.sheettype(src.loc)
				if(sheet)
					var/available_num_sheets = round(materials.storage[matID]/sheet.perunit)
					if(available_num_sheets>0)
						sheet.amount = available_num_sheets
						materials.removeAmount(matID, sheet.amount * sheet.perunit)
					else
						qdel(sheet)
		return 1
	return -1

/obj/machinery/r_n_d/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (shocked)
		shock(user,50)
	if (busy)
		to_chat(user, "<span class='warning'>The [src.name] is busy. Please wait for completion of previous operation.</span>")
		return 1
	if( ..() )
		return 1
	if(panel_open)
		wires.Interact(user)
		return 1
	if (stat)
		return 1
	if (disabled)
		return 1
	if (istype(O, /obj/item/device/multitool))
		if(!panel_open && research_flags &HASOUTPUT)
			var/result = input("Set your location as output?") in list("Yes","No","Machine Location")
			switch(result)
				if("Yes")
					if(!Adjacent(user))
						to_chat(user, "<span class='warning'>Cannot set this as the output location; You're not adjacent to it!</span>")
						return 1

					output_dir = get_dir(src, user)
					to_chat(user, "<span class='notice'>Output set.</span>")
				if("Machine Location")
					output_dir = 0
					to_chat(user, "<span class='notice'>Output set.</span>")
			return 1
		return
	if (!linked_console && !(istype(src, /obj/machinery/r_n_d/fabricator))) //fabricators get a free pass because they aren't tied to a console
		to_chat(user, "\The [src] must be linked to an R&D console first!")
		return 1
	if(istype(O,/obj/item/stack/sheet) && research_flags &TAKESMATIN)
		busy = 1

		var/found = "" //the matID we're compatible with
		for(var/matID in materials.storage)
			var/datum/material/M = materials.getMaterial(matID)
			if(M.sheettype==O.type)
				found = matID
		if(!found)
			if(O.materials && research_flags &FAB_RECYCLER)
				busy = 0
				return 0 //let the autolathe try to do it's thing
			to_chat(user, "<span class='warning'>\The [src] rejects \the [O.name].</span>")
			busy = 0
			return 1
		if(allowed_materials && allowed_materials.len)
			if(!(found in allowed_materials))
				if(O.materials && research_flags &FAB_RECYCLER)
					busy = 0
					return 0 //let the autolathe try to do it's thing
				to_chat(user, "<span class='warning'>\The [src] rejects \the [O.name].</span>")
				busy = 0
				return 1

		var/obj/item/stack/sheet/S = O
		if (TotalMaterials() + S.perunit > max_material_storage)
			to_chat(user, "<span class='warning'>\The [src]'s material bin is full. Please remove material before adding more.</span>")
			busy = 0
			return 1

		var/obj/item/stack/sheet/stack = O
		var/amount = round(input("How many sheets do you want to add? (0 - [stack.amount])") as num)//No decimals
		if(!O || !O.loc || O.loc != user)
			busy = 0
			return
		if(amount < 0)//No negative numbers
			amount = 0
		if(amount == 0)
			busy = 0
			return 1	//1 So the autolathe doesn't recycle the stack.
		if(amount > stack.amount)
			amount = stack.amount
		if(max_material_storage - TotalMaterials() < (amount*stack.perunit))//Can't overfill
			amount = min(stack.amount, round((max_material_storage-TotalMaterials())/stack.perunit))

		if(research_flags & HASMAT_OVER)
			update_icon()
			overlays |= image(icon = icon, icon_state = "[base_state]_[stack.name]")
			spawn(10)
				overlays -= image(icon = icon, icon_state = "[base_state]_[stack.name]")

		icon_state = "[base_state]"
		use_power(max(1000, (3750*amount/10)))
		stack.use(amount)
		to_chat(user, "<span class='notice'>You add [amount] sheet[amount > 1 ? "s":""] to the [src.].</span>")
		icon_state = "[base_state]"

		var/datum/material/material = materials.getMaterial(found)
		materials.addAmount(found, amount * material.cc_per_sheet)
		busy = 0
		return 1
	src.updateUsrDialog()
	return 0

/obj/machinery/r_n_d/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	if(materials)
		return materials.getVolume()
	return 0

// Returns the atom to output to.
// Yes this can potentially return null, however that shouldn't be an issue for the code that uses it.
/obj/machinery/r_n_d/proc/get_output()
	if(!output_dir)
		return get_turf(loc)

	. = get_step(get_turf(src), output_dir)
	if(!.)
		return loc // Map edge I guess.
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
