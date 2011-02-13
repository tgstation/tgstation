
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
	var/mode = "main" //0-10, Main menu, Crew manifest, Engine monitor, Atmos scanner, med records, notes, sec records, messenger, mop locator, signaler, status display.
	var/scanmode = 0 //1 is medical scanner, 2 is forensics, 3 is reagent scanner.

	var/tmode = 0 //Texting mode, 1 to view recieved messages
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 4 //Luminosity for the flashlight function
	var/silent = 0 //To beep or not to beep, that is the question
	var/toff = 0 //If 1, messenger disabled
	var/tnote = null //Current Texts
	var/last_text //No text spamming
	var/last_honk //Also no honk spamming that's bad too
	var/ttone = "beep" //The ringtone!
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!" //Current note in the notepad function.
	var/cart = "" //A place to stick cartridge menu information

	var/obj/item/weapon/integrated_uplink/uplink = null

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
	ttone = "holy"



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

	if ((!isnull(src.cartridge)) && (src.mode == "main"))
		dat += " | <a href='byond://?src=\ref[src];rc=1'><img src=pda_eject.png> Eject [src.cartridge]</a>"
	if (src.mode != "main")
		dat += " | <a href='byond://?src=\ref[src];mm=1'><img src=pda_menu.png> Main Menu</a>"
		dat += " | <a href='byond://?src=\ref[src];refresh=1'><img src=pda_refresh.png> Refresh</a>"

	dat += "<br>"

	if (!src.owner)
		dat += "Warning: No owner information entered.  Please swipe card.<br><br>"
		dat += "<a href='byond://?src=\ref[src];refresh=1'><img src=pda_refresh.png> Retry</a>"
	else
		switch (src.mode)
			if ("main")
				dat += "<h2>PERSONAL DATA ASSISTANT</h2>"
				dat += "Owner: [src.owner], [src.ownjob]<br>"
				dat += text("ID: <A href='?src=\ref[];auth=1'>[]</A><br>", src, (src.id ? "[src.id.registered], [src.id.assignment]" : "----------"))
				dat += "Station Time: [round(world.time / 36000)+12]:[(world.time / 600 % 60) < 10 ? add_zero(world.time / 600 % 60, 1) : world.time / 600 % 60]"//:[world.time / 100 % 6][world.time / 100 % 10]"

				dat += "<br><br>"

				dat += "<h4>General Functions</h4>"
				dat += "<ul>"
				dat += "<li><a href='byond://?src=\ref[src];note=1'><img src=pda_notes.png> Notekeeper</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];mess=1'><img src=pda_mail.png> Messenger</a></li>"

				if (src.cartridge)
					if (src.cartridge.access_clown)
						dat += "<li><a href='byond://?src=\ref[src];honk=1'><img src=pda_honk.png> Honk Synthesizer</a></li>"
					if (src.cartridge.access_manifest)
						dat += "<li><a href='byond://?src=\ref[src];cart=crew'><img src=pda_notes.png> View Crew Manifest</a></li>"
					if(cartridge.access_status_display)
						dat += "<li><a href='byond://?src=\ref[src];cart=status'><img src=pda_status.png> Set Status Display</a></li>"
					dat += "</ul>"

					if (src.cartridge.access_engine)
						dat += "<h4>Engineering Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=\ref[src];cart=power'><img src=pda_power.png> Power Monitor</a></li>"
						dat += "</ul>"
					if (src.cartridge.access_medical)
						dat += "<h4>Medical Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=\ref[src];cart=medical'><img src=pda_medical.png> Medical Records</a></li>"
						dat += "<li><a href='byond://?src=\ref[src];set_scanmode=1'><img src=pda_scanner.png> [src.scanmode == 1 ? "Disable" : "Enable"] Medical Scanner</a></li>"
						dat += "</ul>"
					if (src.cartridge.access_security)
						dat += "<h4>Security Functions</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=\ref[src];cart=security'><img src=pda_cuffs.png> Security Records</A></li>"
						dat += "<li><a href='byond://?src=\ref[src];set_scanmode=2'><img src=pda_scanner.png> [src.scanmode == 2 ? "Disable" : "Enable"] Forensic Scanner</a></li>"
					if(istype(cartridge.radio, /obj/item/radio/integrated/beepsky))
						dat += "<li><a href='byond://?src=\ref[src];cart=beepsky'><img src=pda_cuffs.png> Security Bot Access</a></li>"
						dat += "</ul>"
					else dat += "</ul>"
					if(cartridge.access_quartermaster)
						dat += "<h4>Quartermaster Functions:</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=\ref[src];cart=qm'><img src=pda_crate.png> Supply Records</A></li>"
						dat += "<li><a href='byond://?src=\ref[src];cart=mule'><img src=pda_mule.png> Delivery Bot Control</A></li>"
						dat += "</ul>"
				else dat += "</ul>"

				dat += "<h4>Utilities</h4>"
				dat += "<ul>"
				if (src.cartridge)
					if (src.cartridge.access_janitor)
						dat += "<li><a href='byond://?src=\ref[src];cart=janitor'><img src=pda_bucket.png> Equipment Locator</a></li>"
					if (istype(src.cartridge.radio, /obj/item/radio/integrated/signal))
						dat += "<li><a href='byond://?src=\ref[src];cart=signal'><img src=pda_signaler.png> Signaler System</a></li>"
					if (src.cartridge.access_reagent_scanner)
						dat += "<li><a href='byond://?src=\ref[src];set_scanmode=3'><img src=pda_reagent.png> [src.scanmode == 3 ? "Disable" : "Enable"] Reagent Scanner</a></li>"
				//Remote shuttle shield control for syndies I guess
					if (src.cartridge.access_remote_door)
						dat += "<li><a href='byond://?src=\ref[src];remotedoor=1'><img src=pda_rdoor.png> Toggle Remote Door</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];atmos=1'><img src=pda_atmos.png> Atmospheric Scan</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];flight=1'><img src=pda_flashlight.png> [src.fon ? "Disable" : "Enable"] Flashlight</a></li>"
				dat += "</ul>"

			if ("atmos")

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


			if ("notes")
				dat += "<h4><img src=pda_notes.png> Notekeeper V2.1</h4>"

				if ((!isnull(src.uplink)) && (src.uplink.active))
					dat += "<a href='byond://?src=\ref[src];lock_uplink=1'>Lock</a><br>"
				else
					dat += "<a href='byond://?src=\ref[src];editnote=1'>Edit</a><br>"

				dat += src.note

			if ("cart")
				dat += src.cart

			if ("messenger")

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
			src.mode = "main"

		if (href_list["cart"])
			cartridge.mode = href_list["cart"]
			cartridge.unlock()

		else if (href_list["atmos"])
			src.mode = "atmos"

		else if (href_list["note"])
			src.mode = "notes"

		else if (href_list["mess"])
			src.mode = "messenger"

		else if (href_list["pback"])
			src.tmode = !src.tmode

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
			if (src.mode == "notes")
				var/n = input(usr, "Please enter message", src.name, src.note) as message
				if (!in_range(src, usr) && src.loc != usr)
					return
				n = copytext(adminscrub(n), 1, MAX_MESSAGE_LEN)
				if (src.mode == "notes")
					src.note = n

			else if (src.mode == "messenger")
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
			if (mode == "cart")
				cartridge.unlock()
			else src.updateUsrDialog()

		else if (href_list["close"])
			usr << browse(null, "window=pda")
			usr.machine = null

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
			cartridge.mmode = 0
			cartridge.smode = 0
			if (src.cartridge.radio)
				src.cartridge.radio.hostpda = null
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

		if (src.mode == "messenger" || src.tmode == 1)
			src.overlays = null

		if ((src.honkamt > 0) && (prob(60)))
			src.honkamt--
			playsound(src.loc, 'bikehorn.ogg', 30, 1)

		for (var/mob/M in viewers(1, src.loc))
			if (M.client && M.machine == src)
				src.attack_self(M)

// access to status display signals



/obj/item/device/pda/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if (istype(C, /obj/item/weapon/cartridge) && isnull(src.cartridge))
		user.drop_item()
		C.loc = src
		user << "\blue You insert [C] into [src]."
		src.cartridge = C
		if (C:radio)
			C:radio.hostpda = src
		src.updateUsrDialog()

	else if (istype(C, /obj/item/weapon/card/id) && C:registered)
		if(!src.owner)
			src.owner = C:registered
			src.ownjob = C:assignment
			src.name = "PDA-[src.owner] ([src.ownjob])"
			user << "\blue Card scanned."
			src.updateSelfDialog()
			return
		if(!(src.owner == C:registered))
			user << "\blue Name on card does not match registered name. Please try again."
			src.updateSelfDialog()
			return
		if((src.owner == C:registered) && (src.ownjob == C:assignment))
			user << "\blue Rank is up to date."
			src.updateSelfDialog()
			return
		if((src.owner == C:registered) && (src.ownjob != C:assignment))
			src.ownjob = C:assignment
			src.name = "PDA-[src.owner] ([src.ownjob])"
			user << "\blue Rank updated."
			src.updateSelfDialog()
			return


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
