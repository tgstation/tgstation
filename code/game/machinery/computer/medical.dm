//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/obj/machinery/computer/med_data//TODO:SANITY
	name = "Medical Records"
	desc = "This can be used to check medical records."
	icon_state = "medcomp"
	req_access = list(ACCESS_MEDICAL)
	circuit = "/obj/item/weapon/circuitboard/med_data"
	var/obj/item/weapon/card/id/scan = null
	var/obj/item/weapon/disk/records/disk = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/list/Perp
	var/tempname = null


/obj/machinery/computer/med_data/attackby(obj/item/O as obj, user as mob)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		usr.drop_item()
		O.loc = src
		scan = O
		user << "You insert [O]."
	else if(istype(O, /obj/item/weapon/disk/records) && !disk)
		usr.drop_item()
		O.loc = src
		disk = O
		user << "You insert [O]."
	..()

/obj/machinery/computer/med_data/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/med_data/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/med_data/attack_hand(mob/user as mob)
	if(..())
		return
	var/dat
	if (src.temp)
		dat = text("<TT>[src.temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>")
	else
		dat = text("Confirm Identity: <A href='?src=\ref[];scan=1'>[]</A><HR>", src, (src.scan ? text("[]", src.scan.name) : "----------"))
		if (src.authenticated)
			switch(src.screen)
				if(1.0)
					dat += "<p style='text-align:center;'>"
					dat += text("<A href='?src=\ref[];search=1'>Search Records</A><BR>", src)
					dat += {"
						</p>
						<table style="text-align:center;" cellspacing="0" width="100%">
						<tr>
						<th>Records:</th>
						</tr>
						</table>
						<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th>Name</th>
						<th>ID</th>
						<th>Rank</th>
						<th>Fingerprints</th>
						<th>Physical Status</th>
						<th>Mental Status</th>
						</tr>"}
					for(var/datum/data/record/R in data_core.general)
						var/physstat = R.fields["p_stat"]
						var/background
						switch(physstat)
							if("*Deceased*")
								background = "'background-color:#CD853F;'"
							if("*Unconscious*")
								background = "'background-color:#DC143C;'"
							if("Physically Unfit")
								background = "'background-color:#3BB9FF;'"
							if("Active")
								background = "'background-color:#00FF7F;'"
							if("")
								background = "'background-color:#FFFFFF;'"
								physstat = "No Record."
						dat += text("<tr style=[]><td><A href='?src=\ref[];d_rec=\ref[]'>[]</a></td>", background, src, R, R.fields["name"])
						dat += text("<td>[]</td>", R.fields["id"])
						dat += text("<td>[]</td>", R.fields["rank"])
						dat += text("<td>[]</td>", R.fields["fingerprint"])
						dat += text("<td>[]</td>", physstat)
						dat += text("<td>[]</td></tr>", R.fields["m_stat"])
					dat += "</table><hr width='75%' />"
					dat += "<A href='?src=\ref[src];screen=5'>Virus Database</A><BR>"
					dat += "<A href='?src=\ref[src];screen=6'>Medbot Tracking</A><BR>"
					dat += "<A href='?src=\ref[src];screen=3'>Record Maintenance</A><BR><BR>"
					dat += "<A href='?src=\ref[src];logout=1'>{Log Out}</A>"
				if(2.0)
					if(!Perp.len)
						dat += text("ERROR.  String could not be located.<br><br><A href='?src=\ref[];screen=1'>Back</A>", src)
					else
						dat += {"
							<table style="text-align:center;" cellspacing="0" width="100%">
							<tr>					"}
						dat += text("<th>Search Results for '[]':</th>", tempname)
						dat += {"
							</tr>
							</table>
							<table style="text-align:center;" border="1" cellspacing="0" width="100%">
							<tr>
							<th>Name</th>
							<th>ID</th>
							<th>Rank</th>
							<th>Fingerprints</th>
							<th>Physical Status</th>
							<th>Mental Status</th>
							</tr>					"}
						for(var/i=1, i<=Perp.len, i += 2)
							var/datum/data/record/R = Perp[i]
							var/physstat = R.fields["p_stat"]
							var/background
							switch(physstat)
								if("*Deceased*")
									background = "'background-color:#CD853F;'"
								if("*Unconscious*")
									background = "'background-color:#DC143C;'"
								if("Physically Unfit")
									background = "'background-color:#3BB9FF;'"
								if("Active")
									background = "'background-color:#00FF7F;'"
								if("")
									background = "'background-color:#FFFFFF;'"
									physstat = "No Record."
							dat += text("<tr style=[]><td><A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", background, src, R, R.fields["name"])
							dat += text("<td>[]</td>", R.fields["id"])
							dat += text("<td>[]</td>", R.fields["rank"])
							dat += text("<td>[]</td>", R.fields["fingerprint"])
							dat += text("<td>[]</td>", physstat)
							dat += text("<td>[]</td></tr>", R.fields["m_stat"])
						dat += "</table><hr width='75%' />"
						dat += text("<br><A href='?src=\ref[];screen=1'>Return to index.</A>", src)
				if(3.0)
					dat += "<B>Records Maintenance</B><HR>"
					if(disk)
						dat += "<B>Disk Contents:</B><UL style='margin-top:0;margin-bottom:0'>"
						if(disk.general)
							dat += "<LI>General</LI>"
						if(disk.medical)
							dat += "<LI>Medical</LI>"
						if(disk.security)
							dat += "<LI>Security</LI>"
						dat += "</UL><A href='?src=\ref[src];backup=1'>Backup To Disk</A><BR>"
						if(disk.general && disk.medical)
							dat += "<A href='?src=\ref[src];restore=1'>Restore From Disk</A><BR>"
						else
							dat += "Disk does not contain medical records.<BR>"
						dat += "<A href='?src=\ref[src];eject_disk=1'>Eject Disk</A><BR>"
					else
						dat += "Please insert a records disk.<BR>"
					dat += "<BR><A href='?src=\ref[src];del_all=1'>Delete All Records</A><BR><BR><A href='?src=\ref[src];screen=1'>Back</A>"
				if(4.0)
					dat += "<CENTER><B>Medical Record</B></CENTER><BR>"
					if ((istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1)))
						dat += text("Name: [] ID: []<BR>\nSex: <A href='?src=\ref[];field=sex'>[]</A><BR>\nAge: <A href='?src=\ref[];field=age'>[]</A><BR>\nFingerprint: <A href='?src=\ref[];field=fingerprint'>[]</A><BR>\nPhysical Status: <A href='?src=\ref[];field=p_stat'>[]</A><BR>\nMental Status: <A href='?src=\ref[];field=m_stat'>[]</A><BR>", src.active1.fields["name"], src.active1.fields["id"], src, src.active1.fields["sex"], src, src.active1.fields["age"], src, src.active1.fields["fingerprint"], src, src.active1.fields["p_stat"], src, src.active1.fields["m_stat"])
					else
						dat += "<B>General Record Lost!</B><BR>"
					if ((istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2)))
						dat += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=\ref[];field=b_type'>[]</A><BR>\nDNA: <A href='?src=\ref[];field=b_dna'>[]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=\ref[];field=mi_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=mi_dis_d'>[]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=\ref[];field=ma_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=ma_dis_d'>[]</A><BR>\n<BR>\nAllergies: <A href='?src=\ref[];field=alg'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=alg_d'>[]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=\ref[];field=cdi'>[]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=\ref[];field=cdi_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src, src.active2.fields["b_type"], src, src.active2.fields["b_dna"], src, src.active2.fields["mi_dis"], src, src.active2.fields["mi_dis_d"], src, src.active2.fields["ma_dis"], src, src.active2.fields["ma_dis_d"], src, src.active2.fields["alg"], src, src.active2.fields["alg_d"], src, src.active2.fields["cdi"], src, src.active2.fields["cdi_d"], src, src.active2.fields["notes"])
						var/counter = 1
						while(src.active2.fields[text("com_[]", counter)])
							dat += text("[]<BR><A href='?src=\ref[];del_c=[]'>Delete Entry</A><BR><BR>", src.active2.fields[text("com_[]", counter)], src, counter)
							counter++
						dat += text("<A href='?src=\ref[];add_c=1'>Add Entry</A><BR><BR>", src)
						dat += text("<A href='?src=\ref[];del_r=1'>Delete Record (Medical Only)</A><BR><BR>", src)
					else
						dat += "<B>Medical Record Lost!</B><BR>"
						dat += text("<A href='?src=\ref[src];new=1'>New Record</A><BR><BR>")
					dat += text("\n<A href='?src=\ref[];print_p=1'>Print Record</A><BR>\n<A href='?src=\ref[];screen=1'>Back</A><BR>", src, src)
				if(5.0)
					dat += "<B>Virus Database</B><HR>"
					for(var/Dt in typesof(/datum/disease/))
						var/datum/disease/Dis = new Dt(0)
						if(!Dis.desc)
							continue
						dat += "<a href='?src=\ref[src];vir=[Dt]'>[Dis.name]</a><br>"
					dat += "<br><a href='?src=\ref[src];screen=1'>Back</a>"
				if(6.0)
					dat += "<b>Medical Robot Monitor</b><hr>"
					dat += "<b>Medical Robots:</b><br>"
					var/bdat = null
					for(var/obj/machinery/bot/medbot/M in world)
						var/turf/bl = get_turf(M)
						bdat += "[M.name] - <b>\[[bl.x],[bl.y]\]</b> - [M.on ? "Online" : "Offline"]<br>"
						if((!isnull(M.reagent_glass)) && M.use_beaker)
							bdat += "Reservoir: \[[M.reagent_glass.reagents.total_volume]/[M.reagent_glass.reagents.maximum_volume]\]<br>"
						else
							bdat += "Using Internal Synthesizer.<br>"

					if(!bdat)
						dat += "None detected<br><br>"
					else
						dat += "[bdat]<br>"

					dat += "<a href='?src=\ref[src];screen=1'>Back</a>"

				else
		else
			dat += text("<A href='?src=\ref[];login=1'>{Log In}</A>", src)
	user << browse(text("<HEAD><TITLE>Medical Records</TITLE></HEAD><TT>[]</TT>", dat), "window=med_rec;size=600x400")
	onclose(user, "med_rec")
	return

/obj/machinery/computer/med_data/Topic(href, href_list)
	if(..())
		return
	if (!( data_core.general.Find(src.active1) ))
		src.active1 = null
	if (!( data_core.medical.Find(src.active2) ))
		src.active2 = null
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["temp"])
			src.temp = null
		if (href_list["scan"])
			if (src.scan)
				if(istype(usr,/mob/living/carbon/human) && !usr.get_active_hand())
					usr.put_in_hand(scan)
				else
					scan.loc = get_turf(src)
				scan = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					src.scan = I
		else if (href_list["logout"])
			src.authenticated = null
			src.screen = null
			src.active1 = null
			src.active2 = null
		else if (href_list["login"])
			if (istype(usr, /mob/living/silicon))
				src.active1 = null
				src.active2 = null
				src.authenticated = 1
				src.rank = "AI"
				src.screen = 1
			else if (istype(src.scan, /obj/item/weapon/card/id))
				src.active1 = null
				src.active2 = null
				if (src.check_access(src.scan))
					src.authenticated = src.scan.registered_name
					src.rank = src.scan.assignment
					src.screen = 1
		if (src.authenticated)

			if(href_list["screen"])
				src.screen = text2num(href_list["screen"])
				if(src.screen < 1)
					src.screen = 1

				src.active1 = null
				src.active2 = null

			if(href_list["vir"])
				var/type = href_list["vir"]
				var/datum/disease/Dis = new type(0)
				var/AfS = ""
				for(var/Str in Dis.affected_species)
					AfS += " [Str];"
				src.temp = {"<b>Name:</b> [Dis.name]
<BR><b>Number of stages:</b> [Dis.max_stages]
<BR><b>Spread:</b> [Dis.spread] Transmission
<BR><b>Possible Cure:</b> [(Dis.cure||"none")]
<BR><b>Affected Species:</b>[AfS]
<BR>
<BR><b>Notes:</b> [Dis.desc]
<BR>
<BR><b>Severity:</b> [Dis.severity]"}

			if (href_list["del_all"])
				src.temp = text("Are you sure you wish to delete all records?<br>\n\t<A href='?src=\ref[];temp=1;del_all2=1'>Yes</A><br>\n\t<A href='?src=\ref[];temp=1'>No</A><br>", src, src)

			if (href_list["del_all2"])
				for(var/datum/data/record/R in data_core.medical)
					//R = null
					del(R)
					//Foreach goto(494)
				src.temp = "All records deleted."

			if (href_list["field"])
				var/a1 = src.active1
				var/a2 = src.active2
				switch(href_list["field"])
					if("fingerprint")
						if (istype(src.active1, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please input fingerprint hash:", "Med. records", src.active1.fields["fingerprint"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
								return
							src.active1.fields["fingerprint"] = t1
					if("sex")
						if (istype(src.active1, /datum/data/record))
							if (src.active1.fields["sex"] == "Male")
								src.active1.fields["sex"] = "Female"
							else
								src.active1.fields["sex"] = "Male"
					if("age")
						if (istype(src.active1, /datum/data/record))
							var/t1 = input("Please input age:", "Med. records", src.active1.fields["age"], null)  as num
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
								return
							src.active1.fields["age"] = t1
					if("mi_dis")
						if (istype(src.active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please input minor disabilities list:", "Med. records", src.active2.fields["mi_dis"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["mi_dis"] = t1
					if("mi_dis_d")
						if (istype(src.active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please summarize minor dis.:", "Med. records", src.active2.fields["mi_dis_d"], null)  as message),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["mi_dis_d"] = t1
					if("ma_dis")
						if (istype(src.active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please input major diabilities list:", "Med. records", src.active2.fields["ma_dis"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["ma_dis"] = t1
					if("ma_dis_d")
						if (istype(src.active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please summarize major dis.:", "Med. records", src.active2.fields["ma_dis_d"], null)  as message),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["ma_dis_d"] = t1
					if("alg")
						if (istype(src.active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please state allergies:", "Med. records", src.active2.fields["alg"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["alg"] = t1
					if("alg_d")
						if (istype(src.active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please summarize allergies:", "Med. records", src.active2.fields["alg_d"], null)  as message),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["alg_d"] = t1
					if("cdi")
						if (istype(src.active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please state diseases:", "Med. records", src.active2.fields["cdi"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["cdi"] = t1
					if("cdi_d")
						if (istype(src.active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please summarize diseases:", "Med. records", src.active2.fields["cdi_d"], null)  as message),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["cdi_d"] = t1
					if("notes")
						if (istype(src.active2, /datum/data/record))
							var/t1 = input("Please summarize notes:", "Med. records", src.active2.fields["notes"], null)  as message
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							t1 = copytext(t1, 1, MAX_PAPER_MESSAGE_LEN)
							t1 = html_encode(t1)
							src.active2.fields["notes"] = t1
					if("p_stat")
						if (istype(src.active1, /datum/data/record))
							src.temp = text("<B>Physical Condition:</B><BR>\n\t<A href='?src=\ref[];temp=1;p_stat=deceased'>*Deceased*</A><BR>\n\t<A href='?src=\ref[];temp=1;p_stat=unconscious'>*Unconscious*</A><BR>\n\t<A href='?src=\ref[];temp=1;p_stat=active'>Active</A><BR>\n\t<A href='?src=\ref[];temp=1;p_stat=unfit'>Physically Unfit</A><BR>", src, src, src, src)
					if("m_stat")
						if (istype(src.active1, /datum/data/record))
							src.temp = text("<B>Mental Condition:</B><BR>\n\t<A href='?src=\ref[];temp=1;m_stat=insane'>*Insane*</A><BR>\n\t<A href='?src=\ref[];temp=1;m_stat=unstable'>*Unstable*</A><BR>\n\t<A href='?src=\ref[];temp=1;m_stat=watch'>*Watch*</A><BR>\n\t<A href='?src=\ref[];temp=1;m_stat=stable'>Stable</A><BR>", src, src, src, src)
					if("b_type")
						if (istype(src.active2, /datum/data/record))
							src.temp = text("<B>Blood Type:</B><BR>\n\t<A href='?src=\ref[];temp=1;b_type=an'>A-</A> <A href='?src=\ref[];temp=1;b_type=ap'>A+</A><BR>\n\t<A href='?src=\ref[];temp=1;b_type=bn'>B-</A> <A href='?src=\ref[];temp=1;b_type=bp'>B+</A><BR>\n\t<A href='?src=\ref[];temp=1;b_type=abn'>AB-</A> <A href='?src=\ref[];temp=1;b_type=abp'>AB+</A><BR>\n\t<A href='?src=\ref[];temp=1;b_type=on'>O-</A> <A href='?src=\ref[];temp=1;b_type=op'>O+</A><BR>", src, src, src, src, src, src, src, src)
					if("b_dna")
						if (istype(src.active1, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please input DNA hash:", "Med. records", src.active1.fields["dna"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
								return
							src.active1.fields["dna"] = t1
					else

			if (href_list["p_stat"])
				if (src.active1)
					switch(href_list["p_stat"])
						if("deceased")
							src.active1.fields["p_stat"] = "*Deceased*"
						if("unconscious")
							src.active1.fields["p_stat"] = "*Unconscious*"
						if("active")
							src.active1.fields["p_stat"] = "Active"
						if("unfit")
							src.active1.fields["p_stat"] = "Physically Unfit"

			if (href_list["m_stat"])
				if (src.active1)
					switch(href_list["m_stat"])
						if("insane")
							src.active1.fields["m_stat"] = "*Insane*"
						if("unstable")
							src.active1.fields["m_stat"] = "*Unstable*"
						if("watch")
							src.active1.fields["m_stat"] = "*Watch*"
						if("stable")
							src.active1.fields["m_stat"] = "Stable"


			if (href_list["b_type"])
				if (src.active2)
					switch(href_list["b_type"])
						if("an")
							src.active2.fields["b_type"] = "A-"
						if("bn")
							src.active2.fields["b_type"] = "B-"
						if("abn")
							src.active2.fields["b_type"] = "AB-"
						if("on")
							src.active2.fields["b_type"] = "O-"
						if("ap")
							src.active2.fields["b_type"] = "A+"
						if("bp")
							src.active2.fields["b_type"] = "B+"
						if("abp")
							src.active2.fields["b_type"] = "AB+"
						if("op")
							src.active2.fields["b_type"] = "O+"


			if (href_list["del_r"])
				if (src.active2)
					src.temp = text("Are you sure you wish to delete the record (Medical Portion Only)?<br>\n\t<A href='?src=\ref[];temp=1;del_r2=1'>Yes</A><br>\n\t<A href='?src=\ref[];temp=1'>No</A><br>", src, src)

			if (href_list["del_r2"])
				if (src.active2)
					//src.active2 = null
					del(src.active2)

			if (href_list["d_rec"])
				var/datum/data/record/R = locate(href_list["d_rec"])
				var/datum/data/record/M = locate(href_list["d_rec"])
				if (!( data_core.general.Find(R) ))
					src.temp = "Record Not Found!"
					return
				for(var/datum/data/record/E in data_core.medical)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						M = E
					else
						//Foreach continue //goto(2540)
				src.active1 = R
				src.active2 = M
				src.screen = 4

			if (href_list["new"])
				if ((istype(src.active1, /datum/data/record) && !( istype(src.active2, /datum/data/record) )))
					var/datum/data/record/R = new /datum/data/record(  )
					R.fields["name"] = src.active1.fields["name"]
					R.fields["id"] = src.active1.fields["id"]
					R.name = text("Medical Record #[]", R.fields["id"])
					R.fields["b_type"] = "Unknown"
					R.fields["b_dna"] = "Unknown"
					R.fields["mi_dis"] = "None"
					R.fields["mi_dis_d"] = "No minor disabilities have been declared."
					R.fields["ma_dis"] = "None"
					R.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
					R.fields["alg"] = "None"
					R.fields["alg_d"] = "No allergies have been detected in this patient."
					R.fields["cdi"] = "None"
					R.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
					R.fields["notes"] = "No notes."
					data_core.medical += R
					src.active2 = R
					src.screen = 4

			if (href_list["add_c"])
				if (!( istype(src.active2, /datum/data/record) ))
					return
				var/a2 = src.active2
				var/t1 = copytext(sanitize(input("Add Comment:", "Med. records", null, null)  as message),1,MAX_MESSAGE_LEN)
				if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
					return
				var/counter = 1
				while(src.active2.fields[text("com_[]", counter)])
					counter++
				src.active2.fields[text("com_[]", counter)] = text("Made by [] ([]) on [], 2556<BR>[]", src.authenticated, src.rank, time2text(world.realtime, "DDD MMM DD hh:mm:ss"), t1)

			if (href_list["del_c"])
				if ((istype(src.active2, /datum/data/record) && src.active2.fields[text("com_[]", href_list["del_c"])]))
					src.active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"

			if (href_list["search"])
				var/t1 = input("Search String: (Partial Name or ID or Fingerprints or DNA or Rank)", "Med. records", null, null)  as text
				if ((!( t1 ) || usr.stat || !( src.authenticated ) || usr.restrained() || ((!in_range(src, usr)) && (!istype(usr, /mob/living/silicon)))))
					return
				Perp = new/list()
				t1 = lowertext(t1)
				var/list/components = dd_text2list(t1, " ")
				if(components.len > 5)
					return //Lets not let them search too greedily.
				for(var/datum/data/record/R in data_core.general)
					var/temptext = R.fields["name"] + " " + R.fields["id"] + " " + R.fields["fingerprint"] + " " + R.fields["rank"]

					for(var/datum/data/record/E in data_core.medical)
						if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
							temptext += " " + E.fields["b_dna"]

					for(var/i = 1, i<=components.len, i++)
						if(findtext(temptext,components[i]))
							var/prelist = new/list(2)
							prelist[1] = R
							Perp += prelist
				for(var/i = 1, i<=Perp.len, i+=2)
					for(var/datum/data/record/E in data_core.medical)
						var/datum/data/record/R = Perp[i]
						if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
							Perp[i+1] = E
				tempname = t1
				src.screen = 2

			if (href_list["print_p"])
				if (!( src.printing ))
					src.printing = 1
					sleep(50)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
					P.info = "<CENTER><B>Medical Record</B></CENTER><BR>"
					if ((istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1)))
						P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", src.active1.fields["name"], src.active1.fields["id"], src.active1.fields["sex"], src.active1.fields["age"], src.active1.fields["fingerprint"], src.active1.fields["p_stat"], src.active1.fields["m_stat"])
					else
						P.info += "<B>General Record Lost!</B><BR>"
					if ((istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2)))
						P.info += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: []<BR>\nDNA: []<BR>\n<BR>\nMinor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nMajor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nAllergies: []<BR>\nDetails: []<BR>\n<BR>\nCurrent Diseases: [] (per disease info placed in log/comment section)<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src.active2.fields["b_type"], src.active2.fields["b_dna"], src.active2.fields["mi_dis"], src.active2.fields["mi_dis_d"], src.active2.fields["ma_dis"], src.active2.fields["ma_dis_d"], src.active2.fields["alg"], src.active2.fields["alg_d"], src.active2.fields["cdi"], src.active2.fields["cdi_d"], src.active2.fields["notes"])
						var/counter = 1
						while(src.active2.fields[text("com_[]", counter)])
							P.info += text("[]<BR>", src.active2.fields[text("com_[]", counter)])
							counter++
					else
						P.info += "<B>Medical Record Lost!</B><BR>"
					P.info += "</TT>"
					P.name = "paper - 'Medical Record'"
					src.printing = null
			if (href_list["eject_disk"])
				if (!disk)
					return
				if(istype(usr,/mob/living/carbon/human) && !usr.get_active_hand())
					usr.put_in_hand(disk)
				else
					disk.loc = get_turf(src)
				disk = null
			if (href_list["backup"])
				if (!disk)
					return
				disk.backup(1, 0)
				temp = "Data backup complete."
			if (href_list["restore"])
				if (!disk)
					return
				disk.restore(1, 0)
				temp = "Data restore complete."

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/med_data/laptop
	name = "Medical Laptop"
	desc = "Cheap NanoTrasen Laptop."
	icon_state = "medlaptop"
