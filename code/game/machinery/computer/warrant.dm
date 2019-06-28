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

/obj/machinery/computer/warrant/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/card/id))
		if(!scan)
			if(!user.transferItemToLoc(O, src))
				return
			scan = O
			to_chat(user, "<span class='notice'>You insert [O].</span>")
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		else
			to_chat(user, "<span class='warning'>There's already an ID card in the console.</span>")
	else
		return ..()

/obj/machinery/computer/warrant/ui_interact(mob/user)
	. = ..()

	var/list/dat = list("Logged in as: ")
	if(!scan)
		dat += {"<a href='?src=[REF(src)];choice=Login'>------------</a><hr>"}
	else
		dat += {"<a href='?src=[REF(src)];choice=Logout'>[scan.name]</a><hr>"}
		for(var/datum/data/record/R in GLOB.data_core.security)
			if(R.fields["name"] == scan.registered_name)
				current = R
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
			dat += {"<br>Criminal Status:<br>
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

	var/datum/browser/popup = new(user, "warrant", "Security Warrant Console", 600, 400)
	popup.set_content(dat.Join())
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/warrant/Topic(href, href_list)
	if(..())
		return

	switch(href_list["choice"])
		if("Login")
			eject_id(usr)
			if(!scan)
				var/obj/item/card/id/O = usr.is_holding_item_of_type(/obj/item/card/id)
				if(O)
					if(!usr.transferItemToLoc(O, src))
						return
					scan = O
					updateUsrDialog()
				else
					to_chat(usr, "<span class='danger'>No valid ID.</span>")

		if("Logout")
			eject_id(usr)
			updateUsrDialog()
			current = null

		if("Pay")
			for(var/datum/data/crime/p in current.fields["citation"])
				if(p.dataId == text2num(href_list["cdataid"]))
					var/datum/bank_account/R = scan.registered_account
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
						GLOB.data_core.payCitation(current.fields["id"], text2num(href_list["cdataid"]), pay)
						if (pay == diff)
							investigate_log("Citation Paid off: <strong>[p.crimeName]</strong> Fine: [p.fine] | Paid off by [key_name(usr)]", INVESTIGATE_RECORDS)
						updateUsrDialog()
						return
					else
						var/difference = pay - R.account_balance
						to_chat(usr, "<span class='warning'>ERROR: The linked account requires [difference] more credit\s to perform that withdrawal.</span>")

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
