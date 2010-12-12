//The advanced pea-green monochrome lcd of tomorrow.

/obj/item/device/pda
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = 2.0
	flags = FPRINT | TABLEPASS | ONBELT

	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/mode = 0 //0-10, Main menu, Crew manifest, Engine monitor, Atmos scanner, med records, notes, sec records, messenger, mop locator, signaler, status display.
	var/scanmode = 0 //1 is medical scanner, 2 is forensics, 3 is reagent scanner.
	var/mmode = 0 //medical record viewing mode
	var/smode = 0 //Security record viewing mode???
	var/tmode = 0 //Texting mode, 1 to view recieved messages
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 3 //Luminosity for the flashlight function
	var/silent = 0 //To beep or not to beep, that is the question
	var/toff = 0 //If 1, messenger disabled
	var/tnote = null //Current Texts
	var/last_text //No text spamming
	var/last_honk //Also no honk spamming that's bad too
	var/ttone = "beep" //The ringtone!
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!" //Current note in the notepad function.
	var/datum/data/record/active1 = null //General
	var/datum/data/record/active2 = null //Medical
	var/datum/data/record/active3 = null //Security
	var/obj/item/weapon/integrated_uplink/uplink = null
	var/message1	// used for status_displays
	var/message2
	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above

/obj/item/device/pda/medical
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-m"

/obj/item/device/pda/engineering
	default_cartridge = /obj/item/weapon/cartridge/engineering
	icon_state = "pda-e"

/obj/item/device/pda/security
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-s"

/obj/item/device/pda/janitor
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-j"

/obj/item/device/pda/toxins
	default_cartridge = /obj/item/weapon/cartridge/signal/toxins
	icon_state = "pda-tox"
	ttone = "boom"

/obj/item/device/pda/clown
	default_cartridge = /obj/item/weapon/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/device/pda/mime
	default_cartridge = /obj/item/weapon/cartridge/mime
	icon_state = "pda-mime"
	silent = 1
	ttone = "silence"

/obj/item/device/pda/heads
	default_cartridge = /obj/item/weapon/cartridge/head
	icon_state = "pda-h"

/obj/item/device/pda/captain
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-c"
	toff = 1

/obj/item/device/pda/quartermaster
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-q"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/weapon/cartridge/syndicate
	icon_state = "pda-syn"
	name = "Military PDA"
	owner = "John Doe"
	toff = 1

/obj/item/device/pda/chaplain
	icon_state = "pda-holy"

/obj/item/weapon/cartridge
	name = "generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = 1

	var/access_security = 0
	var/access_engine = 0
	var/access_medical = 0
	var/access_manifest = 0
	var/access_clown = 0
	var/access_mime = 0
	var/access_janitor = 0
	var/access_reagent_scanner = 0
	var/access_remote_door = 0 //Control some blast doors remotely!!
	var/remote_door_id = ""
	var/access_status_display = 0
	var/access_quartermaster = 0
	var/access_hydroponics = 0

	// common cartridge procs

	// send a signal on a frequency
	proc/post_signal(var/freq, var/key, var/value, var/key2, var/value2, var/key3, var/value3)

		//world << "Post: [freq]: [key]=[value], [key2]=[value2]"
		var/datum/radio_frequency/frequency = radio_controller.return_frequency("[freq]")

		if(!frequency) return

		var/datum/signal/signal = new()
		signal.source = src
		signal.transmission_method = 1
		signal.data[key] = value
		if(key2)
			signal.data[key2] = value2
		if(key3)
			signal.data[key3] = value3

		frequency.post_signal(src, signal)


/obj/item/weapon/cartridge/engineering
	name = "Power-ON Cartridge"
	icon_state = "cart-e"
	access_engine = 1

/obj/item/weapon/cartridge/medical
	name = "Med-U Cartridge"
	icon_state = "cart-m"
	access_medical = 1

/obj/item/weapon/cartridge/security
	name = "R.O.B.U.S.T. Cartridge"
	icon_state = "cart-s"
	access_security = 1


	var/list/botlist = null		// list of bots
	var/obj/machinery/bot/secbot/active 	// the active bot; if null, show bot list
	var/list/botstatus			// the status signal sent by the bot

	var/control_freq = 1447

	// create a new QM cartridge, and register to receive bot control & beacon message
	New()
		..()
		spawn(5)
			if(radio_controller)
				radio_controller.add_object(src, "[control_freq]")

	// receive radio signals
	// can detect bot status signals
	// create/populate list as they are recvd

	receive_signal(datum/signal/signal)
		var/obj/item/device/pda/P = src.loc

		/*
		world << "recvd:[P] : [signal.source]"
		for(var/d in signal.data)
			world << "- [d] = [signal.data[d]]"
		*/
		if (signal.data["type"] == "secbot")
			if(!botlist)
				botlist = new()

			if(!(signal.source in botlist))
				botlist += signal.source

			if(active == signal.source)
				var/list/b = signal.data
				botstatus = b.Copy()

		if (istype(P)) P.updateSelfDialog()




	Topic(href, href_list)
		..()
		var/obj/item/device/pda/PDA = src.loc

		switch(href_list["op"])

			if("control")
				active = locate(href_list["bot"])
				post_signal(control_freq, "command", "bot_status", "active", active)

			if("scanbots")		// find all bots
				botlist = null
				post_signal(control_freq, "command", "bot_status")

			if("botlist")
				active = null
				PDA.updateSelfDialog()

			if("stop", "go")
				post_signal(control_freq, "command", href_list["op"], "active", active)
				post_signal(control_freq, "command", "bot_status", "active", active)

			if("summon")
				post_signal(control_freq, "command", "summon", "active", active, "target", get_turf(PDA) )
				post_signal(control_freq, "command", "bot_status", "active", active)

/obj/item/weapon/cartridge/janitor
	name = "CustodiPRO Cartridge"
	desc = "The ultimate in clean-room design."
	icon_state = "cart-j"
	access_janitor = 1

/obj/item/weapon/cartridge/clown
	name = "Honkworks 5.0"
	icon_state = "cart-clown"
	access_clown = 1
	var/honk_charges = 5

/obj/item/weapon/cartridge/mime
	name = "Gestur-O 1000"
	icon_state = "cart-mi"
	access_mime = 1
	var/mime_charges = 5

//Radio cart - Essentially a "one-way" signaler, does nothing with received signals.
/obj/item/weapon/cartridge/signal
	name = "generic signaler cartridge"
	desc = "A data cartridge with an integrated radio signaler module."
	var/frequency = 1457
	var/code = 30.0
	var/last_transmission
	var/datum/radio_frequency/radio_connection
	New()
		..()
		if(radio_controller)
			initialize()

/obj/item/weapon/cartridge/signal/toxins
	name = "Signal Ace 2"
	desc = "Complete with integrated radio signaler!"
	icon_state = "cart-tox"
	access_reagent_scanner = 1

/obj/item/weapon/cartridge/head
	name = "Easy-Record DELUXE"
	icon_state = "cart-h"
	access_manifest = 1
	access_engine = 1
	access_security = 1
	access_status_display = 1

/obj/item/weapon/cartridge/captain
	name = "Value-PAK Cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	access_manifest = 1
	access_engine = 1
	access_security = 1
	access_medical = 1
	access_reagent_scanner = 1
	access_status_display = 1

/obj/item/weapon/cartridge/quartermaster
	name = "Space Parts & Space Vendors Cartridge"
	desc = "Perfect for the Quartermaster on the go!"
	icon_state = "cart-q"
	access_quartermaster = 1

	var/list/botlist = null		// list of bots
	var/obj/machinery/bot/mulebot/active 	// the active bot; if null, show bot list
	var/list/botstatus			// the status signal sent by the bot
	var/list/beacons

	var/beacon_freq = 1445
	var/control_freq = 1447

	// create a new QM cartridge, and register to receive bot control & beacon message
	New()
		..()
		spawn(5)
			if(radio_controller)
				radio_controller.add_object(src, "[control_freq]")
				radio_controller.add_object(src, "[beacon_freq]")
				spawn(10)
					post_signal(beacon_freq, "findbeacon", "delivery")

	// receive radio signals
	// can detect bot status signals
	// and beacon locations
	// create/populate lists as they are recvd

	receive_signal(datum/signal/signal)
		var/obj/item/device/pda/P = src.loc

		/*
		world << "recvd:[P] : [signal.source]"
		for(var/d in signal.data)
			world << "- [d] = [signal.data[d]]"
		*/
		if(signal.data["type"] == "mulebot")
			if(!botlist)
				botlist = new()

			if(!(signal.source in botlist))
				botlist += signal.source

			if(active == signal.source)
				var/list/b = signal.data
				botstatus = b.Copy()

		else if(signal.data["beacon"])
			if(!beacons)
				beacons = new()

			beacons[signal.data["beacon"] ] = signal.source


		if(istype(P)) P.updateSelfDialog()




	Topic(href, href_list)
		..()
		var/obj/item/device/pda/PDA = src.loc
		var/cmd = "command"
		if(active) cmd = "command [active.suffix]"

		switch(href_list["op"])

			if("control")
				active = locate(href_list["bot"])
				post_signal(control_freq, cmd, "bot_status")

			if("scanbots")		// find all bots
				botlist = null
				post_signal(control_freq, "command", "bot_status")

			if("botlist")
				active = null
				PDA.updateSelfDialog()

			if("unload")
				post_signal(control_freq, cmd, "unload")
				post_signal(control_freq, cmd, "bot_status")
			if("setdest")
				if(beacons)
					var/dest = input("Select Bot Destination", "Mulebot [active.suffix] Interlink", active.destination) as null|anything in beacons
					if(dest)
						post_signal(control_freq, cmd, "target", "destination", dest)
						post_signal(control_freq, cmd, "bot_status")

			if("retoff")
				post_signal(control_freq, cmd, "autoret", "value", 0)
				post_signal(control_freq, cmd, "bot_status")
			if("reton")
				post_signal(control_freq, cmd, "autoret", "value", 1)
				post_signal(control_freq, cmd, "bot_status")

			if("pickoff")
				post_signal(control_freq, cmd, "autopick", "value", 0)
				post_signal(control_freq, cmd, "bot_status")
			if("pickon")
				post_signal(control_freq, cmd, "autopick", "value", 1)
				post_signal(control_freq, cmd, "bot_status")

			if("stop", "go", "home")
				post_signal(control_freq, cmd, href_list["op"])
				post_signal(control_freq, cmd, "bot_status")


/obj/item/weapon/cartridge/syndicate
	name = "Detomatix Cartridge"
	icon_state = "cart"
	access_remote_door = 1
	remote_door_id = "syndicate" //Make sure this matches the syndicate shuttle's shield/door id!!
	var/shock_charges = 4
/*
 *	Radio Cartridge, essentially a signaler.
 */


/obj/item/weapon/cartridge/signal/initialize()
	if (src.frequency < 1441 || src.frequency > 1489)
		src.frequency = sanitize_frequency(src.frequency)

	set_frequency(frequency)

/obj/item/weapon/cartridge/signal/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, "[frequency]")
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, "[frequency]")

/obj/item/weapon/cartridge/signal/proc/send_signal(message="ACTIVATE")

	if(last_transmission && world.time < (last_transmission + 5))
		return
	last_transmission = world.time

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = message

	radio_connection.post_signal(src, signal)

	return


/*
 *	The Actual PDA
 */

/obj/item/device/pda/pickup(mob/user)
	if (src.fon)
		src.sd_SetLuminosity(0)
		user.sd_SetLuminosity(user.luminosity + src.f_lum)

/obj/item/device/pda/dropped(mob/user)
	if (src.fon)
		user.sd_SetLuminosity(user.luminosity - src.f_lum)
		src.sd_SetLuminosity(src.f_lum)

/obj/item/device/pda/New()
	..()
	spawn(3)
	if (src.default_cartridge)
		src.cartridge = new src.default_cartridge(src)

/obj/item/device/pda/attack_self(mob/user as mob)
/*
	if (user.client) //load the PDA iconset into the client
		user << browse_rsc('pda_back.png')
		user << browse_rsc('pda_bell.png')
		user << browse_rsc('pda_blank.png')
		user << browse_rsc('pda_boom.png')
		user << browse_rsc('pda_bucket.png')
		user << browse_rsc('pda_crate.png')
		user << browse_rsc('pda_cuffs.png')
		user << browse_rsc('pda_eject.png')
		user << browse_rsc('pda_exit.png')
		user << browse_rsc('pda_flashlight.png')
		user << browse_rsc('pda_honk.png')
		user << browse_rsc('pda_mail.png')
		user << browse_rsc('pda_medical.png')
		user << browse_rsc('pda_menu.png')
		user << browse_rsc('pda_mule.png')
		user << browse_rsc('pda_notes.png')
		user << browse_rsc('pda_power.png')
		user << browse_rsc('pda_rdoor.png')
		user << browse_rsc('pda_reagent.png')
		user << browse_rsc('pda_refresh.png')
		user << browse_rsc('pda_scanner.png')
		user << browse_rsc('pda_signaler.png')
		user << browse_rsc('pda_status.png')*/


	user.machine = src

	var/dat = "<html><head><title>Personal Data Assistant</title></head><body bgcolor=\"#808000\"><style>a, a:link, a:visited, a:active, a:hover { color: #000000; }img {border-style:none;}</style>"

	dat += "<a href='byond://?src=\ref[src];close=1'><img src=pda_exit.png> Close</a>"

	if ((!isnull(src.cartridge)) && (!src.mode))
		dat += " | <a href='byond://?src=\ref[src];rc=1'><img src=pda_eject.png> Eject [src.cartridge]</a>"
	if (src.mode)
		dat += " | <a href='byond://?src=\ref[src];mm=1'><img src=pda_menu.png> Main Menu</a>"
		dat += " | <a href='byond://?src=\ref[src];refresh=1'><img src=pda_refresh.png> Refresh</a>"

	dat += "<br>"

	if (!src.owner)
		dat += "Warning: No owner information entered.  Please swipe card.<br><br>"
		dat += "<a href='byond://?src=\ref[src];refresh=1'><img src=pda_refresh.png> Retry</a>"
	else
		switch (src.mode)
			if (0)
				dat += "<h2>PERSONAL DATA ASSISTANT</h2>"
				dat += "Owner: [src.owner], [src.ownjob]<br>"
				dat += text("ID: <A href='?src=\ref[];auth=1'>[]</A>", src, (src.id ? "[src.id.registered], [src.id.assignment]" : "----------"))
				dat += "<br><br>"

				dat += "<h4>General Functions</h4>"
				dat += "<ul>"
				dat += "<li><a href='byond://?src=\ref[src];note=1'><img src=pda_notes.png> Notekeeper</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];mess=1'><img src=pda_mail.png> Messenger</a></li>"
				if (!isnull(src.cartridge) && src.cartridge.access_clown)
					dat += "<li><a href='byond://?src=\ref[src];honk=1'><img src=pda_honk.png> Honk Synthesizer</a></li>"

				if (!isnull(src.cartridge) && src.cartridge.access_manifest)
					dat += "<li><a href='byond://?src=\ref[src];cm=1'><img src=pda_notes.png> View Crew Manifest</a></li>"


				if(cartridge && cartridge.access_status_display)
					dat += "<li><a href='byond://?src=\ref[src];sd=1'><img src=pda_status.png> Set Status Display</a></li>"


				dat += "</ul>"

				if (!isnull(src.cartridge) && src.cartridge.access_engine)
					dat += "<h4>Engineering Functions</h4>"
					dat += "<ul>"
					dat += "<li><a href='byond://?src=\ref[src];em=1'><img src=pda_power.png> Power Monitor</a></li>"
					dat += "</ul>"

				if (!isnull(src.cartridge) && src.cartridge.access_medical)
					dat += "<h4>Medical Functions</h4>"
					dat += "<ul>"
					dat += "<li><a href='byond://?src=\ref[src];mr=1'><img src=pda_medical.png> Medical Records</a></li>"
					dat += "<li><a href='byond://?src=\ref[src];set_scanmode=1'><img src=pda_scanner.png> [src.scanmode == 1 ? "Disable" : "Enable"] Medical Scanner</a></li>"
					dat += "</ul>"

				if (!isnull(src.cartridge) && src.cartridge.access_security)
					dat += "<h4>Security Functions</h4>"
					dat += "<ul>"
					dat += "<li><a href='byond://?src=\ref[src];sr=1'><img src=pda_cuffs.png> Security Records</A></li>"
					dat += "<li><a href='byond://?src=\ref[src];set_scanmode=2'><img src=pda_scanner.png> [src.scanmode == 2 ? "Disable" : "Enable"] Forensic Scanner</a></li>"
					if(istype(cartridge, /obj/item/weapon/cartridge/security))
						dat += "<li><a href='byond://?src=\ref[src];secbot=1'><img src=pda_cuffs.png> Security Bot Access</a></li>"
					dat += "</ul>"

				if(cartridge && cartridge.access_quartermaster)
					dat += "<h4>Quartermaster Functions:</h4>"
					dat += "<ul>"
					dat += "<li><a href='byond://?src=\ref[src];suppshut=1'><img src=pda_crate.png> Supply Records</A></li>"
					dat += "<li><a href='byond://?src=\ref[src];mulectrl=1'><img src=pda_mule.png> Delivery Bot Control</A></li>"
					dat += "</ul>"

				dat += "<h4>Utilities</h4>"
				dat += "<ul>"
				if (!isnull(src.cartridge) && src.cartridge.access_janitor)
					dat += "<li><a href='byond://?src=\ref[src];jl=1'><img src=pda_bucket.png> Equipment Locator</a></li>"
				if (!isnull(src.cartridge) && (istype(src.cartridge, /obj/item/weapon/cartridge/signal)))
					dat += "<li><a href='byond://?src=\ref[src];sigmode=1'><img src=pda_signaler.png> Signaler System</a></li>"
				if (!isnull(src.cartridge) && src.cartridge.access_reagent_scanner)
					dat += "<li><a href='byond://?src=\ref[src];set_scanmode=3'><img src=pda_reagent.png> [src.scanmode == 3 ? "Disable" : "Enable"] Reagent Scanner</a></li>"
				//Remote shuttle shield control for syndies I guess
				if (!isnull(src.cartridge) && src.cartridge.access_remote_door)
					dat += "<li><a href='byond://?src=\ref[src];remotedoor=1'><img src=pda_rdoor.png> Toggle Remote Door</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];am=1'><img src=pda_atmos.png> Atmospheric Scan</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];flight=1'><img src=pda_flashlight.png> [src.fon ? "Disable" : "Enable"] Flashlight</a></li>"

				dat += "</ul>"

			if (1)

				dat += "<h4><img src=pda_notes.png> Crew Manifest</h4>"
				dat += "Entries cannot be modified from this terminal.<br><br>"

				for (var/datum/data/record/t in data_core.general)
					dat += "[t.fields["name"]] - [t.fields["rank"]]<br>"
				dat += "<br>"

			if (2)

				//muskets 250810
				//experimental PDA power monitoring code
				//mostly ripped off from the power monitor computer
				//powerreport, powerreportnodes, powerreportavail and powerreportviewload are new globals updated by the
				//power monitor computer
				//
				//only the first power computer to come online will update, if that breaks you can build another and it'll take over
				//an existing second power monitor should take over fine too
				//see changes to /game/machinery/computer/power.dm
				dat += "<h4><img src=pda_power.png> Power Monitor</h4>"

				if(!powerreport)
					dat += "\red No connection"
				else
					var/list/L = list()
					for(var/obj/machinery/power/terminal/term in powerreportnodes)
						if(istype(term.master, /obj/machinery/power/apc))
							var/obj/machinery/power/apc/A = term.master
							L += A

					dat += "<PRE>Total power: [powerreportavail] W<BR>Total load:  [num2text(powerreportviewload,10)] W<BR>"

					dat += "<FONT SIZE=-1>"

					if(L.len > 0)
						dat += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

						var/list/S = list(" Off","AOff","  On", " AOn")
						var/list/chg = list("N","C","F")

						for(var/obj/machinery/power/apc/A in L)
							dat += copytext(add_tspace(A.area.name, 30), 1, 30)
							dat += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

					dat += "</FONT></PRE>"

			if (3)

				dat += "<h4><img src=pda_atmos.png> Atmospheric Readings</h4>"

				var/turf/T = get_turf_or_move(user.loc)
				if (isnull(T))
					dat += "Unable to obtain a reading.<br>"
				else
					var/datum/gas_mixture/environment = T.return_air()

					var/pressure = environment.return_pressure()
					var/total_moles = environment.total_moles()

					dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

					if (total_moles)
						var/o2_level = environment.oxygen/total_moles
						var/n2_level = environment.nitrogen/total_moles
						var/co2_level = environment.carbon_dioxide/total_moles
						var/plasma_level = environment.toxins/total_moles
						var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

						dat += "Nitrogen: [round(n2_level*100)]%<br>"

						dat += "Oxygen: [round(o2_level*100)]%<br>"

						dat += "Carbon Dioxide: [round(co2_level*100)]%<br>"

						dat += "Plasma: [round(plasma_level*100)]%<br>"

						if(unknown_level > 0.01)
							dat += "OTHER: [round(unknown_level)]%<br>"

					dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"

				dat += "<br>"

			if (4)
				if (!src.mmode)

					dat += "<h4><img src=pda_medical.png> Medical Record List</h4>"
					for (var/datum/data/record/R in data_core.general)
						dat += "<a href='byond://?src=\ref[src];d_rec=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"
					dat += "<br>"

				else if (src.mmode)

					dat += "<h4><img src=pda_medical.png> Medical Record</h4>"

					dat += "<a href='byond://?src=\ref[src];pback=1'>Back</a><br>"

					if (istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1))
						dat += "Name: [src.active1.fields["name"]] ID: [src.active1.fields["id"]]<br>"
						dat += "Sex: [src.active1.fields["sex"]]<br>"
						dat += "Age: [src.active1.fields["age"]]<br>"
						dat += "Fingerprint: [src.active1.fields["fingerprint"]]<br>"
						dat += "Physical Status: [src.active1.fields["p_stat"]]<br>"
						dat += "Mental Status: [src.active1.fields["m_stat"]]<br>"
					else
						dat += "<b>Record Lost!</b><br>"

					dat += "<br>"

					dat += "<h4><img src=pda_medical.png> Medical Data</h4>"
					if (istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2))
						dat += "Blood Type: [src.active2.fields["b_type"]]<br><br>"

						dat += "Minor Disabilities: [src.active2.fields["mi_dis"]]<br>"
						dat += "Details: [src.active2.fields["mi_dis_d"]]<br><br>"

						dat += "Major Disabilities: [src.active2.fields["ma_dis"]]<br>"
						dat += "Details: [src.active2.fields["ma_dis_d"]]<br><br>"

						dat += "Allergies: [src.active2.fields["alg"]]<br>"
						dat += "Details: [src.active2.fields["alg_d"]]<br><br>"

						dat += "Current Diseases: [src.active2.fields["cdi"]]<br>"
						dat += "Details: [src.active2.fields["cdi_d"]]<br><br>"

						dat += "Important Notes: [src.active2.fields["notes"]]<br>"
					else
						dat += "<b>Record Lost!</b><br>"

					dat += "<br>"

			if (5)
				dat += "<h4><img src=pda_notes.png> Notekeeper V2.1</h4>"

				if ((!isnull(src.uplink)) && (src.uplink.active))
					dat += "<a href='byond://?src=\ref[src];lock_uplink=1'>Lock</a><br>"
				else
					dat += "<a href='byond://?src=\ref[src];editnote=1'>Edit</a><br>"

				dat += src.note

			if (6)
				if (!src.smode)

					dat += "<h4><img src=pda_cuffs.png> Security Record List</h4>"

					for (var/datum/data/record/R in data_core.general)
						dat += "<a href='byond://?src=\ref[src];d_rec=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"

					dat += "<br>"

				else if (src.smode)

					dat += "<h4><img src=pda_cuffs.png> Security Record</h4>"

					dat += "<a href='byond://?src=\ref[src];pback=1'><img src=pda_back.png> Back</a><br>"

					if (istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1))
						dat += "Name: [src.active1.fields["name"]] ID: [src.active1.fields["id"]]<br>"
						dat += "Sex: [src.active1.fields["sex"]]<br>"
						dat += "Age: [src.active1.fields["age"]]<br>"
						dat += "Fingerprint: [src.active1.fields["fingerprint"]]<br>"
						dat += "Physical Status: [src.active1.fields["p_stat"]]<br>"
						dat += "Mental Status: [src.active1.fields["m_stat"]]<br>"
					else
						dat += "<b>Record Lost!</b><br>"

					dat += "<br>"

					dat += "<h4><img src=pda_cuffs.png> Security Data</h4>"
					if (istype(src.active3, /datum/data/record) && data_core.security.Find(src.active3))
						dat += "Criminal Status: [src.active3.fields["criminal"]]<br>"

						dat += "Minor Crimes: [src.active3.fields["mi_crim"]]<br>"
						dat += "Details: [src.active3.fields["mi_crim"]]<br><br>"

						dat += "Major Crimes: [src.active3.fields["ma_crim"]]<br>"
						dat += "Details: [src.active3.fields["ma_crim_d"]]<br><br>"

						dat += "Important Notes:<br>"
						dat += "[src.active3.fields["notes"]]"
					else
						dat += "<b>Record Lost!</b><br>"

					dat += "<br>"

			if (7)

				dat += "<h4><img src=pda_mail.png> SpaceMessenger V3.9.4</h4>"

				if (!src.tmode)

					dat += "<a href='byond://?src=\ref[src];tfunc=1'><img src=pda_bell.png> Ringer: [src.silent == 1 ? "Off" : "On"]</a> | "
					dat += "<a href='byond://?src=\ref[src];tonoff=1'><img src=pda_mail.png> Send / Receive: [src.toff == 1 ? "Off" : "On"]</a> | "
					dat += "<a href='byond://?src=\ref[src];settone=1'><img src=pda_bell.png> Set Ringtone</a> | "
					dat += "<a href='byond://?src=\ref[src];pback=1'><img src=pda_mail.png> Messages</a><br>"

					if (istype(src.cartridge, /obj/item/weapon/cartridge/syndicate))
						dat+= "<b>[src.cartridge:shock_charges] detonation charges left.</b><HR>"

					if (istype(src.cartridge, /obj/item/weapon/cartridge/clown))
						dat+= "<b>[src.cartridge:honk_charges] viral files left.</b><HR>"

					if (istype(src.cartridge, /obj/item/weapon/cartridge/mime))
						dat+= "<b>[src.cartridge:mime_charges] viral files left.</b><HR>"

					dat += "<h4><img src=pda_menu.png> Detected PDAs</h4>"

					dat += "<ul>"

					var/count = 0

					if (!src.toff)
						for (var/obj/item/device/pda/P in world)
							if (!P.owner)
								continue
							else if (P == src)
								continue
							else if (P.toff)
								continue

							dat += "<li><a href='byond://?src=\ref[src];editnote=\ref[P]'>[P]</a>"

							if (istype(src.cartridge, /obj/item/weapon/cartridge/syndicate) && src.cartridge:shock_charges > 0)
								dat += " (<a href='byond://?src=\ref[src];detonate=\ref[P]'><img src=pda_boom.png> *detonate*</a>)"
								//Honk.exe is the poor man's detomatix
							if (istype(src.cartridge, /obj/item/weapon/cartridge/clown) && (src.cartridge:honk_charges > 0) && P.honkamt < 5)
								dat += " (<a href='byond://?src=\ref[src];sendhonk=\ref[P]'><img src=pda_honk.png> *Send Virus*</a>)"
							if (istype(src.cartridge, /obj/item/weapon/cartridge/mime) && (src.cartridge:mime_charges > 0) && P.mimeamt < 5)
								dat += " (<a href='byond://?src=\ref[src];sendmime=\ref[P]'> *Send Virus*</a>)"


							dat += "</li>"
							count++

					dat += "</ul>"

					if (count == 0)
						dat += "None detected.<br>"

				else
					dat += "<a href='byond://?src=\ref[src];tfunc=1'><img src=pda_blank.png> Clear</a> | "
					dat += "<a href='byond://?src=\ref[src];pback=1'><img src=pda_back.png> Back</a><br>"

					dat += "<h4><img src=pda_mail.png> Messages</h4>"

					dat += src.tnote
					dat += "<br>"
			if (8)

				dat += "<h4><img src=pda_bucket.png> Persistent Custodial Object Locator</h4>"

				var/turf/cl = get_turf(src)
				if (cl)
					dat += "Current Orbital Location: <b>\[[cl.x],[cl.y]\]</b>"

					dat += "<h4>Located Mops:</h4>"

					var/ldat
					for (var/obj/item/weapon/mop/M in world)
						var/turf/ml = get_turf(M)

						if (ml.z != cl.z)
							continue

						ldat += "Mop - <b>\[[ml.x],[ml.y]\]</b> - [M.reagents.total_volume ? "Wet" : "Dry"]<br>"

					if (!ldat)
						dat += "None"
					else
						dat += "[ldat]"

					dat += "<h4>Located Mop Buckets:</h4>"

					ldat = null
					for (var/obj/mopbucket/B in world)
						var/turf/bl = get_turf(B)

						if (bl.z != cl.z)
							continue

						ldat += "Bucket - <b>\[[bl.x],[bl.y]\]</b> - Water level: [B.reagents.total_volume]/50<br>"

					if (!ldat)
						dat += "None"
					else
						dat += "[ldat]"

					dat += "<h4>Located Cleanbots:</h4>"

					ldat = null
					for (var/obj/machinery/bot/cleanbot/B in world)
						var/turf/bl = get_turf(B)

						if (bl.z != cl.z)
							continue

						ldat += "Cleanbot - <b>\[[bl.x],[bl.y]\]</b> - [B.on ? "Online" : "Offline"]<br>"

					if (!ldat)
						dat += "None"
					else
						dat += "[ldat]"

				else
					dat += "ERROR: Unable to determine current location."

			if (9)
				if (!isnull(src.cartridge) && (istype(src.cartridge, /obj/item/weapon/cartridge/signal)))
					dat += "<h4><img src=pda_signaler.png> Remote Signaling System</h4>"

					dat += {"
<a href='byond://?src=\ref[src];ssend=1'>Send Signal</A><BR>

Frequency:
<a href='byond://?src=\ref[src];sfreq=-10'>-</a>
<a href='byond://?src=\ref[src];sfreq=-2'>-</a>
[format_frequency(src.cartridge:frequency)]
<a href='byond://?src=\ref[src];sfreq=2'>+</a>
<a href='byond://?src=\ref[src];sfreq=10'>+</a><br>
<br>
Code:
<a href='byond://?src=\ref[src];scode=-5'>-</a>
<a href='byond://?src=\ref[src];scode=-1'>-</a>
[src.cartridge:code]
<a href='byond://?src=\ref[src];scode=1'>+</a>
<a href='byond://?src=\ref[src];scode=5'>+</a><br>"}

				else
					dat += "ERROR: Unable to access cartridge signaler system.<br>Please check cartridge."

			if (10)		// status display

				dat += "<h4><img src=pda_status.png> Station Status Display Interlink</h4>"

				dat += "\[ <A HREF='?src=\ref[src];statdisp=blank'>Clear</A> \]<BR>"
				dat += "\[ <A HREF='?src=\ref[src];statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
				dat += "\[ <A HREF='?src=\ref[src];statdisp=message'>Message</A> \]"
				dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];statdisp=setmsg1'>[ message1 ? message1 : "(none)"]</A>"
				dat += "<li> Line 2: <A HREF='?src=\ref[src];statdisp=setmsg2'>[ message2 ? message2 : "(none)"]</A></ul><br>"
				dat += "\[ Alert: <A HREF='?src=\ref[src];statdisp=alert;alert=default'>None</A> |"
				dat += " <A HREF='?src=\ref[src];statdisp=alert;alert=redalert'>Red Alert</A> |"
				dat += " <A HREF='?src=\ref[src];statdisp=alert;alert=lockdown'>Lockdown</A> |"
				dat += " <A HREF='?src=\ref[src];statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR>"


			if(11)		// Quartermaster Supply Shuttle

				dat += "<h4><img src=pda_crate.png> Supply Record Interlink</h4>"

				dat += "<BR><B>Supply shuttle</B><BR>"
				dat += "Location: [supply_shuttle_moving ? "Moving to station ([supply_shuttle_timeleft] Mins.)":supply_shuttle_at_station ? "Station":"Dock"]<BR>"
				dat += "Current approved orders: <BR><ol>"
				for(var/S in supply_shuttle_shoppinglist)
					var/datum/supply_order/SO = S
					dat += "<li>[SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]</li>"
				dat += "</ol>"

				dat += "Current requests: <BR><ol>"
				for(var/S in supply_shuttle_requestlist)
					var/datum/supply_order/SO = S
					dat += "<li>[SO.object.name] requested by [SO.orderedby]</li>"
				dat += "</ol><font size=\"-3\">Upgrade NOW to Space Parts & Space Vendors PLUS for full remote order control and inventory management."


			if(12)		// Quartermaster mulebot control
				var/obj/item/weapon/cartridge/quartermaster/QC = cartridge
				if(!QC)
					dat += "Interlink Error - Please reinsert cartridge."
					return

				dat += "<h4><img src=pda_mule.png> M.U.L.E. bot Interlink V0.8</h4>"

				if(!QC.active)
					// list of bots
					if(!QC.botlist || (QC.botlist && QC.botlist.len==0))
						dat += "No bots found.<BR>"

					else
						for(var/obj/machinery/bot/mulebot/B in QC.botlist)
							dat += "<A href='byond://?src=\ref[QC];op=control;bot=\ref[B]'>[B] at [B.loc.loc]</A><BR>"



					dat += "<BR><A href='byond://?src=\ref[QC];op=scanbots'><img src=pda_scanner.png> Scan for active bots</A><BR>"

				else	// bot selected, control it


					dat += "<B>[QC.active]</B><BR> Status: (<A href='byond://?src=\ref[QC];op=control;bot=\ref[QC.active]'><img src=pda_refresh.png><i>refresh</i></A>)<BR>"

					if(!QC.botstatus)
						dat += "Waiting for response...<BR>"
					else

						dat += "Location: [QC.botstatus["loca"] ]<BR>"
						dat += "Mode: "

						switch(QC.botstatus["mode"])
							if(0)
								dat += "Ready"
							if(1)
								dat += "Loading/Unloading"
							if(2)
								dat += "Navigating to Delivery Location"
							if(3)
								dat += "Navigating to Home"
							if(4)
								dat += "Waiting for clear path"
							if(5,6)
								dat += "Calculating navigation path"
							if(7)
								dat += "Unable to locate destination"
						var/obj/crate/C = QC.botstatus["load"]
						dat += "<BR>Current Load: [ !C ? "<i>none</i>" : "[C.name] (<A href='byond://?src=\ref[QC];op=unload'><i>unload</i></A>)" ]<BR>"
						dat += "Destination: [!QC.botstatus["dest"] ? "<i>none</i>" : QC.botstatus["dest"] ] (<A href='byond://?src=\ref[QC];op=setdest'><i>set</i></A>)<BR>"
						dat += "Power: [QC.botstatus["powr"]]%<BR>"
						dat += "Home: [!QC.botstatus["home"] ? "<i>none</i>" : QC.botstatus["home"] ]<BR>"
						dat += "Auto Return Home: [QC.botstatus["retn"] ? "<B>On</B> <A href='byond://?src=\ref[QC];op=retoff'>Off</A>" : "(<A href='byond://?src=\ref[QC];op=reton'><i>On</i></A>) <B>Off</B>"]<BR>"
						dat += "Auto Pickup Crate: [QC.botstatus["pick"] ? "<B>On</B> <A href='byond://?src=\ref[QC];op=pickoff'>Off</A>" : "(<A href='byond://?src=\ref[QC];op=pickon'><i>On</i></A>) <B>Off</B>"]<BR><BR>"

						dat += "\[<A href='byond://?src=\ref[QC];op=stop'>Stop</A>\] "
						dat += "\[<A href='byond://?src=\ref[QC];op=go'>Proceed</A>\] "
						dat += "\[<A href='byond://?src=\ref[QC];op=home'>Return Home</A>\]<BR>"
						dat += "<HR><A href='byond://?src=\ref[QC];op=botlist'><img src=pda_back.png>Return to bot list</A>"

			if(13)		// Security Bot control
				var/obj/item/weapon/cartridge/security/SC = cartridge
				if(!SC)
					dat += "Interlink Error - Please reinsert cartridge."
					return

				dat += "<h4><img src=pda_cuffs.png> Securitron Interlink</h4>"

				if(!SC.active)
					// list of bots
					if(!SC.botlist || (SC.botlist && SC.botlist.len==0))
						dat += "No bots found.<BR>"

					else
						for(var/obj/machinery/bot/secbot/B in SC.botlist)
							dat += "<A href='byond://?src=\ref[SC];op=control;bot=\ref[B]'>[B] at [B.loc.loc]</A><BR>"



					dat += "<BR><A href='byond://?src=\ref[SC];op=scanbots'><img src=pda_scanner.png> Scan for active bots</A><BR>"

				else	// bot selected, control it


					dat += "<B>[SC.active]</B><BR> Status: (<A href='byond://?src=\ref[SC];op=control;bot=\ref[SC.active]'><img src=pda_refresh.png><i>refresh</i></A>)<BR>"

					if(!SC.botstatus)
						dat += "Waiting for response...<BR>"
					else

						dat += "Location: [SC.botstatus["loca"] ]<BR>"
						dat += "Mode: "

						switch(SC.botstatus["mode"])
							if(0)
								dat += "Ready"
							if(1)
								dat += "Apprehending target"
							if(2,3)
								dat += "Arresting target"
							if(4)
								dat += "Starting patrol"
							if(5)
								dat += "On patrol"
							if(6)
								dat += "Responding to summons"

						dat += "<BR>\[<A href='byond://?src=\ref[SC];op=stop'>Stop Patrol</A>\] "
						dat += "\[<A href='byond://?src=\ref[SC];op=go'>Start Patrol</A>\] "
						dat += "\[<A href='byond://?src=\ref[SC];op=summon'>Summon Bot</A>\]<BR>"
						dat += "<HR><A href='byond://?src=\ref[SC];op=botlist'><img src=pda_back.png>Return to bot list</A>"

	dat += "</body></html>"
	user << browse(dat, "window=pda")
	onclose(user, "pda", src)

/obj/item/device/pda/Topic(href, href_list)
	..()

	if (usr.contents.Find(src) || usr.contents.Find(src.master) || (istype(src.loc, /turf) && get_dist(src, usr) <= 1))
		if (usr.stat || usr.restrained())
			return

		src.add_fingerprint(usr)
		usr.machine = src

		if (href_list["auth"])
			if (src.id)
				if (istype(src.loc, /mob))
					var/obj/item/W = src.loc:equipped()
					var/emptyHand = (W == null)

					if(emptyHand)
						src.id.DblClick()
						if(!istype(src.id.loc, /obj/item/device/pda))

							src.id = null
			//			src.id.loc = src.loc
//				else if (istype(src.loc, /turf)) src.id.loc = src.loc
				else
					src.id.loc = src.loc
					src.id = null

			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					src.id = I

		if (href_list["mm"])
			src.mode = 0

		else if (href_list["cm"])
			src.mode = 1

		else if (href_list["am"])
			src.mode = 3

		else if (href_list["note"])
			src.mode = 5

		else if (href_list["mess"])
			src.mode = 7

		else if (href_list["sd"])
			src.mode = 10

		else if (href_list["suppshut"])
			src.mode = 11

		else if (href_list["mulectrl"])
			src.mode = 12

		else if (href_list["secbot"])
			mode = 13

		else if (href_list["flight"])
			src.fon = (!src.fon)

			if (usr.contents.Find(src))
				if (src.fon)
					usr.sd_SetLuminosity(usr.luminosity + src.f_lum)
				else
					usr.sd_SetLuminosity(usr.luminosity - src.f_lum)
			else
				src.sd_SetLuminosity(src.fon * src.f_lum)

			src.updateUsrDialog()

		else if (href_list["editnote"])
			if (src.mode == 5)
				var/n = input(usr, "Please enter message", src.name, src.note) as message
				if (!in_range(src, usr) && src.loc != usr)
					return
				n = copytext(adminscrub(n), 1, MAX_MESSAGE_LEN)
				if (src.mode == 5)
					src.note = n

			else if (src.mode == 7)
				var/t = input(usr, "Please enter message", src.name, null) as text
				t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
				if (!t)
					return
				if (!in_range(src, usr) && src.loc != usr)
					return

				var/obj/item/device/pda/P = locate(href_list["editnote"])

				if (isnull(P))
					return

				if (last_text && world.time < last_text + 5)
					return

				if (P.toff || src.toff)
					return

				last_text = world.time

				src.tnote += "<i><b>&rarr; To [P.owner]:</b></i><br>[t]<br>"
				P.tnote += "<i><b>&larr; From <a href='byond://?src=\ref[P];editnote=\ref[src]'>[src.owner]</a>:</b></i><br>[t]<br>"

				if (prob(15)) //Give the AI a chance of intercepting the message
					for (var/mob/living/silicon/ai/A in world)
						A.show_message("<i>Intercepted message from <b>[P:owner]</b>: [t]</i>")

				if (!P.silent)
					playsound(P.loc, 'twobeep.ogg', 50, 1)
					for (var/mob/O in hearers(3, P.loc))
						O.show_message(text("\icon[P] *[P.ttone]*"))

				P.overlays = null
				P.overlays += image('pda.dmi', "pda-r")

		else if (href_list["settone"])
			var/t = input(usr, "Please enter new ringtone", src.name, src.ttone) as text
			if (!in_range(src, usr) && src.loc != usr)
				return

			if (!t)
				return

			if ((src.uplink) && (cmptext(t,src.uplink.lock_code)) && (!src.uplink.active))
				usr << "The PDA softly beeps."
				src.uplink.unlock()
			else
				t = copytext(sanitize(t), 1, 20)
				src.ttone = t


		else if (href_list["refresh"])
			src.updateUsrDialog()

		else if (href_list["close"])
			usr << browse(null, "window=pda")
			usr.machine = null

		else if (href_list["d_rec"])
			var/datum/data/record/R = locate(href_list["d_rec"])
			var/datum/data/record/M = locate(href_list["d_rec"])
			var/datum/data/record/S = locate(href_list["d_rec"])

			if (data_core.general.Find(R))
				for (var/datum/data/record/E in data_core.medical)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						M = E
						break

				for (var/datum/data/record/E in data_core.security)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						S = E
						break

				src.active1 = R
				src.active2 = M
				src.active3 = S

			if (src.mode == 4)
				src.mmode = 1
			else
				src.smode = 1

		else if (href_list["pback"])
			if (src.mode == 4)
				src.mmode = 0
			if (src.mode == 7)
				src.tmode = !src.tmode
			else
				src.smode = 0

		else if (href_list["em"] && !isnull(src.cartridge) && src.cartridge.access_engine)
			src.mode = 2

		else if (href_list["mr"] && !isnull(src.cartridge) && src.cartridge.access_medical)
			src.mode = 4

		else if (href_list["sr"] && !isnull(src.cartridge) && src.cartridge.access_security)
			src.mode = 6

		else if (href_list["jl"] && !isnull(src.cartridge) && src.cartridge.access_janitor)
			src.mode = 8

		else if ((href_list["sigmode"]) && (!isnull(src.cartridge)) && (istype(src.cartridge, /obj/item/weapon/cartridge/signal)))
			src.mode = 9

		else if (href_list["set_scanmode"])
			var/smode = (text2num(href_list["set_scanmode"]))
			if (src.scanmode == smode)
				src.scanmode = 0

			else if ((smode == 1) && (!isnull(src.cartridge)) && (src.cartridge.access_medical))
				src.scanmode = 1

			else if ((smode == 2) && (!isnull(src.cartridge)) && (src.cartridge.access_security))
				src.scanmode = 2

			else if ((smode == 3) && (!isnull(src.cartridge)) && (src.cartridge.access_reagent_scanner))
				src.scanmode = 3

			src.updateUsrDialog()

		else if (href_list["detonate"] && istype(src.cartridge, /obj/item/weapon/cartridge/syndicate))
			var/obj/item/device/pda/P = locate(href_list["detonate"])
			if(P)
				if (!P.toff && src.cartridge:shock_charges > 0)
					src.cartridge:shock_charges--

					var/difficulty = 0

					if (!isnull(P.cartridge))
						difficulty += P.cartridge.access_medical
						difficulty += P.cartridge.access_security
						difficulty += P.cartridge.access_engine
						difficulty += P.cartridge.access_clown
						difficulty += P.cartridge.access_janitor
						difficulty += P.cartridge.access_manifest * 2
					else
						difficulty += 2

					if ((prob(difficulty * 12)) || (P.uplink))
						usr.show_message("\red An error flashes on your [src].", 1)
					else if (prob(difficulty * 3))
						usr.show_message("\red Energy feeds back into your [src]!", 1)
						src.explode()
					else
						usr.show_message("\blue Success!", 1)
						P.explode()
				src.updateUsrDialog()

		else if (href_list["sendhonk"] && istype(src.cartridge, /obj/item/weapon/cartridge/clown))
			var/obj/item/device/pda/P = locate(href_list["sendhonk"])
			if (!P.toff && src.cartridge:honk_charges > 0)
				src.cartridge:honk_charges--
				usr.show_message("\blue Virus sent!", 1)

				P.honkamt = (rand(15,20))
			src.updateUsrDialog()

		else if (href_list["sendmime"] && istype(src.cartridge, /obj/item/weapon/cartridge/mime))
			var/obj/item/device/pda/P = locate(href_list["sendmime"])
			if (!P.toff && src.cartridge:mime_charges > 0)
				src.cartridge:mime_charges--
				usr.show_message("\blue Virus sent!", 1)

				P.silent = 1
				P.ttone = "silence"
			src.updateUsrDialog()

		else if (href_list["remotedoor"] && !isnull(src.cartridge) && src.cartridge.access_remote_door)
			for (var/obj/machinery/door/poddoor/M in machines)
				if (M.id != src.cartridge.remote_door_id)
					continue
				if (M.density)
					spawn(0)
						M.open()
				else
					spawn(0)
						M.close()

		else if (href_list["rc"] && !isnull(src.cartridge))
			var/turf/T = src.loc
			if (ismob(T))
				T = T.loc

			src.cartridge.loc = T
			src.scanmode = 0
			src.mmode = 0
			src.smode = 0
			src.cartridge = null

		else if (href_list["tfunc"]) //If viewing texts then erase them, if not then toggle silent status
			if (src.tmode)
				src.tnote = null
				src.updateUsrDialog()

			else if (!src.tmode)
				src.silent = !src.silent
				src.updateUsrDialog()

		else if (href_list["tonoff"]) //toggle toff
			src.toff = !src.toff

		else if (href_list["lock_uplink"]) //Lock that uplink!!
			if(src.uplink)
				src.uplink.active = 0
				src.note = src.uplink.orignote
				src.updateUsrDialog()

		else if (href_list["honk"])
			if (last_honk && world.time < last_honk + 20)
				return
			playsound(src.loc, 'bikehorn.ogg', 50, 1)
			src.last_honk = world.time

		//Toxins PDA signaler stuff
		else if ((href_list["ssend"]) && (istype(src.cartridge,/obj/item/weapon/cartridge/signal)))
			for(var/obj/item/assembly/r_i_ptank/R in world) //Bomblist stuff
				if((R.part1.code == src.cartridge:code) && (R.part1.frequency == src.cartridge:frequency))
					bombers += "[key_name(usr)] has activated a radio bomb (Freq: [format_frequency(src.cartridge:frequency)], Code: [src.cartridge:code]). Temp = [R.part3.air_contents.temperature-T0C]."
			spawn( 0 )
				src.cartridge:send_signal("ACTIVATE")
				return

		else if ((href_list["sfreq"]) && (istype(src.cartridge,/obj/item/weapon/cartridge/signal)))
			var/new_frequency = sanitize_frequency(src.cartridge:frequency + text2num(href_list["sfreq"]))
			src.cartridge:set_frequency(new_frequency)

		else if ((href_list["scode"]) && (istype(src.cartridge,/obj/item/weapon/cartridge/signal)))
			src.cartridge:code += text2num(href_list["scode"])
			src.cartridge:code = round(src.cartridge:code)
			src.cartridge:code = min(100, src.cartridge:code)
			src.cartridge:code = max(1, src.cartridge:code)

		else if (href_list["statdisp"] && cartridge && cartridge.access_status_display)

			switch(href_list["statdisp"])
				if("message")
					post_status("message", message1, message2)
				if("alert")
					post_status("alert", href_list["alert"])

				if("setmsg1")
					message1 = input("Line 1", "Enter Message Text", message1) as text|null
					src.updateSelfDialog()
				if("setmsg2")
					message2 = input("Line 2", "Enter Message Text", message2) as text|null
					src.updateSelfDialog()
				else
					post_status(href_list["statdisp"])


		if (src.mode == 7 || src.tmode == 1)
			src.overlays = null

		if ((src.honkamt > 0) && (prob(60)))
			src.honkamt--
			playsound(src.loc, 'bikehorn.ogg', 30, 1)

		for (var/mob/M in viewers(1, src.loc))
			if (M.client && M.machine == src)
				src.attack_self(M)

// access to status display signals
/obj/item/device/pda/proc/post_status(var/command, var/data1, var/data2)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency("1435")

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)


/obj/item/device/pda/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if (istype(C, /obj/item/weapon/cartridge) && isnull(src.cartridge))
		user.drop_item()
		C.loc = src
		user << "\blue You insert [C] into [src]."
		src.cartridge = C
		src.updateUsrDialog()

	else if (istype(C, /obj/item/weapon/card/id) && !src.owner && C:registered)
		src.owner = C:registered
		src.ownjob = C:assignment
		src.name = "PDA-[src.owner]"
		user << "\blue Card scanned."
		src.updateUsrDialog()


/obj/item/device/pda/attack(mob/C as mob, mob/user as mob)
	if (istype(C, /mob/living/carbon))
		switch(src.scanmode)
			if(1)

				for (var/mob/O in viewers(C, null))
					O.show_message("\red [user] has analyzed [C]'s vitals!", 1)

				user.show_message("\blue Analyzing Results for [C]:")
				user.show_message("\blue \t Overall Status: [C.stat > 1 ? "dead" : "[C.health]% healthy"]", 1)
				user.show_message("\blue \t Damage Specifics: [C.oxyloss > 50 ? "\red" : "\blue"][C.oxyloss]-[C.toxloss > 50 ? "\red" : "\blue"][C.toxloss]-[C.fireloss > 50 ? "\red" : "\blue"][C.fireloss]-[C.bruteloss > 50 ? "\red" : "\blue"][C.bruteloss]", 1)
				user.show_message("\blue \t Key: Suffocation/Toxin/Burns/Brute", 1)
				user.show_message("\blue \t Body Temperature: [C.bodytemperature-T0C]&deg;C ([C.bodytemperature*1.8-459.67]&deg;F)", 1)
				if(C.virus)
					user.show_message(text("\red <b>Warning Virus Detected.</b>\nName: [C.virus.name].\nType: [C.virus.spread].\nStage: [C.virus.stage]/[C.virus.max_stages].\nPossible Cure: [C.virus.cure]"))

			if(2)
				if (!istype(C:dna, /datum/dna) || !isnull(C:gloves))
					user << "\blue No fingerprints found on [C]"
				else
					user << text("\blue [C]'s Fingerprints: [md5(C:dna.uni_identity)]")
				if ( !(C:blood_DNA) )
					user << "\blue No blood found on [C]"
				else
					user << "\blue Blood found on [C]. Analysing..."
					spawn(15)
						user << "\blue Blood type: [C:blood_type]\nDNA: [C:blood_DNA]"

/obj/item/device/pda/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
	if (src.scanmode == 2)
		if (!A.fingerprints)
			user << "\blue Unable to locate any fingerprints on [A]!"
		else
			var/list/L = params2list(A:fingerprints)
			user << "\blue Isolated [L.len] fingerprints."
			for(var/i in L)
				user << "\blue \t [i]"

	else if (src.scanmode == 3)
		if(!isnull(A.reagents))
			if(A.reagents.reagent_list.len > 0)
				var/reagents_length = A.reagents.reagent_list.len
				user << "\blue [reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found."
				for (var/re in A.reagents.reagent_list)
					user << "\blue \t [re]"
			else
				user << "\blue No active chemical agents found in [A]."
		else
			user << "\blue No significant chemical agents found in [A]."

	else if (!src.scanmode && istype(A, /obj/item/weapon/paper) && src.owner)
		if ((!isnull(src.uplink)) && (src.uplink.active))
			src.uplink.orignote = A:info
		else
			src.note = A:info
		user << "\blue Paper scanned." //concept of scanning paper copyright brainoblivion 2009

/obj/item/device/pda/proc/explode() //This needs tuning.

	var/turf/T = get_turf(src.loc)

	if (ismob(src.loc))
		var/mob/M = src.loc
		M.show_message("\red Your [src] explodes!", 1)

	if(T)
		T.hotspot_expose(700,125)

		explosion(T, -1, -1, 2, 3)

	del(src)
	return

/obj/item/device/pda/Del()
	if (src.id)
		if(istype(src.loc, /mob))
			src.id.loc = src.loc.loc
		else src.id.loc = src.loc
	..()

/obj/item/device/pda/clown/HasEntered(AM as mob|obj) //Clown PDA is slippery.
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if ((istype(M, /mob/living/carbon/human) && (istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP)) || M.m_intent == "walk")
			return

		if ((istype(M, /mob/living/carbon/human) && (M.real_name != src.owner) && (istype(src.cartridge, /obj/item/weapon/cartridge/clown))))
			if (src.cartridge:honk_charges < 5)
				src.cartridge:honk_charges++

		M.pulling = null
		M << "\blue You slipped on the PDA!"
		playsound(src.loc, 'slip.ogg', 50, 1, -3)
		M.stunned = 8
		M.weakened = 5


//AI verb and proc for sending PDA messages.

/mob/living/silicon/ai/verb/cmd_send_pdamesg()
	set category = "AI Commands"
	set name = "Send PDA Message"
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if(usr.stat == 2)
		usr << "You can't send PDA messages because you are dead!"
		return

	for (var/obj/item/device/pda/P in world)
		if (!P.owner)
			continue
		else if (P == src)
			continue
		else if (P.toff)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P

	var/c = input(usr, "Please select a PDA") as null|anything in plist

	if (!c)
		return

	var/selected = plist[c]
	ai_send_pdamesg(selected)

/mob/living/silicon/ai/proc/ai_send_pdamesg(obj/selected as obj)
	var/t = input(usr, "Please enter message", src.name, null) as text
	t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
	if (!t)
		return

	if (selected:toff)
		return

	usr.show_message("<i>PDA message to <b>[selected:owner]</b>: [t]</i>")
	selected:tnote += "<i><b>&larr; From (AI) [usr.name]:</b></i><br>[t]<br>"

	if (!selected:silent)
		playsound(selected.loc, 'twobeep.ogg', 50, 1)
		for (var/mob/O in hearers(3, selected.loc))
			O.show_message(text("\icon[selected] *[selected:ttone]*"))

	selected.overlays = null
	selected.overlays += image('pda.dmi', "pda-r")


//Some spare PDAs in a box

/obj/item/weapon/storage/PDAbox
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'pda.dmi'
	icon_state = "pdabox"
	item_state = "syringe_kit"

/obj/item/weapon/storage/PDAbox/New()
	..()
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)

	var/newcart = pick(1,2,3,4)
	switch(newcart)
		if(1)
			new /obj/item/weapon/cartridge/janitor(src)
		if(2)
			new /obj/item/weapon/cartridge/security(src)
		if(3)
			new /obj/item/weapon/cartridge/medical(src)
		if(4)
			new /obj/item/weapon/cartridge/head(src)

	new /obj/item/weapon/cartridge/signal/toxins(src)

/*
 *Experimental PDA traitor-uplink stuff
 */

//Syndicate uplink hidden inside a traitor PDA
/obj/item/weapon/integrated_uplink
	name = "uplink module"
	desc = "An electronic uplink system of unknown origin."
	icon = 'module.dmi'
	icon_state = "power_mod"
	var/uses = 10
	var/obj/item/device/pda/hostpda = null
	var/orignote = null //Restore original notes when locked.
	var/active = 0 //Are we currently active??
	var/menu_message = ""
	var/lock_code = "password" //What's the password?

//Communicate with traitor through the PDA's note function.
/obj/item/weapon/integrated_uplink/proc/print_to_host(var/text)
	if (isnull(src.hostpda))
		return
	src.hostpda.note = text

	for (var/mob/M in viewers(1, src.hostpda.loc))
		if (M.client && M.machine == src.hostpda)
			src.hostpda.attack_self(M)

	return

//Let's build a menu!
/obj/item/weapon/integrated_uplink/proc/generate_menu()
	src.menu_message = "<B>Syndicate Uplink Console:</B><BR>"
	src.menu_message += "Tele-Crystals left: [src.uses]<BR>"
	src.menu_message += "<HR>"
	src.menu_message += "<B>Request item:</B><BR>"
	src.menu_message += "<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=projector'>Chameleon-projector</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=revolver'>Revolver</A> (7)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=revolver_ammo'>Ammo-357</A> for use with Revolver (2)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=xbow'>Energy Crossbow</A> (5)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=empbox'>5 EMP Grenades</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=voice'>Voice-Changer</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=jump'>Chameleon Jumpsuit</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=card'>Syndicate Card</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=emag'>Electromagnet Card</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=imp_freedom'>Freedom Implant (with injector)</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=sleepypen'>Sleepy Pen</A> (5)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=cloak'>Cloaking Device</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=sword'>Energy Sword</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=bomb'>Low-Yield Bomb</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=powersink'>Power Sink</A> (5)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=detomatix'>Detomatix Cartridge</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=space'>Syndicate-made Space Suit (inludes a helmet)</A> (3)<BR>"
	src.menu_message += "<HR>"
	return

/obj/item/weapon/integrated_uplink/proc/unlock()
	if ((isnull(src.hostpda)) || (src.active))
		return

	src.orignote = src.hostpda.note
	src.active = 1
	src.hostpda.mode = 5 //Switch right to the notes program

	src.generate_menu()
	src.print_to_host(src.menu_message)
	return

/obj/item/weapon/integrated_uplink/Topic(href, href_list)
	if ((isnull(src.hostpda)) || (!src.active))
		return

	if (usr.stat || usr.restrained() || !in_range(src.hostpda, usr))
		return

	if (href_list["buy_item"])
		switch(href_list["buy_item"])
			if("revolver")
				if (src.uses >= 7)
					src.uses -= 7
					var/obj/item/weapon/gun/revolver/O = new /obj/item/weapon/gun/revolver(get_turf(src.hostpda))
					O.bullets = 7
			if("revolver_ammo")
				if (src.uses >= 2)
					src.uses -= 2
					new /obj/item/weapon/ammo/a357(get_turf(src.hostpda))
			if("xbow")
				if (src.uses >= 5)
					src.uses -= 5
					new /obj/item/weapon/gun/energy/crossbow(get_turf(src.hostpda))
			if("empbox")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/weapon/storage/emp_kit(get_turf(src.hostpda))
			if("voice")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/clothing/mask/gas/voice(get_turf(src.hostpda))
			if("jump")
				if (src.uses >= 3)
					src.uses -= 3
					new /obj/item/clothing/under/chameleon(get_turf(src.hostpda))
			if("card")
				if (src.uses >= 3)
					src.uses -= 3
					new /obj/item/weapon/card/id/syndicate(get_turf(src.hostpda))
			if("emag")
				if (src.uses >= 3)
					src.uses -= 3
					new /obj/item/weapon/card/emag(get_turf(src.hostpda))
			if("imp_freedom")
				if (src.uses >= 3)
					src.uses -= 3
					var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(get_turf(src.hostpda))
					O.imp = new /obj/item/weapon/implant/freedom(O)
			if("sleepypen")
				if (src.uses >= 5)
					src.uses -= 5
					new /obj/item/weapon/pen/sleepypen(get_turf(src.hostpda))
			if("projector")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/device/chameleon(get_turf(src.hostpda))
			if("cloak")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/weapon/cloaking_device(get_turf(src.hostpda))
			if("sword")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/weapon/sword(get_turf(src.hostpda))
			if("bomb")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/spawner/newbomb/timer/syndicate(get_turf(src.hostpda))
			if("powersink")
				if (src.uses >= 5)
					src.uses -= 5
					new /obj/item/device/powersink(get_turf(src.hostpda))
			if("detomatix")
				if (src.uses >= 3)
				 src.uses -= 3
				 new /obj/item/weapon/cartridge/syndicate(get_turf(src.hostpda))
			if("space")
				if (src.uses >= 3)
				 src.uses -= 3
				 new /obj/item/clothing/suit/space/syndicate(get_turf(src.hostpda))
				 new /obj/item/clothing/head/helmet/space/syndicate(get_turf(src.hostpda))
		src.generate_menu()
		src.print_to_host(src.menu_message)
		return

	return