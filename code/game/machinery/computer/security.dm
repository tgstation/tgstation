/obj/machinery/computer/secure_data//TODO:SANITY
	name = "security records console"
	desc = "Used to view and edit personnel's security records."
	icon_screen = "security"
	icon_keyboard = "security_key"
	req_one_access = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)
	circuit = /obj/item/weapon/circuitboard/computer/secure_data
	var/obj/item/weapon/card/id/scan = null
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

/obj/machinery/computer/secure_data/syndie
	icon_keyboard = "syndie_key"

/obj/machinery/computer/secure_data/laptop
	name = "security laptop"
	desc = "A cheap Nanotrasen security laptop, it functions as a security records console. It's bolted to the table."
	icon_state = "laptop"
	icon_screen = "seclaptop"
	icon_keyboard = "laptop_key"
	clockwork = TRUE //it'd look weird

/obj/machinery/computer/secure_data/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/card/id))
		if(!scan)
			if(!user.drop_item())
				return
			O.loc = src
			scan = O
			to_chat(user, "<span class='notice'>You insert [O].</span>")
		else
			to_chat(user, "<span class='warning'>There's already an ID card in the console.</span>")
	else
		return ..()

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/secure_data/attack_hand(mob/user)
	if(..())
		return
	if(src.z > 6)
		to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return
	var/dat

	if(temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];choice=Clear Screen'>Clear Screen</A>", temp, src)
	else
		dat = text("Confirm Identity: <A href='?src=\ref[];choice=Confirm Identity'>[]</A><HR>", src, (scan ? text("[]", scan.name) : "----------"))
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
					dat += text("<A href='?src=\ref[];choice=New Record (General)'>New Record</A><BR>", src)
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
<th><A href='?src=\ref[src];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=id'>ID</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=rank'>Rank</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=fingerprint'>Fingerprints</A></th>
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
								if("Parolled")
									background = "'background-color:#CD6500;'"
								if("Discharged")
									background = "'background-color:#006699;'"
								if("None")
									background = "'background-color:#4F7529;'"
								if("")
									background = "''" //"'background-color:#FFFFFF;'"
									crimstat = "No Record."
							dat += "<tr style=[background]>"
							dat += text("<td><input type='hidden' value='[] [] [] []'></input><A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", R.fields["name"], R.fields["id"], R.fields["rank"], R.fields["fingerprint"], src, R, R.fields["name"])
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
					dat += text("<A href='?src=\ref[];choice=Record Maintenance'>Record Maintenance</A><br><br>", src)
					dat += text("<A href='?src=\ref[];choice=Log Out'>{Log Out}</A>",src)
				if(2)
					dat += "<B>Records Maintenance</B><HR>"
					dat += "<BR><A href='?src=\ref[src];choice=Delete All Records'>Delete All Records</A><BR><BR><A href='?src=\ref[src];choice=Return'>Back</A>"
				if(3)
					dat += "<font size='4'><b>Security Record</b></font><br>"
					if(istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1))
						if(istype(active1.fields["photo_front"], /obj/item/weapon/photo))
							var/obj/item/weapon/photo/P1 = active1.fields["photo_front"]
							user << browse_rsc(P1.img, "photo_front")
						if(istype(active1.fields["photo_side"], /obj/item/weapon/photo))
							var/obj/item/weapon/photo/P2 = active1.fields["photo_side"]
							user << browse_rsc(P2.img, "photo_side")
						dat += {"<table><tr><td><table>
						<tr><td>Name:</td><td><A href='?src=\ref[src];choice=Edit Field;field=name'>&nbsp;[active1.fields["name"]]&nbsp;</A></td></tr>
						<tr><td>ID:</td><td><A href='?src=\ref[src];choice=Edit Field;field=id'>&nbsp;[active1.fields["id"]]&nbsp;</A></td></tr>
						<tr><td>Sex:</td><td><A href='?src=\ref[src];choice=Edit Field;field=sex'>&nbsp;[active1.fields["sex"]]&nbsp;</A></td></tr>
						<tr><td>Age:</td><td><A href='?src=\ref[src];choice=Edit Field;field=age'>&nbsp;[active1.fields["age"]]&nbsp;</A></td></tr>"}
						if(config.mutant_races)
							dat += "<tr><td>Species:</td><td><A href ='?src=\ref[src];choice=Edit Field;field=species'>&nbsp;[active1.fields["species"]]&nbsp;</A></td></tr>"
						dat += {"<tr><td>Rank:</td><td><A href='?src=\ref[src];choice=Edit Field;field=rank'>&nbsp;[active1.fields["rank"]]&nbsp;</A></td></tr>
						<tr><td>Fingerprint:</td><td><A href='?src=\ref[src];choice=Edit Field;field=fingerprint'>&nbsp;[active1.fields["fingerprint"]]&nbsp;</A></td></tr>
						<tr><td>Physical Status:</td><td>&nbsp;[active1.fields["p_stat"]]&nbsp;</td></tr>
						<tr><td>Mental Status:</td><td>&nbsp;[active1.fields["m_stat"]]&nbsp;</td></tr>
						</table></td>
						<td><table><td align = center><a href='?src=\ref[src];choice=Edit Field;field=show_photo_front'><img src=photo_front height=80 width=80 border=4></a><br>
						<a href='?src=\ref[src];choice=Edit Field;field=upd_photo_front'>Update front photo</a></td>
						<td align = center><a href='?src=\ref[src];choice=Edit Field;field=show_photo_side'><img src=photo_side height=80 width=80 border=4></a><br>
						<a href='?src=\ref[src];choice=Edit Field;field=upd_photo_side'>Update side photo</a></td></table>
						</td></tr></table></td></tr></table>"}
					else
						dat += "<br>General Record Lost!<br>"
					if((istype(active2, /datum/data/record) && GLOB.data_core.security.Find(active2)))
						dat += "<font size='4'><b>Security Data</b></font>"
						dat += "<br>Criminal Status: <A href='?src=\ref[src];choice=Edit Field;field=criminal'>[active2.fields["criminal"]]</A>"
						dat += "<br><br>Minor Crimes: <A href='?src=\ref[src];choice=Edit Field;field=mi_crim_add'>Add New</A>"


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
							dat += "<td><A href='?src=\ref[src];choice=Edit Field;field=mi_crim_delete;cdataid=[c.dataId]'>\[X\]</A></td>"
							dat += "</tr>"
						dat += "</table>"


						dat += "<br>Major Crimes: <A href='?src=\ref[src];choice=Edit Field;field=ma_crim_add'>Add New</A>"

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
							dat += "<td><A href='?src=\ref[src];choice=Edit Field;field=ma_crim_delete;cdataid=[c.dataId]'>\[X\]</A></td>"
							dat += "</tr>"
						dat += "</table>"

						dat += "<br>\nImportant Notes:<br>\n\t<A href='?src=\ref[src];choice=Edit Field;field=notes'>&nbsp;[active2.fields["notes"]]&nbsp;</A>"
						dat += "<br><br><font size='4'><b>Comments/Log</b></font><br>"
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							dat += (active2.fields[text("com_[]", counter)] + "<BR>")
							if(active2.fields[text("com_[]", counter)] != "<B>Deleted</B>")
								dat += text("<A href='?src=\ref[];choice=Delete Entry;del_c=[]'>Delete Entry</A><BR><BR>", src, counter)
							counter++
						dat += text("<A href='?src=\ref[];choice=Add Entry'>Add Entry</A><br><br>", src)
						dat += text("<A href='?src=\ref[];choice=Delete Record (Security)'>Delete Record (Security Only)</A><br>", src)
					else
						dat += "Security Record Lost!<br>"
						dat += text("<A href='?src=\ref[];choice=New Record (Security)'>New Security Record</A><br><br>", src)
					dat += text("<A href='?src=\ref[];choice=Delete Record (ALL)'>Delete Record (ALL)</A><br><A href='?src=\ref[];choice=Print Record'>Print Record</A><BR><A href='?src=\ref[];choice=Print Poster'>Print Wanted Poster</A><BR><A href='?src=\ref[];choice=Return'>Back</A><BR>", src, src, src, src)
				else
		else
			dat += text("<A href='?src=\ref[];choice=Log In'>{Log In}</A>", src)
	var/datum/browser/popup = new(user, "secure_rec", "Security Records Console", 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/secure_data/Topic(href, href_list)
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
				if(scan)
					if(ishuman(usr) && !usr.get_active_held_item())
						usr.put_in_hands(scan)
					else
						scan.loc = get_turf(src)
					scan = null
				else
					var/obj/item/I = usr.get_active_held_item()
					if(istype(I, /obj/item/weapon/card/id))
						if(!usr.drop_item())
							return
						I.loc = src
						scan = I

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
				else if(istype(scan, /obj/item/weapon/card/id))
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
				var/datum/data/record/R = locate(href_list["d_rec"])
				var/S = locate(href_list["d_rec"])
				if(!( GLOB.data_core.general.Find(R) ))
					temp = "Record Not Found!"
				else
					for(var/datum/data/record/E in GLOB.data_core.security)
						if((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
							S = E
					active1 = R
					active2 = S
					screen = 3


			if("Print Record")
				if(!( printing ))
					printing = 1
					GLOB.data_core.securityPrintCount++
					playsound(loc, 'sound/items/poster_being_created.ogg', 100, 1)
					sleep(30)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( loc )
					P.info = "<CENTER><B>Security Record - (SR-[GLOB.data_core.securityPrintCount])</B></CENTER><BR>"
					if((istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1)))
						P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>", active1.fields["name"], active1.fields["id"], active1.fields["sex"], active1.fields["age"])
						if(config.mutant_races)
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
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							P.info += text("[]<BR>", active2.fields[text("com_[]", counter)])
							counter++
						P.name = text("SR-[] '[]'", GLOB.data_core.securityPrintCount, active1.fields["name"])
					else
						P.info += "<B>Security Record Lost!</B><BR>"
						P.name = text("SR-[] '[]'", GLOB.data_core.securityPrintCount, "Record Lost")
					P.info += "</TT>"
					printing = null
			if("Print Poster")
				if(!( printing ))
					var/wanted_name = stripped_input(usr, "Please enter an alias for the criminal:", "Print Wanted Poster", active1.fields["name"])
					if(wanted_name)
						var/default_description = "A poster declaring [wanted_name] to be a dangerous individual, wanted by Nanotrasen. Report any sightings to security immediately."
						var/list/major_crimes = active2.fields["ma_crim"]
						var/list/minor_crimes = active2.fields["mi_crim"]
						if(major_crimes.len + minor_crimes.len)
							default_description += "\n[wanted_name] is wanted for the following crimes:\n"
						if(minor_crimes.len)
							default_description += "\nMinor Crimes:"
							for(var/datum/data/crime/c in active2.fields["mi_crim"])
								default_description += "\n[c.crimeName]\n"
								default_description += "[c.crimeDetails]\n"
						if(major_crimes.len)
							default_description += "\nMajor Crimes:"
							for(var/datum/data/crime/c in active2.fields["ma_crim"])
								default_description += "\n[c.crimeName]\n"
								default_description += "[c.crimeDetails]\n"

						var/info = stripped_multiline_input(usr, "Please input a description for the poster:", "Print Wanted Poster", default_description, null)
						if(info)
							playsound(loc, 'sound/items/poster_being_created.ogg', 100, 1)
							printing = 1
							sleep(30)
							if((istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1)))//make sure the record still exists.
								var/obj/item/weapon/photo/photo = active1.fields["photo_front"]
								new /obj/item/weapon/poster/wanted(src.loc, photo.img, wanted_name, info)
							printing = 0

//RECORD DELETE
			if("Delete All Records")
				temp = ""
				temp += "Are you sure you wish to delete all Security records?<br>"
				temp += "<a href='?src=\ref[src];choice=Purge All Records'>Yes</a><br>"
				temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if("Purge All Records")
				investigate_log("[usr.name] ([usr.key]) has purged all the security records.", INVESTIGATE_RECORDS)
				for(var/datum/data/record/R in GLOB.data_core.security)
					qdel(R)
				GLOB.data_core.security.Cut()
				temp = "All Security records deleted."

			if("Add Entry")
				if(!( istype(active2, /datum/data/record) ))
					return
				var/a2 = active2
				var/t1 = stripped_multiline_input("Add Comment:", "Secure. records", null, null)
				if(!canUseSecurityRecordsConsole(usr, t1, null, a2))
					return
				var/counter = 1
				while(active2.fields[text("com_[]", counter)])
					counter++
				active2.fields[text("com_[]", counter)] = text("Made by [] ([]) on [] [], []<BR>[]", src.authenticated, src.rank, worldtime2text(), time2text(world.realtime, "MMM DD"), GLOB.year_integer+540, t1)

			if("Delete Record (ALL)")
				if(active1)
					temp = "<h5>Are you sure you wish to delete the record (ALL)?</h5>"
					temp += "<a href='?src=\ref[src];choice=Delete Record (ALL) Execute'>Yes</a><br>"
					temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if("Delete Record (Security)")
				if(active2)
					temp = "<h5>Are you sure you wish to delete the record (Security Portion Only)?</h5>"
					temp += "<a href='?src=\ref[src];choice=Delete Record (Security) Execute'>Yes</a><br>"
					temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if("Delete Entry")
				if((istype(active2, /datum/data/record) && active2.fields[text("com_[]", href_list["del_c"])]))
					active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"
//RECORD CREATE
			if("New Record (Security)")
				if((istype(active1, /datum/data/record) && !( istype(active2, /datum/data/record) )))
					var/datum/data/record/R = new /datum/data/record()
					R.fields["name"] = active1.fields["name"]
					R.fields["id"] = active1.fields["id"]
					R.name = text("Security Record #[]", R.fields["id"])
					R.fields["criminal"] = "None"
					R.fields["mi_crim"] = list()
					R.fields["ma_crim"] = list()
					R.fields["notes"] = "No notes."
					GLOB.data_core.security += R
					active2 = R
					screen = 3

			if("New Record (General)")
				//General Record
				var/datum/data/record/G = new /datum/data/record()
				G.fields["name"] = "New Record"
				G.fields["id"] = "[num2hex(rand(1, 1.6777215E7), 6)]"
				G.fields["rank"] = "Unassigned"
				G.fields["sex"] = "Male"
				G.fields["age"] = "Unknown"
				if(config.mutant_races)
					G.fields["species"] = "Human"
				G.fields["photo_front"] = new /icon()
				G.fields["photo_side"] = new /icon()
				G.fields["fingerprint"] = "?????"
				G.fields["p_stat"] = "Active"
				G.fields["m_stat"] = "Stable"
				GLOB.data_core.general += G
				active1 = G

				//Security Record
				var/datum/data/record/R = new /datum/data/record()
				R.fields["name"] = active1.fields["name"]
				R.fields["id"] = active1.fields["id"]
				R.name = text("Security Record #[]", R.fields["id"])
				R.fields["criminal"] = "None"
				R.fields["mi_crim"] = list()
				R.fields["ma_crim"] = list()
				R.fields["notes"] = "No notes."
				GLOB.data_core.security += R
				active2 = R

				//Medical Record
				var/datum/data/record/M = new /datum/data/record()
				M.fields["id"]			= active1.fields["id"]
				M.fields["name"]		= active1.fields["name"]
				M.fields["blood_type"]	= "?"
				M.fields["b_dna"]		= "?????"
				M.fields["mi_dis"]		= "None"
				M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
				M.fields["ma_dis"]		= "None"
				M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
				M.fields["alg"]			= "None"
				M.fields["alg_d"]		= "No allergies have been detected in this patient."
				M.fields["cdi"]			= "None"
				M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
				M.fields["notes"]		= "No notes."
				GLOB.data_core.medical += M



//FIELD FUNCTIONS
			if("Edit Field")
				var/a1 = active1
				var/a2 = active2

				switch(href_list["field"])
					if("name")
						if(istype(active1, /datum/data/record) || istype(active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please input name:", "Secure. records", active1.fields["name"], null)  as text),1,MAX_MESSAGE_LEN)
							if(!canUseSecurityRecordsConsole(usr, t1, a1))
								return
							if(istype(active1, /datum/data/record))
								active1.fields["name"] = t1
							if(istype(active2, /datum/data/record))
								active2.fields["name"] = t1
					if("id")
						if(istype(active2,/datum/data/record) || istype(active1,/datum/data/record))
							var/t1 = stripped_input(usr, "Please input id:", "Secure. records", active1.fields["id"], null)
							if(!canUseSecurityRecordsConsole(usr, t1, a1))
								return
							if(istype(active1,/datum/data/record))
								active1.fields["id"] = t1
							if(istype(active2,/datum/data/record))
								active2.fields["id"] = t1
					if("fingerprint")
						if(istype(active1, /datum/data/record))
							var/t1 = stripped_input(usr, "Please input fingerprint hash:", "Secure. records", active1.fields["fingerprint"], null)
							if(!canUseSecurityRecordsConsole(usr, t1, a1))
								return
							active1.fields["fingerprint"] = t1
					if("sex")
						if(istype(active1, /datum/data/record))
							if(active1.fields["sex"] == "Male")
								active1.fields["sex"] = "Female"
							else
								active1.fields["sex"] = "Male"
					if("age")
						if(istype(active1, /datum/data/record))
							var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null) as num
							if(!canUseSecurityRecordsConsole(usr, "age", a1))
								return
							active1.fields["age"] = t1
					if("species")
						if(istype(active1, /datum/data/record))
							var/t1 = input("Select a species", "Species Selection") as null|anything in GLOB.roundstart_species
							if(!canUseSecurityRecordsConsole(usr, t1, a1))
								return
							active1.fields["species"] = t1
					if("show_photo_front")
						if(active1.fields["photo_front"])
							if(istype(active1.fields["photo_front"], /obj/item/weapon/photo))
								var/obj/item/weapon/photo/P = active1.fields["photo_front"]
								P.show(usr)
					if("upd_photo_front")
						var/icon/photo = get_photo(usr)
						if(photo)
							qdel(active1.fields["photo_front"])
							active1.fields["photo_front"] = photo
					if("show_photo_side")
						if(active1.fields["photo_side"])
							if(istype(active1.fields["photo_side"], /obj/item/weapon/photo))
								var/obj/item/weapon/photo/P = active1.fields["photo_side"]
								P.show(usr)
					if("upd_photo_side")
						var/icon/photo = get_photo(usr)
						if(photo)
							qdel(active1.fields["photo_side"])
							active1.fields["photo_side"] = photo
					if("mi_crim_add")
						if(istype(active1, /datum/data/record))
							var/t1 = stripped_input(usr, "Please input minor crime names:", "Secure. records", "", null)
							var/t2 = stripped_input(usr, "Please input minor crime details:", "Secure. records", "", null)
							if(!canUseSecurityRecordsConsole(usr, t1, null, a2))
								return
							var/crime = GLOB.data_core.createCrimeEntry(t1, t2, authenticated, worldtime2text())
							GLOB.data_core.addMinorCrime(active1.fields["id"], crime)
					if("mi_crim_delete")
						if(istype(active1, /datum/data/record))
							if(href_list["cdataid"])
								if(!canUseSecurityRecordsConsole(usr, "delete", null, a2))
									return
								GLOB.data_core.removeMinorCrime(active1.fields["id"], href_list["cdataid"])
					if("ma_crim_add")
						if(istype(active1, /datum/data/record))
							var/t1 = stripped_input(usr, "Please input major crime names:", "Secure. records", "", null)
							var/t2 = stripped_input(usr, "Please input major crime details:", "Secure. records", "", null)
							if(!canUseSecurityRecordsConsole(usr, t1, null, a2))
								return
							var/crime = GLOB.data_core.createCrimeEntry(t1, t2, authenticated, worldtime2text())
							GLOB.data_core.addMajorCrime(active1.fields["id"], crime)
					if("ma_crim_delete")
						if(istype(active1, /datum/data/record))
							if(href_list["cdataid"])
								if(!canUseSecurityRecordsConsole(usr, "delete", null, a2))
									return
								GLOB.data_core.removeMajorCrime(active1.fields["id"], href_list["cdataid"])
					if("notes")
						if(istype(active2, /datum/data/record))
							var/t1 = stripped_input(usr, "Please summarize notes:", "Secure. records", active2.fields["notes"], null)
							if(!canUseSecurityRecordsConsole(usr, t1, null, a2))
								return
							active2.fields["notes"] = t1
					if("criminal")
						if(istype(active2, /datum/data/record))
							temp = "<h5>Criminal Status:</h5>"
							temp += "<ul>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=none'>None</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=arrest'>*Arrest*</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=incarcerated'>Incarcerated</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=parolled'>Parolled</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=released'>Discharged</a></li>"
							temp += "</ul>"
					if("rank")
						var/list/L = list( "Head of Personnel", "Captain", "AI", "Central Command" )
						//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
						if((istype(active1, /datum/data/record) && L.Find(rank)))
							temp = "<h5>Rank:</h5>"
							temp += "<ul>"
							for(var/rank in get_all_jobs())
								temp += "<li><a href='?src=\ref[src];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
							temp += "</ul>"
						else
							alert(usr, "You do not have the required rank to do this!")
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
								if("parolled")
									active2.fields["criminal"] = "Parolled"
								if("released")
									active2.fields["criminal"] = "Discharged"
							investigate_log("[active1.fields["name"]] has been set from [old_field] to [active2.fields["criminal"]] by [usr.name] ([usr.key]).", INVESTIGATE_RECORDS)
							for(var/mob/living/carbon/human/H in GLOB.mob_list) //thanks for forcing me to do this, whoever wrote this shitty records system
								H.sec_hud_set_security_status()
					if("Delete Record (Security) Execute")
						investigate_log("[usr.name] ([usr.key]) has deleted the security records for [active1.fields["name"]].", INVESTIGATE_RECORDS)
						if(active2)
							qdel(active2)
							active2 = null

					if("Delete Record (ALL) Execute")
						if(active1)
							investigate_log("[usr.name] ([usr.key]) has deleted all records for [active1.fields["name"]].", INVESTIGATE_RECORDS)
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

/obj/machinery/computer/secure_data/proc/get_photo(mob/user)
	var/obj/item/weapon/photo/P = null
	if(issilicon(user))
		var/mob/living/silicon/tempAI = user
		var/datum/picture/selection = tempAI.GetPhoto()
		if(selection)
			P = new()
			P.photocreate(selection.fields["icon"], selection.fields["img"], selection.fields["desc"])
	else if(istype(user.get_active_held_item(), /obj/item/weapon/photo))
		P = user.get_active_held_item()
	return P

/obj/machinery/computer/secure_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
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
					R.fields["sex"] = pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick("None", "*Arrest*", "Incarcerated", "Parolled", "Discharged")
				if(5)
					R.fields["p_stat"] = pick("*Unconscious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
				if(7)
					R.fields["species"] = pick(GLOB.roundstart_species)
				if(8)
					var/datum/data/record/G = pick(GLOB.data_core.general)
					R.fields["photo_front"] = G.fields["photo_front"]
					R.fields["photo_side"] = G.fields["photo_side"]
			continue

		else if(prob(1))
			qdel(R)
			continue

	..(severity)

/obj/machinery/computer/secure_data/proc/canUseSecurityRecordsConsole(mob/user, message1 = 0, record1, record2)
	if(user)
		if(authenticated)
			if(user.canUseTopic(src))
				if(!trim(message1))
					return 0
				if(!record1 || record1 == active1)
					if(!record2 || record2 == active2)
						return 1
	return 0
