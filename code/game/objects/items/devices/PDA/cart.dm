/obj/item/weapon/cartridge
	name = "generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_TINY

	var/obj/item/radio/integrated/radio = null
	var/access_security = 0
	var/access_engine = 0
	var/access_atmos = 0
	var/access_medical = 0
	var/access_manifest = 0
	var/access_clown = 0
	var/access_mime = 0
	var/access_janitor = 0
//	var/access_flora = 0
	var/access_reagent_scanner = 0
	var/access_newscaster = 0
	var/access_remote_door = 0 //Control some blast doors remotely!!
	var/remote_door_id = ""
	var/access_status_display = 0
	var/access_quartermaster = 0
	var/access_hydroponics = 0
	var/access_dronephone = 0
	var/bot_access_flags = 0 //Bit flags. Selection: SEC_BOT|MULE_BOT|FLOOR_BOT|CLEAN_BOT|MED_BOT
	var/spam_enabled = 0 //Enables "Send to All" Option

	var/mode = null
	var/menu
	var/datum/data/record/active1 = null //General
	var/datum/data/record/active2 = null //Medical
	var/datum/data/record/active3 = null //Security
	var/obj/machinery/computer/monitor/powmonitor = null // Power Monitor
	var/list/powermonitors = list()
	var/message1	// used for status_displays
	var/message2
	var/list/stored_data = list()
	var/current_channel

	var/mob/living/simple_animal/bot/active_bot
	var/list/botlist = list()

/obj/item/weapon/cartridge/engineering
	name = "\improper Power-ON cartridge"
	icon_state = "cart-e"
	access_engine = 1
	access_dronephone = 1
	bot_access_flags = FLOOR_BOT

/obj/item/weapon/cartridge/atmos
	name = "\improper BreatheDeep cartridge"
	icon_state = "cart-a"
	access_atmos = 1
	access_dronephone = 1
	bot_access_flags = FLOOR_BOT

/obj/item/weapon/cartridge/medical
	name = "\improper Med-U cartridge"
	icon_state = "cart-m"
	access_medical = 1
	bot_access_flags = MED_BOT

/obj/item/weapon/cartridge/chemistry
	name = "\improper ChemWhiz cartridge"
	icon_state = "cart-chem"
	access_reagent_scanner = 1
	bot_access_flags = MED_BOT

/obj/item/weapon/cartridge/security
	name = "\improper R.O.B.U.S.T. cartridge"
	icon_state = "cart-s"
	access_security = 1
	bot_access_flags = SEC_BOT

/obj/item/weapon/cartridge/detective
	name = "\improper D.E.T.E.C.T. cartridge"
	icon_state = "cart-s"
	access_security = 1
	access_medical = 1
	access_manifest = 1
	bot_access_flags = SEC_BOT

/obj/item/weapon/cartridge/janitor
	name = "\improper CustodiPRO cartridge"
	desc = "The ultimate in clean-room design."
	icon_state = "cart-j"
	access_janitor = 1
	access_dronephone = 1
	bot_access_flags = CLEAN_BOT

/obj/item/weapon/cartridge/lawyer
	name = "\improper P.R.O.V.E. cartridge"
	icon_state = "cart-s"
	access_security = 1
	spam_enabled = 1

/obj/item/weapon/cartridge/clown
	name = "\improper Honkworks 5.0 cartridge"
	icon_state = "cart-clown"
	access_clown = 1
	var/honk_charges = 5

/obj/item/weapon/cartridge/mime
	name = "\improper Gestur-O 1000 cartridge"
	icon_state = "cart-mi"
	access_mime = 1
	var/mime_charges = 5

/obj/item/weapon/cartridge/librarian
	name = "\improper Lib-Tweet cartridge"
	icon_state = "cart-s"
	access_newscaster = 1

/*
/obj/item/weapon/cartridge/botanist
	name = "\improper Green Thumb v4.20 cartridge"
	icon_state = "cart-b"
	access_flora = 1
*/

/obj/item/weapon/cartridge/roboticist
	name = "\improper B.O.O.P. Remote Control cartridge"
	desc = "Packed with heavy duty triple-bot interlink!"
	bot_access_flags = FLOOR_BOT|CLEAN_BOT|MED_BOT
	access_dronephone = 1

/obj/item/weapon/cartridge/signal
	name = "generic signaler cartridge"
	desc = "A data cartridge with an integrated radio signaler module."

/obj/item/weapon/cartridge/signal/toxins
	name = "\improper Signal Ace 2 cartridge"
	desc = "Complete with integrated radio signaler!"
	icon_state = "cart-tox"
	access_reagent_scanner = 1
	access_atmos = 1

/obj/item/weapon/cartridge/signal/New()
	..()
	radio = new /obj/item/radio/integrated/signal(src)



/obj/item/weapon/cartridge/quartermaster
	name = "space parts & space vendors cartridge"
	desc = "Perfect for the Quartermaster on the go!"
	icon_state = "cart-q"
	access_quartermaster = 1
	bot_access_flags = MULE_BOT

/obj/item/weapon/cartridge/head
	name = "\improper Easy-Record DELUXE cartridge"
	icon_state = "cart-h"
	access_manifest = 1
	access_status_display = 1

/obj/item/weapon/cartridge/hop
	name = "\improper HumanResources9001 cartridge"
	icon_state = "cart-h"
	access_manifest = 1
	access_status_display = 1
	bot_access_flags = MULE_BOT|CLEAN_BOT
	access_janitor = 1
	access_security = 1
	access_newscaster = 1
	access_quartermaster = 1
	access_dronephone = 1

/obj/item/weapon/cartridge/hos
	name = "\improper R.O.B.U.S.T. DELUXE cartridge"
	icon_state = "cart-hos"
	access_manifest = 1
	access_status_display = 1
	access_security = 1
	bot_access_flags = SEC_BOT


/obj/item/weapon/cartridge/ce
	name = "\improper Power-On DELUXE cartridge"
	icon_state = "cart-ce"
	access_manifest = 1
	access_status_display = 1
	access_engine = 1
	access_atmos = 1
	access_dronephone = 1
	bot_access_flags = FLOOR_BOT

/obj/item/weapon/cartridge/cmo
	name = "\improper Med-U DELUXE cartridge"
	icon_state = "cart-cmo"
	access_manifest = 1
	access_status_display = 1
	access_reagent_scanner = 1
	access_medical = 1
	bot_access_flags = MED_BOT

/obj/item/weapon/cartridge/rd
	name = "\improper Signal Ace DELUXE cartridge"
	icon_state = "cart-rd"
	access_manifest = 1
	access_status_display = 1
	access_reagent_scanner = 1
	access_atmos = 1
	access_dronephone = 1
	bot_access_flags = FLOOR_BOT|CLEAN_BOT|MED_BOT

/obj/item/weapon/cartridge/rd/New()
	..()
	radio = new /obj/item/radio/integrated/signal(src)

/obj/item/weapon/cartridge/captain
	name = "\improper Value-PAK cartridge"
	desc = "Now with 350% more value!" //Give the Captain...EVERYTHING! (Except Mime and Clown)
	icon_state = "cart-c"
	access_manifest = 1
	access_engine = 1
	access_security = 1
	access_medical = 1
	access_reagent_scanner = 1
	access_status_display = 1
	access_atmos = 1
	access_newscaster = 1
	access_quartermaster = 1
	access_janitor = 1
	access_dronephone = 1
	bot_access_flags = SEC_BOT|MULE_BOT|FLOOR_BOT|CLEAN_BOT|MED_BOT
	spam_enabled = 1

/obj/item/weapon/cartridge/captain/New()
	..()
	radio = new /obj/item/radio/integrated/signal(src)

/obj/item/weapon/cartridge/syndicate
	name = "\improper Detomatix cartridge"
	icon_state = "cart"
	access_remote_door = 1
	remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!	//don't ask about the name, testing.
	var/shock_charges = 4

/obj/item/weapon/cartridge/proc/unlock()
	if (!istype(loc, /obj/item/device/pda))
		return

	generate_menu()
	print_to_host(menu)
	return

/obj/item/weapon/cartridge/proc/print_to_host(text)
	if (!istype(loc, /obj/item/device/pda))
		return
	var/obj/item/device/pda/P = loc
	P.cart = text

	for (var/mob/M in viewers(1, loc.loc))
		if (M.client && M.machine == loc)
			P.attack_self(M)

	return

/obj/item/weapon/cartridge/proc/post_status(command, data1, data2)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(1435)

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


/obj/item/weapon/cartridge/proc/generate_menu(mob/user)
	switch(mode)
		if(40) //signaller
			var/obj/item/radio/integrated/signal/S = radio
			menu = "<h4><img src=pda_signaler.png> Remote Signaling System</h4>"

			menu += {"
<a href='byond://?src=\ref[src];choice=Send Signal'>Send Signal</A><BR>
Frequency:
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=-10'>-</a>
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=-2'>-</a>
[format_frequency(S.frequency)]
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=2'>+</a>
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=10'>+</a><br>
<br>
Code:
<a href='byond://?src=\ref[src];choice=Signal Code;scode=-5'>-</a>
<a href='byond://?src=\ref[src];choice=Signal Code;scode=-1'>-</a>
[S.code]
<a href='byond://?src=\ref[src];choice=Signal Code;scode=1'>+</a>
<a href='byond://?src=\ref[src];choice=Signal Code;scode=5'>+</a><br>"}
		if (41) //crew manifest

			menu = "<h4><img src=pda_notes.png> Crew Manifest</h4>"
			menu += "Entries cannot be modified from this terminal.<br><br>"
			if(data_core.general)
				for (var/datum/data/record/t in sortRecord(data_core.general))
					menu += "[t.fields["name"]] - [t.fields["rank"]]<br>"
			menu += "<br>"


		if (42) //status displays
			menu = "<h4><img src=pda_status.png> Station Status Display Interlink</h4>"

			menu += "\[ <A HREF='?src=\ref[src];choice=Status;statdisp=blank'>Clear</A> \]<BR>"
			menu += "\[ <A HREF='?src=\ref[src];choice=Status;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			menu += "\[ <A HREF='?src=\ref[src];choice=Status;statdisp=message'>Message</A> \]"
			menu += "<ul><li> Line 1: <A HREF='?src=\ref[src];choice=Status;statdisp=setmsg1'>[ message1 ? message1 : "(none)"]</A>"
			menu += "<li> Line 2: <A HREF='?src=\ref[src];choice=Status;statdisp=setmsg2'>[ message2 ? message2 : "(none)"]</A></ul><br>"
			menu += "\[ Alert: <A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=default'>None</A> |"
			menu += " <A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=redalert'>Red Alert</A> |"
			menu += " <A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			menu += " <A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR>"

		if (43)
			menu = "<h4><img src=pda_power.png> Power Monitors - Please select one</h4><BR>"
			powmonitor = null
			powermonitors = list()
			var/powercount = 0



			for(var/obj/machinery/computer/monitor/pMon in machines)
				if(!(pMon.stat & (NOPOWER|BROKEN)) )
					powercount++
					powermonitors += pMon


			if(!powercount)
				menu += "<span class='danger'>No connection<BR></span>"
			else

				menu += "<FONT SIZE=-1>"
				var/count = 0
				for(var/obj/machinery/computer/monitor/pMon in powermonitors)
					count++
					menu += "<a href='byond://?src=\ref[src];choice=Power Select;target=[count]'>[pMon] </a><BR>"

				menu += "</FONT>"

		if (433)
			menu = "<h4><img src=pda_power.png> Power Monitor </h4><BR>"
			if(!powmonitor)
				menu += "<span class='danger'>No connection<BR></span>"
			else
				var/list/L = list()
				for(var/obj/machinery/power/terminal/term in powmonitor.attached.powernet.nodes)
					if(istype(term.master, /obj/machinery/power/apc))
						var/obj/machinery/power/apc/A = term.master
						L += A

				menu += "<PRE>Total power: [powmonitor.attached.powernet.viewavail] W<BR>Total load:  [num2text(powmonitor.attached.powernet.viewload,10)] W<BR>"

				menu += "<FONT SIZE=-1>"

				if(L.len > 0)
					menu += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

					var/list/S = list(" Off","AOff","  On", " AOn")
					var/list/chg = list("N","C","F")

					for(var/obj/machinery/power/apc/A in L)
						menu += copytext(add_tspace(A.area.name, 30), 1, 30)
						menu += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

				menu += "</FONT></PRE>"

		if (44) //medical records //This thing only displays a single screen so it's hard to really get the sub-menu stuff working.
			menu = "<h4><img src=pda_medical.png> Medical Record List</h4>"
			if(data_core.general)
				for(var/datum/data/record/R in sortRecord(data_core.general))
					menu += "<a href='byond://?src=\ref[src];choice=Medical Records;target=[R.fields["id"]]'>[R.fields["id"]]: [R.fields["name"]]<br>"
			menu += "<br>"
		if(441)
			menu = "<h4><img src=pda_medical.png> Medical Record</h4>"

			if(active1 in data_core.general)
				menu += "Name: [active1.fields["name"]] ID: [active1.fields["id"]]<br>"
				menu += "Sex: [active1.fields["sex"]]<br>"
				menu += "Age: [active1.fields["age"]]<br>"
				menu += "Rank: [active1.fields["rank"]]<br>"
				menu += "Fingerprint: [active1.fields["fingerprint"]]<br>"
				menu += "Physical Status: [active1.fields["p_stat"]]<br>"
				menu += "Mental Status: [active1.fields["m_stat"]]<br>"
			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"

			menu += "<h4><img src=pda_medical.png> Medical Data</h4>"
			if(active2 in data_core.medical)
				menu += "Blood Type: [active2.fields["blood_type"]]<br><br>"

				menu += "Minor Disabilities: [active2.fields["mi_dis"]]<br>"
				menu += "Details: [active2.fields["mi_dis_d"]]<br><br>"

				menu += "Major Disabilities: [active2.fields["ma_dis"]]<br>"
				menu += "Details: [active2.fields["ma_dis_d"]]<br><br>"

				menu += "Allergies: [active2.fields["alg"]]<br>"
				menu += "Details: [active2.fields["alg_d"]]<br><br>"

				menu += "Current Diseases: [active2.fields["cdi"]]<br>"
				menu += "Details: [active2.fields["cdi_d"]]<br><br>"

				menu += "Important Notes: [active2.fields["notes"]]<br>"
			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"
		if (45) //security records
			menu = "<h4><img src=pda_cuffs.png> Security Record List</h4>"
			if(data_core.general)
				for (var/datum/data/record/R in sortRecord(data_core.general))
					menu += "<a href='byond://?src=\ref[src];choice=Security Records;target=[R.fields["id"]]'>[R.fields["id"]]: [R.fields["name"]]<br>"

			menu += "<br>"
		if(451)
			menu = "<h4><img src=pda_cuffs.png> Security Record</h4>"

			if(active1 in data_core.general)
				menu += "Name: [active1.fields["name"]] ID: [active1.fields["id"]]<br>"
				menu += "Sex: [active1.fields["sex"]]<br>"
				menu += "Age: [active1.fields["age"]]<br>"
				menu += "Rank: [active1.fields["rank"]]<br>"
				menu += "Fingerprint: [active1.fields["fingerprint"]]<br>"
				menu += "Physical Status: [active1.fields["p_stat"]]<br>"
				menu += "Mental Status: [active1.fields["m_stat"]]<br>"
			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"

			menu += "<h4><img src=pda_cuffs.png> Security Data</h4>"
			if(active3 in data_core.security)
				menu += "Criminal Status: [active3.fields["criminal"]]<br>"

				menu += text("<BR>\nMinor Crimes:")

				menu +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
				for(var/datum/data/crime/c in active3.fields["mi_crim"])
					menu += "<tr><td>[c.crimeName]</td>"
					menu += "<td>[c.crimeDetails]</td>"
					menu += "<td>[c.author]</td>"
					menu += "<td>[c.time]</td>"
					menu += "</tr>"
				menu += "</table>"

				menu += text("<BR>\nMajor Crimes:")

				menu +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
				for(var/datum/data/crime/c in active3.fields["ma_crim"])
					menu += "<tr><td>[c.crimeName]</td>"
					menu += "<td>[c.crimeDetails]</td>"
					menu += "<td>[c.author]</td>"
					menu += "<td>[c.time]</td>"
					menu += "</tr>"
				menu += "</table>"

				menu += "<BR>\nImportant Notes:<br>"
				menu += "[active3.fields["notes"]]"
			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"

		if (47) //quartermaster order records
			menu = "<h4><img src=pda_crate.png> Supply Record Interlink</h4>"

			menu += "<BR><B>Supply shuttle</B><BR>"
			menu += "Location: "
			switch(SSshuttle.supply.mode)
				if(SHUTTLE_CALL)
					menu += "Moving to "
					if(SSshuttle.supply.z != ZLEVEL_STATION)
						menu += "station"
					else
						menu += "centcomm"
					menu += " ([SSshuttle.supply.timeLeft(600)] Mins)"
				else
					menu += "At "
					if(SSshuttle.supply.z != ZLEVEL_STATION)
						menu += "centcomm"
					else
						menu += "station"
			menu += "<BR>Current approved orders: <BR><ol>"
			for(var/S in SSshuttle.shoppinglist)
				var/datum/supply_order/SO = S
				menu += "<li>#[SO.id] - [SO.pack.name] approved by [SO.orderer] [SO.reason ? "([SO.reason])":""]</li>"
			menu += "</ol>"

			menu += "Current requests: <BR><ol>"
			for(var/S in SSshuttle.requestlist)
				var/datum/supply_order/SO = S
				menu += "<li>#[SO.id] - [SO.pack.name] requested by [SO.orderer]</li>"
			menu += "</ol><font size=\"-3\">Upgrade NOW to Space Parts & Space Vendors PLUS for full remote order control and inventory management."

		if (49) //janitorial locator
			menu = "<h4><img src=pda_bucket.png> Persistent Custodial Object Locator</h4>"

			var/turf/cl = get_turf(src)
			if (cl)
				menu += "Current Orbital Location: <b>\[[cl.x],[cl.y]\]</b>"

				menu += "<h4>Located Mops:</h4>"

				var/ldat
				for (var/obj/item/weapon/mop/M in world)
					var/turf/ml = get_turf(M)

					if(ml)
						if (ml.z != cl.z)
							continue
						var/direction = get_dir(src, M)
						ldat += "Mop - <b>\[[ml.x],[ml.y] ([uppertext(dir2text(direction))])\]</b> - [M.reagents.total_volume ? "Wet" : "Dry"]<br>"

				if (!ldat)
					menu += "None"
				else
					menu += "[ldat]"

				menu += "<h4>Located Janitorial Cart:</h4>"

				ldat = null
				for (var/obj/structure/janitorialcart/B in world)
					var/turf/bl = get_turf(B)

					if(bl)
						if (bl.z != cl.z)
							continue
						var/direction = get_dir(src, B)
						ldat += "Cart - <b>\[[bl.x],[bl.y] ([uppertext(dir2text(direction))])\]</b> - Water level: [B.reagents.total_volume]/100<br>"

				if (!ldat)
					menu += "None"
				else
					menu += "[ldat]"

				menu += "<h4>Located Cleanbots:</h4>"

				ldat = null
				for (var/mob/living/simple_animal/bot/cleanbot/B in living_mob_list)
					var/turf/bl = get_turf(B)

					if(bl)
						if (bl.z != cl.z)
							continue
						var/direction = get_dir(src, B)
						ldat += "Cleanbot - <b>\[[bl.x],[bl.y] ([uppertext(dir2text(direction))])\]</b> - [B.on ? "Online" : "Offline"]<br>"

				if (!ldat)
					menu += "None"
				else
					menu += "[ldat]"

			else
				menu += "ERROR: Unable to determine current location."
			menu += "<br><br><A href='byond://?src=\ref[src];choice=49'>Refresh GPS Locator</a>"

		if (53) // Newscaster
			menu = "<h4><img src=pda_notes.png> Newscaster Access</h4>"
			menu += "<br> Current Newsfeed: <A href='byond://?src=\ref[src];choice=Newscaster Switch Channel'>[current_channel ? current_channel : "None"]</a> <br>"
			var/datum/newscaster/feed_channel/current
			for(var/datum/newscaster/feed_channel/chan in news_network.network_channels)
				if (chan.channel_name == current_channel)
					current = chan
			if(!current)
				menu += "<h5> ERROR : NO CHANNEL FOUND </h5>"
				return
			var/i = 1
			for(var/datum/newscaster/feed_message/msg in current.messages)
				menu +="-[msg.returnBody(-1)] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[msg.returnAuthor(-1)]</FONT>\]</FONT><BR>"
				menu +="<b><font size=1>[msg.comments.len] comment[msg.comments.len > 1 ? "s" : ""]</font></b><br>"
				if(msg.img)
					user << browse_rsc(msg.img, "tmp_photo[i].png")
					menu +="<img src='tmp_photo[i].png' width = '180'><BR>"
				i++
				for(var/datum/newscaster/feed_comment/comment in msg.comments)
					menu +="<font size=1><small>[comment.body]</font><br><font size=1><small><small><small>[comment.author] [comment.time_stamp]</small></small></small></small></font><br>"
			menu += "<br> <A href='byond://?src=\ref[src];choice=Newscaster Message'>Post Message</a>"

		if (54) // Beepsky, Medibot, Floorbot, and Cleanbot access
			menu = "<h4><img src=pda_medbot.png> Bots Interlink</h4>"
			bot_control()

/obj/item/weapon/cartridge/Topic(href, href_list)
	..()

	if (!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr.unset_machine()
		usr << browse(null, "window=pda")
		return

	var/obj/item/device/pda/pda = loc

	switch(href_list["choice"])
		if("Medical Records")
			active1 = find_record("id", href_list["target"], data_core.general)
			if(active1)
				active2 = find_record("id", href_list["target"], data_core.medical)
			pda.mode = 441
			mode = 441
			if(!active2)
				active1 = null

		if("Security Records")
			active1 = find_record("id", href_list["target"], data_core.general)
			if(active1)
				active3 = find_record("id", href_list["target"], data_core.security)
			pda.mode = 451
			mode = 451
			if(!active3)
				active1 = null

		if("Send Signal")
			spawn( 0 )
				var/obj/item/radio/integrated/signal/S = radio
				S.send_signal("ACTIVATE")
				return

		if("Signal Frequency")
			var/obj/item/radio/integrated/signal/S = radio
			var/new_frequency = sanitize_frequency(S.frequency + text2num(href_list["sfreq"]))
			S.set_frequency(new_frequency)

		if("Signal Code")
			var/obj/item/radio/integrated/signal/S = radio
			S.code += text2num(href_list["scode"])
			S.code = round(S.code)
			S.code = min(100, S.code)
			S.code = max(1, S.code)

		if("Status")
			switch(href_list["statdisp"])
				if("message")
					post_status("message", message1, message2)
				if("alert")
					post_status("alert", href_list["alert"])
				if("setmsg1")
					message1 = reject_bad_text(input("Line 1", "Enter Message Text", message1) as text|null, 40)
					updateSelfDialog()
				if("setmsg2")
					message2 = reject_bad_text(input("Line 2", "Enter Message Text", message2) as text|null, 40)
					updateSelfDialog()
				else
					post_status(href_list["statdisp"])
		if("Power Select")
			var/pnum = text2num(href_list["target"])
			powmonitor = powermonitors[pnum]
			pda.mode = 433
			mode = 433

		if("Supply Orders")
			pda.mode =47
			mode = 47

		if("Newscaster Access")
			mode = 53

		if("Newscaster Message")
			var/pda_owner_name = pda.id ? "[pda.id.registered_name] ([pda.id.assignment])" : "Unknown"
			var/message = pda.msg_input()
			var/datum/newscaster/feed_channel/current
			for(var/datum/newscaster/feed_channel/chan in news_network.network_channels)
				if (chan.channel_name == current_channel)
					current = chan
			if(current.locked && current.author != pda_owner_name)
				pda.cart += "<h5> ERROR : NOT AUTHORIZED [pda.id ? "" : "- ID SLOT EMPTY"] </h5>"
				pda.Topic(null,list("choice"="Refresh"))
				return
			news_network.SubmitArticle(message,pda.owner,current_channel)
			pda.Topic(null,list("choice"=num2text(mode)))
			return

		if("Newscaster Switch Channel")
			current_channel = pda.msg_input()
			pda.Topic(null,list("choice"=num2text(mode)))
			return

	//Bot control section! Viciously ripped from radios for being laggy and terrible.
	if(href_list["op"])
		switch(href_list["op"])

			if("control")
				active_bot = locate(href_list["bot"])

			if("botlist")
				active_bot = null
			if("summon") //Args are in the correct order, they are stated here just as an easy reminder.
				active_bot.bot_control(command= "summon", user_turf= get_turf(usr), user_access= pda.GetAccess())
			else //Forward all other bot commands to the bot itself!
				active_bot.bot_control(command= href_list["op"], user= usr)

	if(href_list["mule"]) //MULEbots are special snowflakes, and need different args due to how they work.

		active_bot.bot_control(command= href_list["mule"], user= usr, pda= 1)

	generate_menu(usr)
	print_to_host(menu)



/obj/item/weapon/cartridge/proc/bot_control()


	var/mob/living/simple_animal/bot/Bot

//	if(!SC)
//		menu = "Interlink Error - Please reinsert cartridge."
//		return
	if(active_bot)
		menu += "<B>[active_bot]</B><BR> Status: (<A href='byond://?src=\ref[src];op=control;bot=\ref[active_bot]'><img src=pda_refresh.png><i>refresh</i></A>)<BR>"
		menu += "Model: [active_bot.model]<BR>"
		menu += "Location: [get_area(active_bot)]<BR>"
		menu += "Mode: [active_bot.get_mode()]"
		if(active_bot.allow_pai)
			menu += "<BR>pAI: "
			if(active_bot.paicard && active_bot.paicard.pai)
				menu += "[active_bot.paicard.pai.name]"
				if(active_bot.bot_core.allowed(usr))
					menu += " (<A href='byond://?src=\ref[src];op=ejectpai'><i>eject</i></A>)"
			else
				menu += "<i>none</i>"

		//MULEs!
		if(active_bot.bot_type == MULE_BOT)
			var/mob/living/simple_animal/bot/mulebot/MULE = active_bot
			var/atom/Load = MULE.load
			menu += "<BR>Current Load: [ !Load ? "<i>none</i>" : "[Load.name] (<A href='byond://?src=\ref[src];mule=unload'><i>unload</i></A>)" ]<BR>"
			menu += "Destination: [MULE.destination ? MULE.destination : "<i>None</i>"] (<A href='byond://?src=\ref[src];mule=destination'><i>set</i></A>)<BR>"
			menu += "Set ID: [MULE.suffix] <A href='byond://?src=\ref[src];mule=setid'><i> Modify</i></A><BR>"
			menu += "Power: [MULE.cell ? MULE.cell.percent() : 0]%<BR>"
			menu += "Home: [!MULE.home_destination ? "<i>none</i>" : MULE.home_destination ]<BR>"
			menu += "Delivery Reporting: <A href='byond://?src=\ref[src];mule=report'>[MULE.report_delivery ? "(<B>On</B>)": "(<B>Off</B>)"]</A><BR>"
			menu += "Auto Return Home: <A href='byond://?src=\ref[src];mule=autoret'>[MULE.auto_return ? "(<B>On</B>)": "(<B>Off</B>)"]</A><BR>"
			menu += "Auto Pickup Crate: <A href='byond://?src=\ref[src];mule=autopick'>[MULE.auto_pickup ? "(<B>On</B>)": "(<B>Off</B>)"]</A><BR><BR>" //Hue.

			menu += "\[<A href='byond://?src=\ref[src];mule=stop'>Stop</A>\] "
			menu += "\[<A href='byond://?src=\ref[src];mule=go'>Proceed</A>\] "
			menu += "\[<A href='byond://?src=\ref[src];mule=home'>Return Home</A>\]<BR>"

		else
			menu += "<BR>\[<A href='byond://?src=\ref[src];op=patroloff'>Stop Patrol</A>\] "	//patrolon
			menu += "\[<A href='byond://?src=\ref[src];op=patrolon'>Start Patrol</A>\] "	//patroloff
			menu += "\[<A href='byond://?src=\ref[src];op=summon'>Summon Bot</A>\]<BR>"		//summon
			menu += "Keep an ID inserted to upload access codes upon summoning."

		menu += "<HR><A href='byond://?src=\ref[src];op=botlist'><img src=pda_back.png>Return to bot list</A>"
	else
		menu += "<BR><A href='byond://?src=\ref[src];op=botlist'><img src=pda_refresh.png>Scan for active bots</A><BR><BR>"
		var/turf/current_turf = get_turf(src)
		var/zlevel = current_turf.z
		var/botcount = 0
		for(Bot in living_mob_list) //Git da botz
			if(!Bot.on || Bot.z != zlevel || Bot.remote_disabled || !(bot_access_flags & Bot.bot_type)) //Only non-emagged bots on the same Z-level are detected!
				continue //Also, the PDA must have access to the bot type.
			menu += "<A href='byond://?src=\ref[src];op=control;bot=\ref[Bot]'><b>[Bot.name]</b> ([Bot.get_mode()])<BR>"
			botcount++
		if(!botcount) //No bots at all? Lame.
			menu += "No bots found.<BR>"
			return

	return menu
