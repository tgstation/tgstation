
//The advanced pea-green monochrome lcd of tomorrow.

var/global/list/obj/item/device/pda/PDAs = list()


/obj/item/device/pda
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = 1.0
	slot_flags = SLOT_ID | SLOT_BELT

	//Main variables
	var/owner = null // String name of owner
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/mode = 0 //Controls what menu the PDA will display. 0 is hub; the rest are either built in or based on cartridge.

	//Secondary variables
	var/scanmode = 0 //1 is medical scanner, 2 is forensics, 3 is reagent scanner.
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 3 //Luminosity for the flashlight function
	var/silent = 0 //To beep or not to beep, that is the question
	var/toff = 0 //If 1, messenger disabled
	var/tnote = null //Current Texts
	var/last_text //No text spamming
	var/last_noise //Also no honk spamming that's bad too
	var/ttone = "beep" //The ringtone!
	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""
	var/notescanned = 0 // True if what is in the notekeeper was from a paper.
	var/cart = "" //A place to stick cartridge menu information
	var/detonate = 1 // Can the PDA be blown up?
	var/hidden = 0 // Is the PDA hidden from the PDA list?
	var/emped = 0

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above

	var/obj/item/device/paicard/pai = null	// A slot for a personal AI device

	var/chat_channel = "#ss13" //name of our current NTRC channel
	var/nick = "" //our NTRC nick
	var/list/ntrclog = list() //NTRC message log
	var/new_ntrc_msg = 0

	var/image/photo = null //Scanned photo

	var/noreturn = 0 //whether the PDA can use the Return button, used for the aiPDA chatroom

/obj/item/device/pda/medical
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-medical"

/obj/item/device/pda/viro
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-virology"

/obj/item/device/pda/engineering
	default_cartridge = /obj/item/weapon/cartridge/engineering
	icon_state = "pda-engineer"

/obj/item/device/pda/security
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-security"

/obj/item/device/pda/detective
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon_state = "pda-detective"

/obj/item/device/pda/warden
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/janitor
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-janitor"
	ttone = "slip"

/obj/item/device/pda/toxins
	default_cartridge = /obj/item/weapon/cartridge/signal/toxins
	icon_state = "pda-science"
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
	icon_state = "pda-hop"

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
	icon_state = "pda-captain"
	detonate = 0

/obj/item/device/pda/cargo
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/quartermaster
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-qm"

/obj/item/device/pda/shaftminer
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/weapon/cartridge/syndicate
	icon_state = "pda-syndi"
	name = "military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/device/pda/chaplain
	icon_state = "pda-chaplain"
	ttone = "holy"

/obj/item/device/pda/lawyer
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer"
	ttone = "objection"

/obj/item/device/pda/botanist
	//default_cartridge = /obj/item/weapon/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	icon_state = "pda-roboticist"
	default_cartridge = /obj/item/weapon/cartridge/roboticist

/obj/item/device/pda/librarian
	icon_state = "pda-library"
	default_cartridge = /obj/item/weapon/cartridge/librarian
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	silent = 1 //Quiet in the library!

/obj/item/device/pda/clear
	icon_state = "pda-clear"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/device/pda/cook
	icon_state = "pda-cook"

/obj/item/device/pda/bar
	icon_state = "pda-bartender"

/obj/item/device/pda/atmos
	default_cartridge = /obj/item/weapon/cartridge/atmos
	icon_state = "pda-atmos"

/obj/item/device/pda/chemist
	default_cartridge = /obj/item/weapon/cartridge/chemistry
	icon_state = "pda-chemistry"

/obj/item/device/pda/geneticist
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-genetics"

// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/ai
	icon_state = "NONE"
	ttone = "data"
	fon = 0
	mode = 5
	noreturn = 1
	detonate = 0

/obj/item/device/pda/ai/attack_self(mob/user as mob)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	..()

/obj/item/device/pda/ai/pai
	ttone = "assist"

/*
 *	The Actual PDA
 */
/obj/item/device/pda/pickup(mob/user)
	if(fon)
		SetLuminosity(0)
		user.AddLuminosity(f_lum)

/obj/item/device/pda/dropped(mob/user)
	if(fon)
		user.AddLuminosity(-f_lum)
		SetLuminosity(f_lum)

/obj/item/device/pda/New()
	..()
	if(fon)
		if(!isturf(loc))
			loc.AddLuminosity(f_lum)
			SetLuminosity(0)
		else
			SetLuminosity(f_lum)
	PDAs += src
	if(default_cartridge)
		cartridge = new default_cartridge(src)
	new /obj/item/weapon/pen(src)

/obj/item/device/pda/proc/update_label()
	name = "PDA-[owner] ([ownjob])" //Name generalisation

/obj/item/device/pda/proc/can_use(mob/user)
	if(user && ismob(user))
		if(user.stat || user.restrained() || user.paralysis || user.stunned || user.weakened)
			return 0
		if(loc == user)
			return 1
	return 0

/obj/item/device/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/device/pda/GetID()
	return id

/obj/item/device/pda/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /obj/screen)) && can_use(M))
		return attack_self(M)
	return

//NOTE: graphic resources are loaded on client login
/obj/item/device/pda/attack_self(mob/user as mob)

	user.set_machine(src)

	if(active_uplink_check(user))
		return

	setup_chatrooms()

	var/dat = "<html><head><title>Personal Data Assistant</title></head><body bgcolor=\"#808000\"><style>a, a:link, a:visited, a:active, a:hover { color: #000000; }img {border-style:none;}</style>"

	dat += "<a href='byond://?src=\ref[src];choice=Close'><img src=pda_exit.png> Close</a>"

	if ((!isnull(cartridge)) && (mode == 0))
		dat += " | <a href='byond://?src=\ref[src];choice=Eject'><img src=pda_eject.png> Eject [cartridge]</a>"
	if (mode && !noreturn)
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
				dat += text("<br><A href='?src=\ref[src];choice=UpdateInfo'>[id ? "Update PDA Info" : ""]</A><br><br>")

				dat += "[worldtime2text()]<br>" //:[world.time / 100 % 6][world.time / 100 % 10]"
				dat += "[time2text(world.realtime, "MMM DD")] [year_integer+540]"

				dat += "<br><br>"

				dat += "<h4>General Functions</h4>"
				dat += "<ul>"
				dat += "<li><a href='byond://?src=\ref[src];choice=1'><img src=pda_notes.png> Notekeeper</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];choice=2'><img src=pda_mail.png> Messenger</a></li>"
				dat += "<li><a href='byond://?src=\ref[src];choice=5'><img src=pda_chatroom.png> Nanotrasen Relay Chat</a> ([new_ntrc_msg] unread)</li>"

				if (cartridge)
					if (cartridge.access_clown)
						dat += "<li><a href='byond://?src=\ref[src];choice=Honk'><img src=pda_honk.png> Honk Synthesizer</a></li>"
						dat += "<li><a href='byond://?src=\ref[src];choice=Trombone'><img src=pda_honk.png> Sad Trombone</a></li>"
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
						dat += "</ul>"
					if(cartridge.access_quartermaster)
						dat += "<h4>Quartermaster Functions:</h4>"
						dat += "<ul>"
						dat += "<li><a href='byond://?src=\ref[src];choice=47'><img src=pda_crate.png> Supply Records</A></li>"
						dat += "</ul>"
				dat += "</ul>"

				dat += "<h4>Utilities</h4>"
				dat += "<ul>"
				if (cartridge)
					if(cartridge.bot_access_flags)
						dat += "<li><a href='byond://?src=\ref[src];choice=54'><img src=pda_medbot.png> Bots Access</a></li>"
					if (cartridge.access_janitor)
						dat += "<li><a href='byond://?src=\ref[src];choice=49'><img src=pda_bucket.png> Custodial Locator</a></li>"
					if (istype(cartridge.radio, /obj/item/radio/integrated/signal))
						dat += "<li><a href='byond://?src=\ref[src];choice=40'><img src=pda_signaler.png> Signaler System</a></li>"
					if (cartridge.access_newscaster)
						dat += "<li><a href='byond://?src=\ref[src];choice=53'><img src=pda_notes.png> Newscaster Access </a></li>"
					if (cartridge.access_reagent_scanner)
						dat += "<li><a href='byond://?src=\ref[src];choice=Reagent Scan'><img src=pda_reagent.png> [scanmode == 3 ? "Disable" : "Enable"] Reagent Scanner</a></li>"
					if (cartridge.access_engine)
						dat += "<li><a href='byond://?src=\ref[src];choice=Halogen Counter'><img src=pda_reagent.png> [scanmode == 4 ? "Disable" : "Enable"] Halogen Counter</a></li>"
					if (cartridge.access_atmos)
						dat += "<li><a href='byond://?src=\ref[src];choice=Gas Scan'><img src=pda_reagent.png> [scanmode == 5 ? "Disable" : "Enable"] Gas Scanner</a></li>"
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
				dat += "<h4><img src=pda_notes.png> Notekeeper V2.2</h4>"
				dat += "<a href='byond://?src=\ref[src];choice=Edit'>Edit</a><br>"
				if(notescanned)
					dat += "(This is a scanned image, editing it may cause some text formatting to change.)<br>"
				dat += "<HR><font face=\"[PEN_FONT]\">[(!notehtml ? note : notehtml)]</font>"

			if (2)
				dat += "<h4><img src=pda_mail.png> SpaceMessenger V3.9.6</h4>"
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
					for (var/obj/item/device/pda/P in sortNames(get_viewable_pdas()))
						if (P == src)	continue
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
				dat += "<h4><img src=pda_mail.png> SpaceMessenger V3.9.6</h4>"
				dat += "<a href='byond://?src=\ref[src];choice=Clear'><img src=pda_blank.png> Clear Messages</a>"

				dat += "<h4><img src=pda_mail.png> Messages</h4>"

				dat += tnote
				dat += "<br>"

			if (3)
				dat += "<h4><img src=pda_atmos.png> Atmospheric Readings</h4>"

				var/turf/T = get_turf(user.loc)
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
				new_ntrc_msg = 0
				dat += "<h4><img src=pda_chatroom.png> Nanotrasen Relay Chat Network V1.2</h4>"

				dat += "<a href='byond://?src=\ref[src];choice=Set Nick'>[nick]</a> | "
				dat += "<a href='byond://?src=\ref[src];choice=Set Channel'>[chat_channel]</a> | "
				dat += "<a href='byond://?src=\ref[src];choice=NTRC Message'>Write message</a> | "
				dat += "<a href='byond://?src=\ref[src];choice=NTRC Help'>Help</a><br><HR>"
				if(chat_channel)
					dat += ntrclog[chat_channel]

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

	if(can_use(U)) //Why reinvent the wheel? There's a proc that does exactly that.
		add_fingerprint(U)
		U.set_machine(src)

		switch(href_list["choice"])

//BASIC FUNCTIONS===================================

			if("Close")//Self explanatory
				U.unset_machine()
				U << browse(null, "window=pda")
				return
			if("Refresh")//Refresh, goes to the end of the proc.
			if("Return")//Return
				if(mode<=9)
					mode = 0
				else
					mode = round(mode/10)
					if(mode==4 || mode == 5)//Fix for cartridges. Redirects to hub.
						mode = 0
					else if(mode >= 40 && mode <= 59)//Fix for cartridges. Redirects to refresh the menu.
						cartridge.mode = mode
						cartridge.unlock()
			if ("Authenticate")//Checks for ID
				id_check(U, 1)
			if("UpdateInfo")
				ownjob = id.assignment
				update_label()
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
			if("5")//Chatroom
				mode = 5


//MAIN FUNCTIONS===================================

			if("Light")
				if(fon)
					fon = 0
					if(src in U.contents)	U.AddLuminosity(-f_lum)
					else					SetLuminosity(0)
				else
					fon = 1
					if(src in U.contents)	U.AddLuminosity(f_lum)
					else					SetLuminosity(f_lum)
			if("Medical Scan")
				if(scanmode == 1)
					scanmode = 0
				else if((!isnull(cartridge)) && (cartridge.access_medical))
					scanmode = 1
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
				if ( !(last_noise && world.time < last_noise + 20) )
					playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
					last_noise = world.time
			if("Trombone")
				if ( !(last_noise && world.time < last_noise + 20) )
					playsound(loc, 'sound/misc/sadtrombone.ogg', 50, 1)
					last_noise = world.time
			if("Gas Scan")
				if(scanmode == 5)
					scanmode = 0
				else if((!isnull(cartridge)) && (cartridge.access_atmos))
					scanmode = 5

//NOTEKEEPER FUNCTIONS===================================

			if ("Edit")
				var/n = stripped_multiline_input(U, "Please enter message", name, note)
				if (in_range(src, U) && loc == U)
					if (mode == 1 && n)
						note = n
						notehtml = parsepencode(n, U, SIGNFONT)
						notescanned = 0
				else
					U << browse(null, "window=pda")
					return

//MESSENGER FUNCTIONS===================================

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
						if(src.hidden_uplink && hidden_uplink.check_trigger(U, trim(lowertext(t)), trim(lowertext(lock_code))))
							U << "The PDA softly beeps."
							U << browse(null, "window=pda")
							src.mode = 0
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
							U.show_message("<span class='notice'>Virus sent!</span>", 1)
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
							U.show_message("<span class='notice'>Virus sent!</span>", 1)
							P.silent = 1
							P.ttone = "silence"
					else
						U << "PDA not found."
				else
					U << browse(null, "window=pda")
					return


//CHATROOM FUNCTIONS====================================

			if("Set Nick")
				var/n = trim(stripped_input(U, "Please enter nickname", name, nick, 9))
				if(n)
					nick = n

			if("Set Channel")
				var/t = replacetext(trim(stripped_input(U, "Please enter channel", name, chat_channel, 15)), " ", "_")
				if(t)
					var/datum/chatroom/C = chatchannels[chat_channel]
					var/ret = C.parse_msg(src, nick, "/join [t]")
					if((ret in chatchannels) && (ret != chat_channel))
						ntrclog[chat_channel] = "<hr>" + ntrclog[chat_channel]
						chat_channel = ret

			if("NTRC Message")
				var/t = msg_input(U)
				if(t)
					var/datum/chatroom/C = chatchannels[chat_channel]
					if(C)
						var/ret = C.parse_msg(src, nick, t)
						if(findtextEx(ret, "BAD_", 1, 5))
							ntrclog[chat_channel] = "[ret]<br>" + ntrclog[chat_channel]
						else if(ret in chatchannels)
							chat_channel = ret

			if("NTRC Help")
				var/helptext = "<b>NTRC Commands:</b><br><br>"
				helptext += "/join \[#\](channel name)<br>/register<br>/log (amount of lines)<br><br>"
				usr << browse(helptext, "window=ntrchelp;size=200x200;border=1;can_resize=1;can_close=1;can_minimize=1")



//SYNDICATE FUNCTIONS===================================

			if("Toggle Door")
				if(cartridge && cartridge.access_remote_door)
					for(var/obj/machinery/door/poddoor/M in world)
						if(M.id == cartridge.remote_door_id)
							if(M.density)
								M.open()
							else
								M.close()

			if("Detonate")//Detonate PDA
				if(istype(cartridge, /obj/item/weapon/cartridge/syndicate))
					var/obj/item/device/pda/P = locate(href_list["target"])
					if(!isnull(P))
						if (!P.toff && cartridge:shock_charges > 0)
							cartridge:shock_charges--

							var/difficulty = 0

							if(P.cartridge)
								difficulty += P.cartridge.access_medical
								difficulty += P.cartridge.access_security
								difficulty += P.cartridge.access_engine
								difficulty += P.cartridge.access_clown
								difficulty += P.cartridge.access_janitor
								difficulty += P.cartridge.access_manifest * 2
							else
								difficulty += 2

							if(prob(difficulty * 12) || (P.hidden_uplink))
								U.show_message("<span class='danger'>An error flashes on your [src].</span>", 1)
							else if (prob(difficulty * 3))
								U.show_message("<span class='danger'>Energy feeds back into your [src]!</span>", 1)
								U << browse(null, "window=pda")
								explode()
							else
								U.show_message("<span class='notice'>Success!</span>", 1)
								P.explode()
					else
						U << "PDA not found."
				else
					U.unset_machine()
					U << browse(null, "window=pda")
					return

//pAI FUNCTIONS===================================
			if("pai")
				switch(href_list["option"])
					if("1")		// Configure pAI device
						pai.attack_self(U)
					if("2")		// Eject pAI device
						var/turf/T = get_turf(src.loc)
						if(T)
							pai.loc = T

//LINK FUNCTIONS===================================

			else//Cartridge menu linking
				mode = text2num(href_list["choice"])
				if(cartridge)
					cartridge.mode = mode
					cartridge.unlock()
	else//If not in range, can't interact or not using the pda.
		U.unset_machine()
		U << browse(null, "window=pda")
		return

//EXTRA FUNCTIONS===================================

	if (mode == 2||mode == 21)//To clear message overlays.
		overlays.Cut()

	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)

	if(U.machine == src && href_list["skiprefresh"]!="1")//Final safety.
		attack_self(U)//It auto-closes the menu prior if the user is not in range and so on.
	else
		U.unset_machine()
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

/obj/item/device/pda/proc/msg_input(var/mob/living/U = usr)
	var/t = stripped_input(U, "Please enter message", name, null, MAX_MESSAGE_LEN)
	if (!t || toff)
		return
	if (!in_range(src, U) && loc != U)
		return
	if(!can_use(U))
		return
	if(emped)
		t = Gibberish(t, 100)
	return t

/obj/item/device/pda/proc/create_message(var/mob/living/U = usr, var/obj/item/device/pda/P)

	var/t = msg_input(U)

	if (!t)
		return

	if (last_text && world.time < last_text + 5)
		return

	if (isnull(P) || P.toff || !istype(P))
		return

	last_text = world.time
	var/obj/machinery/message_server/useMS = null
	if(message_servers)
		for (var/obj/machinery/message_server/MS in message_servers)
		//PDAs are now dependant on the Message Server.
			if(MS.active)
				useMS = MS

	var/datum/signal/signal = src.telecomms_process()

	var/useTC = 0
	if(signal)
		if(signal.data["done"])
			useTC = 1
			var/turf/pos = get_turf(P)
			if(pos.z in signal.data["level"])
				useTC = 2
				//Let's make this barely readable
				if(signal.data["compression"] > 0)
					t = Gibberish(t, signal.data["compression"] + 50)

	if(useMS && useTC) // only send the message if it's stable
		if(useTC != 2) // Does our recipient have a broadcaster on their level?
			U << "ERROR: Cannot reach recipient."
			return
		var/msg_ref = useMS.send_pda_message("[P.owner]","[owner]","[t]",photo)
		var/photo_ref = ""
		if(photo)
			photo_ref = "<a href='byond://?src=\ref[msg_ref];photo=1'>(Photo)</a>"
		tnote += "<i><b>&rarr; To [P.owner]:</b></i><br>[t][photo_ref]<br>"
		P.tnote += "<i><b>&larr; From <a href='byond://?src=\ref[P];choice=Message;target=\ref[src]'>[owner]</a> ([ownjob]):</b></i><br>[t][photo_ref]<br>"
		for(var/mob/M in player_list)
			if(isobserver(M) && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTPDA))
				M.show_message("<span class='game say'>PDA Message - <span class='name'>[owner]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t][photo_ref]</span></span>")

		if (!P.silent)
			playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
			P.audible_message("\icon[P] *[P.ttone]*", null, 3)
		//Search for holder of the PDA.
		var/mob/living/L = null
		if(P.loc && isliving(P.loc))
			L = P.loc
		//Maybe they are a pAI!
		else
			L = get(P, /mob/living/silicon)

		if(L)
			L << "\icon[P] <b>Message from [src.owner] ([ownjob]), </b>\"[t]\"[photo_ref] (<a href='byond://?src=\ref[P];choice=Message;skiprefresh=1;target=\ref[src]'>Reply</a>)"

		log_pda("[usr] (PDA: [src.name]) sent \"[t]\" to [P.name]")
		photo = null
		P.overlays.Cut()
		P.overlays += image('icons/obj/pda.dmi', "pda-r")
	else
		U << "<span class='notice'>ERROR: Server isn't responding.</span>"

/obj/item/device/pda/AltClick()
	..()

	if(issilicon(usr))
		return

	if(can_use(usr))
		if(id)
			remove_id()
		else
			usr << "<span class='warning'>This PDA does not have an ID in it!</span>"
	else
		usr << "<span class='warning'>You cannot do that while restrained!</span>"

/obj/item/device/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Eject ID"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		if(id)
			remove_id()
		else
			usr << "<span class='warning'>This PDA does not have an ID in it!</span>"
	else
		usr << "<span class='warning'>You cannot do that while restrained!</span>"


/obj/item/device/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove Pen"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
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
			usr << "<span class='warning'>This PDA does not have a pen in it!</span>"
	else
		usr << "<span class='warning'>You cannot do that while restrained!</span>"

/obj/item/device/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				if(!user.unEquip(I))
					return 0
				I.loc = src
				id = I
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if (istype(I, /obj/item/weapon/card/id) && I:registered_name)
			if(!user.unEquip(I))
				return 0
			var/obj/old_id = id
			I.loc = src
			id = I
			user.put_in_hands(old_id)
	return 1

// access to status display signals
/obj/item/device/pda/attackby(obj/item/C as obj, mob/user as mob, params)
	..()
	if(istype(C, /obj/item/weapon/cartridge) && !cartridge)
		cartridge = C
		if(!user.unEquip(C))
			return
		cartridge.loc = src
		user << "<span class='notice'>You insert [cartridge] into [src].</span>"
		if(cartridge.radio)
			cartridge.radio.hostpda = src

	else if(istype(C, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = C
		if(!idcard.registered_name)
			user << "<span class='warning'>\The [src] rejects the ID!</span>"
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			update_label()
			user << "<span class='notice'>Card scanned.</span>"
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (C in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (C in user.contents)) )
				if( can_use(user) )//If they can still act.
					if(!id_check(user, 2))
						return
					user << "<span class='notice'>You put the ID into \the [src]'s slot.</span>"
					updateSelfDialog()//Update self dialog on success.
			return	//Return in case of failed check or when successful.
		updateSelfDialog()//For the non-input related code.
	else if(istype(C, /obj/item/device/paicard) && !src.pai)
		if(!user.unEquip(C))
			return
		C.loc = src
		pai = C
		user << "<span class='notice'>You slot \the [C] into [src].</span>"
		updateUsrDialog()
	else if(istype(C, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			user << "<span class='warning'>There is already a pen in \the [src]!</span>"
		else
			if(!user.unEquip(C))
				return
			C.loc = src
			user << "<span class='notice'>You slide \the [C] into \the [src].</span>"
	else if(istype(C, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/P = C
		photo = P.img
		user << "<span class='notice'>You scan \the [C].</span>"
	return

/obj/item/device/pda/attack(mob/living/carbon/C, mob/living/user as mob)
	if(istype(C))
		switch(scanmode)

			if(1)
				user.visible_message(text("<span class='alert'>[] has analyzed []'s vitals!</span>", user, C))
				healthscan(user, C, 1)
				src.add_fingerprint(user)

			if(2)
				// Unused

			if(4)
				C.visible_message("<span class='warning'>[user] has analyzed [C]'s radiation levels!</span>")

				user.show_message("<span class='notice'>Analyzing Results for [C]:</span>")
				if(C.radiation)
					user.show_message("\green Radiation Level: \black [C.radiation]")
				else
					user.show_message("<span class='notice'>No radiation detected.</span>")

/obj/item/device/pda/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	switch(scanmode)

		if(3)
			if(!isnull(A.reagents))
				if(A.reagents.reagent_list.len > 0)
					var/reagents_length = A.reagents.reagent_list.len
					user << "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.</span>"
					for (var/re in A.reagents.reagent_list)
						user << "<span class='notice'>\t [re]</span>"
				else
					user << "<span class='notice'>No active chemical agents found in [A].</span>"
			else
				user << "<span class='notice'>No significant chemical agents found in [A].</span>"

		if(5)
			if (istype(A, /obj/item/weapon/tank))
				var/obj/item/weapon/tank/T = A
				atmosanalyzer_scan(T.air_contents, user, T)
			else if (istype(A, /obj/machinery/portable_atmospherics))
				var/obj/machinery/portable_atmospherics/T = A
				atmosanalyzer_scan(T.air_contents, user, T)
			else if (istype(A, /obj/machinery/atmospherics/pipe))
				var/obj/machinery/atmospherics/pipe/T = A
				atmosanalyzer_scan(T.parent.air, user, T)
			else if (istype(A, /obj/machinery/power/rad_collector))
				var/obj/machinery/power/rad_collector/T = A
				if(T.P) atmosanalyzer_scan(T.P.air_contents, user, T)
			else if (istype(A, /obj/item/weapon/flamethrower))
				var/obj/item/weapon/flamethrower/T = A
				if(T.ptank) atmosanalyzer_scan(T.ptank.air_contents, user, T)

	if (!scanmode && istype(A, /obj/item/weapon/paper) && owner)
		if (!A:info)
			user << "<span class='warning'>Unable to scan! Paper is blank.</span>"
			return
		notehtml = A:info
		note = replacetext(notehtml, "<BR>", "\[br\]")
		note = replacetext(note, "<li>", "\[*\]")
		note = replacetext(note, "<ul>", "\[list\]")
		note = replacetext(note, "</ul>", "\[/list\]")
		note = html_encode(note)
		notescanned = 1
		user << "<span class='notice'>Paper scanned. Saved to PDA's notekeeper.</span>" //concept of scanning paper copyright brainoblivion 2009


/obj/item/device/pda/proc/explode() //This needs tuning.
	if(!src.detonate) return
	var/turf/T = get_turf(src.loc)

	if (ismob(loc))
		var/mob/M = loc
		M.show_message("<span class='danger'>Your [src] explodes!</span>", 1)

	if(T)
		T.hotspot_expose(700,125)

		explosion(T, -1, -1, 2, 3)

	qdel(src)
	return

/obj/item/device/pda/Destroy()
	PDAs -= src
	..()

/obj/item/device/pda/clown/Crossed(AM as mob|obj) //Clown PDA is slippery.
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if(M.slip(8, 5, src, NO_SLIP_WHEN_WALKING))
			if (ishuman(M) && (M.real_name != src.owner))
				if (istype(src.cartridge, /obj/item/weapon/cartridge/clown))
					var/obj/item/weapon/cartridge/clown/cart = src.cartridge
					if(cart.honk_charges < 5)
						cart.honk_charges++

//AI verb and proc for sending PDA messages.

/mob/living/silicon/ai/proc/cmd_send_pdamesg(mob/user as mob)
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if(user.stat == 2)
		user << "You can't send PDA messages because you are dead!"
		return

	if(src.aiPDA.toff)
		user << "Turn on your receiver in order to send messages."
		return

	for (var/obj/item/device/pda/P in get_viewable_pdas())
		if (P == src)
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

	var/c = input(user, "Please select a PDA") as null|anything in sortList(plist)

	if (!c)
		return

	var/selected = plist[c]

	if(aicamera.aipictures.len>0)
		var/add_photo = input(user,"Do you want to attach a photo?","Photo","No") as null|anything in list("Yes","No")
		if(add_photo=="Yes")
			var/datum/picture/Pic = aicamera.selectpicture(aicamera)
			src.aiPDA.photo = Pic.fields["img"]
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

/mob/living/silicon/ai/verb/cmd_use_chatroom()
	set category = "AI Commands"
	set name = "PDA - Chatrooms"
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	if(!isnull(aiPDA))
		aiPDA.mode = 5
		aiPDA.attack_self(src)
	else
		usr << "You do not have a PDA. You should make an issue report about this."

/mob/living/silicon/ai/proc/cmd_show_message_log(mob/user as mob)
	if(user.stat == 2)
		user << "You can't do that because you are dead!"
		return
	if(!isnull(aiPDA))
		var/HTML = "<html><head><title>AI PDA Message Log</title></head><body>[aiPDA.tnote]</body></html>"
		user << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")
	else
		user << "You do not have a PDA. You should make an issue report about this."

//Some spare PDAs in a box
/obj/item/weapon/storage/box/PDAs
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/storage.dmi'
	icon_state = "pda"

/obj/item/weapon/storage/box/PDAs/New()
	..()
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/weapon/cartridge/head(src)

	var/newcart = pick(	/obj/item/weapon/cartridge/engineering,
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/medical,
						/obj/item/weapon/cartridge/signal/toxins,
						/obj/item/weapon/cartridge/quartermaster)
	new newcart(src)

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)
	emped += 1
	spawn(200 * severity)
		emped -= 1

//ntrc handler proc
/obj/item/device/pda/proc/msg_chat(channel as text, sender as text, message as text)
	var/msg = "<b>[html_encode(sender)]</b>| [html_encode(message)]<br>"
	if(!channel)
		for(var/C in ntrclog)
			ntrclog[C] = msg + ntrclog[C]
	else
		ntrclog[channel] = msg + ntrclog[channel]
	if (findtext(message, nick) && !silent)
		audible_message("\icon[src] *[ttone]*", null, 3)
	new_ntrc_msg++

/obj/item/device/pda/proc/setup_chatrooms() //this can't be done on New() because the messaging server needs to be instanced first
	if(!nick) //first time using the PDA
		//join the default chat channel
		nick = copytext(sanitize(owner), 1, 9)
		var/datum/chatroom/C = chatchannels[chat_channel]
		C.parse_msg(src, nick, "/join [chat_channel]")

/proc/get_viewable_pdas()
	. = list()
	// Returns a list of PDAs which can be viewed from another PDA/message monitor.
	for(var/obj/item/device/pda/P in PDAs)
		if(!P.owner || P.toff || P.hidden) continue
		. += P
	return .
