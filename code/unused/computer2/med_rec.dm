/datum/computer/file/computer_program/med_data
	name = "Medical Records"
	size = 32.0
	active_icon = "dna"
	req_access = list(access_medical)
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null

/datum/computer/file/computer_program/med_data/return_text()
	if(..())
		return
	var/dat
	if (src.temp)
		dat = text("<TT>[src.temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>")
	else
		dat = text("Confirm Identity: <A href='?src=\ref[];id=auth'>[]</A><HR>", master, (src.master.authid ? text("[]", src.master.authid.name) : "----------"))
		if (src.authenticated)
			switch(src.screen)
				if(1.0)
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
				if(2.0)
					dat += "<B>Record List</B>:<HR>"
					for(var/datum/data/record/R in data_core.general)
						dat += text("<A href='?src=\ref[];d_rec=\ref[]'>[]: []<BR>", src, R, R.fields["id"], R.fields["name"])
						//Foreach goto(132)
					dat += text("<HR><A href='?src=\ref[];screen=1'>Back</A>", src)
				if(3.0)
					dat += text("<B>Records Maintenance</B><HR>\n<A href='?src=\ref[];back=1'>Backup To Disk</A><BR>\n<A href='?src=\ref[];u_load=1'>Upload From disk</A><BR>\n<A href='?src=\ref[];del_all=1'>Delete All Records</A><BR>\n<BR>\n<A href='?src=\ref[];screen=1'>Back</A>", src, src, src, src)
				if(4.0)
					dat += "<CENTER><B>Medical Record</B></CENTER><BR>"
					if ((istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1)))
						dat += text("Name: [] ID: []<BR>\nSex: <A href='?src=\ref[];field=sex'>[]</A><BR>\nAge: <A href='?src=\ref[];field=age'>[]</A><BR>\nFingerprint: <A href='?src=\ref[];field=fingerprint'>[]</A><BR>\nPhysical Status: <A href='?src=\ref[];field=p_stat'>[]</A><BR>\nMental Status: <A href='?src=\ref[];field=m_stat'>[]</A><BR>", src.active1.fields["name"], src.active1.fields["id"], src, src.active1.fields["sex"], src, src.active1.fields["age"], src, src.active1.fields["fingerprint"], src, src.active1.fields["p_stat"], src, src.active1.fields["m_stat"])
					else
						dat += "<B>General Record Lost!</B><BR>"
					if ((istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2)))
						dat += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=\ref[];field=b_type'>[]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=\ref[];field=mi_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=mi_dis_d'>[]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=\ref[];field=ma_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=ma_dis_d'>[]</A><BR>\n<BR>\nAllergies: <A href='?src=\ref[];field=alg'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=alg_d'>[]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=\ref[];field=cdi'>[]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=\ref[];field=cdi_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src, src.active2.fields["b_type"], src, src.active2.fields["mi_dis"], src, src.active2.fields["mi_dis_d"], src, src.active2.fields["ma_dis"], src, src.active2.fields["ma_dis_d"], src, src.active2.fields["alg"], src, src.active2.fields["alg_d"], src, src.active2.fields["cdi"], src, src.active2.fields["cdi_d"], src, src.active2.fields["notes"])
						var/counter = 1
						while(src.active2.fields[text("com_[]", counter)])
							dat += text("[]<BR><A href='?src=\ref[];del_c=[]'>Delete Entry</A><BR><BR>", src.active2.fields[text("com_[]", counter)], src, counter)
							counter++
						dat += text("<A href='?src=\ref[];add_c=1'>Add Entry</A><BR><BR>", src)
						dat += text("<A href='?src=\ref[];del_r=1'>Delete Record (Medical Only)</A><BR><BR>", src)
					else
						dat += "<B>Medical Record Lost!</B><BR>"
						dat += text("<A href='?src=\ref[src];new=1'>New Record</A><BR><BR>")
					dat += text("\n<A href='?src=\ref[];print_p=1'>Print Record</A><BR>\n<A href='?src=\ref[];screen=2'>Back</A><BR>", src, src)
				if(5.0)
					dat += {"<CENTER><B>Virus Database</B></CENTER>
					<br><a href='?src=\ref[src];vir=gbs'>GBS</a>
					<br><a href='?src=\ref[src];vir=cc'>Common Cold</a>
					<br><a href='?src=\ref[src];vir=f'>Flu</A>
					<br><a href='?src=\ref[src];vir=jf'>Jungle Fever</a>
					<br><a href='?src=\ref[src];vir=ca'>Clowning Around</a>
					<br><a href='?src=\ref[src];vir=p'>Plasmatoid</a>
					<br><a href='?src=\ref[src];vir=dna'>Space Rhinovirus</a>
					<br><a href='?src=\ref[src];vir=bot'>Robot Transformation</a>
					<br><a href='?src=\ref[src];screen=1'>Back</a>"}
				if(6.0)
					dat += "<center><b>Medical Robot Monitor</b></center>"
					dat += "<a href='?src=\ref[src];screen=1'>Back</a>"
					dat += "<br><b>Medical Robots:</b>"
					var/bdat = null
					for(var/obj/machinery/bot/medbot/M in world)
						var/turf/bl = get_turf(M)
						bdat += "[M.name] - <b>\[[bl.x],[bl.y]\]</b> - [M.on ? "Online" : "Offline"]<br>"
						if(!isnull(M.reagent_glass))
							bdat += "Reservoir: \[[M.reagent_glass.reagents.total_volume]/[M.reagent_glass.reagents.maximum_volume]\]"
						else
							bdat += "Using Internal Synthesizer."

					if(!bdat)
						dat += "<br><center>None detected</center>"
					else
						dat += "[bdat]"

				else
		else
			dat += text("<A href='?src=\ref[];login=1'>{Log In}</A>", src)
			dat += "<br><a href='byond://?src=\ref[src];quit=1'>{Quit}</a>"

	return dat

/datum/computer/file/computer_program/med_data/Topic(href, href_list)
	if(..())
		return
	if (!( data_core.general.Find(src.active1) ))
		src.active1 = null
	if (!( data_core.medical.Find(src.active2) ))
		src.active2 = null
	if (href_list["temp"])
		src.temp = null
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
		else if (istype(src.master.authid, /obj/item/weapon/card/id))
			src.active1 = null
			src.active2 = null
			if (src.check_access(src.master.authid))
				src.authenticated = src.master.authid.registered_name
				src.rank = src.master.authid.assignment
				src.screen = 1
	if (src.authenticated)

		if(href_list["screen"])
			src.screen = text2num(href_list["screen"])
			if(src.screen < 1)
				src.screen = 1

			src.active1 = null
			src.active2 = null

		if(href_list["vir"])
			switch(href_list["vir"])
				if("gbs")
					src.temp = {"<b>Name:</b> GBS
<BR><b>Number of stages:</b> 5
<BR><b>Spread:</b> Airborne Transmission
<BR><b>Possible Cure:</b> Spaceacillin
<BR><b>Affected Species:</b> Human
<BR>
<BR><b>Notes:</b> If left untreated death will occur.
<BR>
<BR><b>Severity:</b> Major"}
				if("cc")
					src.temp = {"<b>Name:</b> Common Cold
<BR><b>Number of stages:</b> 3
<BR><b>Spread:</b> Airborne Transmission
<BR><b>Possible Cure:</b> Rest
<BR><b>Affected Species:</b> Human
<BR>
<BR><b>Notes:</b> If left untreated the subject will contract the flu.
<BR>
<BR><b>Severity:</b> Minor"}
				if("f")
					src.temp = {"<b>Name:</b> The Flu
<BR><b>Number of stages:</b> 3
<BR><b>Spread:</b> Airborne Transmission
<BR><b>Possible Cure:</b> Rest
<BR><b>Affected Species:</b> Human
<BR>
<BR><b>Notes:</b> If left untreated the subject will feel quite unwell.
<BR>
<BR><b>Severity:</b> Medium"}
				if("jf")
					src.temp = {"<b>Name:</b> Jungle Fever
<BR><b>Number of stages:</b> 1
<BR><b>Spread:</b> Airborne Transmission
<BR><b>Possible Cure:</b> None
<BR><b>Affected Species:</b> Monkey
<BR>
<BR><b>Notes:</b> monkeys with this disease will bite humans, causing humans to spontaneously to mutate into a monkey.
<BR>
<BR><b>Severity:</b> Medium"}
				if("ca")
					src.temp = {"<b>Name:</b> Clowning Around
<BR><b>Number of stages:</b> 4
<BR><b>Spread:</b> Airborne Transmission
<BR><b>Possible Cure:</b> Spaceacillin
<BR><b>Affected Species:</b> Human
<BR>
<BR><b>Notes:</b> Subjects are affected by rampant honking and a fondness for shenanigans. They may also spontaneously phase through closed airlocks.
<BR>
<BR><b>Severity:</b> Laughable"}
				if("p")
					src.temp = {"<b>Name:</b> Plasmatoid
<BR><b>Number of stages:</b> 3
<BR><b>Spread:</b> Airborne Transmission
<BR><b>Possible Cure:</b> Inaprovaline
<BR><b>Affected Species:</b> Human and Monkey
<BR>
<BR><b>Notes:</b> With this disease the victim will need plasma to breathe.
<BR>
<BR><b>Severity:</b> Major"}
				if("dna")
					src.temp = {"<b>Name:</b> Space Rhinovirus
<BR><b>Number of stages:</b> 4
<BR><b>Spread:</b> Airborne Transmission
<BR><b>Possible Cure:</b> Spaceacillin
<BR><b>Affected Species:</b> Human
<BR>
<BR><b>Notes:</b> This disease transplants the genetic code of the intial vector into new hosts.
<BR>
<BR><b>Severity:</b> Medium"}
				if("bot")
					src.temp = {"<b>Name:</b> Robot Transformation
<BR><b>Number of stages:</b> 5
<BR><b>Spread:</b> Infected food
<BR><b>Possible Cure:</b> None
<BR><b>Affected Species:</b> Human
<BR>
<BR><b>Notes:</b> This disease, actually acute nanomachine infection, converts the victim into a cyborg.
<BR>
<BR><b>Severity:</b> Major"}

		if (href_list["del_all"])
			src.temp = text("Are you sure you wish to delete all records?<br>\n\t<A href='?src=\ref[];temp=1;del_all2=1'>Yes</A><br>\n\t<A href='?src=\ref[];temp=1'>No</A><br>", src, src)

		if (href_list["del_all2"])
			for(var/datum/data/record/R in data_core.medical)
				del(R)
			src.temp = "All records deleted."

		if (href_list["field"])
			var/a1 = src.active1
			var/a2 = src.active2
			switch(href_list["field"])
				if("fingerprint")
					if (istype(src.active1, /datum/data/record))
						var/t1 = input("Please input fingerprint hash:", "Med. records", src.active1.fields["id"], null)  as text
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
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
						var/t1 = input("Please input age:", "Med. records", src.active1.fields["age"], null)  as text
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
							return
						src.active1.fields["age"] = t1
				if("mi_dis")
					if (istype(src.active2, /datum/data/record))
						var/t1 = input("Please input minor disabilities list:", "Med. records", src.active2.fields["mi_dis"], null)  as text
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
							return
						src.active2.fields["mi_dis"] = t1
				if("mi_dis_d")
					if (istype(src.active2, /datum/data/record))
						var/t1 = input("Please summarize minor dis.:", "Med. records", src.active2.fields["mi_dis_d"], null)  as message
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
							return
						src.active2.fields["mi_dis_d"] = t1
				if("ma_dis")
					if (istype(src.active2, /datum/data/record))
						var/t1 = input("Please input major diabilities list:", "Med. records", src.active2.fields["ma_dis"], null)  as text
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
							return
						src.active2.fields["ma_dis"] = t1
				if("ma_dis_d")
					if (istype(src.active2, /datum/data/record))
						var/t1 = input("Please summarize major dis.:", "Med. records", src.active2.fields["ma_dis_d"], null)  as message
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
							return
						src.active2.fields["ma_dis_d"] = t1
				if("alg")
					if (istype(src.active2, /datum/data/record))
						var/t1 = input("Please state allergies:", "Med. records", src.active2.fields["alg"], null)  as text
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
							return
						src.active2.fields["alg"] = t1
				if("alg_d")
					if (istype(src.active2, /datum/data/record))
						var/t1 = input("Please summarize allergies:", "Med. records", src.active2.fields["alg_d"], null)  as message
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
							return
						src.active2.fields["alg_d"] = t1
				if("cdi")
					if (istype(src.active2, /datum/data/record))
						var/t1 = input("Please state diseases:", "Med. records", src.active2.fields["cdi"], null)  as text
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
							return
						src.active2.fields["cdi"] = t1
				if("cdi_d")
					if (istype(src.active2, /datum/data/record))
						var/t1 = input("Please summarize diseases:", "Med. records", src.active2.fields["cdi_d"], null)  as message
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
							return
						src.active2.fields["cdi_d"] = t1
				if("notes")
					if (istype(src.active2, /datum/data/record))
						var/t1 = input("Please summarize notes:", "Med. records", src.active2.fields["notes"], null)  as message
						if ((!( t1 ) || !( src.authenticated ) || (!src.master) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
							return
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
						src.active2.fields["m_stat"] = "Stable"


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
				src.temp = "Are you sure you wish to delete the record (Medical Portion Only)?<br>\n\t<A href='?src=\ref[src];temp=1;del_r2=1'>Yes</A><br>\n\t<A href='?src=\ref[src];temp=1'>No</A><br>"

		if (href_list["del_r2"])
			if (src.active2)
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
			var/t1 = input("Add Comment:", "Med. records", null, null)  as message
			if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_range(src.master, usr) && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
				return
			var/counter = 1
			while(src.active2.fields[text("com_[]", counter)])
				counter++
			src.active2.fields[text("com_[]", counter)] = text("Made by [] ([]) on [], 2053<BR>[]", src.authenticated, src.rank, time2text(world.realtime, "DDD MMM DD hh:mm:ss"), t1)

		if (href_list["del_c"])
			if ((istype(src.active2, /datum/data/record) && src.active2.fields[text("com_[]", href_list["del_c"])]))
				src.active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"

		if (href_list["search"])
			var/t1 = input("Search String: (Name or ID)", "Med. records", null, null)  as text
			if ((!( t1 ) || usr.stat || (!src.master) || !( src.authenticated ) || usr.restrained() || ((!in_range(src.master, usr)) && (!istype(usr, /mob/living/silicon)))))
				return
			src.active1 = null
			src.active2 = null
			t1 = lowertext(t1)
			for(var/datum/data/record/R in data_core.general)
				if ((lowertext(R.fields["name"]) == t1 || t1 == lowertext(R.fields["id"])))
					src.active1 = R
				else

			if (!( src.active1 ))
				src.temp = text("Could not locate record [].", t1)
			else
				for(var/datum/data/record/E in data_core.medical)
					if ((E.fields["name"] == src.active1.fields["name"] || E.fields["id"] == src.active1.fields["id"]))
						src.active2 = E
					else

				src.screen = 4

		if (href_list["print_p"])
			var/info = "<CENTER><B>Medical Record</B></CENTER><BR>"
			if ((istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1)))
				info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", src.active1.fields["name"], src.active1.fields["id"], src.active1.fields["sex"], src.active1.fields["age"], src.active1.fields["fingerprint"], src.active1.fields["p_stat"], src.active1.fields["m_stat"])
			else
				info += "<B>General Record Lost!</B><BR>"
			if ((istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2)))
				info += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: []<BR>\n<BR>\nMinor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nMajor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nAllergies: []<BR>\nDetails: []<BR>\n<BR>\nCurrent Diseases: [] (per disease info placed in log/comment section)<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src.active2.fields["b_type"], src.active2.fields["mi_dis"], src.active2.fields["mi_dis_d"], src.active2.fields["ma_dis"], src.active2.fields["ma_dis_d"], src.active2.fields["alg"], src.active2.fields["alg_d"], src.active2.fields["cdi"], src.active2.fields["cdi_d"], src.active2.fields["notes"])
				var/counter = 1
				while(src.active2.fields[text("com_[]", counter)])
					info += text("[]<BR>", src.active2.fields[text("com_[]", counter)])
					counter++
			else
				info += "<B>Medical Record Lost!</B><BR>"
			info += "</TT>"

			var/datum/signal/signal = new
			signal.data["data"] = info
			signal.data["title"] = "Medical Record"
			src.peripheral_command("print",signal)

	src.master.add_fingerprint(usr)
	src.master.updateUsrDialog()
	return