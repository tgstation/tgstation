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
/obj/machinery/r_n_d  //All devices that link into the R&D console fall into thise type for easy identification.
	name = "R&D Device"
	density = 1
	anchored = 1
	var/obj/machinery/computer/rdconsole/linked_console

/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_state = "rdcomp"
	var
		datum/research/files							//Stores all the collected research data.
		obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
		obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.

		obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
		obj/machinery/r_n_d/protolathe/linked_lathe = null				//Linked Protolathe
		obj/machinery/r_n_d/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

		screen = 1.0	//Which screen is currently showing.
		sync = 1		//Will it get updated when the R&D console does it's syncing process.

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
			for(var/obj/machinery/r_n_d/D in orange(3,src))
				if(D.linked_console != null)
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


	New()
		..()
		files = new /datum/research(src) //Setup the research data holder.
		spawn(5)
			SyncRDevices()

	attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
		//The construction/deconstruction of the console code.
		if(istype(D, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/computerframe/A = new /obj/computerframe( src.loc )
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
					var/obj/computerframe/A = new /obj/computerframe( src.loc )
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
		src.updateUsrDialog()
		return

	Topic(href, href_list)
		if(..())
			return

		add_fingerprint(usr)

		usr.machine = src
		if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
			var/temp_screen = text2num(href_list["menu"])
			if(screen <= 1.1 || (3 <= temp_screen && 4.9 >= temp_screen) || src.allowed(usr)) //Unless you are making something, you need access.
				screen = temp_screen
			else
				usr << "Unauthorized Access."

		else if(href_list["updt_tech"]) //Update the research holder with information from the technology disk.
			screen = 0.0
			spawn(50)
				screen = 1.2
				files.AddTech2Known(t_disk.stored)
				updateUsrDialog()

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
			if(linked_destroy.busy)
				usr << "\red The destructive analyzer is busy at the moment."

			else
				linked_destroy.loaded_item:loc = linked_destroy.loc
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				screen = 2.1

		else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
			if(linked_destroy.busy)
				usr << "\red The destructive analyzer is busy at the moment."
			else
				var/choice = input("Proceeding will destroy loaded item.") in list("Proceed", "Cancel")
				linked_destroy.busy = 1
				if(choice == "Cancel") return
				screen = 0.1
				updateUsrDialog()
				flick("d_analyzer_process", linked_destroy)
				spawn(24)
					linked_destroy.busy = 0
					if(linked_destroy.reliability < 90)
						files.UpdateDesign(linked_destroy.loaded_item.type)
					for(var/T in linked_destroy.loaded_item.origin_tech)
						files.UpdateTech(T, linked_destroy.loaded_item.origin_tech[T])
					if(linked_lathe) //Also sends salvaged materials to a linked autolateh, if any.
						linked_lathe.m_amount = min(linked_lathe.max_m_amount, ((linked_lathe.m_amount + linked_destroy.loaded_item.m_amt)/2))
						linked_lathe.g_amount = min(linked_lathe.max_g_amount, ((linked_lathe.g_amount + linked_destroy.loaded_item.g_amt)/2))
					linked_destroy.loaded_item = null
					for(var/I in contents)
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
			spawn(30)
				for(var/obj/machinery/computer/rdconsole/C in world)
					if(C.sync)
						for(var/datum/tech/T in files.known_tech)
							C.files.AddTech2Known(T)
						for(var/datum/design/D in files.known_designs)
							C.files.AddDesign2Known(D)
					C.files.RefreshResearch()
				screen = 1.6
				updateUsrDialog()

		else if(href_list["togglesync"]) //Prevents the console from being synced by other consoles. Can still send data.
			sync = !sync

		else if(href_list["build"]) //Causes the Protolathe to build something.
			var/datum/design/being_built = null
			for(var/datum/design/D in files.known_designs)
				if(D.id == href_list["build"])
					being_built = D
					break
			var/power = max(2000, (text2num(href_list["metal"])+text2num(href_list["glass"]))/5)
			screen = 0.3
			linked_lathe.busy = 1
			flick("protolathe_n",linked_lathe)
			spawn(16)
				use_power(power)
				spawn(16)
					linked_lathe.m_amount -= text2num(href_list["metal"])
					linked_lathe.g_amount -= text2num(href_list["glass"])
					if(linked_lathe.m_amount < 0)
						linked_lathe.m_amount = 0
					if(linked_lathe.g_amount < 0)
						linked_lathe.g_amount = 0
					var/obj/new_item = new being_built.build_path(src)
					new_item.reliability = being_built.reliability
					new_item.loc = linked_lathe.loc
					linked_lathe.busy = 0
					screen = 3.1
					updateUsrDialog()

		else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
			linked_imprinter.busy = 1
			screen = 0.4
			updateUsrDialog()
			flick("circuit_imprinter_ani", linked_imprinter)
			spawn(16)
				var/datum/design/being_built = null
				for(var/datum/design/D in files.known_designs)
					if(D.id == href_list["imprint"])
						being_built = D
						break
				var/power = 0
				for(var/I in being_built.materials)
					switch(I)
						if("$glass")
							linked_imprinter.g_amount -= being_built.materials[I]
							power += being_built.materials[I] / 5
							if(linked_imprinter.g_amount < 0)
								linked_imprinter.g_amount = 0
						if("$metal")
							continue
						else
							linked_imprinter.reagents.remove_reagent(I, being_built.materials[I])
							power += being_built.materials[I]
				var/obj/new_item = new being_built.build_path(src)
				new_item.reliability = being_built.reliability
				use_power(power)
				new_item.loc = linked_imprinter.loc
				linked_imprinter.busy = 0
				screen = 4.1
				updateUsrDialog()

		else if(href_list["dispose"])  //Causes the circuit imprinter to dispose of a single reagent (all of it)
			linked_imprinter.reagents.del_reagent(href_list["dispose"])

		else if(href_list["disposeall"]) //Causes the circuit imprinter to dispose of all it's reagents.
			linked_imprinter.reagents.clear_reagents()

		else if(href_list["find_device"]) //The R&D console looks for devices nearby to link up with.
			screen = 0.0
			spawn(20)
				SyncRDevices()
				screen = 1.6
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

		updateUsrDialog()
		return

	attack_hand(mob/user as mob)
		if(stat & (BROKEN|NOPOWER))
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
				dat += "Disk Contents: (Technology Data Disk)<BR><BR>"
				if(t_disk.stored == null)
					dat += "The disk has no data stored on it.<HR>"
					dat += "Operations: "
					dat += "<A href='?src=\ref[src];menu=3.1'>Load Tech to Disk</A> || "
				else
					dat += "Name: [t_disk.stored.name]<BR>"
					dat += "Level: [t_disk.stored.level]<BR>"
					dat += "Description: [t_disk.stored.desc]<HR>"
					dat += "Operations: "
					dat += "<A href='?src=\ref[src];updt_tech=1'>Upload to Database</A> || "
					dat += "<A href='?src=\ref[src];clear_tech=1'>Clear Disk</A> || "
				dat += "<A href='?src=\ref[src];eject_tech=1'>Eject Disk</A><HR>"
				dat += "<BR><A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(1.3) //Technology Disk submenu
				dat += "Load Technology to Disk:<BR><BR>"
				for(var/datum/tech/T in files.known_tech)
					dat += "[T.name] "
					dat += "<A href='?src=\ref[src];copy_tech=1;copy_tech_ID=[T.id]'>(Copy to Disk)</A><BR>"
				dat += "<HR><BR><A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=3.0'>Return to Disk Operations</A>"

			if(1.4) //Design Disk menu.
				if(d_disk.blueprint == null)
					dat += "The disk has no data stored on it.<HR>"
					dat += "Operations: "
					dat += "<A href='?src=\ref[src];menu=4.1'>Load Design to Disk</A> || "
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
				dat += "<A href='?src=\ref[src];eject_design=1'>Eject Disk</A><HR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(1.5) //Technology disk submenu
				dat += "Load Design to Disk:<BR><BR>"
				for(var/datum/design/D in files.known_designs)
					dat += "[D.name] "
					dat += "<A href='?src=\ref[src];copy_design=1;copy_design_ID=[D.id]'>(Copy to Disk)</A><BR>"
				dat += "<HR><A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=3.0'>Return to Disk Operations</A>"

			if(1.6) //R&D console settings
				dat += "R&D Console Setting:<BR><BR>"
				dat += "<A href='?src=\ref[src];sync=1'>Sync Database with Network</A><BR>"
				if(sync) dat += "<A href='?src=\ref[src];togglesync=1'>Disconnect from Research Network</A><BR>"
				else dat += "<A href='?src=\ref[src];togglesync=1'>Connect to Research Network</A><BR>"
				dat += "<A href='?src=\ref[src];menu=1.7'>Device Linkage Menu</A><BR>"
				dat += "<A href='?src=\ref[src];lock=0.2'>Lock Console</A><BR>"
				dat += "<HR><A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(1.7) //R&D device linkage
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
				dat += "<HR><A href='?src=\ref[src];menu=1.6'>Settings Menu</A>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			////////////////////DESTRUCTIVE ANALYZER SCREENS////////////////////////////
			if(2.0)
				dat += "NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE<BR><BR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(2.1)
				dat += "No Item Loaded. Standing-by...<BR><HR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(2.2)
				dat += "Deconstruction Menu<HR>"
				dat += "Name: [linked_destroy.loaded_item.name]<BR>"
				dat += "Origin Tech:<BR>"
				for(var/T in linked_destroy.loaded_item.origin_tech)
					dat += "* [CallTechName(T)] [linked_destroy.loaded_item.origin_tech[T]]<BR>"
				dat += "<HR><A href='?src=\ref[src];deconstruct=1'>Deconstruct Item</A> || "
				dat += "<A href='?src=\ref[src];eject_item=1'>Eject Item</A> || "
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			/////////////////////PROTOLATHE SCREENS/////////////////////////
			if(3.0)
				dat += "NO PROTOLATHE LINKED TO CONSOLE<BR><BR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(3.1)
				dat += "Protolathe Menu:<BR><BR>"
				dat += "<B>Metal Amount:</B> [linked_lathe.m_amount] cm<sup>3</sup> (MAX: [linked_lathe.max_m_amount])<BR>"
				dat += "<B>Glass Amount:</B> [linked_lathe.g_amount] cm<sup>3</sup> (MAX: [linked_lathe.max_g_amount])<HR>"
				for(var/datum/design/D in files.known_designs)
					if(!(D.build_type & PROTOLATHE))
						continue
					var/temp_glass = 0
					var/temp_metal = 0
					if("$glass" in D.materials) temp_glass = D.materials["$glass"]
					if("$metal" in D.materials) temp_metal = D.materials["$metal"]
					if (linked_lathe.m_amount < temp_metal || linked_lathe.g_amount < temp_glass)
						dat += "[D.name] ([temp_metal]m || [temp_glass]g)<BR>"
					else
						dat += "<A href='?src=\ref[src];build=[D.id];glass=[temp_glass];metal=[temp_metal]'>[D.name] ([temp_metal]m || [temp_glass]g)</A><BR>"
				dat += "<HR><A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			///////////////////CIRCUIT IMPRINTER SCREENS////////////////////
			if(4.0)
				dat += "NO CIRCUIT IMPRINTER LINKED TO CONSOLE<BR><BR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(4.1)
				dat += "Circuit Imprinter Menu:<BR><BR>"
				dat += "Glass Amount: [linked_imprinter.g_amount] cm<sup>3</sup><BR>"
				dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

				for(var/datum/design/D in files.known_designs)
					if(!(D.build_type & IMPRINTER))
						continue
					var/temp_dat = "[D.name]"
					var/temp_glass = 0
					var/check_reagents = 1
					for(var/M in D.materials)
						temp_dat += " [D.materials[M]] [CallMaterialName(M)]"
						if(M == "$glass")
							temp_glass = D.materials[M]
						else if (copytext(M, 1, 2) != "$" && !linked_imprinter.reagents.has_reagent(M, D.materials[M]))
							check_reagents = 0
					if ((linked_imprinter.g_amount >= temp_glass) && check_reagents)
						dat += "* <A href='?src=\ref[src];imprint=[D.id]'>[temp_dat]</A><BR>"
					else
						dat += "* [temp_dat]<BR>"

				dat += "<HR><A href='?src=\ref[src];menu=4.2'>Chemical Storage</A> | "
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(4.2)
				dat += "Chemical Storage<BR><HR>"
				for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
					dat += "Name: [R.name] | Units: [R.volume] "
					dat += "<A href='?src=\ref[src];dispose=[R.id]'>(Purge)</A><BR>"
					dat += "<A href='?src=\ref[src];disposeall=1'><U>Disposal All Chemicals in Storage</U></A><BR>"
				dat += "<HR><A href='?src=\ref[src];menu=4.1'>Imprinter Menu</A> | "
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		user << browse("<TITLE>Research and Development Console</TITLE><HR>[dat]", "window=rdconsole;size=575x400")
		onclose(user, "rdconsole")