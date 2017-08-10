/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter. It also contains the /datum/research holder with all the known/possible technology paths and device designs.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
doesn't have toxins access.

When a R&D console is destroyed or even partially disassembled, you lose all research data on it. However, there are two ways around
this dire fate:
- The easiest way is to go to the settings menu and select "Sync Database with Network." That causes it to upload (but not download)
it's data to every other device in the game. Each console has a "disconnect from network" option that'll will cause data base sync
operations to skip that console. This is useful if you want to make a "public" R&D console or, for example, give the engineers
a circuit imprinter with certain designs on it and don't want it accidentally updating. The downside of this method is that you have
to have physical access to the other console to send data back. Note: An R&D console is on CentCom so if a random griffan happens to
cause a ton of data to be lost, an admin can go send it back.
- The second method is with Technology Disks and Design Disks. Each of these disks can hold technology or design datums in
their entirety. You can then take the disk to any R&D console and upload it's data to it. This method is a lot more secure (since it
won't update every console in existence) but it's more of a hassle to do. Also, the disks can be stolen.


*/

/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/weapon/circuitboard/computer/rdconsole
	var/datum/research/files							//Stores all the collected research data.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/r_n_d/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/r_n_d/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	var/screen = 1.0	//Which screen is currently showing.
	var/id = 0			//ID of the computer (for server restrictions).
	var/sync = 1		//If sync = 0, it doesn't show up on Server Control Console
	var/first_use = 1	//If first_use = 1, it will try to auto-connect with nearby devices

	req_access = list(ACCESS_TOX)	//DATA AND SETTING MANIPULATION REQUIRES SCIENTIST ACCESS.

	var/selected_category
	var/list/datum/design/matching_designs = list() //for the search function
	var/disk_slot_selected = 0


/proc/CallTechName(ID) //A simple helper proc to find the name of a tech with a given ID.
	if(GLOB.tech_list[ID])
		var/datum/tech/tech = GLOB.tech_list[ID]
		return tech.name
	return "ERROR: Report This"

/proc/CallMaterialName(ID)
	if (copytext(ID, 1, 2) == "$" && GLOB.materials_list[ID])
		var/datum/material/material = GLOB.materials_list[ID]
		return material.name

	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return "ERROR: Report This"

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/r_n_d/D in oview(3,src))
		if(D.linked_console != null || D.disabled || D.panel_open)
			continue
		if(istype(D, /obj/machinery/r_n_d/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/protolathe))
			if(linked_lathe == null)
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/circuit_imprinter))
			if(linked_imprinter == null)
				linked_imprinter = D
				D.linked_console = src
	first_use = 0

//Have it automatically push research to the centcom server so wild griffins can't fuck up R&D's work --NEO
/obj/machinery/computer/rdconsole/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in GLOB.machines)
		for(var/v in files.known_tech)
			var/datum/tech/T = files.known_tech[v]
			C.files.AddTech2Known(T)
		for(var/v in files.known_designs)
			var/datum/design/D = files.known_designs[v]
			C.files.AddDesign2Known(D)
		C.files.RefreshResearch()


/obj/machinery/computer/rdconsole/Initialize()
	. = ..()
	files = new /datum/research(src) //Setup the research data holder.
	matching_designs = list()
	if(!id)
		fix_noid_research_servers()

/*	Instead of calling this every tick, it is only being called when needed
/obj/machinery/computer/rdconsole/process()
	griefProtection()
*/

/obj/machinery/computer/rdconsole/attackby(obj/item/weapon/D, mob/user, params)

	//Loading a disk into it.
	if(istype(D, /obj/item/weapon/disk))
		if(t_disk || d_disk)
			to_chat(user, "A disk is already loaded into the machine.")
			return

		if(istype(D, /obj/item/weapon/disk/tech_disk))
			t_disk = D
		else if (istype(D, /obj/item/weapon/disk/design_disk))
			d_disk = D
		else
			to_chat(user, "<span class='danger'>Machine cannot accept disks in that format.</span>")
			return
		if(!user.drop_item())
			return
		D.loc = src
		to_chat(user, "<span class='notice'>You add the disk to the machine!</span>")
	else if(!(linked_destroy && linked_destroy.busy) && !(linked_lathe && linked_lathe.busy) && !(linked_imprinter && linked_imprinter.busy))
		. = ..()
	updateUsrDialog()


/obj/machinery/computer/rdconsole/on_deconstruction()
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	..()


/obj/machinery/computer/rdconsole/emag_act(mob/user)
	if(emagged)
		return
	playsound(src, "sparks", 75, 1)
	emagged = TRUE
	to_chat(user, "<span class='notice'>You disable the security protocols</span>")

/obj/machinery/computer/rdconsole/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)

	usr.set_machine(src)
	if(href_list["disk_slot"])
		disk_slot_selected = text2num(href_list["disk_slot"])

	if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		var/temp_screen = text2num(href_list["menu"])
		screen = temp_screen

	if(href_list["category"])
		selected_category = href_list["category"]

	else if(href_list["updt_tech"]) //Update the research holder with information from the technology disk.
		var/n = text2num(href_list["updt_tech"])
		screen = 0.0
		var/wait = 50
		if(!n)
			wait = 0
			for(var/D in t_disk.tech_stored)
				if(D)
					wait += 50
		spawn(wait)
			screen = 1.2
			if(t_disk)
				if(!n)
					for(var/tech in t_disk.tech_stored)
						files.AddTech2Known(tech)
				else
					files.AddTech2Known(t_disk.tech_stored[n])
				updateUsrDialog()
				griefProtection() //Update centcom too

	else if(href_list["clear_tech"]) //Erase data on the technology disk.
		if(t_disk)
			var/n = text2num(href_list["clear_tech"])
			if(!n)
				for(var/i in 1 to t_disk.max_tech_stored)
					t_disk.tech_stored[i] = null
			else
				t_disk.tech_stored[n] = null

	else if(href_list["eject_tech"]) //Eject the technology disk.
		if(t_disk)
			t_disk.loc = src.loc
			t_disk = null
		screen = 1.0

	else if(href_list["copy_tech"]) //Copy some technology data from the research holder to the disk.
		var/slot = text2num(href_list["copy_tech"])
		var/datum/tech/T = files.known_tech[href_list["copy_tech_ID"]]
		if(T)
			t_disk.tech_stored[slot] = T.copy()
		screen = 1.2

	else if(href_list["updt_design"]) //Updates the research holder with design data from the design disk.
		var/n = text2num(href_list["updt_design"])
		screen = 0.0
		var/wait = 50
		if(!n)
			wait = 0
			for(var/D in d_disk.blueprints)
				if(D)
					wait += 50
		spawn(wait)
			screen = 1.4
			if(d_disk)
				if(!n)
					for(var/D in d_disk.blueprints)
						if(D)
							files.AddDesign2Known(D)
				else
					files.AddDesign2Known(d_disk.blueprints[n])
				updateUsrDialog()
				griefProtection() //Update centcom too

	else if(href_list["clear_design"]) //Erases data on the design disk.
		if(d_disk)
			var/n = text2num(href_list["clear_design"])
			if(!n)
				for(var/i in 1 to d_disk.max_blueprints)
					d_disk.blueprints[i] = null
			else
				d_disk.blueprints[n] = null

	else if(href_list["eject_design"]) //Eject the design disk.
		if(d_disk)
			d_disk.loc = src.loc
			d_disk = null
		screen = 1.0

	else if(href_list["copy_design"]) //Copy design data from the research holder to the design disk.
		var/slot = text2num(href_list["copy_design"])
		var/datum/design/D = files.known_designs[href_list["copy_design_ID"]]
		if(D)
			var/autolathe_friendly = 1
			if(D.reagents_list.len)
				autolathe_friendly = 0
				D.category -= "Imported"
			else
				for(var/x in D.materials)
					if( !(x in list(MAT_METAL, MAT_GLASS)))
						autolathe_friendly = 0
						D.category -= "Imported"

			if(D.build_type & (AUTOLATHE|PROTOLATHE|CRAFTLATHE)) // Specifically excludes circuit imprinter and mechfab
				D.build_type = autolathe_friendly ? (D.build_type | AUTOLATHE) : D.build_type
				D.category |= "Imported"
			d_disk.blueprints[slot] = D
		screen = 1.4

	else if(href_list["eject_item"]) //Eject the item inside the destructive analyzer.
		if(linked_destroy)
			if(linked_destroy.busy)
				to_chat(usr, "<span class='danger'>The destructive analyzer is busy at the moment.</span>")

			else if(linked_destroy.loaded_item)
				linked_destroy.loaded_item.forceMove(linked_destroy.loc)
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				screen = 1.0

	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(!linked_destroy || linked_destroy.busy || !linked_destroy.loaded_item)
			updateUsrDialog()
			return

		var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
		var/cancontinue = FALSE
		for(var/T in temp_tech)
			if(files.IsTechHigher(T, temp_tech[T]))
				cancontinue = TRUE
				break
		if(!cancontinue)
			var/choice = input("This item does not raise tech levels. Proceed destroying loaded item anyway?") in list("Proceed", "Cancel")
			if(choice == "Cancel" || !linked_destroy || !linked_destroy.loaded_item) return
		linked_destroy.busy = TRUE
		screen = 0.1
		updateUsrDialog()
		flick("d_analyzer_process", linked_destroy)
		spawn(24)
			if(linked_destroy)
				linked_destroy.busy = FALSE
				if(!linked_destroy.loaded_item)
					screen = 1.0
					return

				for(var/T in temp_tech)
					var/datum/tech/KT = files.known_tech[T] //For stat logging of high levels
					if(files.IsTechHigher(T, temp_tech[T]) && KT.level >= 5) //For stat logging of high levels
						SSblackbox.add_details("high_research_level","[KT][KT.level + 1]") //+1 to show the level which we're about to get
					files.UpdateTech(T, temp_tech[T])

				if(linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
					for(var/material in linked_destroy.loaded_item.materials)
						linked_lathe.materials.insert_amount(min((linked_lathe.materials.max_amount - linked_lathe.materials.total_amount), (linked_destroy.loaded_item.materials[material]*(linked_destroy.decon_mod/10))), material)
					SSblackbox.add_details("item_deconstructed","[linked_destroy.loaded_item.type]")
				linked_destroy.loaded_item = null
				for(var/obj/I in linked_destroy.contents)
					for(var/mob/M in I.contents)
						M.death()
					if(istype(I, /obj/item/stack/sheet))//Only deconsturcts one sheet at a time instead of the entire stack
						var/obj/item/stack/sheet/S = I
						if(S.amount > 1)
							S.amount--
							linked_destroy.loaded_item = S
						else
							qdel(S)
							linked_destroy.icon_state = "d_analyzer"
					else
						if(!(I in linked_destroy.component_parts))
							qdel(I)
							linked_destroy.icon_state = "d_analyzer"
			screen = 1.0
			use_power(250)
			updateUsrDialog()

	else if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(src.allowed(usr))
			screen = text2num(href_list["lock"])
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["sync"]) //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
		screen = 0.0
		if(!sync)
			to_chat(usr, "<span class='danger'>You must connect to the network first!</span>")
		else
			griefProtection() //Putting this here because I dont trust the sync process
			spawn(30)
				if(src)
					for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
						var/server_processed = 0
						if(S.disabled)
							continue
						if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
							for(var/v in files.known_tech)
								var/datum/tech/T = files.known_tech[v]
								S.files.AddTech2Known(T)
							for(var/v in files.known_designs)
								var/datum/design/D = files.known_designs[v]
								S.files.AddDesign2Known(D)
							S.files.RefreshResearch()
							server_processed = 1
						if(((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom)) || S.hacked)
							for(var/v in S.files.known_tech)
								var/datum/tech/T = S.files.known_tech[v]
								files.AddTech2Known(T)
							for(var/v in S.files.known_designs)
								var/datum/design/D = S.files.known_designs[v]
								files.AddDesign2Known(D)
							files.RefreshResearch()
							server_processed = 1
						if(!istype(S, /obj/machinery/r_n_d/server/centcom) && server_processed)
							S.produce_heat(100)
					screen = 1.6
					updateUsrDialog()

	else if(href_list["togglesync"]) //Prevents the console from being synced by other consoles. Can still send data.
		sync = !sync

	else if(href_list["build"]) //Causes the Protolathe to build something.
		var/datum/design/being_built = files.known_designs[href_list["build"]]
		var/amount = text2num(href_list["amount"])

		if(being_built.make_reagents.len)
			return 0

		if(!linked_lathe || !being_built || !amount)
			updateUsrDialog()
			return

		if(linked_lathe.busy)
			to_chat(usr, "<span class='danger'>Protolathe is busy at the moment.</span>")
			return

		var/coeff = linked_lathe.efficiency_coeff
		var/power = 1000
		var/old_screen = screen

		amount = max(1, min(10, amount))
		for(var/M in being_built.materials)
			power += round(being_built.materials[M] * amount / 5)
		power = max(3000, power)
		screen = 0.3
		var/key = usr.key	//so we don't lose the info during the spawn delay
		if (!(being_built.build_type & PROTOLATHE))
			message_admins("Protolathe exploit attempted by [key_name(usr, usr.client)]!")
			updateUsrDialog()
			return

		var/g2g = 1
		var/enough_materials = 1
		linked_lathe.busy = TRUE
		flick("protolathe_n",linked_lathe)
		use_power(power)

		var/list/efficient_mats = list()
		for(var/MAT in being_built.materials)
			efficient_mats[MAT] = being_built.materials[MAT]*coeff

		if(!linked_lathe.materials.has_materials(efficient_mats, amount))
			linked_lathe.say("Not enough materials to complete prototype.")
			enough_materials = 0
			g2g = 0
		else
			for(var/R in being_built.reagents_list)
				if(!linked_lathe.reagents.has_reagent(R, being_built.reagents_list[R]*coeff))
					linked_lathe.say("Not enough reagents to complete prototype.")
					enough_materials = 0
					g2g = 0

		if(enough_materials)
			linked_lathe.materials.use_amount(efficient_mats, amount)
			for(var/R in being_built.reagents_list)
				linked_lathe.reagents.remove_reagent(R, being_built.reagents_list[R]*coeff)

		var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.

		coeff *= being_built.lathe_time_factor

		spawn(32*coeff*amount**0.8)
			if(linked_lathe)
				if(g2g) //And if we only fail the material requirements, we still spend time and power
					var/already_logged = 0
					for(var/i = 0, i<amount, i++)
						var/obj/item/new_item = new P(src)
						if( new_item.type == /obj/item/weapon/storage/backpack/holding )
							new_item.investigate_log("built by [key]", INVESTIGATE_SINGULO)
						if(!istype(new_item, /obj/item/stack/sheet) && !istype(new_item, /obj/item/weapon/ore/bluespace_crystal)) // To avoid materials dupe glitches
							new_item.materials = efficient_mats.Copy()
						new_item.loc = linked_lathe.loc
						if(!already_logged)
							SSblackbox.add_details("item_printed","[new_item.type]|[amount]")
							already_logged = 1
				screen = old_screen
				linked_lathe.busy = FALSE
			else
				say("Protolathe connection failed. Production halted.")
				screen = 1.0
			updateUsrDialog()

	else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
		var/datum/design/being_built = files.known_designs[href_list["imprint"]]

		if(!linked_imprinter || !being_built)
			updateUsrDialog()
			return

		if(linked_imprinter.busy)
			to_chat(usr, "<span class='danger'>Circuit Imprinter is busy at the moment.</span>")
			updateUsrDialog()
			return

		var/coeff = linked_imprinter.efficiency_coeff

		var/power = 1000
		var/old_screen = screen
		for(var/M in being_built.materials)
			power += round(being_built.materials[M] / 5)
		power = max(4000, power)
		screen = 0.4
		if (!(being_built.build_type & IMPRINTER))
			message_admins("Circuit imprinter exploit attempted by [key_name(usr, usr.client)]!")
			updateUsrDialog()
			return

		var/g2g = 1
		var/enough_materials = 1
		linked_imprinter.busy = TRUE
		flick("circuit_imprinter_ani", linked_imprinter)
		use_power(power)

		var/list/efficient_mats = list()
		for(var/MAT in being_built.materials)
			efficient_mats[MAT] = being_built.materials[MAT]/coeff

		if(!linked_imprinter.materials.has_materials(efficient_mats))
			linked_imprinter.say("Not enough materials to complete prototype.")
			enough_materials = 0
			g2g = 0
		else
			for(var/R in being_built.reagents_list)
				if(!linked_imprinter.reagents.has_reagent(R, being_built.reagents_list[R]/coeff))
					linked_imprinter.say("Not enough reagents to complete prototype.")
					enough_materials = 0
					g2g = 0

		if(enough_materials)
			linked_imprinter.materials.use_amount(efficient_mats)
			for(var/R in being_built.reagents_list)
				linked_imprinter.reagents.remove_reagent(R, being_built.reagents_list[R]/coeff)

		var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.
		spawn(16)
			if(linked_imprinter)
				if(g2g)
					var/obj/item/new_item = new P(src)
					new_item.loc = linked_imprinter.loc
					new_item.materials = efficient_mats.Copy()
					SSblackbox.add_details("circuit_printed","[new_item.type]")
				screen = old_screen
				linked_imprinter.busy = FALSE
			else
				say("Circuit Imprinter connection failed. Production halted.")
				screen = 1.0
			updateUsrDialog()

	//Protolathe Materials
	else if(href_list["disposeP"] && linked_lathe)  //Causes the protolathe to dispose of a single reagent (all of it)
		linked_lathe.reagents.del_reagent(href_list["disposeP"])

	else if(href_list["disposeallP"] && linked_lathe) //Causes the protolathe to dispose of all it's reagents.
		linked_lathe.reagents.clear_reagents()

	else if(href_list["ejectsheet"] && linked_lathe) //Causes the protolathe to eject a sheet of material
		linked_lathe.materials.retrieve_sheets(text2num(href_list["eject_amt"]), href_list["ejectsheet"])

	//Circuit Imprinter Materials
	else if(href_list["disposeI"] && linked_imprinter)  //Causes the circuit imprinter to dispose of a single reagent (all of it)
		linked_imprinter.reagents.del_reagent(href_list["disposeI"])

	else if(href_list["disposeallI"] && linked_imprinter) //Causes the circuit imprinter to dispose of all it's reagents.
		linked_imprinter.reagents.clear_reagents()

	else if(href_list["imprinter_ejectsheet"] && linked_imprinter) //Causes the imprinter to eject a sheet of material
		linked_imprinter.materials.retrieve_sheets(text2num(href_list["eject_amt"]), href_list["imprinter_ejectsheet"])


	else if(href_list["find_device"]) //The R&D console looks for devices nearby to link up with.
		screen = 0.0
		spawn(20)
			SyncRDevices()
			screen = 1.7
			updateUsrDialog()

	else if(href_list["disconnect"]) //The R&D console disconnects with a specific device.
		switch(href_list["disconnect"])
			if("destroy")
				linked_destroy.linked_console = null
				linked_destroy = null
			if("lathe")
				linked_lathe.linked_console = null
				linked_lathe = null
			if("imprinter")
				linked_imprinter.linked_console = null
				linked_imprinter = null

	else if(href_list["reset"]) //Reset the R&D console's database.
		griefProtection()
		var/choice = alert("R&D Console Database Reset", "Are you sure you want to reset the R&D console's database? Data lost cannot be recovered.", "Continue", "Cancel")
		if(choice == "Continue" && usr.canUseTopic(src))
			message_admins("[key_name_admin(usr)] reset \the [src.name]'s database")
			log_game("[key_name_admin(usr)] reset \the [src.name]'s database")
			screen = 0.0
			qdel(files)
			files = new /datum/research(src)
			spawn(20)
				screen = 1.6
				updateUsrDialog()

	else if(href_list["search"]) //Search for designs with name matching pattern
		var/compare

		matching_designs.Cut()

		if(href_list["type"] == "proto")
			compare = PROTOLATHE
			screen = 3.17
		else
			compare = IMPRINTER
			screen = 4.17

		for(var/v in files.known_designs)
			var/datum/design/D = files.known_designs[v]
			if(!(D.build_type & compare))
				continue
			if(findtext(D.name,href_list["to_search"]))
				matching_designs.Add(D)

	updateUsrDialog()
	return


/obj/machinery/computer/rdconsole/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/rdconsole/interact(mob/user)
	user.set_machine(src)

	if(first_use)
		SyncRDevices()

	var/dat = ""
	files.RefreshResearch()
	switch(screen) //A quick check to make sure you get the right screen when a device is disconnected.
		if(2 to 2.9)
			if(screen == 2.3)
				;
			else if(linked_destroy == null)
				screen = 2.0
			else if(linked_destroy.loaded_item == null)
				screen = 2.1
			else
				screen = 2.2
		if(3 to 3.9)
			if(linked_lathe == null)
				screen = 3.0
		if(4 to 4.9)
			if(linked_imprinter == null)
				screen = 4.0

	switch(screen)

		//////////////////////R&D CONSOLE SCREENS//////////////////
		if(0.0) dat += "<div class='statusDisplay'>Updating Database....</div>"

		if(0.1) dat += "<div class='statusDisplay'>Processing and Updating Database...</div>"

		if(0.2)
			dat += "<div class='statusDisplay'>SYSTEM LOCKED</div>"
			dat += "<A href='?src=\ref[src];lock=1.6'>Unlock</A>"

		if(0.3)
			dat += "<div class='statusDisplay'>Constructing Prototype. Please Wait...</div>"

		if(0.4)
			dat += "<div class='statusDisplay'>Imprinting Circuit. Please Wait...</div>"

		if(1.0) //Main Menu
			dat += "<div class='statusDisplay'>"
			dat += "<h3>Main Menu:</h3><BR>"
			dat += "<A href='?src=\ref[src];menu=1.1'>Current Research Levels</A><BR>"
			if(t_disk)
				dat += "<A href='?src=\ref[src];menu=1.2'>Disk Operations</A><BR>"
			else if(d_disk)
				dat += "<A href='?src=\ref[src];menu=1.4'>Disk Operations</A><BR>"
			else
				dat += "<span class='linkOff'>Disk Operations</span><BR>"
			if(linked_destroy)
				dat += "<A href='?src=\ref[src];menu=2.2'>Destructive Analyzer Menu</A><BR>"
			else
				dat += "<span class='linkOff'>Destructive Analyzer Menu</span><BR>"
			if(linked_lathe)
				dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Construction Menu</A><BR>"
			else
				dat += "<span class='linkOff'>Protolathe Construction Menu</span><BR>"
			if(linked_imprinter)
				dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Construction Menu</A><BR>"
			else
				dat += "<span class='linkOff'>Circuit Construction Menu</span><BR>"
			dat += "<A href='?src=\ref[src];menu=1.6'>Settings</A>"
			dat += "</div>"

		if(1.1) //Research viewer
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<h3>Current Research Levels:</h3><BR><div class='statusDisplay'>"
			for(var/v in files.known_tech)
				var/datum/tech/T = files.known_tech[v]
				if(T.level <= 0)
					continue
				dat += "[T.name]<BR>"
				dat +=  "* Level: [T.level]<BR>"
				dat +=  "* Summary: [T.desc]<HR>"
			dat += "</div>"

		if(1.2) //Technology Disk Menu
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "Disk Operations: <A href='?src=\ref[src];clear_tech=0'>Clear Disk</A><A href='?src=\ref[src];updt_tech=0'>Upload All</A><A href='?src=\ref[src];eject_tech=1'>Eject Disk</A>"
			for(var/i in 1 to t_disk.max_tech_stored)
				dat += "<div class='statusDisplay'>"
				if(t_disk.tech_stored[i])
					var/datum/tech/tech = t_disk.tech_stored[i]
					dat += "Name: [tech.name]<BR>"
					dat += "Level: [tech.level]<BR>"
					dat += "Description: [tech.desc]<BR>"
					dat += "Operations: <A href='?src=\ref[src];updt_tech=[i]'>Upload to Database</A><A href='?src=\ref[src];clear_tech=[i]'>Clear Slot</A>"
				else
					dat += "Empty Slot<BR>Operations: <A href='?src=\ref[src];menu=1.3;disk_slot=[i]'>Load Tech to Slot</A>"
				dat += "</div>"
		if(1.3) //Technology Disk submenu
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=1.2'>Return to Disk Operations</A><div class='statusDisplay'>"
			dat += "<h3>Load Technology to Disk:</h3><BR>"
			for(var/v in files.known_tech)
				var/datum/tech/T = files.known_tech[v]
				if(T.level <= 0)
					continue
				dat += "[T.name]"
				dat += "<A href='?src=\ref[src];copy_tech=[disk_slot_selected];copy_tech_ID=[T.id]'>Copy to Disk</A><BR>"
			dat += "</div>"

		if(1.4) //Design Disk menu.
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "Disk Operations: <A href='?src=\ref[src];clear_design=0'>Clear Disk</A><A href='?src=\ref[src];updt_design=0'>Upload All</A><A href='?src=\ref[src];eject_design=1'>Eject Disk</A>"
			for(var/i in 1 to d_disk.max_blueprints)
				dat += "<div class='statusDisplay'>"
				if(d_disk.blueprints[i])
					var/datum/design/D = d_disk.blueprints[i]
					dat += "Name: [D.name]<BR>"
					if(D.build_type)
						dat += "Lathe Types:<BR>"
						if(D.build_type & IMPRINTER) dat += "Circuit Imprinter<BR>"
						if(D.build_type & PROTOLATHE) dat += "Protolathe<BR>"
						if(D.build_type & AUTOLATHE) dat += "Autolathe<BR>"
						if(D.build_type & MECHFAB) dat += "Exosuit Fabricator<BR>"
						if(D.build_type & BIOGENERATOR) dat += "Biogenerator<BR>"
						if(D.build_type & LIMBGROWER) dat += "Limbgrower<BR>"
						if(D.build_type & SMELTER) dat += "Smelter<BR>"
					dat += "Required Materials:<BR>"
					var/all_mats = D.materials + D.reagents_list
					for(var/M in all_mats)
						dat += "* [CallMaterialName(M)] x [all_mats[M]]<BR>"
					dat += "Operations: <A href='?src=\ref[src];updt_design=[i]'>Upload to Database</A> <A href='?src=\ref[src];clear_design=[i]'>Clear Slot</A>"
				else
					dat += "Empty Slot<BR>Operations: <A href='?src=\ref[src];menu=1.5;disk_slot=[i]'>Load Design to Slot</A>"
				dat += "</div>"
		if(1.5) //Design disk submenu
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=1.4'>Return to Disk Operations</A><div class='statusDisplay'>"
			dat += "<h3>Load Design to Disk:</h3><BR>"
			for(var/v in files.known_designs)
				var/datum/design/D = files.known_designs[v]
				dat += "[D.name] "
				dat += "<A href='?src=\ref[src];copy_design=[disk_slot_selected];copy_design_ID=[D.id]'>Copy to Disk</A><BR>"
			dat += "</div>"

		if(1.6) //R&D console settings
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><div class='statusDisplay'>"
			dat += "<h3>R&D Console Setting:</h3><BR>"
			if(sync)
				dat += "<A href='?src=\ref[src];sync=1'>Sync Database with Network</A><BR>"
				dat += "<span class='linkOn'>Connect to Research Network</span><BR>"
				dat += "<A href='?src=\ref[src];togglesync=1'>Disconnect from Research Network</A><BR>"
			else
				dat += "<span class='linkOff'>Sync Database with Network</span><BR>"
				dat += "<A href='?src=\ref[src];togglesync=1'>Connect to Research Network</A><BR>"
				dat += "<span class='linkOn'>Disconnect from Research Network</span><BR>"
			dat += "<A href='?src=\ref[src];menu=1.7'>Device Linkage Menu</A><BR>"
			dat += "<A href='?src=\ref[src];lock=0.2'>Lock Console</A><BR>"
			dat += "<A href='?src=\ref[src];reset=1'>Reset R&D Database</A></div>"

		if(1.7) //R&D device linkage
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=1.6'>Settings Menu</A><div class='statusDisplay'>"
			dat += "<h3>R&D Console Device Linkage Menu:</h3><BR>"
			dat += "<A href='?src=\ref[src];find_device=1'>Re-sync with Nearby Devices</A><BR><BR>"
			dat += "<h3>Linked Devices:</h3><BR>"
			if(linked_destroy)
				dat += "* Destructive Analyzer <A href='?src=\ref[src];disconnect=destroy'>Disconnect</A><BR>"
			else
				dat += "* No Destructive Analyzer Linked<BR>"
			if(linked_lathe)
				dat += "* Protolathe <A href='?src=\ref[src];disconnect=lathe'>Disconnect</A><BR>"
			else
				dat += "* No Protolathe Linked<BR>"
			if(linked_imprinter)
				dat += "* Circuit Imprinter <A href='?src=\ref[src];disconnect=imprinter'>Disconnect</A><BR>"
			else
				dat += "* No Circuit Imprinter Linked<BR>"
			dat += "</div>"

		////////////////////DESTRUCTIVE ANALYZER SCREENS////////////////////////////
		if(2.0)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<div class='statusDisplay'>NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE</div>"

		if(2.1)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<div class='statusDisplay'>No Item Loaded. Standing-by...</div>"

		if(2.2)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><div class='statusDisplay'>"
			dat += "<h3>Deconstruction Menu</h3><BR>"
			dat += "Name: [linked_destroy.loaded_item.name]<BR>"
			dat += "Origin Tech:<BR>"
			var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
			for(var/T in temp_tech)
				dat += "* [CallTechName(T)] [temp_tech[T]]"
				var/datum/tech/F = files.known_tech[T]
				if(F)
					dat += " (Current: [F.level])"

				dat += "<BR>"
			dat += "</div>Options: "
			dat += "<A href='?src=\ref[src];deconstruct=1'>Deconstruct Item</A>"
			dat += "<A href='?src=\ref[src];eject_item=1'>Eject Item</A>"
		if(2.3)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<div class='statusDisplay'>Item is neither reliable enough or broken enough to learn from.</div>"

		/////////////////////PROTOLATHE SCREENS/////////////////////////
		if(3.0)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "<div class='statusDisplay'>NO PROTOLATHE LINKED TO CONSOLE</div>"

		if(3.1)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> "
			dat += "<A href='?src=\ref[src];menu=3.2'>Material Storage</A>"
			dat += "<A href='?src=\ref[src];menu=3.3'>Chemical Storage</A><div class='statusDisplay'>"
			dat += "<h3>Protolathe Menu:</h3><BR>"
			dat += "<B>Material Amount:</B> [linked_lathe.materials.total_amount] / [linked_lathe.materials.max_amount]<BR>"
			dat += "<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] / [linked_lathe.reagents.maximum_volume]<BR>"

			dat += "<form name='search' action='?src=\ref[src]'>\
			<input type='hidden' name='src' value='\ref[src]'>\
			<input type='hidden' name='search' value='to_search'>\
			<input type='hidden' name='type' value='proto'>\
			<input type='text' name='to_search'>\
			<input type='submit' value='Search'>\
			</form><HR>"

			dat += list_categories(linked_lathe.categories, 3.15)

		//Grouping designs by categories, to improve readability
		if(3.15)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Menu</A>"
			dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3><BR>"
			dat += "<B>Material Amount:</B> [linked_lathe.materials.total_amount] / [linked_lathe.materials.max_amount]<BR>"
			dat += "<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] / [linked_lathe.reagents.maximum_volume]<HR>"

			var/coeff = linked_lathe.efficiency_coeff
			for(var/v in files.known_designs)
				var/datum/design/D = files.known_designs[v]
				if(!(selected_category in D.category)|| !(D.build_type & PROTOLATHE))
					continue
				var/temp_material
				var/c = 50
				var/t

				var/all_materials = D.materials + D.reagents_list
				for(var/M in all_materials)
					t = linked_lathe.check_mat(D, M)
					temp_material += " | "
					if (t < 1)
						temp_material += "<span class='bad'>[all_materials[M]*coeff] [CallMaterialName(M)]</span>"
					else
						temp_material += " [all_materials[M]*coeff] [CallMaterialName(M)]"
					c = min(c,t)

				if (c >= 1)
					dat += "<A href='?src=\ref[src];build=[D.id];amount=1'>[D.name]</A>"
					if(c >= 5)
						dat += "<A href='?src=\ref[src];build=[D.id];amount=5'>x5</A>"
					if(c >= 10)
						dat += "<A href='?src=\ref[src];build=[D.id];amount=10'>x10</A>"
					dat += "[temp_material]"
				else
					dat += "<span class='linkOff'>[D.name]</span>[temp_material]"
				dat += "<BR>"
			dat += "</div>"

		if(3.17) //Display search result
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Menu</A>"
			dat += "<div class='statusDisplay'><h3>Search results:</h3><BR>"
			dat += "<B>Material Amount:</B> [linked_lathe.materials.total_amount] / [linked_lathe.materials.max_amount]<BR>"
			dat += "<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] / [linked_lathe.reagents.maximum_volume]<HR>"

			var/coeff = linked_lathe.efficiency_coeff
			for(var/datum/design/D in matching_designs)
				var/temp_material
				var/c = 50
				var/t
				var/all_materials = D.materials + D.reagents_list
				for(var/M in all_materials)
					t = linked_lathe.check_mat(D, M)
					temp_material += " | "
					if (t < 1)
						temp_material += "<span class='bad'>[all_materials[M]*coeff] [CallMaterialName(M)]</span>"
					else
						temp_material += " [all_materials[M]*coeff] [CallMaterialName(M)]"
					c = min(c,t)

				if (c >= 1)
					dat += "<A href='?src=\ref[src];build=[D.id];amount=1'>[D.name]</A>"
					if(c >= 5)
						dat += "<A href='?src=\ref[src];build=[D.id];amount=5'>x5</A>"
					if(c >= 10)
						dat += "<A href='?src=\ref[src];build=[D.id];amount=10'>x10</A>"
					dat += "[temp_material]"
				else
					dat += "<span class='linkOff'>[D.name]</span>[temp_material]"
				dat += "<BR>"
			dat += "</div>"

		if(3.2) //Protolathe Material Storage Sub-menu
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Menu</A><div class='statusDisplay'>"
			dat += "<h3>Material Storage:</h3><BR><HR>"
			if(!linked_lathe)
				dat += "ERROR: Protolathe connection failed."
			else
				for(var/mat_id in linked_lathe.materials.materials)
					var/datum/material/M = linked_lathe.materials.materials[mat_id]
					dat += "* [M.amount] of [M.name]: "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT) dat += "<A href='?src=\ref[src];ejectsheet=[M.id];eject_amt=1'>Eject</A> "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT*5) dat += "<A href='?src=\ref[src];ejectsheet=[M.id];eject_amt=5'>5x</A> "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT) dat += "<A href='?src=\ref[src];ejectsheet=[M.id];eject_amt=50'>All</A>"
					dat += "<BR>"
			dat += "</div>"

		if(3.3)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Menu</A>"
			dat += "<A href='?src=\ref[src];disposeallP=1'>Disposal All Chemicals in Storage</A><div class='statusDisplay'>"
			dat += "<h3>Chemical Storage:</h3><BR><HR>"
			for(var/datum/reagent/R in linked_lathe.reagents.reagent_list)
				dat += "[R.name]: [R.volume]"
				dat += "<A href='?src=\ref[src];disposeP=[R.id]'>Purge</A><BR>"

		///////////////////CIRCUIT IMPRINTER SCREENS////////////////////
		if(4.0)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "<div class='statusDisplay'>NO CIRCUIT IMPRINTER LINKED TO CONSOLE</div>"

		if(4.1)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=4.3'>Material Storage</A>"
			dat += "<A href='?src=\ref[src];menu=4.2'>Chemical Storage</A><div class='statusDisplay'>"
			dat += "<h3>Circuit Imprinter Menu:</h3><BR>"
			dat += "Material Amount: [linked_imprinter.materials.total_amount]<BR>"
			dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

			dat += "<form name='search' action='?src=\ref[src]'>\
			<input type='hidden' name='src' value='\ref[src]'>\
			<input type='hidden' name='search' value='to_search'>\
			<input type='hidden' name='type' value='imprint'>\
			<input type='text' name='to_search'>\
			<input type='submit' value='Search'>\
			</form><HR>"

			dat += list_categories(linked_imprinter.categories, 4.15)

		if(4.15)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Imprinter Menu</A>"
			dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3><BR>"
			dat += "Material Amount: [linked_imprinter.materials.total_amount]<BR>"
			dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

			var/coeff = linked_imprinter.efficiency_coeff
			for(var/v in files.known_designs)
				var/datum/design/D = files.known_designs[v]
				if(!(selected_category in D.category) || !(D.build_type & IMPRINTER))
					continue
				var/temp_materials
				var/check_materials = 1

				var/all_materials = D.materials + D.reagents_list

				for(var/M in all_materials)
					temp_materials += " | "
					if (!linked_imprinter.check_mat(D, M))
						check_materials = 0
						temp_materials += " <span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
					else
						temp_materials += " [all_materials[M]/coeff] [CallMaterialName(M)]"
				if (check_materials)
					dat += "<A href='?src=\ref[src];imprint=[D.id]'>[D.name]</A>[temp_materials]<BR>"
				else
					dat += "<span class='linkOff'>[D.name]</span>[temp_materials]<BR>"
			dat += "</div>"

		if(4.17)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Imprinter Menu</A>"
			dat += "<div class='statusDisplay'><h3>Search results:</h3><BR>"
			dat += "Material Amount: [linked_imprinter.materials.total_amount]<BR>"
			dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

			var/coeff = linked_imprinter.efficiency_coeff
			for(var/datum/design/D in matching_designs)
				var/temp_materials
				var/check_materials = 1
				var/all_materials = D.materials + D.reagents_list
				for(var/M in all_materials)
					temp_materials += " | "
					if (!linked_imprinter.check_mat(D, M))
						check_materials = 0
						temp_materials += " <span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
					else
						temp_materials += " [all_materials[M]/coeff] [CallMaterialName(M)]"
				if (check_materials)
					dat += "<A href='?src=\ref[src];imprint=[D.id]'>[D.name]</A>[temp_materials]<BR>"
				else
					dat += "<span class='linkOff'>[D.name]</span>[temp_materials]<BR>"
			dat += "</div>"

		if(4.2) //Circuit Imprinter Material Storage Sub-menu
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Imprinter Menu</A>"
			dat += "<A href='?src=\ref[src];disposeallI=1'>Disposal All Chemicals in Storage</A><div class='statusDisplay'>"
			dat += "<h3>Chemical Storage:</h3><BR><HR>"
			for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
				dat += "[R.name]: [R.volume]"
				dat += "<A href='?src=\ref[src];disposeI=[R.id]'>Purge</A><BR>"

		if(4.3)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Imprinter Menu</A><div class='statusDisplay'>"
			dat += "<h3>Material Storage:</h3><BR><HR>"
			if(!linked_imprinter)
				dat += "ERROR: Protolathe connection failed."
			else
				for(var/mat_id in linked_imprinter.materials.materials)
					var/datum/material/M = linked_imprinter.materials.materials[mat_id]
					dat += "* [M.amount] of [M.name]: "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=[M.id];eject_amt=1'>Eject</A> "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT*5) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=[M.id];eject_amt=5'>5x</A> "
					if(M.amount >= MINERAL_MATERIAL_AMOUNT) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=[M.id];eject_amt=50'>All</A>"
					dat += "<BR>"
			dat += "</div>"

	var/datum/browser/popup = new(user, "rndconsole", name, 460, 550)
	popup.set_content(dat)
	popup.open()
	return

//helper proc, which return a table containing categories
/obj/machinery/computer/rdconsole/proc/list_categories(list/categories, menu_num as num)
	if(!categories)
		return

	var/line_length = 1
	var/dat = "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			dat += "</tr><tr>"
			line_length = 1

		dat += "<td><A href='?src=\ref[src];category=[C];menu=[menu_num]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	return dat

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	desc = "A console used to interface with R&D tools."
	id = 2
	req_access = null
	req_access_txt = "29"

/obj/machinery/computer/rdconsole/robotics/Initialize()
	. = ..()
	if(circuit)
		circuit.name = "R&D Console - Robotics (Computer Board)"
		circuit.build_path = /obj/machinery/computer/rdconsole/robotics

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	desc = "A console used to interface with R&D tools."
	id = 1

/obj/machinery/computer/rdconsole/experiment
	name = "E.X.P.E.R.I-MENTOR R&D Console"
	desc = "A console used to interface with R&D tools."
	id = 3
