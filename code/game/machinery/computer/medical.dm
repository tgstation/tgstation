

/obj/machinery/computer/med_data//TODO:SANITY
	name = "medical records console"
	desc = "This can be used to check medical records."
	icon_screen = "medcomp"
	icon_keyboard = "med_key"
	req_one_access = list(GLOB.access_medical, GLOB.access_forensics_lockers)
	circuit = /obj/item/weapon/circuitboard/computer/med_data
	var/obj/item/weapon/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1
	var/datum/data/record/active2
	var/a_id = null
	var/temp = null
	var/printing = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/med_data/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		if(!user.drop_item())
			return
		O.loc = src
		scan = O
		to_chat(user, "<span class='notice'>You insert [O].</span>")
	else
		return ..()

/obj/machinery/computer/med_data/attack_hand(mob/user)
	if(..())
		return
	var/dat
	if(src.temp)
		dat = text("<TT>[src.temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>")
	else
		dat = text("Confirm Identity: <A href='?src=\ref[];scan=1'>[]</A><HR>", src, (src.scan ? text("[]", src.scan.name) : "----------"))
		if(src.authenticated)
			switch(src.screen)
				if(1)
					dat += {"
<A href='?src=\ref[src];search=1'>Search Records</A>
<BR><A href='?src=\ref[src];screen=2'>List Records</A>
<BR>
<BR><A href='?src=\ref[src];screen=5'>Virus Database</A>
<BR><A href='?src=\ref[src];screen=6'>Medbot Tracking</A>
<BR>
<BR><A href='?src=\ref[src];screen=3'>Record Maintenance</A>
<BR><A href='?src=\ref[src];logout=1'>{Log Out}</A><BR>
"}
				if(2)
					dat += {"
</p>
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>
<th>Records:</th>
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th><A href='?src=\ref[src];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=id'>ID</A></th>
<th>Fingerprints (F) | DNA (D)</th>
<th><A href='?src=\ref[src];choice=Sorting;sort=bloodtype'>Blood Type</A></th>
<th>Physical Status</th>
<th>Mental Status</th>
</tr>"}


					if(!isnull(GLOB.data_core.general))
						for(var/datum/data/record/R in sortRecord(GLOB.data_core.general, sortBy, order))
							var/blood_type = ""
							var/b_dna = ""
							for(var/datum/data/record/E in GLOB.data_core.medical)
								if((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
									blood_type = E.fields["blood_type"]
									b_dna = E.fields["b_dna"]
							var/background

							if(R.fields["m_stat"] == "*Insane*" || R.fields["p_stat"] == "*Deceased*")
								background = "'background-color:#990000;'"
							else if(R.fields["p_stat"] == "*Unconscious*" || R.fields["m_stat"] == "*Unstable*")
								background = "'background-color:#CD6500;'"
							else if(R.fields["p_stat"] == "Physically Unfit" || R.fields["m_stat"] == "*Watch*")
								background = "'background-color:#3BB9FF;'"
							else
								background = "'background-color:#4F7529;'"

							dat += text("<tr style=[]><td><A href='?src=\ref[];d_rec=[]'>[]</a></td>", background, src, R.fields["id"], R.fields["name"])
							dat += text("<td>[]</td>", R.fields["id"])
							dat += text("<td><b>F:</b> []<BR><b>D:</b> []</td>", R.fields["fingerprint"], b_dna)
							dat += text("<td>[]</td>", blood_type)
							dat += text("<td>[]</td>", R.fields["p_stat"])
							dat += text("<td>[]</td></tr>", R.fields["m_stat"])
					dat += "</table><hr width='75%' />"
//					if(GLOB.data_core.general)
//						for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
//							dat += "<A href='?src=\ref[src];d_rec=[R.fields["id"]]'>[R.fields["id"]]: [R.fields["name"]]<BR>"
//							//Foreach goto(132)
					dat += text("<HR><A href='?src=\ref[];screen=1'>Back</A>", src)
				if(3)
					dat += text("<B>Records Maintenance</B><HR>\n<A href='?src=\ref[];back=1'>Backup To Disk</A><BR>\n<A href='?src=\ref[];u_load=1'>Upload From Disk</A><BR>\n<A href='?src=\ref[];del_all=1'>Delete All Records</A><BR>\n<BR>\n<A href='?src=\ref[];screen=1'>Back</A>", src, src, src, src)
				if(4)

					dat += "<table><tr><td><b><font size='4'>Medical Record</font></b></td></tr>"
					if(active1 in GLOB.data_core.general)
						if(istype(active1.fields["photo_front"], /obj/item/weapon/photo))
							var/obj/item/weapon/photo/P1 = active1.fields["photo_front"]
							user << browse_rsc(P1.img, "photo_front")
						if(istype(active1.fields["photo_side"], /obj/item/weapon/photo))
							var/obj/item/weapon/photo/P2 = active1.fields["photo_side"]
							user << browse_rsc(P2.img, "photo_side")
						dat += "<tr><td>Name:</td><td>[active1.fields["name"]]</td>"
						dat += "<td><a href='?src=\ref[src];field=show_photo_front'><img src=photo_front height=80 width=80 border=4></a></td>"
						dat += "<td><a href='?src=\ref[src];field=show_photo_side'><img src=photo_side height=80 width=80 border=4></a></td></tr>"
						dat += "<tr><td>ID:</td><td>[active1.fields["id"]]</td></tr>"
						dat += "<tr><td>Sex:</td><td><A href='?src=\ref[src];field=sex'>&nbsp;[active1.fields["sex"]]&nbsp;</A></td></tr>"
						dat += "<tr><td>Age:</td><td><A href='?src=\ref[src];field=age'>&nbsp;[active1.fields["age"]]&nbsp;</A></td></tr>"
						if(config.mutant_races)
							dat += "<tr><td>Species:</td><td><A href='?src=\ref[src];field=species'>&nbsp;[active1.fields["species"]]&nbsp;</A></td></tr>"
						dat += "<tr><td>Fingerprint:</td><td><A href='?src=\ref[src];field=fingerprint'>&nbsp;[active1.fields["fingerprint"]]&nbsp;</A></td></tr>"
						dat += "<tr><td>Physical Status:</td><td><A href='?src=\ref[src];field=p_stat'>&nbsp;[active1.fields["p_stat"]]&nbsp;</A></td></tr>"
						dat += "<tr><td>Mental Status:</td><td><A href='?src=\ref[src];field=m_stat'>&nbsp;[active1.fields["m_stat"]]&nbsp;</A></td></tr>"
					else
						dat += "<tr><td>General Record Lost!</td></tr>"

					dat += "<tr><td><br><b><font size='4'>Medical Data</font></b></td></tr>"
					if(active2 in GLOB.data_core.medical)
						dat += "<tr><td>Blood Type:</td><td><A href='?src=\ref[src];field=blood_type'>&nbsp;[active2.fields["blood_type"]]&nbsp;</A></td></tr>"
						dat += "<tr><td>DNA:</td><td><A href='?src=\ref[src];field=b_dna'>&nbsp;[active2.fields["b_dna"]]&nbsp;</A></td></tr>"
						dat += "<tr><td><br>Minor Disabilities:</td><td><br><A href='?src=\ref[src];field=mi_dis'>&nbsp;[active2.fields["mi_dis"]]&nbsp;</A></td></tr>"
						dat += "<tr><td>Details:</td><td><A href='?src=\ref[src];field=mi_dis_d'>&nbsp;[active2.fields["mi_dis_d"]]&nbsp;</A></td></tr>"
						dat += "<tr><td><br>Major Disabilities:</td><td><br><A href='?src=\ref[src];field=ma_dis'>&nbsp;[active2.fields["ma_dis"]]&nbsp;</A></td></tr>"
						dat += "<tr><td>Details:</td><td><A href='?src=\ref[src];field=ma_dis_d'>&nbsp;[active2.fields["ma_dis_d"]]&nbsp;</A></td></tr>"
						dat += "<tr><td><br>Allergies:</td><td><br><A href='?src=\ref[src];field=alg'>&nbsp;[active2.fields["alg"]]&nbsp;</A></td></tr>"
						dat += "<tr><td>Details:</td><td><A href='?src=\ref[src];field=alg_d'>&nbsp;[active2.fields["alg_d"]]&nbsp;</A></td></tr>"
						dat += "<tr><td><br>Current Diseases:</td><td><br><A href='?src=\ref[src];field=cdi'>&nbsp;[active2.fields["cdi"]]&nbsp;</A></td></tr>" //(per disease info placed in log/comment section)
						dat += "<tr><td>Details:</td><td><A href='?src=\ref[src];field=cdi_d'>&nbsp;[active2.fields["cdi_d"]]&nbsp;</A></td></tr>"
						dat += "<tr><td><br>Important Notes:</td><td><br><A href='?src=\ref[src];field=notes'>&nbsp;[active2.fields["notes"]]&nbsp;</A></td></tr>"

						dat += "<tr><td><br><b><font size='4'>Comments/Log</font></b></td></tr>"
						var/counter = 1
						while(src.active2.fields[text("com_[]", counter)])
							dat += "<tr><td>[active2.fields[text("com_[]", counter)]]</td></tr><tr><td><A href='?src=\ref[src];del_c=[counter]'>Delete Entry</A></td></tr>"
							counter++
						dat += "<tr><td><A href='?src=\ref[src];add_c=1'>Add Entry</A></td></tr>"

						dat += "<tr><td><br><A href='?src=\ref[src];del_r=1'>Delete Record (Medical Only)</A></td></tr>"
					else
						dat += "<tr><td>Medical Record Lost!</tr>"
						dat += "<tr><td><br><A href='?src=\ref[src];new=1'>New Record</A></td></tr>"
					dat += "<tr><td><A href='?src=\ref[src];print_p=1'>Print Record</A></td></tr>"
					dat += "<tr><td><A href='?src=\ref[src];screen=2'>Back</A></td></tr>"
					dat += "</table>"
				if(5)
					dat += "<CENTER><B>Virus Database</B></CENTER>"
					for(var/Dt in typesof(/datum/disease/))
						var/datum/disease/Dis = new Dt(0)
						if(istype(Dis, /datum/disease/advance))
							continue // TODO (tm): Add advance diseases to the virus database which no one uses.
						if(!Dis.desc)
							continue
						dat += "<br><a href='?src=\ref[src];vir=[Dt]'>[Dis.name]</a>"
					dat += "<br><a href='?src=\ref[src];screen=1'>Back</a>"
				if(6)
					dat += "<center><b>Medical Robot Monitor</b></center>"
					dat += "<a href='?src=\ref[src];screen=1'>Back</a>"
					dat += "<br><b>Medical Robots:</b>"
					var/bdat = null
					for(var/mob/living/simple_animal/bot/medbot/M in GLOB.living_mob_list)
						if(M.z != src.z)
							continue	//only find medibots on the same z-level as the computer
						var/turf/bl = get_turf(M)
						if(bl)	//if it can't find a turf for the medibot, then it probably shouldn't be showing up
							bdat += "[M.name] - <b>\[[bl.x],[bl.y]\]</b> - [M.on ? "Online" : "Offline"]<br>"
							if((!isnull(M.reagent_glass)) && M.use_beaker)
								bdat += "Reservoir: \[[M.reagent_glass.reagents.total_volume]/[M.reagent_glass.reagents.maximum_volume]\]<br>"
							else
								bdat += "Using Internal Synthesizer.<br>"

					if(!bdat)
						dat += "<br><center>None detected</center>"
					else
						dat += "<br>[bdat]"

				else
		else
			dat += text("<A href='?src=\ref[];login=1'>{Log In}</A>", src)
	var/datum/browser/popup = new(user, "med_rec", "Medical Records Console", 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/med_data/Topic(href, href_list)
	. = ..()
	if(.)
		return .
	if(!(active1 in GLOB.data_core.general))
		src.active1 = null
	if(!(active2 in GLOB.data_core.medical))
		src.active2 = null

	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr) || IsAdminGhost(usr))
		usr.set_machine(src)
		if(href_list["temp"])
			src.temp = null
		if(href_list["scan"])
			if(src.scan)
				if(ishuman(usr) && !usr.get_active_held_item())
					usr.put_in_hands(scan)
				else
					scan.loc = get_turf(src)
				src.scan = null
			else
				var/obj/item/I = usr.get_active_held_item()
				if(istype(I, /obj/item/weapon/card/id))
					if(!usr.drop_item())
						return
					I.loc = src
					src.scan = I
		else if(href_list["logout"])
			src.authenticated = null
			src.screen = null
			src.active1 = null
			src.active2 = null
		else if(href_list["choice"])
			// SORTING!
			if(href_list["choice"] == "Sorting")
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
		else if(href_list["login"])
			if(issilicon(usr))
				src.active1 = null
				src.active2 = null
				src.authenticated = 1
				src.rank = "AI"
				src.screen = 1
			else if(IsAdminGhost(usr))
				src.active1 = null
				src.active2 = null
				src.authenticated = 1
				src.rank = "Central Command"
				src.screen = 1
			else if(istype(src.scan, /obj/item/weapon/card/id))
				src.active1 = null
				src.active2 = null
				if(src.check_access(src.scan))
					src.authenticated = src.scan.registered_name
					src.rank = src.scan.assignment
					src.screen = 1
		if(src.authenticated)

			if(href_list["screen"])
				src.screen = text2num(href_list["screen"])
				if(src.screen < 1)
					src.screen = 1

				src.active1 = null
				src.active2 = null

			else if(href_list["vir"])
				var/type = href_list["vir"]
				var/datum/disease/Dis = new type(0)
				var/AfS = ""
				for(var/mob/M in Dis.viable_mobtypes)
					AfS += " [initial(M.name)];"
				src.temp = {"<b>Name:</b> [Dis.name]
<BR><b>Number of stages:</b> [Dis.max_stages]
<BR><b>Spread:</b> [Dis.spread_text] Transmission
<BR><b>Possible Cure:</b> [(Dis.cure_text||"none")]
<BR><b>Affected Lifeforms:</b>[AfS]
<BR>
<BR><b>Notes:</b> [Dis.desc]
<BR>
<BR><b>Severity:</b> [Dis.severity]"}

			else if(href_list["del_all"])
				src.temp = text("Are you sure you wish to delete all records?<br>\n\t<A href='?src=\ref[];temp=1;del_all2=1'>Yes</A><br>\n\t<A href='?src=\ref[];temp=1'>No</A><br>", src, src)

			else if(href_list["del_all2"])
				investigate_log("[usr.name] ([usr.key]) has deleted all medical records.", INVESTIGATE_RECORDS)
				GLOB.data_core.medical.Cut()
				src.temp = "All records deleted."

			else if(href_list["field"])
				var/a1 = src.active1
				var/a2 = src.active2
				switch(href_list["field"])
					if("fingerprint")
						if(active1)
							var/t1 = stripped_input("Please input fingerprint hash:", "Med. records", src.active1.fields["fingerprint"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, a1))
								return
							src.active1.fields["fingerprint"] = t1
					if("sex")
						if(active1)
							if(src.active1.fields["sex"] == "Male")
								src.active1.fields["sex"] = "Female"
							else
								src.active1.fields["sex"] = "Male"
					if("age")
						if(active1)
							var/t1 = input("Please input age:", "Med. records", src.active1.fields["age"], null)  as num
							if(!canUseMedicalRecordsConsole(usr, t1, a1))
								return
							src.active1.fields["age"] = t1
					if("species")
						if(active1)
							var/t1 = stripped_input("Please input species name", "Med. records", src.active1.fields["species"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, a1))
								return
							active1.fields["species"] = t1
					if("mi_dis")
						if(active2)
							var/t1 = stripped_input("Please input minor disabilities list:", "Med. records", src.active2.fields["mi_dis"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							src.active2.fields["mi_dis"] = t1
					if("mi_dis_d")
						if(active2)
							var/t1 = stripped_multiline_input("Please summarize minor dis.:", "Med. records", src.active2.fields["mi_dis_d"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							src.active2.fields["mi_dis_d"] = t1
					if("ma_dis")
						if(active2)
							var/t1 = stripped_input("Please input major diabilities list:", "Med. records", src.active2.fields["ma_dis"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							src.active2.fields["ma_dis"] = t1
					if("ma_dis_d")
						if(active2)
							var/t1 = stripped_multiline_input("Please summarize major dis.:", "Med. records", src.active2.fields["ma_dis_d"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							src.active2.fields["ma_dis_d"] = t1
					if("alg")
						if(active2)
							var/t1 = stripped_input("Please state allergies:", "Med. records", src.active2.fields["alg"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							src.active2.fields["alg"] = t1
					if("alg_d")
						if(active2)
							var/t1 = stripped_multiline_input("Please summarize allergies:", "Med. records", src.active2.fields["alg_d"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							src.active2.fields["alg_d"] = t1
					if("cdi")
						if(active2)
							var/t1 = stripped_input("Please state diseases:", "Med. records", src.active2.fields["cdi"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							src.active2.fields["cdi"] = t1
					if("cdi_d")
						if(active2)
							var/t1 = stripped_multiline_input("Please summarize diseases:", "Med. records", src.active2.fields["cdi_d"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							src.active2.fields["cdi_d"] = t1
					if("notes")
						if(active2)
							var/t1 = stripped_multiline_input("Please summarize notes:", "Med. records", src.active2.fields["notes"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							src.active2.fields["notes"] = t1
					if("p_stat")
						if(active1)
							src.temp = text("<B>Physical Condition:</B><BR>\n\t<A href='?src=\ref[];temp=1;p_stat=deceased'>*Deceased*</A><BR>\n\t<A href='?src=\ref[];temp=1;p_stat=unconscious'>*Unconscious*</A><BR>\n\t<A href='?src=\ref[];temp=1;p_stat=active'>Active</A><BR>\n\t<A href='?src=\ref[];temp=1;p_stat=unfit'>Physically Unfit</A><BR>", src, src, src, src)
					if("m_stat")
						if(active1)
							src.temp = text("<B>Mental Condition:</B><BR>\n\t<A href='?src=\ref[];temp=1;m_stat=insane'>*Insane*</A><BR>\n\t<A href='?src=\ref[];temp=1;m_stat=unstable'>*Unstable*</A><BR>\n\t<A href='?src=\ref[];temp=1;m_stat=watch'>*Watch*</A><BR>\n\t<A href='?src=\ref[];temp=1;m_stat=stable'>Stable</A><BR>", src, src, src, src)
					if("blood_type")
						if(active2)
							src.temp = text("<B>Blood Type:</B><BR>\n\t<A href='?src=\ref[];temp=1;blood_type=an'>A-</A> <A href='?src=\ref[];temp=1;blood_type=ap'>A+</A><BR>\n\t<A href='?src=\ref[];temp=1;blood_type=bn'>B-</A> <A href='?src=\ref[];temp=1;blood_type=bp'>B+</A><BR>\n\t<A href='?src=\ref[];temp=1;blood_type=abn'>AB-</A> <A href='?src=\ref[];temp=1;blood_type=abp'>AB+</A><BR>\n\t<A href='?src=\ref[];temp=1;blood_type=on'>O-</A> <A href='?src=\ref[];temp=1;blood_type=op'>O+</A><BR>", src, src, src, src, src, src, src, src)
					if("b_dna")
						if(active2)
							var/t1 = stripped_input("Please input DNA hash:", "Med. records", src.active2.fields["b_dna"], null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							src.active2.fields["b_dna"] = t1
					if("show_photo_front")
						if(active1)
							if(active1.fields["photo_front"])
								if(istype(active1.fields["photo_front"], /obj/item/weapon/photo))
									var/obj/item/weapon/photo/P = active1.fields["photo_front"]
									P.show(usr)
					if("show_photo_side")
						if(active1)
							if(active1.fields["photo_side"])
								if(istype(active1.fields["photo_side"], /obj/item/weapon/photo))
									var/obj/item/weapon/photo/P = active1.fields["photo_side"]
									P.show(usr)
					else

			else if(href_list["p_stat"])
				if(active1)
					switch(href_list["p_stat"])
						if("deceased")
							src.active1.fields["p_stat"] = "*Deceased*"
						if("unconscious")
							src.active1.fields["p_stat"] = "*Unconscious*"
						if("active")
							src.active1.fields["p_stat"] = "Active"
						if("unfit")
							src.active1.fields["p_stat"] = "Physically Unfit"

			else if(href_list["m_stat"])
				if(active1)
					switch(href_list["m_stat"])
						if("insane")
							src.active1.fields["m_stat"] = "*Insane*"
						if("unstable")
							src.active1.fields["m_stat"] = "*Unstable*"
						if("watch")
							src.active1.fields["m_stat"] = "*Watch*"
						if("stable")
							src.active1.fields["m_stat"] = "Stable"


			else if(href_list["blood_type"])
				if(active2)
					switch(href_list["blood_type"])
						if("an")
							src.active2.fields["blood_type"] = "A-"
						if("bn")
							src.active2.fields["blood_type"] = "B-"
						if("abn")
							src.active2.fields["blood_type"] = "AB-"
						if("on")
							src.active2.fields["blood_type"] = "O-"
						if("ap")
							src.active2.fields["blood_type"] = "A+"
						if("bp")
							src.active2.fields["blood_type"] = "B+"
						if("abp")
							src.active2.fields["blood_type"] = "AB+"
						if("op")
							src.active2.fields["blood_type"] = "O+"


			else if(href_list["del_r"])
				if(active2)
					src.temp = text("Are you sure you wish to delete the record (Medical Portion Only)?<br>\n\t<A href='?src=\ref[];temp=1;del_r2=1'>Yes</A><br>\n\t<A href='?src=\ref[];temp=1'>No</A><br>", src, src)

			else if(href_list["del_r2"])
				investigate_log("[usr.name] ([usr.key]) has deleted the medical records for [active1.fields["name"]].", INVESTIGATE_RECORDS)
				if(active2)
					qdel(active2)
					active2 = null

			else if(href_list["d_rec"])
				active1 = find_record("id", href_list["d_rec"], GLOB.data_core.general)
				if(active1)
					active2 = find_record("id", href_list["d_rec"], GLOB.data_core.medical)
				if(!active2)
					active1 = null
				screen = 4

			else if(href_list["new"])
				if((istype(src.active1, /datum/data/record) && !( istype(src.active2, /datum/data/record) )))
					var/datum/data/record/R = new /datum/data/record(  )
					R.fields["name"] = src.active1.fields["name"]
					R.fields["id"] = src.active1.fields["id"]
					R.name = text("Medical Record #[]", R.fields["id"])
					R.fields["blood_type"] = "Unknown"
					R.fields["b_dna"] = "Unknown"
					R.fields["mi_dis"] = "None"
					R.fields["mi_dis_d"] = "No minor disabilities have been diagnosed."
					R.fields["ma_dis"] = "None"
					R.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
					R.fields["alg"] = "None"
					R.fields["alg_d"] = "No allergies have been detected in this patient."
					R.fields["cdi"] = "None"
					R.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
					R.fields["notes"] = "No notes."
					GLOB.data_core.medical += R
					src.active2 = R
					src.screen = 4

			else if(href_list["add_c"])
				if(!(active2 in GLOB.data_core.medical))
					return
				var/a2 = src.active2
				var/t1 = stripped_multiline_input("Add Comment:", "Med. records", null, null)
				if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
					return
				var/counter = 1
				while(src.active2.fields[text("com_[]", counter)])
					counter++
				src.active2.fields[text("com_[]", counter)] = text("Made by [] ([]) on [] [], []<BR>[]", src.authenticated, src.rank, worldtime2text(), time2text(world.realtime, "MMM DD"), GLOB.year_integer+540, t1)

			else if(href_list["del_c"])
				if((istype(src.active2, /datum/data/record) && src.active2.fields[text("com_[]", href_list["del_c"])]))
					src.active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"

			else if(href_list["search"])
				var/t1 = stripped_input(usr, "Search String: (Name, DNA, or ID)", "Med. records")
				if(!canUseMedicalRecordsConsole(usr, t1))
					return
				src.active1 = null
				src.active2 = null
				t1 = lowertext(t1)
				for(var/datum/data/record/R in GLOB.data_core.medical)
					if((lowertext(R.fields["name"]) == t1 || t1 == lowertext(R.fields["id"]) || t1 == lowertext(R.fields["b_dna"])))
						src.active2 = R
					else
						//Foreach continue //goto(3229)
				if(!( src.active2 ))
					src.temp = text("Could not locate record [].", sanitize(t1))
				else
					for(var/datum/data/record/E in GLOB.data_core.general)
						if((E.fields["name"] == src.active2.fields["name"] || E.fields["id"] == src.active2.fields["id"]))
							src.active1 = E
						else
							//Foreach continue //goto(3334)
					src.screen = 4

			else if(href_list["print_p"])
				if(!( src.printing ))
					src.printing = 1
					GLOB.data_core.medicalPrintCount++
					playsound(loc, 'sound/items/poster_being_created.ogg', 100, 1)
					sleep(30)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
					P.info = "<CENTER><B>Medical Record - (MR-[GLOB.data_core.medicalPrintCount])</B></CENTER><BR>"
					if(active1 in GLOB.data_core.general)
						P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>", src.active1.fields["name"], src.active1.fields["id"], src.active1.fields["sex"], src.active1.fields["age"])
						if(config.mutant_races)
							P.info += "\nSpecies: [active1.fields["species"]]<BR>"
						P.info += text("\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", src.active1.fields["fingerprint"], src.active1.fields["p_stat"], src.active1.fields["m_stat"])
					else
						P.info += "<B>General Record Lost!</B><BR>"
					if(active2 in GLOB.data_core.medical)
						P.info += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: []<BR>\nDNA: []<BR>\n<BR>\nMinor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nMajor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nAllergies: []<BR>\nDetails: []<BR>\n<BR>\nCurrent Diseases: [] (per disease info placed in log/comment section)<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src.active2.fields["blood_type"], src.active2.fields["b_dna"], src.active2.fields["mi_dis"], src.active2.fields["mi_dis_d"], src.active2.fields["ma_dis"], src.active2.fields["ma_dis_d"], src.active2.fields["alg"], src.active2.fields["alg_d"], src.active2.fields["cdi"], src.active2.fields["cdi_d"], src.active2.fields["notes"])
						var/counter = 1
						while(src.active2.fields[text("com_[]", counter)])
							P.info += text("[]<BR>", src.active2.fields[text("com_[]", counter)])
							counter++
						P.name = text("MR-[] '[]'", GLOB.data_core.medicalPrintCount, src.active1.fields["name"])
					else
						P.info += "<B>Medical Record Lost!</B><BR>"
						P.name = text("MR-[] '[]'", GLOB.data_core.medicalPrintCount, "Record Lost")
					P.info += "</TT>"
					src.printing = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/med_data/emp_act(severity)
	if(!(stat & (BROKEN|NOPOWER)))
		for(var/datum/data/record/R in GLOB.data_core.medical)
			if(prob(10/severity))
				switch(rand(1,6))
					if(1)
						if(prob(10))
							R.fields["name"] = random_unique_lizard_name(R.fields["sex"],1)
						else
							R.fields["name"] = random_unique_name(R.fields["sex"],1)
					if(2)
						R.fields["sex"]	= pick("Male", "Female")
					if(3)
						R.fields["age"] = rand(AGE_MIN, AGE_MAX)
					if(4)
						R.fields["blood_type"] = random_blood_type()
					if(5)
						R.fields["p_stat"] = pick("*Unconcious*", "Active", "Physically Unfit")
					if(6)
						R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
				continue

			else if(prob(1))
				qdel(R)
				continue
	..()

/obj/machinery/computer/med_data/proc/canUseMedicalRecordsConsole(mob/user, message = 1, record1, record2)
	if(user)
		if(message)
			if(authenticated)
				if(user.canUseTopic(src))
					if(!record1 || record1 == active1)
						if(!record2 || record2 == active2)
							return 1
	return 0

/obj/machinery/computer/med_data/laptop
	name = "medical laptop"
	desc = "A cheap Nanotrasen medical laptop, it functions as a medical records computer. It's bolted to the table."
	icon_state = "laptop"
	icon_screen = "medlaptop"
	icon_keyboard = "laptop_key"
	clockwork = TRUE //it'd look weird
