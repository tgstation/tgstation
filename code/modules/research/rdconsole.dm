//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

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
- The second method is with Technology Disks and Design Disks. Each of these disks can hold a single technology or design datum in
it's entirety. You can then take the disk to any R&D console and upload it's data to it. This method is a lot more secure (since it
won't update every console in existence) but it's more of a hassle to do. Also, the disks can be stolen.


*/
#define RESEARCH_MAX_Q_LEN 30
/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_state = "rdcomp"
	circuit = "/obj/item/weapon/circuitboard/rdconsole"
	var/datum/research/files							//Stores all the collected research data.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/r_n_d/fabricator/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/r_n_d/fabricator/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	var/list/obj/machinery/linked_machines = list()
	var/list/research_machines = list(
		/obj/machinery/r_n_d/fabricator/protolathe,
		/obj/machinery/r_n_d/destructive_analyzer,
		/obj/machinery/r_n_d/fabricator/circuit_imprinter,
		/obj/machinery/r_n_d/fabricator/mech
		)

	var/screen = 1.0	//Which screen is currently showing.
	var/id = 0			//ID of the computer (for server restrictions).
	var/sync = 1		//If sync = 0, it doesn't show up on Server Control Console

	req_access = list(access_tox)	//Data and setting manipulation requires scientist access.

	l_color = "#CD00CD"

/obj/machinery/computer/rdconsole/proc/Maximize()
	files.known_tech=files.possible_tech
	for(var/datum/tech/KT in files.known_tech)
		if(KT.level < KT.max_level)
			KT.level=KT.max_level

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
			var/datum/reagent/T = new R()
			if(T.id == ID)
				return_name = T.name
				break
	return return_name

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/r_n_d/D in area_contents(areaMaster)) //any machine in the room, just for funsies
		if(D.linked_console != null || D.disabled || D.panel_open)
			continue
		if(D.type in research_machines)
			linked_machines += D
			D.linked_console = src
			D.update_icon()
	for(var/obj/machinery/r_n_d/D in linked_machines)
		switch(D.type)
			if(/obj/machinery/r_n_d/fabricator/protolathe)
				if(!linked_lathe)
					linked_lathe = D
			if(/obj/machinery/r_n_d/destructive_analyzer)
				if(!linked_destroy)
					linked_destroy = D
			if(/obj/machinery/r_n_d/fabricator/circuit_imprinter)
				if(!linked_imprinter)
					linked_imprinter = D
	return

//Have it automatically push research to the centcomm server so wild griffins can't fuck up R&D's work --NEO
/obj/machinery/computer/rdconsole/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in machines)
		for(var/datum/tech/T in files.known_tech)
			C.files.AddTech2Known(T)
		for(var/datum/design/D in files.known_designs)
			C.files.AddDesign2Known(D)
		C.files.RefreshResearch()


/obj/machinery/computer/rdconsole/New()
	..()
	files = new /datum/research(src) //Setup the research data holder.
	if(!id)
		for(var/obj/machinery/r_n_d/server/centcom/S in machines)
			S.initialize()
			break

/obj/machinery/computer/rdconsole/initialize()
	SyncRDevices()

/*	Instead of calling this every tick, it is only being called when needed
/obj/machinery/computer/rdconsole/process()
	griefProtection()
*/

/obj/machinery/computer/rdconsole/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
	if(..())
		return
	if(istype(D, /obj/item/weapon/disk))
		if(t_disk || d_disk)
			user << "A disk is already loaded into the machine."
			return

		if(istype(D, /obj/item/weapon/disk/tech_disk)) t_disk = D
		else if (istype(D, /obj/item/weapon/disk/design_disk)) d_disk = D
		else
			user << "\red Machine cannot accept disks in that format."
			return
		user.drop_item()
		D.loc = src
		user << "\blue You add the disk to the machine!"
	src.updateUsrDialog()
	return

/obj/machinery/computer/rdconsole/emag(mob/user)
	playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
	emagged = 1
	user << "\blue You you disable the security protocols"

/obj/machinery/computer/rdconsole/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)

	usr.set_machine(src)
	if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		var/temp_screen = text2num(href_list["menu"])
		if(temp_screen <= 1.1 || (3 <= temp_screen && 4.9 >= temp_screen) || src.allowed(usr) || emagged) //Unless you are making something, you need access.
			screen = temp_screen
		else
			usr << "Unauthorized Access."

	else if(href_list["updt_tech"]) //Update the research holder with information from the technology disk.
		screen = 0.0
		spawn(50)
			screen = 1.2
			files.AddTech2Known(t_disk.stored)
			updateUsrDialog()
			griefProtection() //Update centcomm too

	else if(href_list["hax"]) // aww shit
		if(!usr.client.holder) return
		screen = 0.0
		spawn(50)
			Maximize()
			screen = 1.0
			updateUsrDialog()
			griefProtection() //Update centcomm too

	else if(href_list["clear_tech"]) //Erase data on the technology disk.
		t_disk.stored = null

	else if(href_list["eject_tech"]) //Eject the technology disk.
		t_disk:loc = src.loc
		t_disk = null
		screen = 1.0

	else if(href_list["copy_tech"]) //Copys some technology data from the research holder to the disk.
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
			griefProtection() //Update centcomm too

	else if(href_list["clear_design"]) //Erases data on the design disk.
		d_disk.blueprint = null

	else if(href_list["eject_design"]) //Eject the design disk.
		d_disk:loc = src.loc
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
				usr << "\red The destructive analyzer is busy at the moment."

			else if(linked_destroy.loaded_item)
				linked_destroy.loaded_item.loc = linked_destroy.loc
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				screen = 2.1

	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(linked_destroy)
			if(linked_destroy.busy)
				usr << "\red The destructive analyzer is busy at the moment."
			else
				var/choice = input("Proceeding will destroy loaded item.") in list("Proceed", "Cancel")
				if(choice == "Cancel" || !linked_destroy) return
				linked_destroy.busy = 1
				screen = 0.1
				updateUsrDialog()
				flick("d_analyzer_process", linked_destroy)
				spawn(24)
					if(linked_destroy)
						if(!linked_destroy.hacked)
							if(!linked_destroy.loaded_item)
								usr <<"\red The destructive analyzer appears to be empty."
								screen = 1.0
								linked_destroy.busy = 0
								return
							if(linked_destroy.loaded_item.reliability >= 90)
								var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
								for(var/T in temp_tech)
									files.UpdateTech(T, temp_tech[T])
							if(linked_destroy.loaded_item.reliability < 100 && linked_destroy.loaded_item.crit_fail)
								files.UpdateDesign(linked_destroy.loaded_item.type)
							if(linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
								var/datum/material/metal = linked_lathe.materials["iron"]
								var/datum/material/glass = linked_lathe.materials["glass"]
								metal.stored += min((linked_lathe.max_material_storage - linked_lathe.TotalMaterials()), (linked_destroy.loaded_item.m_amt*linked_destroy.decon_mod))
								glass.stored += min((linked_lathe.max_material_storage - linked_lathe.TotalMaterials()), (linked_destroy.loaded_item.g_amt*linked_destroy.decon_mod))
								linked_lathe.materials["iron"]=metal
								linked_lathe.materials["glass"]=glass
							linked_destroy.loaded_item = null
						for(var/obj/I in linked_destroy.contents)
							for(var/mob/M in I.contents)
								M.death()
							if(istype(I,/obj/item/stack/sheet))//Only deconsturcts one sheet at a time instead of the entire stack
								var/obj/item/stack/sheet/S = I
								if(S.amount > 1)
									S.amount--
									linked_destroy.loaded_item = S
								else
									del(S)
									linked_destroy.icon_state = "d_analyzer"
							else
								if(!(I in linked_destroy.component_parts))
									del(I)
									linked_destroy.icon_state = "d_analyzer"
						use_power(250)
						screen = 1.0
						updateUsrDialog()
						linked_destroy.busy = 0

	else if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(src.allowed(usr))
			screen = text2num(href_list["lock"])
		else
			usr << "Unauthorized Access."

	else if(href_list["sync"]) //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
		screen = 0.0
		if(!sync)
			usr << "\red You must connect to the network first!"
		else
			griefProtection() //Putting this here because I dont trust the sync process
			spawn(30)
				if(src)
					for(var/obj/machinery/r_n_d/server/S in machines)
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
		if(linked_lathe)
			var/datum/design/being_built = null
			for(var/datum/design/D in files.known_designs)
				if(D.id == href_list["build"])
					being_built = D
					break
			if(being_built)
				var/power = 2000
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(2000, power)
				//screen = 0.3
				var/n = Clamp(text2num(href_list["n"]), 0, RESEARCH_MAX_Q_LEN - linked_lathe.queue.len)
				for(var/i=1;i<=n;i++)
					use_power(power)
					linked_lathe.queue += being_built
				if(href_list["now"]=="1")
					linked_lathe.stopped=0
				updateUsrDialog()

	else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
		if(linked_imprinter)
			var/datum/design/being_built = null

			if(linked_imprinter.queue.len >= RESEARCH_MAX_Q_LEN)
				usr << "<span class=\"warning\">Maximum number of items in production queue exceeded.</span>"
				return

			for(var/datum/design/D in files.known_designs)
				if(D.id == href_list["imprint"])
					being_built = D
					break
			if(being_built)
				var/power = 2000
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(2000, power)
				var/n = Clamp(text2num(href_list["n"]), 0, RESEARCH_MAX_Q_LEN - linked_imprinter.queue.len)
				for(var/i=1;i<=n;i++)
					linked_imprinter.queue += being_built
					use_power(power)
				if(href_list["now"]=="1")
					linked_imprinter.stopped=0
				updateUsrDialog()

	else if(href_list["disposeI"] && linked_imprinter)  //Causes the circuit imprinter to dispose of a single reagent (all of it)
		linked_imprinter.reagents.del_reagent(href_list["dispose"])

	else if(href_list["disposeallI"] && linked_imprinter) //Causes the circuit imprinter to dispose of all it's reagents.
		linked_imprinter.reagents.clear_reagents()

	else if(href_list["disposeP"] && linked_lathe)  //Causes the protolathe to dispose of a single reagent (all of it)
		linked_lathe.reagents.del_reagent(href_list["dispose"])

	else if(href_list["disposeallP"] && linked_lathe) //Causes the protolathe to dispose of all it's reagents.
		linked_lathe.reagents.clear_reagents()

	else if(href_list["removeQItem"]) //Causes the protolathe to dispose of all it's reagents.
		var/i=text2num(href_list["removeQItem"])
		switch(href_list["device"])
			if("protolathe")
				if(linked_lathe)
					linked_lathe.queue.Cut(i,i+1)
			if("imprinter")
				if(linked_imprinter)
					linked_imprinter.queue.Cut(i,i+1)

	else if(href_list["clearQ"]) //Causes the protolathe to dispose of all it's reagents.
		switch(href_list["device"])
			if("protolathe")
				if(linked_lathe)
					linked_lathe.queue.Cut()
			if("imprinter")
				if(linked_imprinter)
					linked_imprinter.queue.Cut()

	else if(href_list["setProtolatheStopped"] && linked_lathe) //Causes the protolathe to dispose of all it's reagents.
		linked_lathe.stopped=(href_list["setProtolatheStopped"]=="1")

	else if(href_list["setImprinterStopped"] && linked_imprinter) //Causes the protolathe to dispose of all it's reagents.
		linked_imprinter.stopped=(href_list["setImprinterStopped"]=="1")

	else if(href_list["lathe_ejectsheet"] && linked_lathe) //Causes the protolathe to eject a sheet of material
		var/desired_num_sheets = text2num(href_list["lathe_ejectsheet_amt"])
		if (desired_num_sheets <= 0)
			return
		var/matID=href_list["lathe_ejectsheet"]
		var/datum/material/M=linked_lathe.materials[matID]
		if(!istype(M))
			warning("PROTOLATHE: Unknown material [matID]! ([href])")
		else
			var/obj/item/stack/sheet/sheet = new M.sheettype(linked_lathe.output.loc)
			var/available_num_sheets = round(M.stored/sheet.perunit)
			if(available_num_sheets>0)
				sheet.amount = min(available_num_sheets, desired_num_sheets)
				M.stored = max(0, (M.stored-sheet.amount * sheet.perunit))
				linked_lathe.materials[M.id]=M
			else
				del sheet
	else if(href_list["imprinter_ejectsheet"] && linked_imprinter) //Causes the protolathe to eject a sheet of material
		var/desired_num_sheets = text2num(href_list["imprinter_ejectsheet_amt"])
		if (desired_num_sheets <= 0) return
		var/matID=href_list["imprinter_ejectsheet"]
		var/datum/material/M=linked_imprinter.materials[matID]
		if(!istype(M))
			warning("IMPRINTER: Unknown material [matID]! ([href])")
		else
			var/obj/item/stack/sheet/sheet = new M.sheettype(linked_imprinter.output.loc)
			var/available_num_sheets = round(M.stored/sheet.perunit)
			if(available_num_sheets>0)
				sheet.amount = min(available_num_sheets, desired_num_sheets)
				M.stored = max(0, (M.stored-sheet.amount * sheet.perunit))
				linked_imprinter.materials[M.id]=M
			else
				del sheet

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
				linked_destroy.update_icon()
				linked_destroy = null
			if("lathe")
				linked_lathe.linked_console = null
				linked_lathe.update_icon()
				linked_lathe = null
			if("imprinter")
				linked_imprinter.linked_console = null
				linked_imprinter.update_icon()
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
	updateUsrDialog()
	return

/obj/machinery/computer/rdconsole/proc/protolathe_header()
	var/list/options=list()
	if(screen!=3.1)
		options += "<A href='?src=\ref[src];menu=3.1'>Design Selection</A>"
	if(screen!=3.2)
		options += "<A href='?src=\ref[src];menu=3.2'>Material Storage</A>"
	if(screen!=3.3)
		options += "<A href='?src=\ref[src];menu=3.3'>Chemical Storage</A>"
	if(screen!=3.4)
		options += "<A href='?src=\ref[src];menu=3.4'>Production Queue</A> ([linked_lathe.queue.len])"
	return {"\[<A href='?src=\ref[src];menu=1.0'>Main Menu</A>\]
	<div class="header">[list2text(options," || ")]</div><hr />"}

/obj/machinery/computer/rdconsole/proc/CircuitImprinterHeader()
	var/list/options=list()
	if(screen!=4.1)
		options += "<A href='?src=\ref[src];menu=4.1'>Design Selection</A>"
	if(screen!=4.3)
		options += "<A href='?src=\ref[src];menu=4.3'>Material Storage</A>"
	if(screen!=4.2)
		options += "<A href='?src=\ref[src];menu=4.2'>Chemical Storage</A>"
	if(screen!=4.4)
		options += "<A href='?src=\ref[src];menu=4.4'>Production Queue</A> ([linked_imprinter.queue.len])"
	return {"\[<A href='?src=\ref[src];menu=1.0'>Main Menu</A>\]
	<div class=\"header\">[list2text(options," || ")]</div><hr />"}

/obj/machinery/computer/rdconsole/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	if(ishuman(user))
		if(istype(user:gloves, /obj/item/clothing/gloves/space_ninja)&&user:gloves:candrain&&!user:gloves:draining)
			call(/obj/item/clothing/gloves/space_ninja/proc/drain)("RESEARCH",src,user:wear_suit)
			return

	user.set_machine(src)
	var/dat = ""
	files.RefreshResearch()
	switch(screen) //A quick check to make sure you get the right screen when a device is disconnected.
		if(2 to 2.9)
			if(linked_destroy == null)
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
		if(0.0) dat += "Updating Database...."

		if(0.1) dat += "Processing and Updating Database..."

		if(0.2)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:584: dat += "SYSTEM LOCKED<BR><BR>"
			dat += {"SYSTEM LOCKED<BR><BR>
				<A href='?src=\ref[src];lock=1.6'>Unlock</A>"}
			// END AUTOFIX
		if(0.3)
			dat += "Constructing Prototypes. Please Wait..."

		if(0.4)
			dat += "Imprinting Circuit. Please Wait..."

		if(1.0) //Main Menu

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:594: dat += "Main Menu:<BR><BR>"
			dat += {"Main Menu:<BR><BR>
				<A href='?src=\ref[src];menu=1.1'>Current Research Levels</A><BR>"}
			// END AUTOFIX
			if(t_disk) dat += "<A href='?src=\ref[src];menu=1.2'>Disk Operations</A><BR>"
			else if(d_disk) dat += "<A href='?src=\ref[src];menu=1.4'>Disk Operations</A><BR>"
			else dat += "(Please Insert Disk)<BR>"
			if(linked_destroy != null) dat += "<A href='?src=\ref[src];menu=2.2'>Destructive Analyzer Menu</A><BR>"
			if(linked_lathe != null) dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Construction Menu</A><BR>"
			if(linked_imprinter != null) dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Construction Menu</A><BR>"
			if(user.client.holder) dat += "<A href='?src=\ref[src];hax=1'>MAXIMUM SCIENCE</A><BR>"
			dat += "<A href='?src=\ref[src];menu=1.6'>Settings</A>"

		if(1.1) //Research viewer
			dat += "Current Research Levels:<BR><BR>"
			for(var/datum/tech/T in files.known_tech)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:607: dat += "[T.name]<BR>"
				dat += {"[T.name]<BR>
					* Level: [T.level]<BR>
					* Summary: [T.desc]<HR>"}
				// END AUTOFIX
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(1.2) //Technology Disk Menu


			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:614: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>
				Disk Contents: (Technology Data Disk)<BR><BR>"}
			// END AUTOFIX
			if(t_disk.stored == null)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:617: dat += "The disk has no data stored on it.<HR>"
				dat += {"The disk has no data stored on it.<HR>
					Operations:
					<A href='?src=\ref[src];menu=1.3'>Load Tech to Disk</A> || "}
				// END AUTOFIX
			else

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:621: dat += "Name: [t_disk.stored.name]<BR>"
				dat += {"Name: [t_disk.stored.name]<BR>
					Level: [t_disk.stored.level]<BR>
					Description: [t_disk.stored.desc]<HR>
					Operations:
					<A href='?src=\ref[src];updt_tech=1'>Upload to Database</A> ||
					<A href='?src=\ref[src];clear_tech=1'>Clear Disk</A> || "}
				// END AUTOFIX
			dat += "<A href='?src=\ref[src];eject_tech=1'>Eject Disk</A>"

		if(1.3) //Technology Disk submenu

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:630: dat += "<BR><A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += {"<BR><A href='?src=\ref[src];menu=1.0'>Main Menu</A> ||
				<A href='?src=\ref[src];menu=1.2'>Return to Disk Operations</A><HR>
				Load Technology to Disk:<BR><BR>"}
			// END AUTOFIX
			for(var/datum/tech/T in files.known_tech)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:634: dat += "[T.name] "
				dat += {"[T.name]
					<A href='?src=\ref[src];copy_tech=1;copy_tech_ID=[T.id]'>(Copy to Disk)</A><BR>"}
				// END AUTOFIX
		if(1.4) //Design Disk menu.
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			if(d_disk.blueprint == null)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:640: dat += "The disk has no data stored on it.<HR>"
				dat += {"The disk has no data stored on it.<HR>
					Operations:
					<A href='?src=\ref[src];menu=1.5'>Load Design to Disk</A> || "}
				// END AUTOFIX
			else

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:644: dat += "Name: [d_disk.blueprint.name]<BR>"
				dat += {"Name: [d_disk.blueprint.name]<BR>
					Level: [between(0, (d_disk.blueprint.reliability + rand(-15,15)), 100)]<BR>"}
				// END AUTOFIX
				switch(d_disk.blueprint.build_type)
					if(IMPRINTER) dat += "Lathe Type: Circuit Imprinter<BR>"
					if(PROTOLATHE) dat += "Lathe Type: Proto-lathe<BR>"
					if(AUTOLATHE) dat += "Lathe Type: Auto-lathe<BR>"
				dat += "Required Materials:<BR>"
				for(var/M in d_disk.blueprint.materials)
					if(copytext(M, 1, 2) == "$") dat += "* [copytext(M, 2)] x [d_disk.blueprint.materials[M]]<BR>"
					else dat += "* [M] x [d_disk.blueprint.materials[M]]<BR>"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:654: dat += "<HR>Operations: "
				dat += {"<HR>Operations:
					<A href='?src=\ref[src];updt_design=1'>Upload to Database</A> ||
					<A href='?src=\ref[src];clear_design=1'>Clear Disk</A> || "}
				// END AUTOFIX
			dat += "<A href='?src=\ref[src];eject_design=1'>Eject Disk</A>"

		if(1.5) //Technology disk submenu

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:660: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A> ||
				<A href='?src=\ref[src];menu=1.4'>Return to Disk Operations</A><HR>
				Load Design to Disk:<BR><BR>"}
			// END AUTOFIX
			for(var/datum/design/D in files.known_designs)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:664: dat += "[D.name] "
				dat += {"[D.name]
					<A href='?src=\ref[src];copy_design=1;copy_design_ID=[D.id]'>(Copy to Disk)</A><BR>"}
				// END AUTOFIX
		if(1.6) //R&D console settings

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:668: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>
				R&D Console Setting:<BR><BR>"}
			// END AUTOFIX
			if(sync)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:671: dat += "<A href='?src=\ref[src];sync=1'>Sync Database with Network</A><BR>"
				dat += {"<A href='?src=\ref[src];sync=1'>Sync Database with Network</A><BR>
					<A href='?src=\ref[src];togglesync=1'>Disconnect from Research Network</A><BR>"}
				// END AUTOFIX
			else
				dat += "<A href='?src=\ref[src];togglesync=1'>Connect to Research Network</A><BR>"

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:675: dat += "<A href='?src=\ref[src];menu=1.7'>Device Linkage Menu</A><BR>"
			dat += {"<A href='?src=\ref[src];menu=1.7'>Device Linkage Menu</A><BR>
				<A href='?src=\ref[src];lock=0.2'>Lock Console</A><BR>
				<A href='?src=\ref[src];reset=1'>Reset R&D Database.</A><BR>"}
			// END AUTOFIX
		if(1.7) //R&D device linkage

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:680: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A> ||
				<A href='?src=\ref[src];menu=1.6'>Settings Menu</A><HR>
				R&D Console Device Linkage Menu:<BR><BR>
				<A href='?src=\ref[src];find_device=1'>Re-sync with Nearby Devices</A><BR>
				Linked Devices:<BR>"}
			// END AUTOFIX
			var/remain_link = linked_machines
			if(linked_destroy)
				dat += "* Destructive Analyzer <A href='?src=\ref[src];disconnect=destroy'>(Disconnect)</A><BR>"
				remain_link -= linked_destroy
			else
				dat += "* (No Destructive Analyzer Linked)<BR>"
			if(linked_lathe)
				dat += "* Protolathe <A href='?src=\ref[src];disconnect=lathe'>(Disconnect)</A><BR>"
				remain_link -= linked_lathe
			else
				dat += "* (No Protolathe Linked)<BR>"
			if(linked_imprinter)
				dat += "* Circuit Imprinter <A href='?src=\ref[src];disconnect=imprinter'>(Disconnect)</A><BR>"
				remain_link -= linked_imprinter
			else
				dat += "* (No Circuit Imprinter Linked)<BR>"
			if(remain_link)
				for(var/obj/machinery/r_n_d/R in remain_link)
					dat += "* [R.name] <BR>"

		////////////////////DESTRUCTIVE ANALYZER SCREENS////////////////////////////
		if(2.0)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:700: dat += "NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE<BR><BR>"
			dat += {"NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE<BR><BR>
				<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"}
			// END AUTOFIX
		if(2.1)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:704: dat += "No Item Loaded. Standing-by...<BR><HR>"
			dat += {"No Item Loaded. Standing-by...<BR><HR>
				<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"}
			// END AUTOFIX
		if(2.2)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:708: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>
				Deconstruction Menu<HR>
				Name: [linked_destroy.loaded_item.name]<BR>
				Origin Tech:<BR>"}
			// END AUTOFIX
			var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
			for(var/T in temp_tech)
				dat += "* [CallTechName(T)] [temp_tech[T]]<BR>"

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:715: dat += "<HR><A href='?src=\ref[src];deconstruct=1'>Deconstruct Item</A> || "
			dat += {"<HR><A href='?src=\ref[src];deconstruct=1'>Deconstruct Item</A> ||
				<A href='?src=\ref[src];eject_item=1'>Eject Item</A> || "}
			// END AUTOFIX
		/////////////////////PROTOLATHE SCREENS/////////////////////////
		if(3.0)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:720: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>
				NO PROTOLATHE LINKED TO CONSOLE<BR><BR>"}
			// END AUTOFIX
		if(3.1)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:724: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += protolathe_header()+{"Protolathe Menu:<BR>
				<B>Material Amount:</B> [linked_lathe.TotalMaterials()] cm<sup>3</sup> (MAX: [linked_lathe.max_material_storage])<BR>
				<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] (MAX: [linked_lathe.reagents.maximum_volume])<HR><ul>"}
			// END AUTOFIX
			for(var/datum/design/D in files.known_designs)
				if(!(D.build_type & PROTOLATHE))
					continue
				var/temp_dat = "[D.name]"
				var/upTo=10
				for(var/M in D.materials)
					temp_dat += " [D.materials[M]] [CallMaterialName(M)]"
					var/num_units_avail=linked_lathe.check_mat(D,M,upTo)
					if(upTo && num_units_avail<upTo)
						upTo=num_units_avail
				if (upTo)
					dat += {"<li>
						<A href='?src=\ref[src];build=[D.id];n=1;now=1'>[temp_dat]</A>
						<A href='?src=\ref[src];build=[D.id];n=1'>(Queue &times;1)</A>"}
					if(upTo>=5)
						dat += "<A href='?src=\ref[src];build=[D.id];n=5'>(&times;5)</A>"
					if(upTo>=10)
						dat += "<A href='?src=\ref[src];build=[D.id];n=10'>(&times;10)</A>"
					dat += "</li>"
				else
					dat += "<li>[temp_dat]</li>"
			dat += "</ul>"

		if(3.2) //Protolathe Material Storage Sub-menu

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:763: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += protolathe_header()+{"Material Storage<ul>"}
			// END AUTOFIX


			for(var/matID in linked_lathe.materials)
				var/datum/material/M=linked_lathe.materials[matID]
				dat += "<li>[M.stored] cm<sup>3</sup> of [M.processed_name]"
				if(M.stored >= M.cc_per_sheet)
					dat += " - <A href='?src=\ref[src];lathe_ejectsheet=[matID];lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
					if(M.stored >= (M.cc_per_sheet*5))
						dat += "<A href='?src=\ref[src];lathe_ejectsheet=[matID];lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
					dat += "<A href='?src=\ref[src];lathe_ejectsheet=[matID];lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
				else
					dat += " - <em>(Empty)</em>"
				dat += "</li>"
			dat += "</ul>"

		if(3.3) //Protolathe Chemical Storage Submenu

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:823: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += protolathe_header()+{"Chemical Storage<BR><HR>"}
			// END AUTOFIX
			for(var/datum/reagent/R in linked_lathe.reagents.reagent_list)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:827: dat += "Name: [R.name] | Units: [R.volume] "
				dat += {"Name: [R.name] | Units: [R.volume]
					<A href='?src=\ref[src];disposeP=[R.id]'>(Purge)</A><BR>
					<A href='?src=\ref[src];disposeallP=1'><U>Disposal All Chemicals in Storage</U></A><BR>"}
				// END AUTOFIX

		if(3.4) //Protolathe Queue Management
			dat += protolathe_header()+"Production Queue<BR><HR><ul>"
			for(var/i=1;i<=linked_lathe.queue.len;i++)
				var/datum/design/I=linked_lathe.queue[i]
				dat += "<li>Name: [I.name]"
				if(linked_lathe.stopped)
					dat += "<A href='?src=\ref[src];removeQItem=[i];device=protolathe'>(Remove)</A></li>"
			dat += "</ul><A href='?src=\ref[src];clearQ=1;device=protolathe'>Remove All Queued Items</A><br />"
			if(linked_lathe.stopped)
				dat += "<A href='?src=\ref[src];setProtolatheStopped=0' style='color:green'>Start Production</A>"
			else
				dat += "<A href='?src=\ref[src];setProtolatheStopped=1' style='color:red'>Stop Production</A>"

		///////////////////CIRCUIT IMPRINTER SCREENS////////////////////
		if(4.0)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:833: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += {"<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>
				NO CIRCUIT IMPRINTER LINKED TO CONSOLE<BR><BR>"}
			// END AUTOFIX
		if(4.1)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:837: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += {"[CircuitImprinterHeader()]
				Circuit Imprinter Menu:<BR>
				<b>Material Amount:</b> [linked_imprinter.TotalMaterials()] cm<sup>3</sup><BR>
				<b>Chemical Volume:</b> [linked_imprinter.reagents.total_volume]<ul>"}
			// END AUTOFIX
			for(var/datum/design/D in files.known_designs)
				if(!(D.build_type & IMPRINTER))
					continue
				var/temp_dat = "[D.name]"
				var/upTo=10
				for(var/M in D.materials)
					temp_dat += " [D.materials[M]] [CallMaterialName(M)]"
					var/num_units_avail=linked_imprinter.check_mat(D,M,upTo)
					if(num_units_avail<upTo)
						upTo=num_units_avail
						if(!upTo)
							break
				if (upTo)
					dat += {"<li><A href='?src=\ref[src];imprint=[D.id];n=1;now=1'>[temp_dat]</A>
						<A href='?src=\ref[src];imprint=[D.id];n=1'>(Queue &times;1)</A>"}
					if(upTo>=5)
						dat += "<A href='?src=\ref[src];imprint=[D.id];n=5'>(&times;5)</A>"
					if(upTo>=10)
						dat += "<A href='?src=\ref[src];imprint=[D.id];n=10'>(&times;10)</A>"
					dat += "</li>"
				else
					dat += "<li>[temp_dat]</li>"
			dat += "</ul>"

		if(4.2)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:869: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += {"[CircuitImprinterHeader()]
				Chemical Storage<HR>"}
			// END AUTOFIX
			for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:873: dat += "Name: [R.name] | Units: [R.volume] "
				dat += {"Name: [R.name] | Units: [R.volume]
					<A href='?src=\ref[src];disposeI=[R.id]'>(Purge)</A><BR>
					<A href='?src=\ref[src];disposeallI=1'><U>Disposal All Chemicals in Storage</U></A><BR>"}
				// END AUTOFIX
		if(4.3)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\rdconsole.dm:878: dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += {"[CircuitImprinterHeader()]
				Material Storage<HR><ul>"}


			for(var/matID in linked_imprinter.materials.storage)
				var/datum/material/M=linked_imprinter.materials.storage[matID]
				if(!(M.sheettype in linked_imprinter.allowed_materials))
					continue
				dat += "<li>[M.stored] cm<sup>3</sup> of [M.processed_name]"
				if(M.stored >= M.cc_per_sheet)
					dat += " - <A href='?src=\ref[src];imprinter_ejectsheet=[matID];imprinter_ejectsheet_amt=1'>(1 Sheet)</A> "
					if(M.stored >= (M.cc_per_sheet*5))
						dat += "<A href='?src=\ref[src];imprinter_ejectsheet=[matID];imprinter_ejectsheet_amt=5'>(5 Sheets)</A> "
					dat += "<A href='?src=\ref[src];imprinter_ejectsheet=[matID];imprinter_ejectsheet_amt=50'>(Max Sheets)</A>"
				else
					dat += " - <em>(Empty)</em>"
				dat += "</li>"
			dat += "</ul>"

		if(4.4) //Imprinter Queue Management
			dat += CircuitImprinterHeader()+"Production Queue<BR><HR><ul>"
			for(var/i=1;i<=linked_imprinter.queue.len;i++)
				var/datum/design/I=linked_imprinter.queue[i]
				dat += "<li>Name: [I.name]"
				if(linked_imprinter.stopped)
					dat += "<A href='?src=\ref[src];removeQItem=[i];device=imprinter'>(Remove)</A></li>"
			dat += "</ul><A href='?src=\ref[src];clearQ=1;device=imprinter'>Remove All Queued Items</A><br />"
			if(linked_imprinter.stopped)
				dat += "<A href='?src=\ref[src];setImprinterStopped=0' style='color:green'>Start Production</A>"
			else
				dat += "<A href='?src=\ref[src];setImprinterStopped=1' style='color:red'>Stop Production</A>"

	user << browse("<TITLE>Research and Development Console</TITLE><HR>[dat]", "window=rdconsole;size=575x400")
	onclose(user, "rdconsole")

/obj/machinery/computer/rdconsole/mommi
	name = "MoMMI R&D Console"
	id = 2
	req_access = list(access_tox)
	circuit = "/obj/item/weapon/circuitboard/rdconsole/mommi"

	l_color = "#CD00CD"

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	id = 2
	req_one_access = list(access_robotics)
	req_access=list()
	circuit = "/obj/item/weapon/circuitboard/rdconsole/robotics"

	l_color = "#CD00CD"

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	id = 1
	req_access = list(access_tox)
	circuit = "/obj/item/weapon/circuitboard/rdconsole"

	l_color = "#CD00CD"