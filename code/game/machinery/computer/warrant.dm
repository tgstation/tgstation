/obj/machinery/computer/warrant//TODO:SANITY
	name = "security warrant console"
	desc = "Used to view a crewmembers security records"
	icon_screen = "security"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/warrant
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/warrant/examine(mob/user)
	. = ..()
	if(scan)
		. += "<span class='notice'>Alt-click to eject the ID card.</span>"

/obj/machinery/computer/warrant/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/card/id))
		if(!scan)
			if(!user.transferItemToLoc(O, src))
				return
			scan = O
			to_chat(user, "<span class='notice'>You insert [O].</span>")
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>There's already an ID card in the console.</span>")
	else
		return ..()

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/warrant/ui_interact(mob/user)
	. = ..()
	if(src.z > 6)
		to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return
	var/dat

	if(temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=[REF(src)];choice=Clear Screen'>Clear Screen</A>", temp)
	else
		dat = text("Confirm Identity: <A href='?src=[REF(src)];choice=Confirm Identity'>[]</A><HR>", (scan ? text("[]", scan.name) : "----------"))
		if(authenticated)
			for(var/datum/data/record/R in GLOB.data_core.security)
				if(R.fields["name"] == scan.registered_name)
					active2 = R
			if(istype(active2, /datum/data/record))
				var/background
				var/notice = ""
				switch(active2.fields["criminal"])
					if("*Arrest*")
						background = "background-color:#990000;"
						notice = "<br>**REPORT TO THE BRIG**"
					if("Incarcerated")
						background = "background-color:#CD6500;"
					if("Paroled")
						background = "background-color:#CD6500;"
					if("Discharged")
						background = "background-color:#006699;"
					if("None")
						background = "background-color:#4F7529;"
					if("")
						background = "''" //"'background-color:#FFFFFF;'"
				dat += "<font size='4'><b>Warrant Data</b></font>"
				dat += {"<table>
				<tr><td>Name:</td><td>&nbsp;[active2.fields["name"]]&nbsp;</td></tr>
				<tr><td>ID:</td><td>&nbsp;[active2.fields["id"]]&nbsp;</td></tr>
				</table>"}
				dat += "<br>Criminal Status:<br><div style='[background] padding: 3px; text-align: center;'><strong>[active2.fields["criminal"]][notice]</strong></div>"
				dat += "<br><br>Citations:"

				dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
				<tr>
				<th>Crime</th>
				<th>Fine</th>
				<th>Author</th>
				<th>Time Added</th>
				<th>Amount Due</th>
				<th>Make Payment</th>
				</tr>"}
				for(var/datum/data/crime/c in active2.fields["citation"])
					var/owed = c.fine - c.paid
					dat += "<tr><td>[c.crimeName]</td>"
					dat += "<td>$[c.fine]</td>"
					dat += "<td>[c.author]</td>"
					dat += "<td>[c.time]</td>"
					if(owed > 0)
						dat += "<td>$[owed]</td>"
						dat += "<td><A href='?src=[REF(src)];choice=Pay;field=citation_pay;cdataid=[c.dataId]'>\[Pay\]</A></td>"
					else
						dat += "<td colspan='2'>All Paid Off</td>"
					dat += "</tr>"
				dat += "</table>"

				dat += "<br>Minor Crimes:"
				dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
				<tr>
				<th>Crime</th>
				<th>Details</th>
				<th>Author</th>
				<th>Time Added</th>
				</tr>"}
				for(var/datum/data/crime/c in active2.fields["mi_crim"])
					dat += "<tr><td>[c.crimeName]</td>"
					dat += "<td>[c.crimeDetails]</td>"
					dat += "<td>[c.author]</td>"
					dat += "<td>[c.time]</td>"
					dat += "</tr>"
				dat += "</table>"

				dat += "<br>Major Crimes:"
				dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
				<tr>
				<th>Crime</th>
				<th>Details</th>
				<th>Author</th>
				<th>Time Added</th>
				</tr>"}
				for(var/datum/data/crime/c in active2.fields["ma_crim"])
					dat += "<tr><td>[c.crimeName]</td>"
					dat += "<td>[c.crimeDetails]</td>"
					dat += "<td>[c.author]</td>"
					dat += "<td>[c.time]</td>"
					dat += "</tr>"
				dat += "</table>"

				dat += "<HR><A href='?src=[REF(src)];choice=Log Out'>{Log Out}</A>"
			else
				dat += "<br>Security Record Lost!<br>"
		else
			dat += "<A href='?src=[REF(src)];choice=Log In'>{Log In}</A>"
	var/datum/browser/popup = new(user, "secure_rec", "Security Warrant Console", 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/warrant/Topic(href, href_list)
	. = ..()
	if(.)
		return .
	if(!( GLOB.data_core.general.Find(active1) ))
		active1 = null
	if(!( GLOB.data_core.security.Find(active2) ))
		active2 = null
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr) || IsAdminGhost(usr))
		usr.set_machine(src)
		switch(href_list["choice"])
//BASIC FUNCTIONS
			if("Clear Screen")
				temp = null

			if("Return")
				screen = 1
				active1 = null
				active2 = null

			if("Confirm Identity")
				authenticated = null
				screen = null
				active1 = null
				active2 = null
				eject_id(usr)

			if("Log Out")
				authenticated = null
				screen = null
				active1 = null
				active2 = null

			if("Log In")
				if(issilicon(usr))
					var/mob/living/silicon/borg = usr
					active1 = null
					active2 = null
					authenticated = borg.name
					rank = "AI"
					screen = 1
				else if(IsAdminGhost(usr))
					active1 = null
					active2 = null
					authenticated = usr.client.holder.admin_signature
					rank = "Central Command"
					screen = 1
				else if(istype(scan, /obj/item/card/id))
					active1 = null
					active2 = null
					if(check_access(scan))
						authenticated = scan.registered_name
						rank = scan.assignment
						screen = 1
//RECORD FUNCTIONS

			if("Browse Record")
				var/datum/data/record/R = locate(href_list["d_rec"]) in GLOB.data_core.general
				if(!R)
					temp = "Record Not Found!"
				else
					active1 = active2 = R
					for(var/datum/data/record/E in GLOB.data_core.security)
						if((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
							active2 = E
					screen = 3

			if("Pay")
				for(var/datum/data/crime/p in active2.fields["citation"])
					if(p.dataId == text2num(href_list["cdataid"]))
						var/datum/bank_account/R = scan.registered_account
						to_chat(world, "Found your citation and your account!")
						var/diff = p.fine - p.paid
						var/pay = FLOOR(input(usr, "Please enter how much you would like to pay:", "Citation Payment", 50) as num, 1)
						if(!pay || pay < 0)
							to_chat(usr, "<span class='warning'>You're pretty sure that's not how money works.</span>")
							return
						if(pay > diff)
							to_chat(usr, "<span class='notice'>You only owe $[diff] credit\s to pay off this fine.</span>")
							return
						if(R.adjust_money(-pay))
							to_chat(usr, "<span class='notice'>You have paid $[pay] credit\s towards your fine.</span>")
							var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_SEC)
							D.adjust_money(pay)
							GLOB.data_core.payCitation(active2.fields["id"], text2num(href_list["cdataid"]), pay)
							if (pay == diff)
								investigate_log("Citation Paid off: <strong>[p.crimeName]</strong> Fine: [p.fine] | Paid off by [key_name(usr)]", INVESTIGATE_RECORDS)
							updateUsrDialog()
							return
						else
							var/difference = pay - R.account_balance
							to_chat(usr, "<span class='warning'>ERROR: The linked account requires [difference] more credit\s to perform that withdrawal.</span>")


//TEMPORARY MENU FUNCTIONS
			else//To properly clear as per clear screen.
				temp=null
	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/warrant/proc/get_photo(mob/user)
	var/obj/item/photo/P = null
	if(issilicon(user))
		var/mob/living/silicon/tempAI = user
		var/datum/picture/selection = tempAI.GetPhoto(user)
		if(selection)
			P = new(null, selection)
	else if(istype(user.get_active_held_item(), /obj/item/photo))
		P = user.get_active_held_item()
	return P

/obj/machinery/computer/warrant/emp_act(severity)
	. = ..()

	if(stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_SELF)
		return

/obj/machinery/computer/warrant/proc/canUseSecurityRecordsConsole(mob/user, message1 = 0, record1, record2)
	if(user)
		if(authenticated)
			if(user.canUseTopic(src, BE_CLOSE))
				if(!trim(message1))
					return 0
				if(!record1 || record1 == active1)
					if(!record2 || record2 == active2)
						return 1
	return 0

/obj/machinery/computer/warrant/AltClick(mob/user)
	if(user.canUseTopic(src, !issilicon(user)))
		eject_id(user)

/obj/machinery/computer/warrant/proc/eject_id(mob/user)
	if(scan)
		scan.forceMove(drop_location())
		if(!issilicon(user) && Adjacent(user))
			user.put_in_hands(scan)
		scan = null
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	else //switching the ID with the one you're holding
		if(issilicon(user) || !Adjacent(user))
			return
		var/obj/item/card/id/held_id = user.is_holding_item_of_type(/obj/item/card/id)
		if(QDELETED(held_id) || !user.transferItemToLoc(held_id, src))
			return
		scan = held_id
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
