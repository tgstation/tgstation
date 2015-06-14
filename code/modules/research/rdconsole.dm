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
to have physical access to the other console to send data back. Note: An R&D console is on Centcom so if a random griffan happens to
cause a ton of data to be lost, an admin can go send it back.
- The second method is with Technology Disks and Design Disks. Each of these disks can hold a single technology or design datum in
it's entirety. You can then take the disk to any R&D console and upload it's data to it. This method is a lot more secure (since it
won't update every console in existence) but it's more of a hassle to do. Also, the disks can be stolen.


*/

/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_state = "rdcomp"
	circuit = /obj/item/weapon/circuitboard/rdconsole
	var/datum/research/files							//Stores all the collected research data.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/r_n_d/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/r_n_d/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	var/screen = 1.0	//Which screen is currently showing.
	var/id = 0			//ID of the computer (for server restrictions).
	var/sync = 1		//If sync = 0, it doesn't show up on Server Control Console

	req_access = list(access_tox)	//Data and setting manipulation requires scientist access.

	var/selected_category
	var/list/datum/design/matching_designs = list() //for the search function


/obj/machinery/computer/rdconsole/proc/CallTechName(var/ID) //A simple helper proc to find the name of a tech with a given ID.
	var/datum/tech/check_tech
	var/return_name = null
	for(var/T in typesof(/datum/tech) - /datum/tech)
		check_tech = null
		check_tech = new T()
		if(check_tech.id == ID)
			return_name = check_tech.name
			del(check_tech)
			check_tech = null
			break

	return return_name

/obj/machinery/computer/rdconsole/proc/CallMaterialName(var/ID)
	var/datum/reagent/temp_reagent
	var/return_name = null
	if (copytext(ID, 1, 2) == "$")
		return_name = copytext(ID, 2)
		switch(return_name)
			if("metal")
				return_name = "Metal"
			if("glass")
				return_name = "Glass"
			if("gold")
				return_name = "Gold"
			if("silver")
				return_name = "Silver"
			if("plasma")
				return_name = "Solid Plasma"
			if("uranium")
				return_name = "Uranium"
			if("diamond")
				return_name = "Diamond"
			if("clown")
				return_name = "Bananium"
	else
		for(var/R in typesof(/datum/reagent) - /datum/reagent)
			temp_reagent = null
			temp_reagent = new R()
			if(temp_reagent.id == ID)
				return_name = temp_reagent.name
				del(temp_reagent)
				temp_reagent = null
				break
	return return_name

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
	return

//Have it automatically push research to the centcom server so wild griffins can't fuck up R&D's work --NEO
/obj/machinery/computer/rdconsole/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in world)
		for(var/datum/tech/T in files.known_tech)
			C.files.AddTech2Known(T)
		for(var/datum/design/D in files.known_designs)
			C.files.AddDesign2Known(D)
		C.files.RefreshResearch()


/obj/machinery/computer/rdconsole/New()
	..()
	files = new /datum/research(src) //Setup the research data holder.
	matching_designs = list()
	if(!id)
		for(var/obj/machinery/r_n_d/server/centcom/S in world)
			S.initialize()
			break

/obj/machinery/computer/rdconsole/initialize()
	SyncRDevices()

/*	Instead of calling this every tick, it is only being called when needed
/obj/machinery/computer/rdconsole/process()
	griefProtection()
*/

/obj/machinery/computer/rdconsole/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob, params)

	//Loading a disk into it.
	if(istype(D, /obj/item/weapon/disk))
		if(t_disk || d_disk)
			user << "A disk is already loaded into the machine."
			return

		if(istype(D, /obj/item/weapon/disk/tech_disk)) t_disk = D
		else if (istype(D, /obj/item/weapon/disk/design_disk)) d_disk = D
		else
			user << "<span class='danger'>Machine cannot accept disks in that format.</span>"
			return
		user.drop_item()
		D.loc = src
		user << "<span class='notice'>You add the disk to the machine!</span>"
	else
		..()
	src.updateUsrDialog()
	return

/obj/machinery/computer/rdconsole/emag_act(mob/user as mob)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		user << "<span class='notice'>You disable the security protocols</span>"

/obj/machinery/computer/rdconsole/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)

	usr.set_machine(src)
	if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		var/temp_screen = text2num(href_list["menu"])
		screen = temp_screen

	if(href_list["category"])
		selected_category = href_list["category"]

	else if(href_list["updt_tech"]) //Update the research holder with information from the technology disk.
		screen = 0.0
		spawn(50)
			screen = 1.2
			files.AddTech2Known(t_disk.stored)
			updateUsrDialog()
			griefProtection() //Update centcom too

	else if(href_list["clear_tech"]) //Erase data on the technology disk.
		if(t_disk)
			t_disk.stored = null

	else if(href_list["eject_tech"]) //Eject the technology disk.
		if(t_disk)
			t_disk.loc = src.loc
			t_disk = null
		screen = 1.0

	else if(href_list["copy_tech"]) //Copy some technology data from the research holder to the disk.
		for(var/datum/tech/T in files.known_tech)
			if(href_list["copy_tech_ID"] == T.id)
				t_disk.stored = T
				break
		screen = 1.2

	else if(href_list["updt_design"]) //Updates the research holder with design data from the design disk.
		screen = 0.0
		spawn(50)
			screen = 1.4
			files.AddDesign2Known(d_disk.blueprint)
			updateUsrDialog()
			griefProtection() //Update centcom too

	else if(href_list["clear_design"]) //Erases data on the design disk.
		if(d_disk)
			d_disk.blueprint = null

	else if(href_list["eject_design"]) //Eject the design disk.
		if(d_disk)
			d_disk.loc = src.loc
			d_disk = null
		screen = 1.0

	else if(href_list["copy_design"]) //Copy design data from the research holder to the design disk.
		for(var/datum/design/D in files.known_designs)
			if(href_list["copy_design_ID"] == D.id)
				d_disk.blueprint = D
				break
		screen = 1.4

	else if(href_list["eject_item"]) //Eject the item inside the destructive analyzer.
		if(linked_destroy)
			if(linked_destroy.busy)
				usr << "<span class='danger'>The destructive analyzer is busy at the moment.</span>"

			else if(linked_destroy.loaded_item)
				linked_destroy.loaded_item.loc = linked_destroy.loc
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				screen = 2.1

	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(linked_destroy)
			if(linked_destroy.busy)
				usr << "<span class='danger'>The destructive analyzer is busy at the moment.</span>"
			else
				var/choice = input("Proceeding will destroy loaded item.") in list("Proceed", "Cancel")
				if(choice == "Cancel" || !linked_destroy) return
				linked_destroy.busy = 1
				screen = 0.1
				updateUsrDialog()
				flick("d_analyzer_process", linked_destroy)
				spawn(24)
					if(linked_destroy)
						linked_destroy.busy = 0
						if(!linked_destroy.hacked)
							if(!linked_destroy.loaded_item)
								usr <<"<span class='danger'>The destructive analyzer appears to be empty.</span>"
								screen = 1.0
								return
							if((linked_destroy.loaded_item.reliability >= 99 - (linked_destroy.decon_mod * 3)) || linked_destroy.loaded_item.crit_fail)
								var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
								for(var/T in temp_tech)
									if(prob(linked_destroy.loaded_item.reliability))               //If deconstructed item is not reliable enough its just being wasted, else it is pocessed
										files.UpdateTech(T, temp_tech[T])                          //Check if deconstructed item has research levels higher/same/one less than current ones
								files.UpdateDesigns(linked_destroy.loaded_item, temp_tech, src)    //If if such reseach type found all the known designs are checked for having this research type in them
								screen = 1.0                                                       //If design have it it gains some reliability
							else                                                                   //Same design always gain quality
								screen = 2.3                                                       //Crit fail gives the same design a lot of reliability, like really a lot
							if(linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
								linked_lathe.m_amount += min((linked_lathe.max_material_storage - linked_lathe.TotalMaterials()), (linked_destroy.loaded_item.m_amt*(linked_destroy.decon_mod/10)))
								linked_lathe.g_amount += min((linked_lathe.max_material_storage - linked_lathe.TotalMaterials()), (linked_destroy.loaded_item.g_amt*(linked_destroy.decon_mod/10)))
								feedback_add_details("item_deconstructed","[linked_destroy.loaded_item.name]")
							linked_destroy.loaded_item = null
						else
							screen = 1.0
						for(var/obj/I in linked_destroy.contents)
							for(var/mob/M in I.contents)
								M.death()
							if(istype(I,/obj/item/stack/sheet))//Only deconsturcts one sheet at a time instead of the entire stack
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
						use_power(250)
						updateUsrDialog()

	else if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(src.allowed(usr))
			screen = text2num(href_list["lock"])
		else
			usr << "Unauthorized Access."

	else if(href_list["sync"]) //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
		screen = 0.0
		if(!sync)
			usr << "<span class='danger'>You must connect to the network first!</span>"
		else
			griefProtection() //Putting this here because I dont trust the sync process
			spawn(30)
				if(src)
					for(var/obj/machinery/r_n_d/server/S in world)
						var/server_processed = 0
						if(S.disabled)
							continue
						if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
							for(var/datum/tech/T in files.known_tech)
								S.files.AddTech2Known(T)
							for(var/datum/design/D in files.known_designs)
								S.files.AddDesign2Known(D)
							S.files.RefreshResearch()
							server_processed = 1
						if(((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom)) || S.hacked)
							for(var/datum/tech/T in S.files.known_tech)
								files.AddTech2Known(T)
							for(var/datum/design/D in S.files.known_designs)
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
		var/coeff
		if(linked_lathe)
			coeff = linked_lathe.efficiency_coeff
		else
			coeff = 1
		var/g2g = 1
		if(linked_lathe)
			var/datum/design/being_built = null
			for(var/datum/design/D in files.known_designs)
				if(D.id == href_list["build"])
					being_built = D
					break
			if(being_built)
				var/power = 2000
				var/amount=text2num(href_list["amount"])
				var/old_screen = screen
				amount = max(1, min(10, amount))
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] * amount / 5)
				power = max(2000, power)
				screen = 0.3
				if(linked_lathe.busy)
					g2g = 0
				var/key = usr.key	//so we don't lose the info during the spawn delay
				if (!(being_built.build_type & PROTOLATHE))
					g2g = 0
					message_admins("Protolathe exploit attempted by [key_name(usr, usr.client)]!")



				if (g2g) //If input is incorrect, nothing happens
					var/enough_materials = 1
					linked_lathe.busy = 1
					flick("protolathe_n",linked_lathe)
					use_power(power)

					for(var/M in being_built.materials)
						if(linked_lathe.check_mat(being_built, M) < amount)
							src.visible_message("<span class='notice'>The [src.name] beeps, \"Not enough materials to complete prototype.\"</span>")
							enough_materials = 0
							g2g = 0
							break
					if(enough_materials)
						for(var/M in being_built.materials)
							switch(M)
								if("$metal")
									linked_lathe.m_amount = max(0, (linked_lathe.m_amount-(being_built.materials[M]/coeff * amount)))
								if("$glass")
									linked_lathe.g_amount = max(0, (linked_lathe.g_amount-(being_built.materials[M]/coeff * amount)))
								if("$gold")
									linked_lathe.gold_amount = max(0, (linked_lathe.gold_amount-(being_built.materials[M]/coeff * amount)))
								if("$silver")
									linked_lathe.silver_amount = max(0, (linked_lathe.silver_amount-(being_built.materials[M]/coeff * amount)))
								if("$plasma")
									linked_lathe.plasma_amount = max(0, (linked_lathe.plasma_amount-(being_built.materials[M]/coeff * amount)))
								if("$uranium")
									linked_lathe.uranium_amount = max(0, (linked_lathe.uranium_amount-(being_built.materials[M]/coeff * amount)))
								if("$diamond")
									linked_lathe.diamond_amount = max(0, (linked_lathe.diamond_amount-(being_built.materials[M]/coeff * amount)))
								if("$bananium")
									linked_lathe.clown_amount = max(0, (linked_lathe.clown_amount-(being_built.materials[M]/coeff * amount)))
								else
									linked_lathe.reagents.remove_reagent(M, being_built.materials[M]/coeff * amount)

					var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.
					var/R = being_built.reliability
					spawn(32*amount/coeff)
						if(g2g) //And if we only fail the material requirements, we still spend time and power
							var/already_logged = 0
							for(var/i = 0, i<amount, i++)
								var/obj/item/new_item = new P(src)
								if( new_item.type == /obj/item/weapon/storage/backpack/holding )
									new_item.investigate_log("built by [key]","singulo")
								new_item.reliability = R
								new_item.m_amt /= coeff
								new_item.g_amt /= coeff
								if(linked_lathe.hacked)
									R = max((new_item.reliability/2), 0)
								new_item.loc = linked_lathe.loc
								if(!already_logged)
									feedback_add_details("item_printed","[new_item.name]|[amount]")
									already_logged = 1
						linked_lathe.busy = 0
						screen = old_screen
						updateUsrDialog()

	else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
		var/coeff = linked_imprinter.efficiency_coeff
		var/g2g = 1
		if(linked_imprinter)
			var/datum/design/being_built = null
			for(var/datum/design/D in files.known_designs)
				if(D.id == href_list["imprint"])
					being_built = D
					break
			if(being_built)
				var/power = 2000
				var/old_screen = screen
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(2000, power)
				screen = 0.4
				if (linked_imprinter.busy)
					g2g = 0
				if (!(being_built.build_type & IMPRINTER))
					g2g = 0
					message_admins("Circuit imprinter exploit attempted by [key_name(usr, usr.client)]!")

				if (g2g) //Again, if input is wrong, do nothing
					linked_imprinter.busy = 1
					flick("circuit_imprinter_ani",linked_imprinter)
					use_power(power)

					for(var/M in being_built.materials)
						if(!linked_imprinter.check_mat(being_built, M))
							src.visible_message("<span class='notice'>The [src.name] beeps, \"Not enough materials to complete prototype.\"</span>")
							g2g = 0
							break
						switch(M)
							if("$glass")
								linked_imprinter.g_amount = max(0, (linked_imprinter.g_amount-being_built.materials[M]/coeff))
							if("$gold")
								linked_imprinter.gold_amount = max(0, (linked_imprinter.gold_amount-being_built.materials[M]/coeff))
							if("$diamond")
								linked_imprinter.diamond_amount = max(0, (linked_imprinter.diamond_amount-being_built.materials[M]/coeff))
							else
								linked_imprinter.reagents.remove_reagent(M, being_built.materials[M]/coeff)

					var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.
					var/R = being_built.reliability
					spawn(16)
						if(g2g)
							var/obj/item/new_item = new P(src)
							new_item.reliability = R
							new_item.loc = linked_imprinter.loc
							feedback_add_details("circuit_printed","[new_item.name]")
						linked_imprinter.busy = 0
						screen = old_screen
						updateUsrDialog()

	else if(href_list["disposeI"] && linked_imprinter)  //Causes the circuit imprinter to dispose of a single reagent (all of it)
		linked_imprinter.reagents.del_reagent(href_list["disposeI"])

	else if(href_list["disposeallI"] && linked_imprinter) //Causes the circuit imprinter to dispose of all it's reagents.
		linked_imprinter.reagents.clear_reagents()

	else if(href_list["disposeP"] && linked_lathe)  //Causes the protolathe to dispose of a single reagent (all of it)
		linked_lathe.reagents.del_reagent(href_list["disposeP"])

	else if(href_list["disposeallP"] && linked_lathe) //Causes the protolathe to dispose of all it's reagents.
		linked_lathe.reagents.clear_reagents()

	else if(href_list["lathe_ejectsheet"] && linked_lathe) //Causes the protolathe to eject a sheet of material
		var/desired_num_sheets = text2num(href_list["lathe_ejectsheet_amt"])
		var/res_amount, type
		switch(href_list["lathe_ejectsheet"])
			if("metal")
				type = /obj/item/stack/sheet/metal
				res_amount = "m_amount"
			if("glass")
				type = /obj/item/stack/sheet/glass
				res_amount = "g_amount"
			if("gold")
				type = /obj/item/stack/sheet/mineral/gold
				res_amount = "gold_amount"
			if("silver")
				type = /obj/item/stack/sheet/mineral/silver
				res_amount = "silver_amount"
			if("plasma")
				type = /obj/item/stack/sheet/mineral/plasma
				res_amount = "plasma_amount"
			if("uranium")
				type = /obj/item/stack/sheet/mineral/uranium
				res_amount = "uranium_amount"
			if("diamond")
				type = /obj/item/stack/sheet/mineral/diamond
				res_amount = "diamond_amount"
			if("clown")
				type = /obj/item/stack/sheet/mineral/bananium
				res_amount = "clown_amount"
		if(ispath(type) && hasvar(linked_lathe, res_amount))
			var/obj/item/stack/sheet/sheet = new type(linked_lathe.loc)
			var/available_num_sheets = round(linked_lathe.vars[res_amount]/sheet.perunit)
			if(available_num_sheets>0)
				sheet.amount = min(available_num_sheets, desired_num_sheets)
				linked_lathe.vars[res_amount] = max(0, (linked_lathe.vars[res_amount]-sheet.amount * sheet.perunit))
			else
				qdel(sheet)
	else if(href_list["imprinter_ejectsheet"] && linked_imprinter) //Causes the protolathe to eject a sheet of material
		var/desired_num_sheets = text2num(href_list["imprinter_ejectsheet_amt"])
		var/res_amount, type
		switch(href_list["imprinter_ejectsheet"])
			if("glass")
				type = /obj/item/stack/sheet/glass
				res_amount = "g_amount"
			if("gold")
				type = /obj/item/stack/sheet/mineral/gold
				res_amount = "gold_amount"
			if("diamond")
				type = /obj/item/stack/sheet/mineral/diamond
				res_amount = "diamond_amount"
		if(ispath(type) && hasvar(linked_imprinter, res_amount))
			var/obj/item/stack/sheet/sheet = new type(linked_imprinter.loc)
			var/available_num_sheets = round(linked_imprinter.vars[res_amount]/sheet.perunit)
			if(available_num_sheets>0)
				sheet.amount = min(available_num_sheets, desired_num_sheets)
				linked_imprinter.vars[res_amount] = max(0, (linked_imprinter.vars[res_amount]-sheet.amount * sheet.perunit))
			else
				qdel(sheet)

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
		if(choice == "Continue")
			screen = 0.0
			del(files)
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

		for(var/datum/design/D in files.known_designs)
			if(!(D.build_type & compare))
				continue
			if(findtext(D.name,href_list["to_search"]))
				matching_designs.Add(D)

	updateUsrDialog()
	return


/obj/machinery/computer/rdconsole/attack_hand(mob/user as mob)
	if(..())
		return
	interact(user)

/obj/machinery/computer/rdconsole/interact(mob/user)

	user.set_machine(src)
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
			for(var/datum/tech/T in files.known_tech)
				dat += "[T.name]<BR>"
				dat +=  "* Level: [T.level]<BR>"
				dat +=  "* Summary: [T.desc]<HR>"
			dat += "</div>"

		if(1.2) //Technology Disk Menu

			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "<div class='statusDisplay'>Technology Data Disk Contents:<BR><BR>"
			if(t_disk.stored == null)
				dat += "The disk has no data stored on it.</div>"
				dat += "Operations: "
				dat += "<A href='?src=\ref[src];menu=1.3'>Load Tech to Disk</A>"
			else
				dat += "Name: [t_disk.stored.name]<BR>"
				dat += "Level: [t_disk.stored.level]<BR>"
				dat += "Description: [t_disk.stored.desc]</div>"
				dat += "Operations: "
				dat += "<A href='?src=\ref[src];updt_tech=1'>Upload to Database</A>"
				dat += "<A href='?src=\ref[src];clear_tech=1'>Clear Disk</A>"
			dat += "<A href='?src=\ref[src];eject_tech=1'>Eject Disk</A>"

		if(1.3) //Technology Disk submenu
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=1.2'>Return to Disk Operations</A><div class='statusDisplay'>"
			dat += "<h3>Load Technology to Disk:</h3><BR>"
			for(var/datum/tech/T in files.known_tech)
				dat += "[T.name] "
				dat += "<A href='?src=\ref[src];copy_tech=1;copy_tech_ID=[T.id]'>Copy to Disk</A><BR>"
			dat += "</div>"

		if(1.4) //Design Disk menu.
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><div class='statusDisplay'>"
			if(d_disk.blueprint == null)
				dat += "The disk has no data stored on it.</div>"
				dat += "Operations: "
				dat += "<A href='?src=\ref[src];menu=1.5'>Load Design to Disk</A>"
			else
				dat += "Name: [d_disk.blueprint.name]<BR>"
				dat += "Level: [Clamp((d_disk.blueprint.reliability + rand(-15,15)), 0, 100)]<BR>"
				switch(d_disk.blueprint.build_type)
					if(IMPRINTER) dat += "Lathe Type: Circuit Imprinter<BR>"
					if(PROTOLATHE) dat += "Lathe Type: Proto-lathe<BR>"
					if(AUTOLATHE) dat += "Lathe Type: Auto-lathe<BR>"
				dat += "Required Materials:<BR>"
				for(var/M in d_disk.blueprint.materials)
					if(copytext(M, 1, 2) == "$") dat += "* [copytext(M, 2)] x [d_disk.blueprint.materials[M]]<BR>"
					else dat += "* [M] x [d_disk.blueprint.materials[M]]<BR>"
				dat += "</div>Operations: "
				dat += "<A href='?src=\ref[src];updt_design=1'>Upload to Database</A>"
				dat += "<A href='?src=\ref[src];clear_design=1'>Clear Disk</A>"
			dat += "<A href='?src=\ref[src];eject_design=1'>Eject Disk</A>"

		if(1.5) //Technology disk submenu
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=1.4'>Return to Disk Operations</A><div class='statusDisplay'>"
			dat += "<h3>Load Design to Disk:</h3><BR>"
			for(var/datum/design/D in files.known_designs)
				dat += "[D.name] "
				dat += "<A href='?src=\ref[src];copy_design=1;copy_design_ID=[D.id]'>Copy to Disk</A><BR>"
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
			dat += "Reliability: [linked_destroy.loaded_item.reliability]<BR>"
			dat += "Origin Tech:<BR>"
			var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
			for(var/T in temp_tech)
				dat += "* [CallTechName(T)] [temp_tech[T]]<BR>"
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
			dat += "<B>Material Amount:</B> [linked_lathe.TotalMaterials()] / [linked_lathe.max_material_storage]<BR>"
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
			dat += "<B>Material Amount:</B> [linked_lathe.TotalMaterials()] / [linked_lathe.max_material_storage]<BR>"
			dat += "<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] / [linked_lathe.reagents.maximum_volume]<HR>"

			var/coeff = linked_lathe.efficiency_coeff
			for(var/datum/design/D in files.known_designs)
				if(!(selected_category in D.category)|| !(D.build_type & PROTOLATHE))
					continue
				var/temp_material
				var/c = 50
				var/t
				for(var/M in D.materials)
					t = linked_lathe.check_mat(D, M)
					temp_material += " | "
					if (t < 1)
						temp_material += "<span class='bad'>[D.materials[M]/coeff] [CallMaterialName(M)]</span>"
					else
						temp_material += " [D.materials[M]/coeff] [CallMaterialName(M)]"
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
			dat += "<B>Material Amount:</B> [linked_lathe.TotalMaterials()] / [linked_lathe.max_material_storage]<BR>"
			dat += "<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] / [linked_lathe.reagents.maximum_volume]<HR>"

			var/coeff = linked_lathe.efficiency_coeff
			for(var/datum/design/D in matching_designs)
				var/temp_material
				var/c = 50
				var/t
				for(var/M in D.materials)
					t = linked_lathe.check_mat(D, M)
					temp_material += " | "
					if (t < 1)
						temp_material += "<span class='bad'>[D.materials[M]/coeff] [CallMaterialName(M)]</span>"
					else
						temp_material += " [D.materials[M]/coeff] [CallMaterialName(M)]"
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
			//Metal
			dat += "* [linked_lathe.m_amount] of Metal: "
			if(linked_lathe.m_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=metal;lathe_ejectsheet_amt=1'>Eject</A> "
			if(linked_lathe.m_amount >= 18750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=metal;lathe_ejectsheet_amt=5'>5x</A> "
			if(linked_lathe.m_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=metal;lathe_ejectsheet_amt=50'>All</A>"
			dat += "<BR>"
			//Glass
			dat += "* [linked_lathe.g_amount] of Glass: "
			if(linked_lathe.g_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=glass;lathe_ejectsheet_amt=1'>Eject</A> "
			if(linked_lathe.g_amount >= 18750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=glass;lathe_ejectsheet_amt=5'>5x</A> "
			if(linked_lathe.g_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=glass;lathe_ejectsheet_amt=50'>All</A>"
			dat += "<BR>"
			//Gold
			dat += "* [linked_lathe.gold_amount] of Gold: "
			if(linked_lathe.gold_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=gold;lathe_ejectsheet_amt=1'>Eject</A> "
			if(linked_lathe.gold_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=gold;lathe_ejectsheet_amt=5'>5x</A> "
			if(linked_lathe.gold_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=gold;lathe_ejectsheet_amt=50'>All</A>"
			dat += "<BR>"
			//Silver
			dat += "* [linked_lathe.silver_amount] of Silver: "
			if(linked_lathe.silver_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=silver;lathe_ejectsheet_amt=1'>Eject</A> "
			if(linked_lathe.silver_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=silver;lathe_ejectsheet_amt=5'>5x</A> "
			if(linked_lathe.silver_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=silver;lathe_ejectsheet_amt=50'>All</A>"
			dat += "<BR>"
			//Plasma
			dat += "* [linked_lathe.plasma_amount] of Solid Plasma: "
			if(linked_lathe.plasma_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=plasma;lathe_ejectsheet_amt=1'>Eject</A> "
			if(linked_lathe.plasma_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=plasma;lathe_ejectsheet_amt=5'>5x</A> "
			if(linked_lathe.plasma_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=plasmalathe_ejectsheet_amt=50'>All</A>"
			dat += "<BR>"
			//Uranium
			dat += "* [linked_lathe.uranium_amount] of Uranium: "
			if(linked_lathe.uranium_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=uranium;lathe_ejectsheet_amt=1'>Eject</A> "
			if(linked_lathe.uranium_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=uranium;lathe_ejectsheet_amt=5'>5x</A> "
			if(linked_lathe.uranium_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=uranium;lathe_ejectsheet_amt=50'>All</A>"
			dat += "<BR>"
			//Diamond
			dat += "* [linked_lathe.diamond_amount] of Diamond: "
			if(linked_lathe.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=diamond;lathe_ejectsheet_amt=1'>Eject</A> "
			if(linked_lathe.diamond_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=diamond;lathe_ejectsheet_amt=5'>5x</A> "
			if(linked_lathe.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=diamond;lathe_ejectsheet_amt=50'>All</A>"
			dat += "<BR>"
			//Bananium
			dat += "* [linked_lathe.clown_amount] of Bananium: "
			if(linked_lathe.clown_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=clown;lathe_ejectsheet_amt=1'>Eject</A> "
			if(linked_lathe.clown_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=clown;lathe_ejectsheet_amt=5'>5x</A> "
			if(linked_lathe.clown_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=clown;lathe_ejectsheet_amt=50'>All</A>"
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
			dat += "Material Amount: [linked_imprinter.TotalMaterials()]<BR>"
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
			dat += "Material Amount: [linked_imprinter.TotalMaterials()]<BR>"
			dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

			var/coeff = linked_imprinter.efficiency_coeff
			for(var/datum/design/D in files.known_designs)
				if(!(selected_category in D.category) || !(D.build_type & IMPRINTER))
					continue
				var/temp_materials
				var/check_materials = 1
				for(var/M in D.materials)
					temp_materials += " | "
					if (!linked_imprinter.check_mat(D, M))
						check_materials = 0
						temp_materials += " <span class='bad'>[D.materials[M]/coeff] [CallMaterialName(M)]</span>"
					else
						temp_materials += " [D.materials[M]/coeff] [CallMaterialName(M)]"
				if (check_materials)
					dat += "<A href='?src=\ref[src];imprint=[D.id]'>[D.name]</A>[temp_materials]<BR>"
				else
					dat += "<span class='linkOff'>[D.name]</span>[temp_materials]<BR>"
			dat += "</div>"

		if(4.17)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Imprinter Menu</A>"
			dat += "<div class='statusDisplay'><h3>Search results:</h3><BR>"
			dat += "Material Amount: [linked_imprinter.TotalMaterials()]<BR>"
			dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

			var/coeff = linked_imprinter.efficiency_coeff
			for(var/datum/design/D in matching_designs)
				var/temp_materials
				var/check_materials = 1
				for(var/M in D.materials)
					temp_materials += " | "
					if (!linked_imprinter.check_mat(D, M))
						check_materials = 0
						temp_materials += " <span class='bad'>[D.materials[M]/coeff] [CallMaterialName(M)]</span>"
					else
						temp_materials += " [D.materials[M]/coeff] [CallMaterialName(M)]"
				if (check_materials)
					dat += "<A href='?src=\ref[src];imprint=[D.id]'>[D.name]</A>[temp_materials]<BR>"
				else
					dat += "<span class='linkOff'>[D.name]</span>[temp_materials]<BR>"
			dat += "</div>"

		if(4.2)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=4.1'>Imprinter Menu</A>"
			dat += "<A href='?src=\ref[src];disposeallI=1'>Disposal All Chemicals in Storage</A><div class='statusDisplay'>"
			dat += "<h3>Chemical Storage:</h3><BR><HR>"
			for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
				dat += "[R.name]: [R.volume]"
				dat += "<A href='?src=\ref[src];disposeI=[R.id]'>Purge</A><BR>"

		if(4.3)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Imprinter Menu</A><div class='statusDisplay'>"
			dat += "<h3>Material Storage:</h3><BR><HR>"
			//Glass
			dat += "* [linked_imprinter.g_amount]  glass: "
			if(linked_imprinter.g_amount >= 3750) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=glass;imprinter_ejectsheet_amt=1'>Eject</A> "
			if(linked_imprinter.g_amount >= 18750) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=glass;imprinter_ejectsheet_amt=5'>5x</A> "
			if(linked_imprinter.g_amount >= 3750) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=glass;imprinter_ejectsheet_amt=50'>All</A>"
			dat += "<BR>"
			//Gold
			dat += "* [linked_imprinter.gold_amount] gold: "
			if(linked_imprinter.gold_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=gold;imprinter_ejectsheet_amt=1'>Eject</A> "
			if(linked_imprinter.gold_amount >= 10000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=gold;imprinter_ejectsheet_amt=5'>5x</A> "
			if(linked_imprinter.gold_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=gold;imprinter_ejectsheet_amt=50'>All</A>"
			dat += "<BR>"
			//Diamond
			dat += "* [linked_imprinter.diamond_amount] diamond: "
			if(linked_imprinter.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=diamond;imprinter_ejectsheet_amt=1'>Eject</A> "
			if(linked_imprinter.diamond_amount >= 10000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=diamond;imprinter_ejectsheet_amt=5'>5x</A> "
			if(linked_imprinter.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=diamond;imprinter_ejectsheet_amt=50'>All</A>"
			dat += "</div>"

	var/datum/browser/popup = new(user, "rndconsole", name, 460, 550)
	popup.set_content(dat)
	popup.open()
	return

//helper proc, which return a table containing categories
/obj/machinery/computer/rdconsole/proc/list_categories(var/list/categories, var/menu_num as num)
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

/obj/machinery/computer/rdconsole/robotics/New()
	..()
	if(circuit)
		circuit.name = "circuit board (RD Console - Robotics)"
		circuit.build_path = /obj/machinery/computer/rdconsole/robotics

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	desc = "A console used to interface with R&D tools."
	id = 1

/obj/machinery/computer/rdconsole/experiment
	name = "E.X.P.E.R.I-MENTOR R&D Console"
	desc = "A console used to interface with R&D tools."
	id = 1
