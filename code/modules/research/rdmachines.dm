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
	var/list/wires = list()
	var/hack_wire
	var/disable_wire
	var/shock_wire
	var/obj/machinery/computer/rdconsole/linked_console
	var/obj/output
	var/stopped = 0
	var/base_state = ""
	var/build_time = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY

	var/nano_file = ""

	var/list/datum/materials/materials = list()
	var/max_material_storage = 0
	var/list/allowed_materials[0]

	var/research_flags //see setup.dm for details of these

/obj/machinery/r_n_d/New()
	..()
	wires["Red"] = 0
	wires["Blue"] = 0
	wires["Green"] = 0
	wires["Yellow"] = 0
	wires["Black"] = 0
	wires["White"] = 0
	var/list/w = list("Red","Blue","Green","Yellow","Black","White")
	src.hack_wire = pick(w)
	w -= src.hack_wire
	src.shock_wire = pick(w)
	w -= src.shock_wire
	src.disable_wire = pick(w)
	w -= src.disable_wire

	base_state = icon_state
	icon_state_open = "[base_state]_t"

	for(var/oredata in typesof(/datum/material) - /datum/material)
		var/datum/material/ore_datum = new oredata
		materials[ore_datum.id]=ore_datum

	// Define initial output.
	if(research_flags &HASOUTPUT)
		output = src
		for(var/direction in cardinal)
			var/O = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(O)
				output=O
				break

/obj/machinery/r_n_d/update_icon()
	overlays.Cut()
	if(linked_console)
		overlays += "[base_state]_link"

/obj/machinery/r_n_d/blob_act()
	if (prob(50))
		del(src)

/obj/machinery/r_n_d/meteorhit()
	del(src)
	return

/obj/machinery/r_n_d/attack_hand(mob/user as mob)
	if (shocked)
		shock(user,50)
	if(panel_open)
		var/dat as text
		dat += "[src.name] Wires:<BR>"
		for(var/wire in src.wires)
			dat += text("[wire] Wire: <A href='?src=\ref[src];wire=[wire];cut=1'>[src.wires[wire] ? "Mend" : "Cut"]</A> <A href='?src=\ref[src];wire=[wire];pulse=1'>Pulse</A><BR>")

		dat += text("The red light is [src.disabled ? "off" : "on"].<BR>")
		dat += text("The green light is [src.shocked ? "off" : "on"].<BR>")
		dat += text("The blue light is [src.hacked ? "off" : "on"].<BR>")
		user << browse("<HTML><HEAD><TITLE>[src.name] Hacking</TITLE></HEAD><BODY>[dat]</BODY></HTML>","window=hack_win")
	else if (research_flags & NANOTOUCH)
		ui_interact(user)
	return


/obj/machinery/r_n_d/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["pulse"])
		var/temp_wire = href_list["wire"]
		if (!istype(usr.get_active_hand(), /obj/item/device/multitool))
			usr << "You need a multitool!"
		else
			if(src.wires[temp_wire])
				usr << "You can't pulse a cut wire."
			else
				if(src.hack_wire == href_list["wire"])
					src.hacked = !src.hacked
					spawn(100) src.hacked = !src.hacked
				if(src.disable_wire == href_list["wire"])
					src.disabled = !src.disabled
					src.shock(usr,50)
					spawn(100) src.disabled = !src.disabled
				if(src.shock_wire == href_list["wire"])
					src.shocked = !src.shocked
					src.shock(usr,50)
					spawn(100) src.shocked = !src.shocked
	if(href_list["cut"])
		if (!istype(usr.get_active_hand(), /obj/item/weapon/wirecutters))
			usr << "You need wirecutters!"
		else
			var/temp_wire = href_list["wire"]
			wires[temp_wire] = !wires[temp_wire]
			if(src.hack_wire == temp_wire)
				src.hacked = !src.hacked
			if(src.disable_wire == temp_wire)
				src.disabled = !src.disabled
				src.shock(usr,50)
			if(src.shock_wire == temp_wire)
				src.shocked = !src.shocked
				src.shock(usr,50)
	src.updateUsrDialog()

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
			overlays -= "[base_state]_link"
			return 1

/obj/machinery/r_n_d/crowbarDestroy(mob/user)
	if(..() == 1)
		for(var/matID in materials)
			var/datum/material/M = materials[matID]
			var/obj/item/stack/sheet/sheet = new M.sheettype(src.loc)
			var/available_num_sheets = round(M.stored/sheet.perunit)
			if(available_num_sheets>0)
				sheet.amount = available_num_sheets
				M.stored = max(0, (M.stored-sheet.amount * sheet.perunit))
				materials[M.id]=M
			else
				del sheet
		return 1
	return -1

/obj/machinery/r_n_d/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (shocked)
		shock(user,50)
	if (disabled)
		return 1
	if (busy)
		user << "\red The [src.name] is busy. Please wait for completion of previous operation."
		return 1
	if (stat)
		return 1
	if( ..() )
		return 1
	if (istype(O, /obj/item/device/multitool))
		if(!panel_open && research_flags &HASOUTPUT)
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
	if (!linked_console && !(istype(src, /obj/machinery/r_n_d/fabricator))) //fabricators get a free pass because they aren't tied to a console
		user << "\The [src.name] must be linked to an R&D console first!"
		return 0
	if(istype(O,/obj/item/stack/sheet) && research_flags &TAKESMATIN)
		var/accepted = 1
		if(allowed_materials && allowed_materials.len)
			if( !(O.type in allowed_materials) )
				accepted = 0
			else
				accepted = 1
		if(accepted)
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
			var/amount = round(input("How many sheets do you want to add? (0 - [stack.amount])") as num)//No decimals
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

			if(research_flags &HASMAT_OVER)
				update_icon()
				overlays += "[base_state]_[stack.name]"
				sleep(10)
				overlays -= "[base_state]_[stack.name]"

			icon_state = "[base_state]"
			busy = 1
			use_power(max(1000, (3750*amount/10)))
			var/stacktype = stack.type
			stack.use(amount)
			if (do_after(user, 16))
				user << "\blue You add [amount] sheets to the [src.name]."
				icon_state = "[base_state]"
				for(var/id in materials)
					var/datum/material/material=materials[id]
					if(stacktype == material.sheettype)
						material.stored += (amount * material.cc_per_sheet)
						materials[id]=material
			else
				new stacktype(src.loc, amount)
		else
			user <<"<span class='notice'>The [src.name] rejects the [O]!</span>"
		busy = 0
		src.updateUsrDialog()
		return 1
	return 0

/obj/machinery/r_n_d/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	var/total=0
	if(materials)
		for(var/id in materials.storage)
			total += materials.getAmount(id)
		return total
	else
		return null

/obj/machinery/r_n_d/proc/check_mat(var/datum/design/being_built, var/M, var/num_requested=1)
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

//give it an object or a type
//if it gets passed an object, it makes it into a type
//it then finds the design which has a buildpath of that type
//confirmed to work by Comic
/obj/machinery/r_n_d/proc/FindDesign(var/part as anything)
	if(!ispath(part))
		var/obj/thispart = part
		part = thispart.type
	for(var/thisdesign in typesof(/datum/design))
		var/datum/design/D = thisdesign
		if(initial(D.build_path) == part)
			return D
	return

//sum of the required tech of a design
/obj/machinery/r_n_d/proc/TechTotal(var/datum/design/part)
	var/total = 0
	for(var/tech in part.req_tech)
		total += part.req_tech[tech]
	return total

//sum of the required materials of a design
//do not confuse this with Total_Materials. That gets the machine's materials, this gets design materials
/obj/machinery/r_n_d/proc/MatTotal(var/datum/design/part)
	var/total = 0
	for(var/matID in part.materials)
		total += part.materials[matID]
	//log_admin("[total] for [part.name]")
	return total
