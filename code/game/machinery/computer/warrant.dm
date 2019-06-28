/obj/machinery/computer/warrant//TODO:SANITY
	name = "security warrant console"
	desc = "Used to view crewmember security records"
	icon_screen = "security"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/warrant
	light_color = LIGHT_COLOR_RED
	var/obj/item/card/id/scan = null
	var/screen = null
	var/datum/data/record/current = null

/obj/machinery/computer/warrant/Initialize()
	. = ..()

/obj/machinery/computer/warrant/examine(mob/user)
	. = ..()
	if(scan)
		. += "<span class='notice'>Alt-click to eject the ID card.</span>"

/obj/machinery/computer/warrant/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		attack_hand(user)
	else
		return ..()

/obj/machinery/computer/warrant/ui_interact(mob/user)
	. = ..()

	var/list/dat = list("Logged in as: ")
	if(scan)
		dat += {"<a href='?src=[REF(src)];choice=Logout'>[scan.registered_name]</a><hr>"}
		if(current)
			var/background
			var/notice = ""
			switch(current.fields["criminal"])
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
			<tr><td>Name:</td><td>&nbsp;[current.fields["name"]]&nbsp;</td></tr>
			<tr><td>ID:</td><td>&nbsp;[current.fields["id"]]&nbsp;</td></tr>
			</table>"}
			dat += {"Criminal Status:<br>
			<div style='[background] padding: 3px; text-align: center;'>
			<strong>[current.fields["criminal"]][notice]</strong>
			</div>"}

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
			for(var/datum/data/crime/c in current.fields["citation"])
				var/owed = c.fine - c.paid
				dat += {"<tr><td>[c.crimeName]</td>
				<td>$[c.fine]</td>
				<td>[c.author]</td>
				<td>[c.time]</td>"}
				if(owed > 0)
					dat += {"<td>$[owed]</td>
					<td><A href='?src=[REF(src)];choice=Pay;field=citation_pay;cdataid=[c.dataId]'>\[Pay\]</A></td>"}
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
			for(var/datum/data/crime/c in current.fields["mi_crim"])
				dat += {"<tr><td>[c.crimeName]</td>
				<td>[c.crimeDetails]</td>
				<td>[c.author]</td>
				<td>[c.time]</td>
				</tr>"}
			dat += "</table>"

			dat += "<br>Major Crimes:"
			dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
			<tr>
			<th>Crime</th>
			<th>Details</th>
			<th>Author</th>
			<th>Time Added</th>
			</tr>"}
			for(var/datum/data/crime/c in current.fields["ma_crim"])
				dat += {"<tr><td>[c.crimeName]</td>
				<td>[c.crimeDetails]</td>
				<td>[c.author]</td>
				<td>[c.time]</td>
				</tr>"}
			dat += "</table>"
		else
			dat += {"<span>** No security record found for this ID **</span>"}
	else
		dat += {"<a href='?src=[REF(src)];choice=Login'>------------</a><hr>"}

	var/datum/browser/popup = new(user, "warrant", "Security Warrant Console", 600, 400)
	popup.set_content(dat.Join())
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/warrant/Topic(href, href_list)
	if(..())
		return

	switch(href_list["choice"])
		if("Login")
			var/mob/M = usr
			scan = M.get_idcard(TRUE)
			if(scan && istype(scan))
				for(var/datum/data/record/R in GLOB.data_core.security)
					if(R.fields["name"] == scan.registered_name)
						current = R
				playsound(src, 'sound/machines/terminal_on.ogg', 50, 0)
		if("Logout")
			current = null
			scan = null
			playsound(src, 'sound/machines/terminal_off.ogg', 50, 0)

		if("Pay")
			for(var/datum/data/crime/p in current.fields["citation"])
				if(p.dataId == text2num(href_list["cdataid"]))
					var/obj/item/holochip/C = usr.is_holding_item_of_type(/obj/item/holochip)
					if(C && istype(C))
						var/pay = C.get_item_credit_value()
						if(!pay)
							to_chat(usr, "<span class='warning'>[C] doesn't seem to be worth anything!</span>")
						else
							var/diff = p.fine - p.paid
							GLOB.data_core.payCitation(current.fields["id"], text2num(href_list["cdataid"]), pay)
							to_chat(usr, "<span class='notice'>You have paid [pay] credit\s towards your fine</span>")
							if (pay == diff || pay > diff || pay >= diff)
								investigate_log("Citation Paid off: <strong>[p.crimeName]</strong> Fine: [p.fine] | Paid off by [key_name(usr)]", INVESTIGATE_RECORDS)
								to_chat(usr, "<span class='notice'>The fine has been paid in full</span>")
							qdel(C)
							playsound(src, "terminal_type", 25, 0)
					else
						to_chat(usr, "<span class='warning'>Fines can only be paid with holochips</span>")
	updateUsrDialog()
	add_fingerprint(usr)


/obj/machinery/computer/warrant/emp_act(severity)
	. = ..()

	if(stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_SELF)
		return

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
