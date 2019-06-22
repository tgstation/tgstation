/obj/machinery/computer/warrant//TODO:SANITY
	name = "security records console"
	desc = "Used to view and edit personnel's security records."
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

/obj/machinery/computer/warrant/syndie
	icon_keyboard = "syndie_key"

/obj/machinery/computer/warrant/laptop
	name = "security laptop"
	desc = "A cheap Nanotrasen security laptop, it functions as a security records console. It's bolted to the table."
	icon_state = "laptop"
	icon_screen = "seclaptop"
	icon_keyboard = "laptop_key"
	clockwork = TRUE //it'd look weird
	pass_flags = PASSTABLE

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
			switch(screen)
				if(1)

					//body tag start + onload and onkeypress (onkeyup) javascript event calls
					dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"
					//search bar javascript
					dat += {"

		<head>
			<script src="jquery.min.js"></script>
			<script type='text/javascript'>

				function updateSearch(){
					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{
						$("#maintable_data").children("tbody").children("tr").children("td").children("input").filter(function(index)
						{
							return $(this)\[0\].value.toLowerCase().indexOf(filter) == -1
						}).parent("td").parent("tr").hide()
					}
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}
					dat += {"
<p style='text-align:center;'>"}
					dat += "<A href='?src=[REF(src)];choice=New Record (General)'>New Record</A><BR>"
					//search bar
					dat += {"
						<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
							<tr id='search_tr'>
								<td align='center'>
									<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
								</td>
							</tr>
						</table>
					"}
					dat += {"
</p>
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>
<th>Records:</th>
</tr>
</table>

<span id='maintable_data_archive'>
<table id='maintable_data' style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th><A href='?src=[REF(src)];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=[REF(src)];choice=Sorting;sort=id'>ID</A></th>
<th><A href='?src=[REF(src)];choice=Sorting;sort=rank'>Rank</A></th>
<th><A href='?src=[REF(src)];choice=Sorting;sort=fingerprint'>Fingerprints</A></th>
<th>Criminal Status</th>
</tr>"}
					if(!isnull(GLOB.data_core.general))
						for(var/datum/data/record/R in sortRecord(GLOB.data_core.general, sortBy, order))
							var/crimstat = ""
							for(var/datum/data/record/E in GLOB.data_core.security)
								if((E.fields["name"] == R.fields["name"]) && (E.fields["id"] == R.fields["id"]))
									crimstat = E.fields["criminal"]
							var/background
							switch(crimstat)
								if("*Arrest*")
									background = "'background-color:#990000;'"
								if("Incarcerated")
									background = "'background-color:#CD6500;'"
								if("Paroled")
									background = "'background-color:#CD6500;'"
								if("Discharged")
									background = "'background-color:#006699;'"
								if("None")
									background = "'background-color:#4F7529;'"
								if("")
									background = "''" //"'background-color:#FFFFFF;'"
									crimstat = "No Record."
							dat += "<tr style=[background]>"
							dat += text("<td><input type='hidden' value='[] [] [] []'></input><A href='?src=[REF(src)];choice=Browse Record;d_rec=[REF(R)]'>[]</a></td>", R.fields["name"], R.fields["id"], R.fields["rank"], R.fields["fingerprint"], R.fields["name"])
							dat += text("<td>[]</td>", R.fields["id"])
							dat += text("<td>[]</td>", R.fields["rank"])
							dat += text("<td>[]</td>", R.fields["fingerprint"])
							dat += text("<td>[]</td></tr>", crimstat)
						dat += {"
						</table></span>
						<script type='text/javascript'>
							var maintable = document.getElementById("maintable_data_archive");
							var complete_list = maintable.innerHTML;
						</script>
						<hr width='75%' />"}
					dat += "<A href='?src=[REF(src)];choice=Record Maintenance'>Record Maintenance</A><br><br>"
					dat += "<A href='?src=[REF(src)];choice=Log Out'>{Log Out}</A>"
				if(2)
					dat += "<B>Records Maintenance</B><HR>"
					dat += "<BR><A href='?src=[REF(src)];choice=Delete All Records'>Delete All Records</A><BR><BR><A href='?src=[REF(src)];choice=Return'>Back</A>"
				if(3)
					dat += "<font size='4'><b>Security Record</b></font><br>"
					if(istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1))
						if(istype(active1.fields["photo_front"], /obj/item/photo))
							var/obj/item/photo/P1 = active1.fields["photo_front"]
							user << browse_rsc(P1.picture.picture_image, "photo_front")
						if(istype(active1.fields["photo_side"], /obj/item/photo))
							var/obj/item/photo/P2 = active1.fields["photo_side"]
							user << browse_rsc(P2.picture.picture_image, "photo_side")
						dat += {"<table><tr><td><table>
						<tr><td>Name:</td><td><A href='?src=[REF(src)];choice=Edit Field;field=name'>&nbsp;[active1.fields["name"]]&nbsp;</A></td></tr>
						<tr><td>ID:</td><td><A href='?src=[REF(src)];choice=Edit Field;field=id'>&nbsp;[active1.fields["id"]]&nbsp;</A></td></tr>
						<tr><td>Gender:</td><td><A href='?src=[REF(src)];choice=Edit Field;field=gender'>&nbsp;[active1.fields["gender"]]&nbsp;</A></td></tr>
						<tr><td>Age:</td><td><A href='?src=[REF(src)];choice=Edit Field;field=age'>&nbsp;[active1.fields["age"]]&nbsp;</A></td></tr>"}
						dat += "<tr><td>Species:</td><td><A href ='?src=[REF(src)];choice=Edit Field;field=species'>&nbsp;[active1.fields["species"]]&nbsp;</A></td></tr>"
						dat += {"<tr><td>Rank:</td><td><A href='?src=[REF(src)];choice=Edit Field;field=rank'>&nbsp;[active1.fields["rank"]]&nbsp;</A></td></tr>
						<tr><td>Fingerprint:</td><td><A href='?src=[REF(src)];choice=Edit Field;field=fingerprint'>&nbsp;[active1.fields["fingerprint"]]&nbsp;</A></td></tr>
						<tr><td>Physical Status:</td><td>&nbsp;[active1.fields["p_stat"]]&nbsp;</td></tr>
						<tr><td>Mental Status:</td><td>&nbsp;[active1.fields["m_stat"]]&nbsp;</td></tr>
						</table></td>
						<td><table><td align = center><a href='?src=[REF(src)];choice=Edit Field;field=show_photo_front'><img src=photo_front height=80 width=80 border=4></a><br>
						<a href='?src=[REF(src)];choice=Edit Field;field=print_photo_front'>Print photo</a><br>
						<a href='?src=[REF(src)];choice=Edit Field;field=upd_photo_front'>Update front photo</a></td>
						<td align = center><a href='?src=[REF(src)];choice=Edit Field;field=show_photo_side'><img src=photo_side height=80 width=80 border=4></a><br>
						<a href='?src=[REF(src)];choice=Edit Field;field=print_photo_side'>Print photo</a><br>
						<a href='?src=[REF(src)];choice=Edit Field;field=upd_photo_side'>Update side photo</a></td></table>
						</td></tr></table></td></tr></table>"}
					else
						dat += "<br>General Record Lost!<br>"
					if((istype(active2, /datum/data/record) && GLOB.data_core.security.Find(active2)))
						dat += "<font size='4'><b>Security Data</b></font>"
						dat += "<br>Criminal Status: <A href='?src=[REF(src)];choice=Edit Field;field=criminal'>[active2.fields["criminal"]]</A>"
						dat += "<br><br>Citations: <A href='?src=[REF(src)];choice=Edit Field;field=citation_add'>Add New</A>"

						dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th>Crime</th>
						<th>Fine</th>
						<th>Author</th>
						<th>Time Added</th>
						<th>Del</th>
						</tr>"}
						for(var/datum/data/crime/c in active2.fields["citation"])
							dat += "<tr><td>[c.crimeName]</td>"
							dat += "<td>$[c.fine]</td>"
							dat += "<td>[c.author]</td>"
							dat += "<td>[c.time]</td>"
							dat += "<td><A href='?src=[REF(src)];choice=Edit Field;field=citation_delete;cdataid=[c.dataId]'>\[X\]</A></td>"
							dat += "</tr>"
						dat += "</table>"

						dat += "<br><br>Minor Crimes: <A href='?src=[REF(src)];choice=Edit Field;field=mi_crim_add'>Add New</A>"


						dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th>Crime</th>
						<th>Details</th>
						<th>Author</th>
						<th>Time Added</th>
						<th>Del</th>
						</tr>"}
						for(var/datum/data/crime/c in active2.fields["mi_crim"])
							dat += "<tr><td>[c.crimeName]</td>"
							dat += "<td>[c.crimeDetails]</td>"
							dat += "<td>[c.author]</td>"
							dat += "<td>[c.time]</td>"
							dat += "<td><A href='?src=[REF(src)];choice=Edit Field;field=mi_crim_delete;cdataid=[c.dataId]'>\[X\]</A></td>"
							dat += "</tr>"
						dat += "</table>"


						dat += "<br>Major Crimes: <A href='?src=[REF(src)];choice=Edit Field;field=ma_crim_add'>Add New</A>"

						dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th>Crime</th>
						<th>Details</th>
						<th>Author</th>
						<th>Time Added</th>
						<th>Del</th>
						</tr>"}
						for(var/datum/data/crime/c in active2.fields["ma_crim"])
							dat += "<tr><td>[c.crimeName]</td>"
							dat += "<td>[c.crimeDetails]</td>"
							dat += "<td>[c.author]</td>"
							dat += "<td>[c.time]</td>"
							dat += "<td><A href='?src=[REF(src)];choice=Edit Field;field=ma_crim_delete;cdataid=[c.dataId]'>\[X\]</A></td>"
							dat += "</tr>"
						dat += "</table>"

						dat += "<br>\nImportant Notes:<br>\n\t<A href='?src=[REF(src)];choice=Edit Field;field=notes'>&nbsp;[active2.fields["notes"]]&nbsp;</A>"
						dat += "<br><br><font size='4'><b>Comments/Log</b></font><br>"
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							dat += (active2.fields[text("com_[]", counter)] + "<BR>")
							if(active2.fields[text("com_[]", counter)] != "<B>Deleted</B>")
								dat += text("<A href='?src=[REF(src)];choice=Delete Entry;del_c=[]'>Delete Entry</A><BR><BR>", counter)
							counter++
						dat += "<A href='?src=[REF(src)];choice=Add Entry'>Add Entry</A><br><br>"
						dat += "<A href='?src=[REF(src)];choice=Delete Record (Security)'>Delete Record (Security Only)</A><br>"
					else
						dat += "Security Record Lost!<br>"
						dat += "<A href='?src=[REF(src)];choice=New Record (Security)'>New Security Record</A><br><br>"
					dat += "<A href='?src=[REF(src)];choice=Delete Record (ALL)'>Delete Record (ALL)</A><br><A href='?src=[REF(src)];choice=Print Record'>Print Record</A><BR><A href='?src=[REF(src)];choice=Print Poster'>Print Wanted Poster</A><BR><A href='?src=[REF(src)];choice=Print Missing'>Print Missing Persons Poster</A><BR><A href='?src=[REF(src)];choice=Return'>Back</A><BR><BR>"
					dat += "<A href='?src=[REF(src)];choice=Log Out'>{Log Out}</A>"
				else
		else
			dat += "<A href='?src=[REF(src)];choice=Log In'>{Log In}</A>"
	var/datum/browser/popup = new(user, "secure_rec", "Security Records Console", 600, 400)
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
// SORTING!
			if("Sorting")
				// Reverse the order if clicked twice
				if(sortBy == href_list["sort"])
					if(order == 1)
						order = -1
					else
						order = 1
				else
				// New sorting order!
					sortBy = href_list["sort"]
					order = initial(order)
//BASIC FUNCTIONS
			if("Clear Screen")
				temp = null

			if("Return")
				screen = 1
				active1 = null
				active2 = null

			if("Confirm Identity")
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
			if("Record Maintenance")
				screen = 2
				active1 = null
				active2 = null

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


			if("Print Record")
				if(!( printing ))
					printing = 1
					GLOB.data_core.securityPrintCount++
					playsound(loc, 'sound/items/poster_being_created.ogg', 100, 1)
					sleep(30)
					var/obj/item/paper/P = new /obj/item/paper( loc )
					P.info = "<CENTER><B>Security Record - (SR-[GLOB.data_core.securityPrintCount])</B></CENTER><BR>"
					if((istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1)))
						P.info += text("Name: [] ID: []<BR>\nGender: []<BR>\nAge: []<BR>", active1.fields["name"], active1.fields["id"], active1.fields["gender"], active1.fields["age"])
						P.info += "\nSpecies: [active1.fields["species"]]<BR>"
						P.info += text("\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", active1.fields["fingerprint"], active1.fields["p_stat"], active1.fields["m_stat"])
					else
						P.info += "<B>General Record Lost!</B><BR>"
					if((istype(active2, /datum/data/record) && GLOB.data_core.security.Find(active2)))
						P.info += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []", active2.fields["criminal"])

						P.info += "<BR>\n<BR>\nMinor Crimes:<BR>\n"
						P.info +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
						for(var/datum/data/crime/c in active2.fields["mi_crim"])
							P.info += "<tr><td>[c.crimeName]</td>"
							P.info += "<td>[c.crimeDetails]</td>"
							P.info += "<td>[c.author]</td>"
							P.info += "<td>[c.time]</td>"
							P.info += "</tr>"
						P.info += "</table>"

						P.info += "<BR>\nMajor Crimes: <BR>\n"
						P.info +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
						for(var/datum/data/crime/c in active2.fields["ma_crim"])
							P.info += "<tr><td>[c.crimeName]</td>"
							P.info += "<td>[c.crimeDetails]</td>"
							P.info += "<td>[c.author]</td>"
							P.info += "<td>[c.time]</td>"
							P.info += "</tr>"
						P.info += "</table>"


						P.info += text("<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", active2.fields["notes"])

//TEMPORARY MENU FUNCTIONS
			else//To properly clear as per clear screen.
				temp=null
				switch(href_list["choice"])
					if("Change Rank")
						if(active1)
							active1.fields["rank"] = href_list["rank"]
							if(href_list["rank"] in get_all_jobs())
								active1.fields["real_rank"] = href_list["real_rank"]

					if("Change Criminal Status")
						if(active2)
							var/old_field = active2.fields["criminal"]
							switch(href_list["criminal2"])
								if("none")
									active2.fields["criminal"] = "None"
								if("arrest")
									active2.fields["criminal"] = "*Arrest*"
								if("incarcerated")
									active2.fields["criminal"] = "Incarcerated"
								if("paroled")
									active2.fields["criminal"] = "Paroled"
								if("released")
									active2.fields["criminal"] = "Discharged"
							investigate_log("[active1.fields["name"]] has been set from [old_field] to [active2.fields["criminal"]] by [key_name(usr)].", INVESTIGATE_RECORDS)
							for(var/mob/living/carbon/human/H in GLOB.carbon_list)
								H.sec_hud_set_security_status()
					if("Delete Record (Security) Execute")
						investigate_log("[key_name(usr)] has deleted the security records for [active1.fields["name"]].", INVESTIGATE_RECORDS)
						if(active2)
							qdel(active2)
							active2 = null

					if("Delete Record (ALL) Execute")
						if(active1)
							investigate_log("[key_name(usr)] has deleted all records for [active1.fields["name"]].", INVESTIGATE_RECORDS)
							for(var/datum/data/record/R in GLOB.data_core.medical)
								if((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
									qdel(R)
									break
							qdel(active1)
							active1 = null

						if(active2)
							qdel(active2)
							active2 = null
					else
						temp = "This function does not appear to be working at the moment. Our apologies."

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

/obj/machinery/computer/warrant/proc/print_photo(icon/temp, person_name)
	if (printing)
		return
	printing = TRUE
	sleep(20)
	var/obj/item/photo/P = new/obj/item/photo(drop_location())
	var/datum/picture/toEmbed = new(name = person_name, desc = "The photo on file for [person_name].", image = temp)
	P.set_picture(toEmbed, TRUE, TRUE)
	P.pixel_x = rand(-10, 10)
	P.pixel_y = rand(-10, 10)
	printing = FALSE

/obj/machinery/computer/warrant/emp_act(severity)
	. = ..()

	if(stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_SELF)
		return

	for(var/datum/data/record/R in GLOB.data_core.security)
		if(prob(10/severity))
			switch(rand(1,8))
				if(1)
					if(prob(10))
						R.fields["name"] = "[pick(lizard_name(MALE),lizard_name(FEMALE))]"
					else
						R.fields["name"] = "[pick(pick(GLOB.first_names_male), pick(GLOB.first_names_female))] [pick(GLOB.last_names)]"
				if(2)
					R.fields["gender"] = pick("Male", "Female", "Other")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick("None", "*Arrest*", "Incarcerated", "Paroled", "Discharged")
				if(5)
					R.fields["p_stat"] = pick("*Unconscious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
				if(7)
					R.fields["species"] = pick(GLOB.roundstart_races)
				if(8)
					var/datum/data/record/G = pick(GLOB.data_core.general)
					R.fields["photo_front"] = G.fields["photo_front"]
					R.fields["photo_side"] = G.fields["photo_side"]
			continue

		else if(prob(1))
			qdel(R)
			continue

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
