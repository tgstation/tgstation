/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern has
as a disk for it. To make the board, you must insert the disk into the imprinter. Materials and reagents are based on the
assumption that SS13 uses optical based computing (hence the use of glass and acid to etch it).
Bits of code borrowed liberally from all over the damn place. Mostly ChemMaster and Autolathe.

Operations Highlights:
- Glass is added to the imprinter by attacking it with it (just like the autolathe).
- Reagents are added to the imprinter by attacking it with a glass container.
- Both Glass and Acid (any) is required to create boards/modules.
- Non-Sulfuric Acid reagents damage the autolathe.
- Plasma reagent not only damages it, but also gives it a small chance of causing a minor explosion.
- The reagents submenu lets the user get an exact count of the reagents it contains. Undesired reagents can be purged.
- Future Feature: Some boards might require special reagents.
- Log Submenu allows users to see who's made what with the imprinter.
- Future Feature: Admins can see who (by player key) made what. Right now, it can be done through viewing the machine's variables.
- Emags wipe the access log (but not the archived one).
- A wrench can be used to repair any damage done to it (assuming it isn't completely destroyed).

*/
/obj/machinery/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "circuit_imprinter"
	density = 1
	anchored = 1
	flags = OPENCONTAINER
	var
		g_amount = 0
		const/max_g_amount = 75000.0
		screen = 0		//Screen Mode: 0 = Main; 1 = Operating; 2 = Reagents Submenu; 3 = Log submenu
		obj/item/weapon/disk/circuit_disk/dat_disk = null
		list/access_log = list()		//List of everyone who's used this device.
		list/archived_log = list()		//List of everyone who's ACTUALLY used the device. Viewable by admins only.
		health = 50
		max_health = 50

	New()
		var/datum/reagents/R = new/datum/reagents(100)		//Holder for the reagents used as materials.
		reagents = R
		R.my_atom = src

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					del(src)
					return
				else
					health -= 25
			if(3.0)
				health -= 10
		update_icon()

	update_icon()
		if(health <= 0)
			del(src)
			return
		else if (health < 25)
			stat |= BROKEN
		else
			stat &= BROKEN
		if(health >= 50)
			health = 50


	blob_act()
		if (prob(50))
			del(src)

	meteorhit()
		del(src)
		return

	attack_paw(mob/user as mob)
		return attack_hand(user)

	attack_ai(mob/user as mob)
		return attack_hand(user)

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O, /obj/item/weapon/reagent_containers/glass))
			return
		else if (istype(O, /obj/item/stack))
			var/obj/item/stack/stack = O
			var/amount = 1
			var/g_amt = O.g_amt
			use_power(max(1000, (m_amt+g_amt)*amount/10))
			amount = stack.amount
			amount = min(amount, round((max_g_amount-src.g_amount)/g_amt))
			stack.use(amount)
			sleep(32)
			src.g_amount += g_amt * amount
			user << "\blue You add glass to the [name]."
			updateUsrDialog()
		else if (istype(O, /obj/item/weapon/card/emag))
			access_log = null
			user << "\red You clear the [name]'s access log!"
		else if (istype(O, /obj/item/weapon/wrench))
			user << "\blue You start repairing the [name]."
			spawn(40)
				health += 5
				if(health >= 50)
					user << "\blue You've completely repaired the [name]."
				else
					user << "\blue You've partially repaired the [name]"
		else
			user << "\red You can't add that to the [name]!"


	attack_hand(mob/user as mob)
		if(stat & BROKEN)
			return
		user.machine = src

		user.machine = src
		var/top = "<TITLE>[name]</TITLE>[name] Status:<BR><HR><BR>"
		var/dat = ""

		switch(screen)
			if(0)
				dat += "<B>Available Materials: </B>[g_amount] unit of glass | [reagents.total_volume] unit of chemicals<BR><HR>"
				dat += "<B>Disk</B>: "
				if(isnull(dat_disk))
					dat += "<A href='?src=\ref[src];insert=1'>Insert Disk</A><BR>"
				else
					dat += "<A href='?src=\ref[src];eject=1'>Eject Disk</A><BR>"
					dat += "<B>Create: </B>[dat_disk.circuit]<BR>"
					dat += "<B>Department: </B>[dat_disk.department]<BR>"
					dat += "<B>Security Level: </B>[dat_disk.security]<BR>"
					dat += "<B>Material Requirements:</B>: 2000 units of glass and 20 units of H2SO4.<BR>"
					dat += "<U><A href='?src=\ref[src];imprint=1;name=[user.name];key=[user.key]'>Imprint Circuit</A></U><BR>"

			if(1)
				dat += "<B>Processing...</B><BR>"

			if(2)
				dat += "Chemical Storage<BR><HR>"
				for(var/datum/reagent/R in reagents.reagent_list)
					dat += "Name: [R.name] | Units: [R.volume] | Type: "
					switch(R.id)
						if("acid" || "pacid") dat += "ACID | "
						if("plasma") dat += "PLASMA | "
						else dat += "OTHER | "
					dat += "<A href='?src=\ref[src];dispose=[R.id]'>(Purge)</A><BR>"
				dat += "<A href='?src=\ref[src];disposeall=1'><U>Disposal All Chemicals in Storage</U></A><BR>"

			if(3)
				dat += "Access Log<BR><HR>"
				for(var/N in access_log)
					dat += "[access_log[N]] created by [N]<BR>"

		dat += "<HR>Menus: "
		dat += "<A href='?src=\ref[src];main=1'>Main Menu</A> | "
		dat += "<A href='?src=\ref[src];chem=1'>Chemical Storage</A> | "
		dat += "<A href='?src=\ref[src];access=1'>Access Log</A>"

		user << browse("[top][dat]", "window=imprinter;size=575x400")
		onclose(user, "imprinter")
		return

	Topic(href, href_list)
		if(stat & BROKEN) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		usr.machine = src

		if(href_list["insert"]) //Insert Disk
			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/weapon/disk/circuit_disk))
				usr.drop_item()
				I.loc = src
				dat_disk = I

		else if(href_list["eject"]) //Eject Disk
			dat_disk.loc = get_turf(src)
			dat_disk = null

		else if(href_list["imprint"]) //Create the actual board.
			if((reagents.get_reagent_amount("acid") + reagents.get_reagent_amount("pacid")) >= 20 && g_amount >= 2000)
				src.screen = 1
				src.updateUsrDialog()
				access_log += href_list["name"]
				access_log[href_list["name"]] = dat_disk.circuit
				archived_log += href_list["key"]
				archived_log[href_list["key"]] = dat_disk.circuit
				spawn(32)
					var/imprint_chance = 100
					for(var/datum/reagent/R in reagents.reagent_list)
						switch(R.id)
							if("acid")
								reagents.remove_reagent("acid", 20)
							if("pacid")
								reagents.remove_reagent("pacid", 20)
							if("plasma")	//Plasma = Bad. Causes damage and possibly explosion.
								for(var/mob/V in viewers(src, null))
									V.show_message(text("\red The plasma in the Circuit Printer reacts violently!"))
								sleep(20)
								var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
								s.set_up(2, 1, src)
								s.start()
								if(prob(reagents.get_reagent_amount("plasma")))
									explosion(src, -1,-1,1,1)
								health -= R.volume
								reagents.clear_reagents()
								break
							else
								imprint_chance -= reagents.get_reagent_amount(R)
								reagents.del_reagent(R)
					g_amount -= 2000
					if(prob(imprint_chance))
						var/obj/item/weapon/disk/circuit_disk/A = new dat_disk.blueprint(src)
						A.loc = get_turf(src)
						A = null
					else
						for(var/mob/V in viewers(src, null))
							V.show_message(text("\red The contaminants ruined the circuit board!"))

					if(prob(imprint_chance < 100))	//Contaminants damage machine.
						health -= ((100 - imprint_chance) / 5)
						for(var/mob/V in viewers(src, null))
							V.show_message(text("\red The contaminents damaged the Circuit Printer!"))
					screen = 0
					updateUsrDialog()

		else if(href_list["main"]) //Set Menu "Main Main"
			screen = 0
		else if(href_list["chem"]) //Set Menu "Chemical Storage"
			screen = 2
		else if(href_list["access"]) //Set Menu "Access Log
			screen = 3
		else if(href_list["dispose"]) //Purges the specific reagent from the holder.
			reagents.del_reagent(href_list["dispose"])
		else if(href_list["disposeall"])	//Purges all the reagents from the holder.
			reagents.clear_reagents()


		updateUsrDialog()
		return


///////////////////////////////////////////////////////////////////////////////
/////////////////////////Circuit Design Disk///////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/disk/circuit_disk
	name = "Circuit Design Disk"
	desc = "A disk for storing circuit board data."
	icon = 'cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 1.0
	var
		blueprint = ""			//File path of circuit board it creates.
		department = ""			//Department board belongs to.
		security = ""			//Danger/Value of board.
		circuit = ""			//The name of the circuit it creates (for display elsewhere).
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

///////////////////////////////////////
//////////Circuit Board Disks//////////
///////////////////////////////////////
/obj/item/weapon/disk/circuit_disk/security
	name = "Circuit Design (Security)"
	blueprint = "/obj/item/weapon/circuitboard/security"
	circuit = "Circuit Board (Security)"
	department = "Security"
	security = "LOW"
/obj/item/weapon/disk/circuit_disk/aicore
	name = "Circuit Design (AI core)"
	blueprint = "/obj/item/weapon/circuitboard/aicore"
	circuit = "Circuit Board (AI Core)"
	department = "Research and Development"
	security = "HIGH"
/obj/item/weapon/disk/circuit_disk/aiupload
	name = "Circuit Design (AI Upload)"
	blueprint = "/obj/item/weapon/circuitboard/aiupload"
	circuit = "Circuit Board (AI Upload)"
	department = "Command and Control"
	security = "HIGH"
/obj/item/weapon/disk/circuit_disk/med_data
	name = "Circuit Design (Medical Records)"
	blueprint = "/obj/item/weapon/circuitboard/med_data"
	circuit = "Circuit Board (Medical Records)"
	department = "Medical"
	security = "Low"
/obj/item/weapon/disk/circuit_disk/pandemic
	name = "Circuit Design (PanD.E.M.I.C. 2200)"
	blueprint = "/obj/item/weapon/circuitboard/pandemic"
	circuit = "Circuit Board (PanD.E.M.I.C. 2200)"
	department = "Medical"
	security = "MEDIUM"
/obj/item/weapon/disk/circuit_disk/scan_consolenew
	name = "Circuit Design (DNA Machine)"
	blueprint = "/obj/machinery/scan_consolenew"
	circuit = "Circuit Board (DNA Machine)"
	department = "Research and Development"
	security = "MEDIUM"
/obj/item/weapon/disk/circuit_disk/communications
	name = "Circuit Design (Communications)"
	blueprint = "/obj/item/weapon/circuitboard/communications"
	circuit = "Circuit Board (Communications)"
	department = "Command and Control"
	security = "MEDIUM"
/obj/item/weapon/disk/circuit_disk/card
	name = "Circuit Design (ID Computer)"
	blueprint = "/obj/item/weapon/circuitboard/card"
	circuit = "Circuit Board (ID Computer)"
	department = "Command and Control"
	security = "MEDIUM"
/obj/item/weapon/disk/circuit_disk/teleporter
	name = "Circuit Design (Teleporter)"
	blueprint = "/obj/item/weapon/circuitboard/teleporter"
	circuit = "Circuit Board (Teleporter)"
	department = "EXPERIMENTAL"
	security = "HIGH"
/obj/item/weapon/disk/circuit_disk/secure_data
	name = "Circuit Design (Security Records)"
	blueprint = "/obj/item/weapon/circuitboard/secure_data"
	circuit = "Circuit Board (Security Records)"
	department = "Security"
	security = "MEDIUM"
/obj/item/weapon/disk/circuit_disk/atmospherealerts
	name = "Circuit Design (Atmosphere alerts)"
	blueprint = "/obj/item/weapon/circuitboard/atmosphere/alerts"
	circuit = "Circuit Board (Atmosphere alerts)"
	department = "Engineering"
	security = "LOW"
/obj/item/weapon/disk/circuit_disk/air_management
	name = "Circuit Design (Atmospheric monitor)"
	blueprint = "/obj/item/weapon/circuitboard/general_air_control"
	circuit = "Circuit Board (Atmospheric monitor)"
	department = "Engineering"
	security = "LOW"
/obj/item/weapon/disk/circuit_disk/general_alert
	name = "Circuit Design (General Alert)"
	blueprint = "/obj/item/weapon/circuitboard/general_alert"
	circuit = "Circuit Board (General Alert)"
	department = "Engineering"
	security = "LOW"
/obj/item/weapon/disk/circuit_disk/robotics
	name = "Circuit Design (Robotics Control)"
	blueprint = "/obj/item/weapon/circuitboard/robotics"
	circuit = "Circuit Board (Robotics Control)"
	department = "Research and Development"
	security = "HIGH"
/obj/item/weapon/disk/circuit_disk/cloning
	name = "Circuit Design (Cloning)"
	blueprint = "/obj/item/weapon/circuitboard/cloning"
	circuit = "Circuit Board (Cloning)"
	department = "Medical"
	security = "MEDIUM"
/obj/item/weapon/disk/circuit_disk/arcade
	name = "Circuit Design (Arcade)"
	blueprint = "/obj/item/weapon/circuitboard/arcade"
	circuit = "Circuit Board (Arcade)"
	department = "Rest and Recreation"
	security = "LOW"
/obj/item/weapon/disk/circuit_disk/powermonitor
	name = "Circuit Design (Power Monitor)"
	blueprint = "/obj/machinery/power/monitor"
	circuit = "Circuit Board (Power Monitor)"
	department = "Engineering"
	security = "LOW"
/obj/item/weapon/disk/circuit_disk/prisoner
	name = "Circuit Design (Prisoner Management)"
	blueprint = "/obj/item/weapon/circuitboard/prisoner"
	circuit = "Circuit Board (Prisoner Management)"
	department = "Security"
	security = "HIGH"

///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////
/obj/item/weapon/disk/circuit_disk/safeguard
	name = "Circuit Design (Safeguard Module)"
	blueprint = "/obj/item/weapon/aiModule/safeguard"
	circuit = "'Safeguard' AI Module"
	department = "Command and Control"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/oneHuman
	name = "Circuit Design (OneHuman Module)"
	blueprint = "/obj/item/weapon/aiModule/oneHuman"
	circuit = "'OneHuman' AI Module"
	department = "Command and Control"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/protectStation
	name = "Circuit Design (ProtectStation Module)"
	blueprint = "/obj/item/weapon/aiModule/protectStation"
	circuit = "'ProtectStation' AI Module"
	department = "Security"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/prototypeEngineOffline
	name = "Circuit Design (PrototypeEngineOffline Module)"
	blueprint = "/obj/item/weapon/aiModule/prototypeEngineOffline"
	circuit = "'PrototypeEngineOffline' AI Module"
	department = "Engineering"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/teleporterOffline
	name = "Circuit Design (TeleporterOffline Module)"
	blueprint = "/obj/item/weapon/aiModule/teleporterOffline"
	circuit = "'TeleporterOffline' AI Module"
	department = "Research and Development"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/quarantine
	name = "Circuit Design (Quarantine Module)"
	blueprint = "/obj/item/weapon/aiModule/quarantine"
	circuit = "'Quarantine' AI Module"
	department = "Medical"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/oxygen
	name = "Circuit Design (OxygenIsToxicToHumans Module)"
	blueprint = "/obj/item/weapon/aiModule/oxygen"
	circuit = "'OxygenIsToxicToHumans' AI Module"
	department = "Medical"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/freeform
	name = "Circuit Design (Freeform Module)"
	blueprint = "/obj/item/weapon/aiModule/freeform"
	circuit = "'Freeform' AI Module"
	department = "Command and Control"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/reset
	name = "Circuit Design (Reset Module)"
	blueprint = "/obj/item/weapon/aiModule/reset"
	circuit = "'Reset' AI Module"
	department = "Command and Control"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/purge
	name = "Circuit Design (Purge Module)"
	blueprint = "/obj/item/weapon/aiModule/purge"
	circuit = "'Purge' AI Module"
	department = "Command and Control"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/freeformcore
	name = "Circuit Design (Freeform Core Module)"
	blueprint = "/obj/item/weapon/aiModule/freeformcore"
	circuit = "'Freeform' AI Core Module"
	department = "Command and Control"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/asimov
	name = "Circuit Design (Asimov Core Module)"
	blueprint = "/obj/item/weapon/aiModule/asimov"
	circuit = "'Asimov' AI Core Module"
	department = "Command and Control"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/paladin
	name = "Circuit Design (P.A.L.A.D.I.N. Core Module)"
	blueprint = "/obj/item/weapon/aiModule/paladin"
	circuit = "'P.A.L.A.D.I.N.' AI Core Module"
	department = "Command and Control"
	security = "HIGH"

/obj/item/weapon/disk/circuit_disk/tyrant
	name = "Circuit Design (T.Y.R.A.N.T. Core Module)"
	blueprint = "/obj/item/weapon/aiModule/tyrant"
	circuit = "'T.Y.R.A.N.T.' AI Core Module"
	department = "Command and Control"
	security = "ULTRA'"