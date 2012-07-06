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

/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_state = "rdcomp"
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

	proc
		CallTechName(var/ID) //A simple helper proc to find the name of a tech with a given ID.
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

		CallMaterialName(var/ID)
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

		SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
			for(var/obj/machinery/r_n_d/D in oview(3,src))
				if(D.linked_console != null || D.disabled || D.opened)
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

		//Have it automatically push research to the centcomm server so wild griffins can't fuck up R&D's work --NEO
		griefProtection()
			for(var/obj/machinery/r_n_d/server/centcom/C in world)
				for(var/datum/tech/T in files.known_tech)
					C.files.AddTech2Known(T)
				for(var/datum/design/D in files.known_designs)
					C.files.AddDesign2Known(D)
				C.files.RefreshResearch()


	New()
		..()
		files = new /datum/research(src) //Setup the research data holder.
		if(!id)
			for(var/obj/machinery/r_n_d/server/centcom/S in world)
				S.initialize()
				break

	initialize()
		SyncRDevices()

/*	Instead of calling this every tick, it is only being called when needed
	process()
		griefProtection()
*/

	attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
		//The construction/deconstruction of the console code.
		if(istype(D, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					new /obj/item/weapon/shard( src.loc )
					var/obj/item/weapon/circuitboard/rdconsole/M = new /obj/item/weapon/circuitboard/rdconsole( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					del(src)
				else
					user << "\blue You disconnect the monitor."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					var/obj/item/weapon/circuitboard/rdconsole/M = new /obj/item/weapon/circuitboard/rdconsole( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					del(src)
		//Loading a disk into it.
		else if(istype(D, /obj/item/weapon/disk))
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
		else if(istype(D, /obj/item/weapon/card/emag) && !emagged)
			playsound(src.loc, 'sparks4.ogg', 75, 1)
			emagged = 1
			user << "\blue You you disable the security protocols"
		src.updateUsrDialog()
		return

	Topic(href, href_list)
		if(..())
			return

		add_fingerprint(usr)

		usr.machine = src
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
					if(choice == "Cancel") return
					linked_destroy.busy = 1
					screen = 0.1
					updateUsrDialog()
					flick("d_analyzer_process", linked_destroy)
					spawn(24)
						if(linked_destroy)
							linked_destroy.busy = 0
							if(!linked_destroy.hacked)
								if(!linked_destroy.loaded_item)
									usr <<"\red The destructive analyzer appears to be empty."
									screen = 1.0
									return
								if(linked_destroy.loaded_item.reliability >= 90)
									var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
									for(var/T in temp_tech)
										files.UpdateTech(T, temp_tech[T])
								if(linked_destroy.loaded_item.reliability < 100 && linked_destroy.loaded_item.crit_fail)
									files.UpdateDesign(linked_destroy.loaded_item.type)
								if(linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
									linked_lathe.m_amount += min((linked_lathe.max_material_storage - linked_lathe.TotalMaterials()), (linked_destroy.loaded_item.m_amt*linked_destroy.decon_mod))
									linked_lathe.g_amount += min((linked_lathe.max_material_storage - linked_lathe.TotalMaterials()), (linked_destroy.loaded_item.g_amt*linked_destroy.decon_mod))
								linked_destroy.loaded_item = null
							for(var/obj/I in linked_destroy.contents)
								for(var/mob/M in I.contents)
									M.death()
								del(I)
							use_power(250)
							linked_destroy.icon_state = "d_analyzer"
							screen = 1.0
							updateUsrDialog()

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
			if(linked_lathe)
				var/datum/design/being_built = null
				for(var/datum/design/D in files.known_designs)
					if(D.id == href_list["build"])
						being_built = D
						break
				var/power = 2000
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(2000, power)
				screen = 0.3
				linked_lathe.busy = 1
				flick("protolathe_n",linked_lathe)
				var/key = usr.key	//so we don't lose the info during the spawn delay
				spawn(16)
					use_power(power)
					spawn(16)
						for(var/M in being_built.materials)
							switch(M)
								if("$metal")
									linked_lathe.m_amount = max(0, (linked_lathe.m_amount-being_built.materials[M]))
								if("$glass")
									linked_lathe.g_amount = max(0, (linked_lathe.g_amount-being_built.materials[M]))
								if("$gold")
									linked_lathe.gold_amount = max(0, (linked_lathe.gold_amount-being_built.materials[M]))
								if("$silver")
									linked_lathe.silver_amount = max(0, (linked_lathe.silver_amount-being_built.materials[M]))
								if("$plasma")
									linked_lathe.plasma_amount = max(0, (linked_lathe.plasma_amount-being_built.materials[M]))
								if("$uranium")
									linked_lathe.uranium_amount = max(0, (linked_lathe.uranium_amount-being_built.materials[M]))
								if("$diamond")
									linked_lathe.diamond_amount = max(0, (linked_lathe.diamond_amount-being_built.materials[M]))
								if("$clown")
									linked_lathe.clown_amount = max(0, (linked_lathe.clown_amount-being_built.materials[M]))
								else
									linked_lathe.reagents.remove_reagent(M, being_built.materials[M])

						if(being_built.build_path)
							var/obj/new_item = new being_built.build_path(src)
							if( new_item.type == /obj/item/weapon/storage/backpack/holding )
								new_item.investigate_log("built by [key]","singulo")
							new_item.reliability = being_built.reliability
							if(linked_lathe.hacked) being_built.reliability = max((reliability / 2), 0)
							if(being_built.locked)
								var/obj/item/weapon/storage/lockbox/L = new/obj/item/weapon/storage/lockbox(linked_lathe.loc)
								new_item.loc = L
								L.name += " ([new_item.name])"
							else
								new_item.loc = linked_lathe.loc
							linked_lathe.busy = 0
							screen = 3.1
							updateUsrDialog()

		else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
			if(linked_imprinter)
				var/datum/design/being_built = null
				for(var/datum/design/D in files.known_designs)
					if(D.id == href_list["imprint"])
						being_built = D
						break
				var/power = 2000
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(2000, power)
				screen = 0.4
				linked_imprinter.busy = 1
				flick("circuit_imprinter_ani",linked_imprinter)
				spawn(16)
					use_power(power)
					for(var/M in being_built.materials)
						switch(M)
							if("$glass")
								linked_imprinter.g_amount = max(0, (linked_imprinter.g_amount-being_built.materials[M]))
							if("$gold")
								linked_imprinter.gold_amount = max(0, (linked_imprinter.gold_amount-being_built.materials[M]))
							if("$diamond")
								linked_imprinter.diamond_amount = max(0, (linked_imprinter.diamond_amount-being_built.materials[M]))
							else
								linked_imprinter.reagents.remove_reagent(M, being_built.materials[M])
					var/obj/new_item = new being_built.build_path(src)
					new_item.reliability = being_built.reliability
					if(linked_imprinter.hacked) being_built.reliability = max((reliability / 2), 0)
					new_item.loc = linked_imprinter.loc
					linked_imprinter.busy = 0
					screen = 4.1
					updateUsrDialog()

		else if(href_list["disposeI"] && linked_imprinter)  //Causes the circuit imprinter to dispose of a single reagent (all of it)
			linked_imprinter.reagents.del_reagent(href_list["dispose"])

		else if(href_list["disposeallI"] && linked_imprinter) //Causes the circuit imprinter to dispose of all it's reagents.
			linked_imprinter.reagents.clear_reagents()

		else if(href_list["disposeP"] && linked_lathe)  //Causes the protolathe to dispose of a single reagent (all of it)
			linked_lathe.reagents.del_reagent(href_list["dispose"])

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
					type = /obj/item/stack/sheet/gold
					res_amount = "gold_amount"
				if("silver")
					type = /obj/item/stack/sheet/silver
					res_amount = "silver_amount"
				if("plasma")
					type = /obj/item/stack/sheet/plasma
					res_amount = "plasma_amount"
				if("uranium")
					type = /obj/item/stack/sheet/uranium
					res_amount = "uranium_amount"
				if("diamond")
					type = /obj/item/stack/sheet/diamond
					res_amount = "diamond_amount"
				if("clown")
					type = /obj/item/stack/sheet/clown
					res_amount = "clown_amount"
			if(ispath(type) && hasvar(linked_lathe, res_amount))
				var/obj/item/stack/sheet/sheet = new type(linked_lathe.loc)
				var/available_num_sheets = round(linked_lathe.vars[res_amount]/sheet.perunit)
				if(available_num_sheets>0)
					sheet.amount = min(available_num_sheets, desired_num_sheets)
					linked_lathe.vars[res_amount] = max(0, (linked_lathe.vars[res_amount]-sheet.amount * sheet.perunit))
				else
					del sheet
		else if(href_list["imprinter_ejectsheet"] && linked_imprinter) //Causes the protolathe to eject a sheet of material
			var/desired_num_sheets = text2num(href_list["imprinter_ejectsheet_amt"])
			var/res_amount, type
			switch(href_list["imprinter_ejectsheet"])
				if("glass")
					type = /obj/item/stack/sheet/glass
					res_amount = "g_amount"
				if("gold")
					type = /obj/item/stack/sheet/gold
					res_amount = "gold_amount"
				if("diamond")
					type = /obj/item/stack/sheet/diamond
					res_amount = "diamond_amount"
			if(ispath(type) && hasvar(linked_imprinter, res_amount))
				var/obj/item/stack/sheet/sheet = new type(linked_imprinter.loc)
				var/available_num_sheets = round(linked_imprinter.vars[res_amount]/sheet.perunit)
				if(available_num_sheets>0)
					sheet.amount = min(available_num_sheets, desired_num_sheets)
					linked_imprinter.vars[res_amount] = max(0, (linked_imprinter.vars[res_amount]-sheet.amount * sheet.perunit))
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
		updateUsrDialog()
		return

	attack_hand(mob/user as mob)
		if(stat & (BROKEN|NOPOWER))
			return

		if(ishuman(user))
			if(istype(user:gloves, /obj/item/clothing/gloves/space_ninja)&&user:gloves:candrain&&!user:gloves:draining)
				call(/obj/item/clothing/gloves/space_ninja/proc/drain)("RESEARCH",src,user:wear_suit)
				return

		user.machine = src
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
				dat += "SYSTEM LOCKED<BR><BR>"
				dat += "<A href='?src=\ref[src];lock=1.6'>Unlock</A>"

			if(0.3)
				dat += "Constructing Prototype. Please Wait..."

			if(0.4)
				dat += "Imprinting Circuit. Please Wait..."

			if(1.0) //Main Menu
				dat += "Main Menu:<BR><BR>"
				dat += "<A href='?src=\ref[src];menu=1.1'>Current Research Levels</A><BR>"
				if(t_disk) dat += "<A href='?src=\ref[src];menu=1.2'>Disk Operations</A><BR>"
				else if(d_disk) dat += "<A href='?src=\ref[src];menu=1.4'>Disk Operations</A><BR>"
				else dat += "(Please Insert Disk)<BR>"
				if(linked_destroy != null) dat += "<A href='?src=\ref[src];menu=2.2'>Destructive Analyzer Menu</A><BR>"
				if(linked_lathe != null) dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Construction Menu</A><BR>"
				if(linked_imprinter != null) dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Construction Menu</A><BR>"
				dat += "<A href='?src=\ref[src];menu=1.6'>Settings</A>"

			if(1.1) //Research viewer
				dat += "Current Research Levels:<BR><BR>"
				for(var/datum/tech/T in files.known_tech)
					dat += "[T.name]<BR>"
					dat +=  "* Level: [T.level]<BR>"
					dat +=  "* Summary: [T.desc]<HR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(1.2) //Technology Disk Menu

				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
				dat += "Disk Contents: (Technology Data Disk)<BR><BR>"
				if(t_disk.stored == null)
					dat += "The disk has no data stored on it.<HR>"
					dat += "Operations: "
					dat += "<A href='?src=\ref[src];menu=1.3'>Load Tech to Disk</A> || "
				else
					dat += "Name: [t_disk.stored.name]<BR>"
					dat += "Level: [t_disk.stored.level]<BR>"
					dat += "Description: [t_disk.stored.desc]<HR>"
					dat += "Operations: "
					dat += "<A href='?src=\ref[src];updt_tech=1'>Upload to Database</A> || "
					dat += "<A href='?src=\ref[src];clear_tech=1'>Clear Disk</A> || "
				dat += "<A href='?src=\ref[src];eject_tech=1'>Eject Disk</A>"

			if(1.3) //Technology Disk submenu
				dat += "<BR><A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=1.2'>Return to Disk Operations</A><HR>"
				dat += "Load Technology to Disk:<BR><BR>"
				for(var/datum/tech/T in files.known_tech)
					dat += "[T.name] "
					dat += "<A href='?src=\ref[src];copy_tech=1;copy_tech_ID=[T.id]'>(Copy to Disk)</A><BR>"

			if(1.4) //Design Disk menu.
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
				if(d_disk.blueprint == null)
					dat += "The disk has no data stored on it.<HR>"
					dat += "Operations: "
					dat += "<A href='?src=\ref[src];menu=1.5'>Load Design to Disk</A> || "
				else
					dat += "Name: [d_disk.blueprint.name]<BR>"
					dat += "Level: [between(0, (d_disk.blueprint.reliability + rand(-15,15)), 100)]<BR>"
					switch(d_disk.blueprint.build_type)
						if(IMPRINTER) dat += "Lathe Type: Circuit Imprinter<BR>"
						if(PROTOLATHE) dat += "Lathe Type: Proto-lathe<BR>"
						if(AUTOLATHE) dat += "Lathe Type: Auto-lathe<BR>"
					dat += "Required Materials:<BR>"
					for(var/M in d_disk.blueprint.materials)
						if(copytext(M, 1, 2) == "$") dat += "* [copytext(M, 2)] x [d_disk.blueprint.materials[M]]<BR>"
						else dat += "* [M] x [d_disk.blueprint.materials[M]]<BR>"
					dat += "<HR>Operations: "
					dat += "<A href='?src=\ref[src];updt_design=1'>Upload to Database</A> || "
					dat += "<A href='?src=\ref[src];clear_design=1'>Clear Disk</A> || "
				dat += "<A href='?src=\ref[src];eject_design=1'>Eject Disk</A>"

			if(1.5) //Technology disk submenu
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=1.4'>Return to Disk Operations</A><HR>"
				dat += "Load Design to Disk:<BR><BR>"
				for(var/datum/design/D in files.known_designs)
					dat += "[D.name] "
					dat += "<A href='?src=\ref[src];copy_design=1;copy_design_ID=[D.id]'>(Copy to Disk)</A><BR>"

			if(1.6) //R&D console settings
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
				dat += "R&D Console Setting:<BR><BR>"
				if(sync)
					dat += "<A href='?src=\ref[src];sync=1'>Sync Database with Network</A><BR>"
					dat += "<A href='?src=\ref[src];togglesync=1'>Disconnect from Research Network</A><BR>"
				else
					dat += "<A href='?src=\ref[src];togglesync=1'>Connect to Research Network</A><BR>"
				dat += "<A href='?src=\ref[src];menu=1.7'>Device Linkage Menu</A><BR>"
				dat += "<A href='?src=\ref[src];lock=0.2'>Lock Console</A><BR>"
				dat += "<A href='?src=\ref[src];reset=1'>Reset R&D Database.</A><BR>"

			if(1.7) //R&D device linkage
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=1.6'>Settings Menu</A><HR> "
				dat += "R&D Console Device Linkage Menu:<BR><BR>"
				dat += "<A href='?src=\ref[src];find_device=1'>Re-sync with Nearby Devices</A><BR>"
				dat += "Linked Devices:<BR>"
				if(linked_destroy)
					dat += "* Destructive Analyzer <A href='?src=\ref[src];disconnect=destroy'>(Disconnect)</A><BR>"
				else
					dat += "* (No Destructive Analyzer Linked)<BR>"
				if(linked_lathe)
					dat += "* Protolathe <A href='?src=\ref[src];disconnect=lathe'>(Disconnect)</A><BR>"
				else
					dat += "* (No Protolathe Linked)<BR>"
				if(linked_imprinter)
					dat += "* Circuit Imprinter <A href='?src=\ref[src];disconnect=imprinter'>(Disconnect)</A><BR>"
				else
					dat += "* (No Circuit Imprinter Linked)<BR>"

			////////////////////DESTRUCTIVE ANALYZER SCREENS////////////////////////////
			if(2.0)
				dat += "NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE<BR><BR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(2.1)
				dat += "No Item Loaded. Standing-by...<BR><HR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(2.2)
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
				dat += "Deconstruction Menu<HR>"
				dat += "Name: [linked_destroy.loaded_item.name]<BR>"
				dat += "Origin Tech:<BR>"
				var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
				for(var/T in temp_tech)
					dat += "* [CallTechName(T)] [temp_tech[T]]<BR>"
				dat += "<HR><A href='?src=\ref[src];deconstruct=1'>Deconstruct Item</A> || "
				dat += "<A href='?src=\ref[src];eject_item=1'>Eject Item</A> || "

			/////////////////////PROTOLATHE SCREENS/////////////////////////
			if(3.0)
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
				dat += "NO PROTOLATHE LINKED TO CONSOLE<BR><BR>"

			if(3.1)
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=3.2'>Material Storage</A> || "
				dat += "<A href='?src=\ref[src];menu=3.3'>Chemical Storage</A><HR>"
				dat += "Protolathe Menu:<BR><BR>"
				dat += "<B>Material Amount:</B> [linked_lathe.TotalMaterials()] cm<sup>3</sup> (MAX: [linked_lathe.max_material_storage])<BR>"
				dat += "<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] (MAX: [linked_lathe.reagents.maximum_volume])<HR>"
				for(var/datum/design/D in files.known_designs)
					if(!(D.build_type & PROTOLATHE))
						continue
					var/temp_dat = "[D.name]"
					var/check_materials = 1
					for(var/M in D.materials)
						temp_dat += " [D.materials[M]] [CallMaterialName(M)]"
						if(copytext(M, 1, 2) == "$")
							switch(M)
								if("$glass")
									if(D.materials[M] > linked_lathe.g_amount) check_materials = 0
								if("$metal")
									if(D.materials[M] > linked_lathe.m_amount) check_materials = 0
								if("$gold")
									if(D.materials[M] > linked_lathe.gold_amount) check_materials = 0
								if("$silver")
									if(D.materials[M] > linked_lathe.silver_amount) check_materials = 0
								if("$plasma")
									if(D.materials[M] > linked_lathe.plasma_amount) check_materials = 0
								if("$uranium")
									if(D.materials[M] > linked_lathe.uranium_amount) check_materials = 0
								if("$diamond")
									if(D.materials[M] > linked_lathe.diamond_amount) check_materials = 0
								if("$clown")
									if(D.materials[M] > linked_lathe.clown_amount) check_materials = 0
						else if (!linked_lathe.reagents.has_reagent(M, D.materials[M]))
							check_materials = 0
					if (check_materials)
						dat += "* <A href='?src=\ref[src];build=[D.id]'>[temp_dat]</A><BR>"
					else
						dat += "* [temp_dat]<BR>"

			if(3.2) //Protolathe Material Storage Sub-menu
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Menu</A><HR>"
				dat += "Material Storage<BR><HR>"
				//Metal
				dat += "* [linked_lathe.m_amount] cm<sup>3</sup> of Metal || "
				dat += "Eject: "
				if(linked_lathe.m_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=metal;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_lathe.m_amount >= 18750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=metal;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_lathe.m_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=metal;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
				dat += "<BR>"
				//Glass
				dat += "* [linked_lathe.g_amount] cm<sup>3</sup> of Glass || "
				dat += "Eject: "
				if(linked_lathe.g_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=glass;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_lathe.g_amount >= 18750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=glass;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_lathe.g_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=glass;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
				dat += "<BR>"
				//Gold
				dat += "* [linked_lathe.gold_amount] cm<sup>3</sup> of Gold || "
				dat += "Eject: "
				if(linked_lathe.gold_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=gold;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_lathe.gold_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=gold;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_lathe.gold_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=gold;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
				dat += "<BR>"
				//Silver
				dat += "* [linked_lathe.silver_amount] cm<sup>3</sup> of Silver || "
				dat += "Eject: "
				if(linked_lathe.silver_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=silver;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_lathe.silver_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=silver;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_lathe.silver_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=silver;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
				dat += "<BR>"
				//Plasma
				dat += "* [linked_lathe.plasma_amount] cm<sup>3</sup> of Solid Plasma || "
				dat += "Eject: "
				if(linked_lathe.plasma_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=plasma;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_lathe.plasma_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=plasma;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_lathe.plasma_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=plasmalathe_ejectsheet_amt=50'>(Max Sheets)</A>"
				dat += "<BR>"
				//Uranium
				dat += "* [linked_lathe.uranium_amount] cm<sup>3</sup> of Uranium || "
				dat += "Eject: "
				if(linked_lathe.uranium_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=uranium;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_lathe.uranium_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=uranium;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_lathe.uranium_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=uranium;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
				dat += "<BR>"
				//Diamond
				dat += "* [linked_lathe.diamond_amount] cm<sup>3</sup> of Diamond || "
				dat += "Eject: "
				if(linked_lathe.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=diamond;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_lathe.diamond_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=diamond;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_lathe.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=diamond;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
				dat += "<BR>"
				//Bananium
				dat += "* [linked_lathe.clown_amount] cm<sup>3</sup> of Bananium || "
				dat += "Eject: "
				if(linked_lathe.clown_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=clown;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_lathe.clown_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=clown;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_lathe.clown_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=clown;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"

			if(3.3) //Protolathe Chemical Storage Submenu
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Menu</A><HR>"
				dat += "Chemical Storage<BR><HR>"
				for(var/datum/reagent/R in linked_lathe.reagents.reagent_list)
					dat += "Name: [R.name] | Units: [R.volume] "
					dat += "<A href='?src=\ref[src];disposeP=[R.id]'>(Purge)</A><BR>"
					dat += "<A href='?src=\ref[src];disposeallP=1'><U>Disposal All Chemicals in Storage</U></A><BR>"

			///////////////////CIRCUIT IMPRINTER SCREENS////////////////////
			if(4.0)
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
				dat += "NO CIRCUIT IMPRINTER LINKED TO CONSOLE<BR><BR>"

			if(4.1)
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=4.3'>Material Storage</A> || "
				dat += "<A href='?src=\ref[src];menu=4.2'>Chemical Storage</A><HR>"
				dat += "Circuit Imprinter Menu:<BR><BR>"
				dat += "Material Amount: [linked_imprinter.TotalMaterials()] cm<sup>3</sup><BR>"
				dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

				for(var/datum/design/D in files.known_designs)
					if(!(D.build_type & IMPRINTER))
						continue
					var/temp_dat = "[D.name]"
					var/check_materials = 1
					for(var/M in D.materials)
						temp_dat += " [D.materials[M]] [CallMaterialName(M)]"
						if(copytext(M, 1, 2) == "$")
							switch(M)
								if("$glass")
									if(D.materials[M] > linked_imprinter.g_amount) check_materials = 0
								if("$gold")
									if(D.materials[M] > linked_imprinter.gold_amount) check_materials = 0
								if("$diamond")
									if(D.materials[M] > linked_imprinter.diamond_amount) check_materials = 0
						else if (!linked_imprinter.reagents.has_reagent(M, D.materials[M]))
							check_materials = 0
					if (check_materials)
						dat += "* <A href='?src=\ref[src];imprint=[D.id]'>[temp_dat]</A><BR>"
					else
						dat += "* [temp_dat]<BR>"

			if(4.2)
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=4.1'>Imprinter Menu</A><HR>"
				dat += "Chemical Storage<BR><HR>"
				for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
					dat += "Name: [R.name] | Units: [R.volume] "
					dat += "<A href='?src=\ref[src];disposeI=[R.id]'>(Purge)</A><BR>"
					dat += "<A href='?src=\ref[src];disposeallI=1'><U>Disposal All Chemicals in Storage</U></A><BR>"

			if(4.3)
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Imprinter Menu</A><HR>"
				dat += "Material Storage<BR><HR>"
				//Glass
				dat += "* [linked_imprinter.g_amount] cm<sup>3</sup> of Glass || "
				dat += "Eject: "
				if(linked_imprinter.g_amount >= 3750) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=glass;imprinter_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_imprinter.g_amount >= 18750) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=glass;imprinter_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_imprinter.g_amount >= 3750) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=glass;imprinter_ejectsheet_amt=50'>(Max Sheets)</A>"
				dat += "<BR>"
				//Gold
				dat += "* [linked_imprinter.gold_amount] cm<sup>3</sup> of Gold || "
				dat += "Eject: "
				if(linked_imprinter.gold_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=gold;imprinter_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_imprinter.gold_amount >= 10000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=gold;imprinter_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_imprinter.gold_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=gold;imprinter_ejectsheet_amt=50'>(Max Sheets)</A>"
				dat += "<BR>"
				//Diamond
				dat += "* [linked_imprinter.diamond_amount] cm<sup>3</sup> of Diamond || "
				dat += "Eject: "
				if(linked_imprinter.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=diamond;imprinter_ejectsheet_amt=1'>(1 Sheet)</A> "
				if(linked_imprinter.diamond_amount >= 10000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=diamond;imprinter_ejectsheet_amt=5'>(5 Sheets)</A> "
				if(linked_imprinter.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=diamond;imprinter_ejectsheet_amt=50'>(Max Sheets)</A>"

		user << browse("<TITLE>Research and Development Console</TITLE><HR>[dat]", "window=rdconsole;size=575x400")
		onclose(user, "rdconsole")

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	id = 2
	req_access = null
	req_access_txt = "29"

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	id = 1