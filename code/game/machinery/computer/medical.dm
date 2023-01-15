

/obj/machinery/computer/med_data//TODO:SANITY
	name = "medical records console"
	desc = "This can be used to check medical records."
	icon_screen = "medcomp"
	icon_keyboard = "med_key"
	req_one_access = list(ACCESS_MEDICAL, ACCESS_DETECTIVE, ACCESS_GENETICS)
	circuit = /obj/item/circuitboard/computer/med_data
	light_color = LIGHT_COLOR_BLUE
	var/rank = null
	var/screen = null
	var/datum/record/crew/active1
	var/datum/record/crew/active2
	var/temp = null
	var/printing = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending


/obj/machinery/computer/med_data/syndie
	icon_keyboard = "syndie_key"
	req_one_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/med_data/ui_interact(mob/user)
	. = ..()
	if(isliving(user))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	var/dat
	if(temp)
		dat = text("<TT>[temp]</TT><BR><BR><A href='?src=[REF(src)];temp=1'>Clear Screen</A>")
	else
		if(authenticated)
			switch(screen)
				if(1)
					dat += {"
<A href='?src=[REF(src)];search=1'>Search Records</A>
<BR><A href='?src=[REF(src)];screen=2'>List Records</A>
<BR>
<BR><A href='?src=[REF(src)];screen=5'>Virus Database</A>
<BR><A href='?src=[REF(src)];screen=6'>Medbot Tracking</A>
<BR>
<BR><A href='?src=[REF(src)];screen=3'>Record Maintenance</A>
<BR><A href='?src=[REF(src)];logout=1'>{Log Out}</A><BR>
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
<th><A href='?src=[REF(src)];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=[REF(src)];choice=Sorting;sort=id'>ID</A></th>
<th>Fingerprints (F) | DNA UE (D)</th>
<th><A href='?src=[REF(src)];choice=Sorting;sort=bloodtype'>Blood Type</A></th>
<th>Physical Status</th>
<th>Mental Status</th>
</tr>"}


					if(!isnull(GLOB.data_core.general))
						for(var/datum/record/crew/record in sort_record(GLOB.data_core.general, sortBy, order))
							var/background

							if(record.m_stat == "*Insane*" || record.p_stat == "*Deceased*")
								background = "'background-color:#990000;'"
							else if(record.p_stat == "*Unconscious*" || record.m_stat == "*Unstable*")
								background = "'background-color:#CD6500;'"
							else if(record.p_stat == "Physically Unfit" || record.m_stat == "*Watch*")
								background = "'background-color:#3BB9FF;'"
							else
								background = "'background-color:#4F7529;'"

							dat += text("<tr style=[]><td><A href='?src=[REF(src)];d_rec=[]'>[]</a></td>", background, record.id, record.name)
							dat += text("<td>[]</td>", record.id)
							dat += text("<td><b>F:</b> []<BR><b>D:</b> []</td>", record.fingerprint, record.dna)
							dat += text("<td>[]</td>", record.blood_type)
							dat += text("<td>[]</td>", record.p_stat)
							dat += text("<td>[]</td></tr>", record.m_stat)
					dat += "</table><hr width='75%' />"
					dat += "<HR><A href='?src=[REF(src)];screen=1'>Back</A>"
				if(3)
					dat += "<B>Records Maintenance</B><HR>\n<A href='?src=[REF(src)];back=1'>Backup To Disk</A><BR>\n<A href='?src=[REF(src)];u_load=1'>Upload From Disk</A><BR>\n<A href='?src=[REF(src)];del_all=1'>Delete All Records</A><BR>\n<BR>\n<A href='?src=[REF(src)];screen=1'>Back</A>"
				if(4)

					dat += "<table><tr><td><b><font size='4'>Medical Record</font></b></td></tr>"
					if(!(active1 in GLOB.data_core.general))
						dat += "<tr><td>Medical Record Lost!</tr>"
						dat += "<tr><td><br><A href='?src=[REF(src)];new=1'>New Record</A></td></tr>"
					else
						var/front_photo = active1.get_front_photo()
						if(istype(front_photo, /obj/item/photo))
							var/obj/item/photo/photo_front = front_photo
							user << browse_rsc(photo_front.picture.picture_image, "photo_front")
						var/side_photo = active1.get_side_photo()
						if(istype(side_photo, /obj/item/photo))
							var/obj/item/photo/photo_side = side_photo
							user << browse_rsc(photo_side.picture.picture_image, "photo_side")
						dat += "<tr><td>Name:</td><td>[active1.name]</td>"
						dat += "<td><a href='?src=[REF(src)];field=show_photo_front'><img src=photo_front height=96 width=96 border=4 style=\"-ms-interpolation-mode:nearest-neighbor\"></a></td>"
						dat += "<td><a href='?src=[REF(src)];field=show_photo_side'><img src=photo_side height=96 width=96 border=4 style=\"-ms-interpolation-mode:nearest-neighbor\"></a></td></tr>"
						dat += "<tr><td>ID:</td><td>[active1.id]</td></tr>"
						dat += "<tr><td>Gender:</td><td><A href='?src=[REF(src)];field=gender'>&nbsp;[active1.gender]&nbsp;</A></td></tr>"
						dat += "<tr><td>Age:</td><td><A href='?src=[REF(src)];field=age'>&nbsp;[active1.age]&nbsp;</A></td></tr>"
						dat += "<tr><td>Species:</td><td><A href='?src=[REF(src)];field=species'>&nbsp;[active1.species]&nbsp;</A></td></tr>"
						dat += "<tr><td>Fingerprint:</td><td><A href='?src=[REF(src)];field=fingerprint'>&nbsp;[active1.fingerprint]&nbsp;</A></td></tr>"
						dat += "<tr><td>Physical Status:</td><td><A href='?src=[REF(src)];field=p_stat'>&nbsp;[active1.p_stat]&nbsp;</A></td></tr>"
						dat += "<tr><td>Mental Status:</td><td><A href='?src=[REF(src)];field=m_stat'>&nbsp;[active1.m_stat]&nbsp;</A></td></tr>"
						dat += "<tr><td>Blood Type:</td><td><A href='?src=[REF(src)];field=blood_type'>&nbsp;[active2.blood_type]&nbsp;</A></td></tr>"
						dat += "<tr><td>DNA:</td><td><A href='?src=[REF(src)];field=dna'>&nbsp;[active2.dna]&nbsp;</A></td></tr>"
						dat += "<tr><td><br>Minor Disabilities:</td><td><br><A href='?src=[REF(src)];field=mi_dis'>&nbsp;[active2.mi_dis]&nbsp;</A></td></tr>"
						dat += "<tr><td>Details:</td><td><A href='?src=[REF(src)];field=mi_dis_d'>&nbsp;[active2.mi_dis_d]&nbsp;</A></td></tr>"
						dat += "<tr><td><br>Major Disabilities:</td><td><br><A href='?src=[REF(src)];field=ma_dis'>&nbsp;[active2.ma_dis]&nbsp;</A></td></tr>"
						dat += "<tr><td>Details:</td><td><A href='?src=[REF(src)];field=ma_dis_d'>&nbsp;[active2.ma_dis_d]&nbsp;</A></td></tr>"
						dat += "<tr><td><br>Current Diseases:</td><td><br><A href='?src=[REF(src)];field=cdi'>&nbsp;[active2.cdi]&nbsp;</A></td></tr>" //(per disease info placed in log/comment section)
						dat += "<tr><td>Details:</td><td><A href='?src=[REF(src)];field=cdi_d'>&nbsp;[active2.cdi_d]&nbsp;</A></td></tr>"
						dat += "<tr><td><br>Important Notes:</td><td><br><A href='?src=[REF(src)];field=notes'>&nbsp;[active2.medical_notes]&nbsp;</A></td></tr>"
						dat += "<tr><td><br>Notes Cont'd:</td><td><br><A href='?src=[REF(src)];field=notes'>&nbsp;[active2.medical_notes_d]&nbsp;</A></td></tr>"
						dat += "<tr><td><A href='?src=[REF(src)];add_c=1'>Add Entry</A></td></tr>"
						dat += "<tr><td><br><A href='?src=[REF(src)];del_r=1'>Delete Record (Medical Only)</A></td></tr>"

					dat += "<tr><td><A href='?src=[REF(src)];print_p=1'>Print Record</A></td></tr>"
					dat += "<tr><td><A href='?src=[REF(src)];screen=2'>Back</A></td></tr>"
					dat += "</table>"
				if(5)
					dat += "<CENTER><B>Virus Database</B></CENTER>"
					for(var/Dt in typesof(/datum/disease/))
						var/datum/disease/Dis = new Dt(0)
						if(istype(Dis, /datum/disease/advance))
							continue // TODO (tm): Add advance diseases to the virus database which no one uses.
						if(!Dis.desc)
							continue
						dat += "<br><a href='?src=[REF(src)];vir=[Dt]'>[Dis.name]</a>"
					dat += "<br><a href='?src=[REF(src)];screen=1'>Back</a>"
				if(6)
					dat += "<center><b>Medical Robot Monitor</b></center>"
					dat += "<a href='?src=[REF(src)];screen=1'>Back</a>"
					dat += "<br><b>Medical Robots:</b>"
					var/bdat = null
					for(var/mob/living/simple_animal/bot/medbot/M in GLOB.alive_mob_list)
						if(M.z != z)
							continue //only find medibots on the same z-level as the computer
						var/turf/bl = get_turf(M)
						if(bl) //if it can't find a turf for the medibot, then it probably shouldn't be showing up
							bdat += "[M.name] - <b>\[[bl.x],[bl.y]\]</b> - [M.bot_mode_flags & BOT_MODE_ON ? "Online" : "Offline"]<br>"
					if(!bdat)
						dat += "<br><center>None detected</center>"
					else
						dat += "<br>[bdat]"

				else
		else
			dat += "<A href='?src=[REF(src)];login=1'>{Log In}</A>"
	var/datum/browser/popup = new(user, "med_rec", "Medical Records Console", 600, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/med_data/Topic(href, href_list)
	. = ..()
	if(.)
		return .
	if(!(active1 in GLOB.data_core.general))
		active1 = null
	if(!(active2 in GLOB.data_core.general))
		active2 = null

	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr) || isAdminGhostAI(usr))
		usr.set_machine(src)
		if(href_list["temp"])
			temp = null
		else if(href_list["logout"])
			authenticated = null
			screen = null
			active1 = null
			active2 = null
			playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)
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
			var/obj/item/card/id/I
			if(isliving(usr))
				var/mob/living/L = usr
				I = L.get_idcard(TRUE)
			if(issilicon(usr))
				active1 = null
				active2 = null
				authenticated = 1
				rank = "AI"
				screen = 1
			else if(isAdminGhostAI(usr))
				active1 = null
				active2 = null
				authenticated = 1
				rank = "Central Command"
				screen = 1
			else if(istype(I) && check_access(I))
				active1 = null
				active2 = null
				authenticated = I.registered_name
				rank = I.assignment
				screen = 1
			else
				to_chat(usr, span_danger("Unauthorized access."))
			playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)
		if(authenticated)
			if(href_list["screen"])
				screen = text2num(href_list["screen"])
				if(screen < 1)
					screen = 1

				active1 = null
				active2 = null

			else if(href_list["vir"])
				var/type = text2path(href_list["vir"] || "")
				if(!ispath(type, /datum/disease))
					return

				var/datum/disease/disease = new type(0)
				var/applicable_mob_names = ""
				for(var/mob/viable_mob as anything in disease.viable_mobtypes)
					applicable_mob_names += " [initial(viable_mob.name)];"
				temp = {"<b>Name:</b> [disease.name]
<BR><b>Number of stages:</b> [disease.max_stages]
<BR><b>Spread:</b> [disease.spread_text] Transmission
<BR><b>Possible Cure:</b> [(disease.cure_text||"none")]
<BR><b>Affected Lifeforms:</b>[applicable_mob_names]
<BR>
<BR><b>Notes:</b> [disease.desc]
<BR>
<BR><b>Severity:</b> [disease.severity]"}

			else if(href_list["del_all"])
				temp = "Are you sure you wish to delete all records?<br>\n\t<A href='?src=[REF(src)];temp=1;del_all2=1'>Yes</A><br>\n\t<A href='?src=[REF(src)];temp=1'>No</A><br>"

			else if(href_list["del_all2"])
				usr.investigate_log("has deleted all medical records.", INVESTIGATE_RECORDS)
				GLOB.data_core.general.Cut()
				temp = "All records deleted."

			else if(href_list["field"])
				var/a1 = active1
				var/a2 = active2
				switch(href_list["field"])
					if("fingerprint")
						if(active1)
							var/t1 = stripped_input("Please input fingerprint hash:", "Med. records", active1.fingerprint, null)
							if(!canUseMedicalRecordsConsole(usr, t1, a1))
								return
							active1.fingerprint = t1
					if("gender")
						if(active1)
							if(active1.gender == "Male")
								active1.gender = "Female"
							else if(active1.gender == "Female")
								active1.gender = "Other"
							else
								active1.gender = "Male"
					if("age")
						if(active1)
							var/t1 = input("Please input age:", "Med. records", active1.age, null)  as num
							if(!canUseMedicalRecordsConsole(usr, t1, a1))
								return
							active1.age = t1
					if("species")
						if(active1)
							var/t1 = stripped_input("Please input species name", "Med. records", active1.species, null)
							if(!canUseMedicalRecordsConsole(usr, t1, a1))
								return
							active1.species = t1
					if("mi_dis")
						if(active2)
							var/t1 = stripped_input("Please input minor disabilities list:", "Med. records", active2.mi_dis, null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							active2.mi_dis = t1
					if("mi_dis_d")
						if(active2)
							var/t1 = stripped_input("Please summarize minor dis.:", "Med. records", active2.mi_dis_d, null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							active2.mi_dis_d = t1
					if("ma_dis")
						if(active2)
							var/t1 = stripped_input("Please input major disabilities list:", "Med. records", active2.ma_dis, null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							active2.ma_dis = t1
					if("ma_dis_d")
						if(active2)
							var/t1 = stripped_input("Please summarize major dis.:", "Med. records", active2.ma_dis_d, null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							active2.ma_dis_d = t1
					if("alg")
						if(active2)
							var/t1 = stripped_input("Please state allergies:", "Med. records", active2.alg, null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							active2.alg = t1
					if("alg_d")
						if(active2)
							var/t1 = stripped_input("Please summarize allergies:", "Med. records", active2.alg_d, null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							active2.alg_d = t1
					if("cdi")
						if(active2)
							var/t1 = stripped_input("Please state diseases:", "Med. records", active2.cdi, null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							active2.cdi = t1
					if("cdi_d")
						if(active2)
							var/t1 = stripped_input("Please summarize diseases:", "Med. records", active2.cdi_d, null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							active2.cdi_d = t1
					if("notes")
						if(active2)
							var/t1 = stripped_input("Please summarize notes:", "Med. records", active2.medical_notes, null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							active2.medical_notes = t1
					if("p_stat")
						if(active1)
							temp = "<B>Physical Condition:</B><BR>\n\t<A href='?src=[REF(src)];temp=1;p_stat=deceased'>*Deceased*</A><BR>\n\t<A href='?src=[REF(src)];temp=1;p_stat=unconscious'>*Unconscious*</A><BR>\n\t<A href='?src=[REF(src)];temp=1;p_stat=active'>Active</A><BR>\n\t<A href='?src=[REF(src)];temp=1;p_stat=unfit'>Physically Unfit</A><BR>"
					if("m_stat")
						if(active1)
							temp = "<B>Mental Condition:</B><BR>\n\t<A href='?src=[REF(src)];temp=1;m_stat=insane'>*Insane*</A><BR>\n\t<A href='?src=[REF(src)];temp=1;m_stat=unstable'>*Unstable*</A><BR>\n\t<A href='?src=[REF(src)];temp=1;m_stat=watch'>*Watch*</A><BR>\n\t<A href='?src=[REF(src)];temp=1;m_stat=stable'>Stable</A><BR>"
					if("blood_type")
						if(active2)
							temp = "<B>Blood Type:</B><BR>\n\t<A href='?src=[REF(src)];temp=1;blood_type=an'>A-</A> <A href='?src=[REF(src)];temp=1;blood_type=ap'>A+</A><BR>\n\t<A href='?src=[REF(src)];temp=1;blood_type=bn'>B-</A> <A href='?src=[REF(src)];temp=1;blood_type=bp'>B+</A><BR>\n\t<A href='?src=[REF(src)];temp=1;blood_type=abn'>AB-</A> <A href='?src=[REF(src)];temp=1;blood_type=abp'>AB+</A><BR>\n\t<A href='?src=[REF(src)];temp=1;blood_type=on'>O-</A> <A href='?src=[REF(src)];temp=1;blood_type=op'>O+</A><BR>"
					if("dna")
						if(active2)
							var/t1 = stripped_input("Please input DNA hash:", "Med. records", active2.dna, null)
							if(!canUseMedicalRecordsConsole(usr, t1, null, a2))
								return
							active2.dna = t1
					if("show_photo_front")
						if(active1)
							var/front_photo = active1.get_front_photo()
							if(istype(front_photo, /obj/item/photo))
								var/obj/item/photo/photo = front_photo
								photo.show(usr)
					if("show_photo_side")
						if(active1)
							var/side_photo = active1.get_side_photo()
							if(istype(side_photo, /obj/item/photo))
								var/obj/item/photo/photo = side_photo
								photo.show(usr)
					else

			else if(href_list["p_stat"])
				if(active1)
					switch(href_list["p_stat"])
						if("deceased")
							active1.p_stat = "*Deceased*"
						if("unconscious")
							active1.p_stat = "*Unconscious*"
						if("active")
							active1.p_stat = "Active"
						if("unfit")
							active1.p_stat = "Physically Unfit"

			else if(href_list["m_stat"])
				if(active1)
					switch(href_list["m_stat"])
						if("insane")
							active1.m_stat = "*Insane*"
						if("unstable")
							active1.m_stat = "*Unstable*"
						if("watch")
							active1.m_stat = "*Watch*"
						if("stable")
							active1.m_stat = "Stable"


			else if(href_list["blood_type"])
				if(active2)
					switch(href_list["blood_type"])
						if("an")
							active2.blood_type = "A-"
						if("bn")
							active2.blood_type = "B-"
						if("abn")
							active2.blood_type = "AB-"
						if("on")
							active2.blood_type = "O-"
						if("ap")
							active2.blood_type = "A+"
						if("bp")
							active2.blood_type = "B+"
						if("abp")
							active2.blood_type = "AB+"
						if("op")
							active2.blood_type = "O+"


			else if(href_list["del_r"])
				if(active2)
					temp = "Are you sure you wish to delete the record (Medical Portion Only)?<br>\n\t<A href='?src=[REF(src)];temp=1;del_r2=1'>Yes</A><br>\n\t<A href='?src=[REF(src)];temp=1'>No</A><br>"

			else if(href_list["del_r2"])
				usr.investigate_log("has deleted the medical records for [active1.name].", INVESTIGATE_RECORDS)
				if(active2)
					qdel(active2)
					active2 = null

			else if(href_list["d_rec"])
				active1 = find_record("id", href_list["d_rec"], GLOB.data_core.general)
				if(active1)
					active2 = find_record("id", href_list["d_rec"], GLOB.data_core.general)
				if(!active2)
					active1 = null
				screen = 4

			else if(href_list["new"])
				if((istype(active1, /datum/record/crew) && !( istype(active2, /datum/record/crew) )))
					var/datum/record/crew/record = new
					active2 = record
					screen = 4

			else if(href_list["search"])
				var/t1 = stripped_input(usr, "Search String: (Name, DNA, or ID)", "Med. records")
				if(!canUseMedicalRecordsConsole(usr, t1))
					return
				active1 = null
				active2 = null
				t1 = lowertext(t1)
				for(var/datum/record/crew/record in GLOB.data_core.general)
					if((lowertext(record.name) == t1 || t1 == lowertext(record.id) || t1 == lowertext(record.dna)))
						active2 = record
					else
						//Foreach continue //goto(3229)
				if(!( active2 ))
					temp = text("Could not locate record [].", sanitize(t1))
				else
					for(var/datum/record/crew/record in GLOB.data_core.general)
						if((record.name == active2.name || record.id == active2.id))
							active1 = record
						else
							//Foreach continue //goto(3334)
					screen = 4

			else if(href_list["print_p"])
				if(!( printing ))
					printing = 1
					GLOB.data_core.print_count++
					playsound(loc, 'sound/items/poster_being_created.ogg', 100, TRUE)
					sleep(3 SECONDS)
					var/obj/item/paper/printed_paper = new /obj/item/paper(loc)
					var/final_paper_text = "<CENTER><B>Medical Record - (MR-[GLOB.data_core.print_count])</B></CENTER><BR>"
					if(active1 in GLOB.data_core.general)
						final_paper_text += text("Name: [] ID: []<BR>\nGender: []<BR>\nAge: []<BR>", active1.name, active1.id, active1.gender, active1.age)
						final_paper_text += "\nSpecies: [active1.species]<BR>"
						final_paper_text += text("\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", active1.fingerprint, active1.p_stat, active1.m_stat)
					else
						final_paper_text += "<B>General Record Lost!</B><BR>"
					if(active2 in GLOB.data_core.general)
						final_paper_text += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: []<BR>\nDNA: []<BR>\n<BR>\nMinor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nMajor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nAllergies: []<BR>\nDetails: []<BR>\n<BR>\nCurrent Diseases: [] (per disease info placed in log/comment section)<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", active2.blood_type, active2.dna, active2.mi_dis, active2.mi_dis_d, active2.ma_dis, active2.ma_dis_d, active2.alg, active2.alg_d, active2.cdi, active2.cdi_d, active2.medical_notes)
						printed_paper.name = text("MR-[] '[]'", GLOB.data_core.print_count, active1.name)
					else
						final_paper_text += "<B>Medical Record Lost!</B><BR>"
						printed_paper.name = text("MR-[] '[]'", GLOB.data_core.print_count, "Record Lost")
					final_paper_text += "</TT>"
					printed_paper.add_raw_text(final_paper_text)
					printed_paper.update_appearance()
					printing = null

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/med_data/emp_act(severity)
	. = ..()
	if(machine_stat & (BROKEN|NOPOWER) || (. & EMP_PROTECT_SELF))
		return
	for(var/datum/record/crew/record in GLOB.data_core.general)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					if(prob(10))
						record.name = random_unique_lizard_name(record.gender,1)
					else
						record.name = random_unique_name(record.gender,1)
				if(2)
					record.gender = pick("Male", "Female", "Other")
				if(3)
					record.age = rand(AGE_MIN, AGE_MAX)
				if(4)
					record.blood_type = random_blood_type()
				if(5)
					record.p_stat = pick("*Unconscious*", "Active", "Physically Unfit")
				if(6)
					record.m_stat = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			qdel(record)
			continue

/obj/machinery/computer/med_data/proc/canUseMedicalRecordsConsole(mob/user, message = 1, record1, record2)
	if(user && message && authenticated)
		if(user.canUseTopic(src, !issilicon(user)))
			if(!record1 || record1 == active1)
				if(!record2 || record2 == active2)
					return TRUE
	return FALSE

/obj/machinery/computer/med_data/laptop
	name = "medical laptop"
	desc = "A cheap Nanotrasen medical laptop, it functions as a medical records computer. It's bolted to the table."
	icon_state = "laptop"
	icon_screen = "medlaptop"
	icon_keyboard = "laptop_key"
	pass_flags = PASSTABLE
