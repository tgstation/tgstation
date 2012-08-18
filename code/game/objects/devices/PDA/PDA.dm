
//The advanced pea-green monochrome lcd of tomorrow.

var/global/list/obj/item/device/pda/PDAs = list()


/obj/item/device/pda
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_ID | SLOT_BELT

	//Main variables
	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/mode = 0 //Controls what menu the PDA will display. 0 is hub; the rest are either built in or based on cartridge.

	//Secondary variables
	var/scanmode = 0 //1 is medical scanner, 2 is forensics, 3 is reagent scanner.
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 4 //Luminosity for the flashlight function
	var/silent = 0 //To beep or not to beep, that is the question
	var/toff = 0 //If 1, messenger disabled
	var/tnote = null //Current Texts
	var/last_text //No text spamming
	var/last_honk //Also no honk spamming that's bad too
	var/ttone = "beep" //The ringtone!
	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""
	var/cart = "" //A place to stick cartridge menu information
	var/detonate = 1 // Can the PDA be blown up?

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above

	var/obj/item/device/paicard/pai = null	// A slot for a personal AI device

/obj/item/device/pda/medical
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-m"

/obj/item/device/pda/engineering
	default_cartridge = /obj/item/weapon/cartridge/engineering
	icon_state = "pda-e"

/obj/item/device/pda/security
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-s"

/obj/item/device/pda/detective
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon_state = "pda-det"

/obj/item/device/pda/warden
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/janitor
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-j"
	ttone = "slip"

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

/obj/item/device/pda/heads/hop
	default_cartridge = /obj/item/weapon/cartridge/hop
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hos
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/ce
	default_cartridge = /obj/item/weapon/cartridge/ce
	icon_state = "pda-ce"

/obj/item/device/pda/heads/cmo
	default_cartridge = /obj/item/weapon/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/device/pda/heads/rd
	default_cartridge = /obj/item/weapon/cartridge/rd
	icon_state = "pda-rd"

/obj/item/device/pda/captain
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-c"
	toff = 1

/obj/item/device/pda/cargo
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/quartermaster
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-q"

/obj/item/device/pda/shaftminer
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/weapon/cartridge/syndicate
	icon_state = "pda-syn"
	name = "Military PDA"
	owner = "John Doe"
	toff = 1

/obj/item/device/pda/chaplain
	icon_state = "pda-holy"
	ttone = "holy"

/obj/item/device/pda/lawyer
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer"
	ttone = "objection"

/obj/item/device/pda/botanist
	//default_cartridge = /obj/item/weapon/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	icon_state = "pda-robot"

/obj/item/device/pda/librarian
	icon_state = "pda-libb"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	silent = 1 //Quiet in the library!


/obj/item/device/pda/chef
	icon_state = "pda-chef"

/obj/item/device/pda/bar
	icon_state = "pda-bar"

/obj/item/device/pda/atmos
	icon_state = "pda-atmo"

/obj/item/device/pda/chemist
	default_cartridge = /obj/item/weapon/cartridge/chemistry
	icon_state = "pda-chem"

/obj/item/device/pda/geneticist
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-gene"

// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/ai
	icon_state = "NONE"
	ttone = "data"
	detonate = 0

/obj/item/device/pda/pai
	icon_state = "NONE"
	ttone = "data"
	detonate = 0

/obj/item/device/pda/ai/attack_self(mob/user as mob)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return

/*
 *	The Actual PDA
 */
/obj/item/device/pda/pickup(mob/user)
	if (fon)
		sd_SetLuminosity(0)
		user.total_luminosity += f_lum

/obj/item/device/pda/dropped(mob/user)
	if (fon)
		user.total_luminosity -= f_lum
		sd_SetLuminosity(f_lum)

/obj/item/device/pda/New()
	..()
	PDAs += src
	spawn(3)
	if (default_cartridge)
		cartridge = new default_cartridge(src)

/obj/item/device/pda/proc/can_use()

	if(istype(src, /obj/item/device/pda/ai) || istype(src, /obj/item/device/pda/pai))
		return 1
	if(!ismob(loc))
		return 0

	var/mob/M = loc
	if(!M.canmove)
		return 0
	if((src in M.contents) || ( istype(loc, /turf) && in_range(src, M) ))
		return 1
	else
		return 0

/obj/item/device/pda/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /obj/screen)) && !M.restrained() && !M.stat && can_use())
		return attack_self(M)
	return

//NOTE: graphic resources are loaded on client login
/obj/item/device/pda/attack_self(mob/user as mob)

	user.machine = src

	if(active_uplink_check(user))
		return

	var/dat = "<html><head><title>Personal Data Assistant</title></head><body bgcolor=\"#808000\"><style>a, a:link, a:visited, a:active, a:hover { color: #000000; }img {border-style:none;}</style>"

	dat += "<a href='byond://?src=\ref[src];choice=Close'><img src=pda_exit.png> Close</a>"

	if ((!isnull(cartridge)) && (mode == 0))
		dat += " | <a href='byond://?src=\ref[src];choice=Eject'><img src=pda_eject.png> Eject [cartridge]</a>"
	if (mode)
		dat += " | <a href='byond://?src=\ref[src];choice=Return'><img src=pda_menu.png> Return</a>"
	dat += " | <a href='byond://?src=\ref[src];choice=Refresh'><img src=pda_refresh.png> Refresh</a>"

	dat += "<br>"

	if (!owner)
		dat += "Warning: No owner information entered.  Please swipe card.<br><br>"
		dat += "<a href='byond://?src=\ref[src];choice=Refresh'><img src=pda_refresh.png> Retry</a>"
	else
		switch (mode)
			if (0)
				dat += "<h2>PERSONAL DATA ASSISTANT v.1.2</h2>"
				dat += "Owner: [owner], [ownjob]<br>"
				dat += text("ID: <A href='?src=\ref[src];choice=Authenticate'>[id ? "[id.registered_name], [id.assignment]" : "----------"]")
				dat += text("<br><A href='?src=\ref[src];choice=UpdateInfo'>[id ? "Update PDA Info" : ""]</A><br>")

				dat += "Station Time: [worldtime2text()]"//:[world.time / 100 % 6][world.time / 100 % 10]"

				dat += "<br><br>"

				dat += "<h4>General Functions</h4>"
				dat += "<ul>"
				dat += "<li><a href='byond://?src=\ref[src];choice=1'><img src=pda_notes.png> Notekeeper</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];choice=2'><img src=pda_mail.png> Messenger</a></li>"
				//dat += "<li><a href='byond://?src=\red[src];choice=chatroom'><img src=pda_chatroom.png> Nanotrasen Relay Chat</a></li>"

				if (cartridge)
					if (cartridge.access_clown)
						dat += "<li><a href='byond://?src=\ref[src];choice=Honk'><img src=pda_honk.png> Honk Synthesizer</a></li>"
					if (cartridge.access_manifest)
						dat += "<li><a href='byond://?src=\ref[src];choice=41'><img src=pda_notes.png> View Crew Manifest</a></li>"
					if(cartridge.access_status_display)
						dat += "<li><a href='byond://?src=\ref[src];choice=42'><img src=pda_status.png> Set Status Display</a></li>"
					dat += "</ul>"
					if (cartridge.access_engine)
						dat += "<h4>Engineering Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=\ref[src];choice=43'><img src=pda_power.png> Power Monitor</a></li>"
						dat += "</ul>"
					if (cartridge.access_medical)
						dat += "<h4>Medical Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=\ref[src];choice=44'><img src=pda_medical.png> Medical Records</a></li>"
						dat += "<li><a href='byond://?src=\ref[src];choice=Medical Scan'><img src=pda_scanner.png> [scanmode == 1 ? "Disable" : "Enable"] Medical Scanner</a></li>"
						dat += "</ul>"
					if (cartridge.access_security)
						dat += "<h4>Security Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=\ref[src];choice=45'><img src=pda_cuffs.png> Security Records</A></li>"
						dat += "<li><a href='byond://?src=\ref[src];choice=Forensic Scan'><img src=pda_scanner.png> [scanmode == 2 ? "Disable" : "Enable"] Forensic Scanner</a></li>"
					if(istype(cartridge.radio, /obj/item/radio/integrated/beepsky))
						dat += "<li><a href='byond://?src=\ref[src];choice=46'><img src=pda_cuffs.png> Security Bot Access</a></li>"
						dat += "</ul>"
					else	dat += "</ul>"
					if(cartridge.access_quartermaster)
						dat += "<h4>Quartermaster Functions:</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=\ref[src];choice=47'><img src=pda_crate.png> Supply Records</A></li>"
						dat += "<li><a href='byond://?src=\ref[src];choice=48'><img src=pda_mule.png> Delivery Bot Control</A></li>"
						dat += "</ul>"
				dat += "</ul>"

				dat += "<h4>Utilities</h4>"
				dat += "<ul>"
				if (cartridge)
					if (cartridge.access_janitor)
						dat += "<li><a href='byond://?src=\ref[src];choice=49'><img src=pda_bucket.png> Equipment Locator</a></li>"
					if (istype(cartridge.radio, /obj/item/radio/integrated/signal))
						dat += "<li><a href='byond://?src=\ref[src];choice=40'><img src=pda_signaler.png> Signaler System</a></li>"
					if (cartridge.access_reagent_scanner)
						dat += "<li><a href='byond://?src=\ref[src];choice=Reagent Scan'><img src=pda_reagent.png> [scanmode == 3 ? "Disable" : "Enable"] Reagent Scanner</a></li>"
					if (cartridge.access_engine)
						dat += "<li><a href='byond://?src=\ref[src];choice=Halogen Counter'><img src=pda_reagent.png> [scanmode == 4 ? "Disable" : "Enable"] Halogen Counter</a></li>"
					if (cartridge.access_remote_door)
						dat += "<li><a href='byond://?src=\ref[src];choice=Toggle Door'><img src=pda_rdoor.png> Toggle Remote Door</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];choice=3'><img src=pda_atmos.png> Atmospheric Scan</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];choice=Light'><img src=pda_flashlight.png> [fon ? "Disable" : "Enable"] Flashlight</a></li>"
				if (pai)
					if(pai.loc != src)
						pai = null
					else
						dat += "<li><a href='byond://?src=\ref[src];choice=pai;option=1'>pAI Device Configuration</a></li>"
						dat += "<li><a href='byond://?src=\ref[src];choice=pai;option=2'>Eject pAI Device</a></li>"
				dat += "</ul>"

			if (1)
				dat += "<h4><img src=pda_notes.png> Notekeeper V2.1</h4>"
				dat += "<a href='byond://?src=\ref[src];choice=Edit'> Edit</a><br>"
				dat += note

			if (2)
				dat += "<h4><img src=pda_mail.png> SpaceMessenger V3.9.4</h4>"
				dat += "<a href='byond://?src=\ref[src];choice=Toggle Ringer'><img src=pda_bell.png> Ringer: [silent == 1 ? "Off" : "On"]</a> | "
				dat += "<a href='byond://?src=\ref[src];choice=Toggle Messenger'><img src=pda_mail.png> Send / Receive: [toff == 1 ? "Off" : "On"]</a> | "
				dat += "<a href='byond://?src=\ref[src];choice=Ringtone'><img src=pda_bell.png> Set Ringtone</a> | "
				dat += "<a href='byond://?src=\ref[src];choice=21'><img src=pda_mail.png> Messages</a><br>"

				if (istype(cartridge, /obj/item/weapon/cartridge/syndicate))
					dat += "<b>[cartridge:shock_charges] detonation charges left.</b><HR>"
				if (istype(cartridge, /obj/item/weapon/cartridge/clown))
					dat += "<b>[cartridge:honk_charges] viral files left.</b><HR>"
				if (istype(cartridge, /obj/item/weapon/cartridge/mime))
					dat += "<b>[cartridge:mime_charges] viral files left.</b><HR>"

				dat += "<h4><img src=pda_menu.png> Detected PDAs</h4>"

				dat += "<ul>"

				var/count = 0

				if (!toff)
					for (var/obj/item/device/pda/P in sortAtom(PDAs))
						if (!P.owner||P.toff||P == src)	continue
						dat += "<li><a href='byond://?src=\ref[src];choice=Message;target=\ref[P]'>[P]</a>"
						if (istype(cartridge, /obj/item/weapon/cartridge/syndicate) && P.detonate)
							dat += " (<a href='byond://?src=\ref[src];choice=Detonate;target=\ref[P]'><img src=pda_boom.png>*Detonate*</a>)"
						if (istype(cartridge, /obj/item/weapon/cartridge/clown))
							dat += " (<a href='byond://?src=\ref[src];choice=Send Honk;target=\ref[P]'><img src=pda_honk.png>*Send Virus*</a>)"
						if (istype(cartridge, /obj/item/weapon/cartridge/mime))
							dat += " (<a href='byond://?src=\ref[src];choice=Send Silence;target=\ref[P]'>*Send Virus*</a>)"
						dat += "</li>"
						count++
				dat += "</ul>"
				if (count == 0)
					dat += "None detected.<br>"

			if(21)
				dat += "<h4><img src=pda_mail.png> SpaceMessenger V3.9.4</h4>"
				dat += "<a href='byond://?src=\ref[src];choice=Clear'><img src=pda_blank.png> Clear Messages</a>"

				dat += "<h4><img src=pda_mail.png> Messages</h4>"

				dat += tnote
				dat += "<br>"

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

			if (5)
				dat += "<h4><img src=pda_chatroom.png> Nanotrasen Relay Chat</h4>"

				dat += "<h4><img src=pda_menu.png> Detected Channels</h4>: <li>"
				for(var/datum/chatroom/C in chatrooms)
					dat += "<a href='byond://?src=\ref[src];pdachannel=[C.name]'>#[html_encode(lowertext(C.name))]"
					if(C.password != "")
						dat += " <img src=pda_locked.png>"
					dat += "</li>"



			else//Else it links to the cart menu proc. Although, it really uses menu hub 4--menu 4 doesn't really exist as it simply redirects to hub.
				dat += cart

	dat += "</body></html>"
	user << browse(dat, "window=pda;size=400x444;border=1;can_resize=1;can_close=0;can_minimize=0")
	onclose(user, "pda", src)

/obj/item/device/pda/Topic(href, href_list)
	..()
	var/mob/living/U = usr
	//Looking for master was kind of pointless since PDAs don't appear to have one.
	//if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ) )

	if(can_use()) //Why reinvent the wheel? There's a proc that does exactly that.
		if ( !(U.stat || U.restrained()) )

			add_fingerprint(U)
			U.machine = src

			switch(href_list["choice"])

//BASIC FUNCTIONS===================================

				if("Close")//Self explanatory
					U.machine = null
					U << browse(null, "window=pda")
					return
				if("Refresh")//Refresh, goes to the end of the proc.
				if("Return")//Return
					if(mode<=9)
						mode = 0
					else
						mode = round(mode/10)
						if(mode==4)//Fix for cartridges. Redirects to hub.
							mode = 0
						else if(mode >= 40 && mode <= 49)//Fix for cartridges. Redirects to refresh the menu.
							cartridge.mode = mode
							cartridge.unlock()
				if ("Authenticate")//Checks for ID
					id_check(U, 1)
				if("UpdateInfo")
					ownjob = id.assignment
					name = "PDA-[owner] ([ownjob])"
				if("Eject")//Ejects the cart, only done from hub.
					if (!isnull(cartridge))
						var/turf/T = loc
						if(ismob(T))
							T = T.loc
						cartridge.loc = T
						scanmode = 0
						if (cartridge.radio)
							cartridge.radio.hostpda = null
						cartridge = null

//MENU FUNCTIONS===================================

				if("0")//Hub
					mode = 0
				if("1")//Notes
					mode = 1
				if("2")//Messenger
					mode = 2
				if("21")//Read messeges
					mode = 21
				if("3")//Atmos scan
					mode = 3
				if("4")//Redirects to hub
					mode = 0
				if("chatroom") // chatroom hub
					mode = 5


//MAIN FUNCTIONS===================================

				if("Light")
					fon = (!fon)
					if (src in U.contents)
						if (fon)
							U.total_luminosity += f_lum
						else
							U.total_luminosity -= f_lum
					else
						sd_SetLuminosity(fon * f_lum)
				if("Medical Scan")
					if(scanmode == 1)
						scanmode = 0
					else if((!isnull(cartridge)) && (cartridge.access_medical))
						scanmode = 1
				if("Forensic Scan")
					if(scanmode == 2)
						scanmode = 0
					else if((!isnull(cartridge)) && (cartridge.access_security))
						scanmode = 2
				if("Reagent Scan")
					if(scanmode == 3)
						scanmode = 0
					else if((!isnull(cartridge)) && (cartridge.access_reagent_scanner))
						scanmode = 3
				if("Halogen Counter")
					if(scanmode == 4)
						scanmode = 0
					else if((!isnull(cartridge)) && (cartridge.access_engine))
						scanmode = 4
				if("Honk")
					if ( !(last_honk && world.time < last_honk + 20) )
						playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
						last_honk = world.time

//MESSENGER/NOTE FUNCTIONS===================================

				if ("Edit")
					var/n = input(U, "Please enter message", name, notehtml) as message
					if (in_range(src, U) && loc == U)
						n = copytext(adminscrub(n), 1, MAX_MESSAGE_LEN)
						if (mode == 1)
							note = dd_replacetext(n, "\n", "<BR>")
							notehtml = n
					else
						U << browse(null, "window=pda")
						return
				if("Toggle Messenger")
					toff = !toff
				if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
					silent = !silent
				if("Clear")//Clears messages
					tnote = null
				if("Ringtone")
					var/t = input(U, "Please enter new ringtone", name, ttone) as text
					if (in_range(src, U) && loc == U)
						if (t)
							if(src.hidden_uplink && hidden_uplink.check_trigger(U, t, lock_code))
								U << "The PDA softly beeps."
								U << browse(null, "window=pda")
							else
								t = copytext(sanitize(t), 1, 20)
								ttone = t
					else
						U << browse(null, "window=pda")
						return
				if("Message")
					var/obj/item/device/pda/P = locate(href_list["target"])
					src.create_message(U, P)

				if("Send Honk")//Honk virus
					if(istype(cartridge, /obj/item/weapon/cartridge/clown))//Cartridge checks are kind of unnecessary since everything is done through switch.
						var/obj/item/device/pda/P = locate(href_list["target"])//Leaving it alone in case it may do something useful, I guess.
						if(!isnull(P))
							if (!P.toff && cartridge:honk_charges > 0)
								cartridge:honk_charges--
								U.show_message("\blue Virus sent!", 1)
								P.honkamt = (rand(15,20))
						else
							U << "PDA not found."
					else
						U << browse(null, "window=pda")
						return
				if("Send Silence")//Silent virus
					if(istype(cartridge, /obj/item/weapon/cartridge/mime))
						var/obj/item/device/pda/P = locate(href_list["target"])
						if(!isnull(P))
							if (!P.toff && cartridge:mime_charges > 0)
								cartridge:mime_charges--
								U.show_message("\blue Virus sent!", 1)
								P.silent = 1
								P.ttone = "silence"
						else
							U << "PDA not found."
					else
						U << browse(null, "window=pda")
						return


//SYNDICATE FUNCTIONS===================================

				if("Toggle Door")
					if(!isnull(cartridge) && cartridge.access_remote_door)
						for(var/obj/machinery/door/poddoor/M in machines)
							if(M.id == cartridge.remote_door_id)
								if(M.density)
									spawn(0)
										M.open()
								else
									spawn(0)
										M.close()

				if("Detonate")//Detonate PDA
					if(istype(cartridge, /obj/item/weapon/cartridge/syndicate))
						var/obj/item/device/pda/P = locate(href_list["target"])
						if(!isnull(P))
							if (!P.toff && cartridge:shock_charges > 0)
								cartridge:shock_charges--

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

								if ((prob(difficulty * 12)) || (P.hidden_uplink))
									U.show_message("\red An error flashes on your [src].", 1)
								else if (prob(difficulty * 3))
									U.show_message("\red Energy feeds back into your [src]!", 1)
									U << browse(null, "window=pda")
									explode()
								else
									U.show_message("\blue Success!", 1)
									P.explode()
						else
							U << "PDA not found."
					else
						U.machine = null
						U << browse(null, "window=pda")
						return

//pAI FUNCTIONS===================================
				if("pai")
					switch(href_list["option"])
						if("1")		// Configure pAI device
							pai.attack_self(U)
						if("2")		// Eject pAI device
							var/turf/T = get_turf_or_move(src.loc)
							if(T)
								pai.loc = T

//LINK FUNCTIONS===================================

				else//Cartridge menu linking
					mode = text2num(href_list["choice"])
					cartridge.mode = mode
					cartridge.unlock()
		else//If can't interact.
			U.machine = null
			U << browse(null, "window=pda")
			return
	else//If not in range or not using the pda.
		U.machine = null
		U << browse(null, "window=pda")
		return

//EXTRA FUNCTIONS===================================

	if (mode == 2||mode == 21)//To clear message overlays.
		overlays = null

	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)

	if(U.machine == src && href_list["skiprefresh"]!="1")//Final safety.
		attack_self(U)//It auto-closes the menu prior if the user is not in range and so on.
	else
		U.machine = null
		U << browse(null, "window=pda")
	return

/obj/item/device/pda/proc/remove_id()
	if (id)
		if (ismob(loc))
			var/mob/M = loc
			M.put_in_hands(id)
			usr << "<span class='notice'>You remove the ID from the [name].</span>"
		else
			id.loc = get_turf(src)
		id = null

/obj/item/device/pda/proc/create_message(var/mob/living/U = usr, var/obj/item/device/pda/P)

	var/t = input(U, "Please enter message", name, null) as text
	t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
	if (!t || !istype(P))
		return
	if (!in_range(src, U) && loc != U)
		return

	if (isnull(P)||P.toff || toff)
		return

	if (last_text && world.time < last_text + 5)
		return

	last_text = world.time
	// check if telecomms I/O route 1459 is stable
	//var/telecomms_intact = telecomms_process(P.owner, owner, t)
	var/obj/machinery/message_server/useMS = null
	if(message_servers)
		for (var/obj/machinery/message_server/MS in message_servers)
		//PDAs are now dependant on the Message Server.
			if(MS.active)
				useMS = MS
				break

	var/datum/signal/signal = telecomms_process()

	var/useTC = 0
	if(signal)
		if(signal.data["done"])
			useTC = 1
			if(P.loc.z in signal.data["level"])
				useTC = 2
				//Let's make this barely readable
				if(signal.data["compression"] > 0)
					t = Gibberish(t, signal.data["compression"] + 50)

	if(useMS && useTC) // only send the message if it's stable
		if(useTC != 2) // Does our recepient have a broadcaster on their level?
			U << "ERROR: Cannot reach recepient."
			return
		useMS.send_pda_message("[P.owner]","[owner]","[t]")

		tnote += "<i><b>&rarr; To [P.owner]:</b></i><br>[t]<br>"
		P.tnote += "<i><b>&larr; From <a href='byond://?src=\ref[P];choice=Message;target=\ref[src]'>[owner]</a> ([ownjob]):</b></i><br>[t]<br>"

		if (prob(15)) //Give the AI a chance of intercepting the message
			var/who = src.owner
			if(prob(50))
				who = P:owner
			for(var/mob/living/silicon/ai/ai in mob_list)
				// Allows other AIs to intercept the message but the AI won't intercept their own message.
				if(ai.aiPDA != P && ai.aiPDA != src)
					ai.show_message("<i>Intercepted message from <b>[who]</b>: [t]</i>")

		if (!P.silent)
			playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
		for (var/mob/O in hearers(3, P.loc))
			if(!P.silent) O.show_message(text("\icon[P] *[P.ttone]*"))
		//Search for holder of the PDA.
		var/mob/living/L = null
		if(P.loc && isliving(P.loc))
			L = P.loc
		//Maybe they are a pAI!
		else if(istype(P, /obj/item/device/pda/pai) && P.loc)
			//Search through the location's contents
			for(var/obj/item/device/paicard/Pcard in P.loc)
				//If there's a Pcard there then get the mind inside
				if(Pcard.pai)
					var/mob/living/silicon/pai/pai = Pcard.pai
					//Is it the pAI that is receiving the message?
					if(pai.pda && pai.pda == P)
						L = pai
						break
		if(L)
			L << "\icon[P] <b>Message from [src.owner] ([ownjob]), </b>\"[t]\" (<a href='byond://?src=\ref[P];choice=Message;skiprefresh=1;target=\ref[src]'>Reply</a>)"

		log_pda("[usr] (PDA: [src.name]) sent \"[t]\" to [P.name]")
		P.overlays = null
		P.overlays += image('icons/obj/pda.dmi', "pda-r")
	else
		U << "<span class='notice'>ERROR: Server isn't responding.</span>"


/obj/item/device/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	if ( !(usr.stat || usr.restrained()) )
		if(id)
			remove_id()
		else
			usr << "<span class='notice'>This PDA does not have an ID in it.</span>"
	else
		usr << "<span class='notice'>You cannot do this while restrained.</span>"


/obj/item/device/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr

	if ( !(usr.stat || usr.restrained()) )
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			if (istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(O)
					usr << "<span class='notice'>You remove \the [O] from \the [src].</span>"
					return
			O.loc = get_turf(src)
		else
			usr << "<span class='notice'>This PDA does not have a pen in it.</span>"
	else
		usr << "<span class='notice'>You cannot do this while restrained.</span>"

/obj/item/device/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				user.drop_item()
				I.loc = src
				id = I
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if (istype(I, /obj/item/weapon/card/id) && I:registered_name)
			var/obj/old_id = id
			user.drop_item()
			I.loc = src
			id = I
			user.put_in_hands(old_id)
	return

// access to status display signals
/obj/item/device/pda/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(istype(C, /obj/item/weapon/cartridge) && !cartridge)
		user.drop_item()
		C.loc = src
		user << "<span class='notice'>You insert [C] into [src].</span>"
		cartridge = C
		if(C:radio)
			C:radio.hostpda = src

	else if(istype(C, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = C
		if(!idcard.registered_name)
			user << "<span class='notice'>\The [src] rejects the ID.</span>"
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			name = "PDA-[owner] ([ownjob])"
			user << "<span class='notice'>Card scanned.</span>"
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (C in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (C in user.contents)) )
				if(!(user.stat || user.restrained()) )//If they can still act.
					id_check(user, 2)
					user << "<span class='notice'>You put the ID into \the [src]'s slot.</span>"
					updateSelfDialog()//Update self dialog on success.
			return	//Return in case of failed check or when successful.
		updateSelfDialog()//For the non-input related code.
	else if(istype(C, /obj/item/device/paicard) && !src.pai)
		user.drop_item()
		C.loc = src
		pai = C
		user << "<span class='notice'>You slot \the [C] into [src].</span>"
		updateUsrDialog()
	else if(istype(C, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			user << "<span class='notice'>There is already a pen in \the [src].</span>"
		else
			user.drop_item()
			C.loc = src
			user << "<span class='notice'>You slide \the [C] into \the [src].</span>"
	return

/obj/item/device/pda/attack(mob/living/C as mob, mob/living/user as mob)
	if (istype(C, /mob/living/carbon))
		switch(scanmode)
			if(1)

				for (var/mob/O in viewers(C, null))
					O.show_message("\red [user] has analyzed [C]'s vitals!", 1)

				user.show_message("\blue Analyzing Results for [C]:")
				user.show_message("\blue \t Overall Status: [C.stat > 1 ? "dead" : "[C.health - C.halloss]% healthy"]", 1)
				user.show_message("\blue \t Damage Specifics: [C.getOxyLoss() > 50 ? "\red" : "\blue"][C.getOxyLoss()]-[C.getToxLoss() > 50 ? "\red" : "\blue"][C.getToxLoss()]-[C.getFireLoss() > 50 ? "\red" : "\blue"][C.getFireLoss()]-[C.getBruteLoss() > 50 ? "\red" : "\blue"][C.getBruteLoss()]", 1)
				user.show_message("\blue \t Key: Suffocation/Toxin/Burns/Brute", 1)
				user.show_message("\blue \t Body Temperature: [C.bodytemperature-T0C]&deg;C ([C.bodytemperature*1.8-459.67]&deg;F)", 1)
				if(C.tod && (C.stat == DEAD || (C.status_flags & FAKEDEATH)))
					user.show_message("\blue \t Time of Death: [C.tod]")
				if(istype(C, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = C
					var/list/damaged = H.get_damaged_organs(1,1)
					user.show_message("\blue Localized Damage, Brute/Burn:",1)
					if(length(damaged)>0)
						for(var/datum/organ/external/org in damaged)
							user.show_message(text("\blue \t []: []\blue-[]",capitalize(org.getDisplayName()),(org.brute_dam > 0)?"\red [org.brute_dam]":0,(org.burn_dam > 0)?"\red [org.burn_dam]":0),1)
					else
						user.show_message("\blue \t Limbs are OK.",1)

				for(var/datum/disease/D in C.viruses)
					if(!D.hidden[SCANNER])
						user.show_message(text("\red <b>Warning: [D.form] Detected</b>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]"))

			if(2)
				if (!istype(C:dna, /datum/dna))
					user << "\blue No fingerprints found on [C]"
				else if(!istype(C, /mob/living/carbon/monkey))
					if(!isnull(C:gloves))
						user << "\blue No fingerprints found on [C]"
				else
					user << text("\blue [C]'s Fingerprints: [md5(C:dna.uni_identity)]")
				if ( !(C:blood_DNA) )
					user << "\blue No blood found on [C]"
					if(C:blood_DNA)
						del(C:blood_DNA)
				else
					user << "\blue Blood found on [C]. Analysing..."
					spawn(15)
						for(var/blood in C:blood_DNA)
							user << "\blue Blood type: [C:blood_DNA[blood]]\nDNA: [blood]"

			if(4)
				for (var/mob/O in viewers(C, null))
					O.show_message("\red [user] has analyzed [C]'s radiation levels!", 1)

				user.show_message("\blue Analyzing Results for [C]:")
				if(C.radiation)
					user.show_message("\green Radiation Level: \black [C.radiation]")
				else
					user.show_message("\blue No radiation detected.")

/obj/item/device/pda/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
	switch(scanmode)
		if(2)
			if(!istype(A, /obj/item/weapon/f_card))
				if (!A.fingerprints)
					user << "\blue Unable to locate any fingerprints on [A]!"
				else
					user << "\blue Isolated [A:fingerprints.len] fingerprints."
					var/list/prints = A:fingerprints
					var/list/complete_prints = list()
					for(var/i in prints)
						var/print = prints[i]
						if(stringpercent(print) <= FINGERPRINT_COMPLETE)
							complete_prints += print
					if(complete_prints.len < 1)
						user << "\blue No intact prints found"
					else
						user << "\blue Found [complete_prints.len] intact prints"
						for(var/i in complete_prints)
							user << "\blue [i]"
				if(cartridge && cartridge.access_security)
					cartridge.add_data(A)
					user << "Data added to internal storage.  Scan with a High-Resolution Scanner to retreive."

		if(3)
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

	if (!scanmode && istype(A, /obj/item/weapon/paper) && owner)
		note = A:info
		user << "\blue Paper scanned." //concept of scanning paper copyright brainoblivion 2009


/obj/item/device/pda/proc/explode() //This needs tuning.
	if(!src.detonate) return
	var/turf/T = get_turf(src.loc)

	if (ismob(loc))
		var/mob/M = loc
		M.show_message("\red Your [src] explodes!", 1)

	if(T)
		T.hotspot_expose(700,125)

		explosion(T, -1, -1, 2, 3)

	del(src)
	return

/obj/item/device/pda/Del()
	PDAs -= src
	if (src.id)
		src.id.loc = get_turf(src.loc)
	..()

/obj/item/device/pda/clown/HasEntered(AM as mob|obj) //Clown PDA is slippery.
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if ((istype(M, /mob/living/carbon/human) && (istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP)) || M.m_intent == "walk")
			return

		if ((istype(M, /mob/living/carbon/human) && (M.real_name != src.owner) && (istype(src.cartridge, /obj/item/weapon/cartridge/clown))))
			if (src.cartridge:honk_charges < 5)
				src.cartridge:honk_charges++

		M.stop_pulling()
		M << "\blue You slipped on the PDA!"
		playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(8)
		M.Weaken(5)


//AI verb and proc for sending PDA messages.

/mob/living/silicon/ai/verb/cmd_send_pdamesg()
	set category = "AI Commands"
	set name = "PDA - Send Message"
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if(usr.stat == 2)
		usr << "You can't send PDA messages because you are dead!"
		return

	if(src.aiPDA.toff)
		usr << "Turn on your receiver in order to send messages."
		return

	for (var/obj/item/device/pda/P in PDAs)
		if (!P.owner)
			continue
		else if (P == src)
			continue
		else if (P.toff)
			continue
		else if (P == src.aiPDA)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P

	var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)

	if (!c)
		return

	var/selected = plist[c]
	src.aiPDA.create_message(src, selected)


/mob/living/silicon/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI Commands"
	set name = "PDA - Toggle Sender/Receiver"
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	if(!isnull(aiPDA))
		aiPDA.toff = !aiPDA.toff
		usr << "<span class='notice'>PDA sender/receiver toggled [(aiPDA.toff ? "Off" : "On")]!</span>"
	else
		usr << "You do not have a PDA. You should make an issue report about this."

/mob/living/silicon/ai/verb/cmd_toggle_pda_silent()
	set category = "AI Commands"
	set name = "PDA - Toggle Ringer"
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	if(!isnull(aiPDA))
		//0
		aiPDA.silent = !aiPDA.silent
		usr << "<span class='notice'>PDA ringer toggled [(aiPDA.silent ? "Off" : "On")]!</span>"
	else
		usr << "You do not have a PDA. You should make an issue report about this."

/mob/living/silicon/ai/verb/cmd_show_message_log()
	set category = "AI Commands"
	set name = "PDA - Show Message Log"
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	if(!isnull(aiPDA))
		var/HTML = "<html><head><title>AI PDA Message Log</title></head><body>[aiPDA.tnote]</body></html>"
		usr << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")
	else
		usr << "You do not have a PDA. You should make an issue report about this."




//Some spare PDAs in a box

/obj/item/weapon/storage/PDAbox
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/PDAbox/New()
	..()
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)

	var/newcart = pick(1,2,3,4)
	switch(newcart)
		if(1)
			new /obj/item/weapon/cartridge/engineering(src)
		if(2)
			new /obj/item/weapon/cartridge/security(src)
		if(3)
			new /obj/item/weapon/cartridge/medical(src)
		if(4)
			new /obj/item/weapon/cartridge/signal/toxins(src)

	new /obj/item/weapon/cartridge/head(src)


// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)