/mob/living/silicon/pai/var/list/available_software = list("crew manifest" = 5, "medical records" = 5, "security records" = 5, "camera" = 5, "atmosphere sensor" = 10, "heartbeat sensor" = 10, "security HUD" = 10, "medical HUD" = 10, "universal translator" = 10)

/mob/living/silicon/pai/Topic(href, href_list)
	..()
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]))
	if (href_list["radio"])
		src.card.radio.attack_self(src)
	if (href_list["software"])
		var/s = href_list["software"]
		world << s
		switch(s)
			if("crew manifest")
				src.softwareManifest()
			if("medical records")
				//blah
			if("security records")
				//blah
			if("camera")
				// blah
			if("atmosphere sensor")
				// blah
			if("heartbeat sensor")
				// blah
			if("security HUD")
				// blah
			if("medical HUD")
				//blah
			if("universal translator")
				src.universal_speak = !src.universal_speak
			else
				//blahblah
	if(href_list["softFunction"])
		var/s = href_list["softFunction"]
		if(s == "medical records")
			var/medFunction = href_list["medFunction"]
			if(medFunction == "view")
				// Pretty much totally stolen from medical.dm in computers
				var/datum/data/record/R = locate(href_list["med_rec"])
				var/datum/data/record/M = locate(href_list["med_rec"])
				if (!( data_core.general.Find(R) ))
					src.temp = "Medical Records: <pre>Record Not Found.</pre>"
					return
				for(var/datum/data/record/E in data_core.medical)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						M = E
				src.medicalActive1 = R
				src.medicalActive2 = M
				src.medScreen = 1		// Set screen to view a specific record
			var/tempScreen = href_list["screen"]
			if(tempScreen)
				src.medScreen = tempScreen
	if (href_list["buy"])
		var/s = href_list["buy"]
		var/dat = ""
		if(!src.available_software.Find(s))
			dat += "<h2><font color=#FF0000>Error</h2><br><h3>Requested software package not found.</font></h3>"
			src << browse(dat, "window=paibuy")
			onclose(src, "paibuy")
		else if(src.ram < src.available_software[s])
			dat += "<h2><font color=#FF0000>Error</h2><br><h3>Not enough Remaining Available Memory to complete requested task.</font></h3>"
			src << browse(dat, "window=paibuy")
			onclose(src, "paibuy")
		else
			src.ram -= src.available_software[s]
			switch(s)
				if("crew manifest")
					src.software.Add("crew manifest")
				if("medical records")
					src.software.Add("medical records")
				if("security records")
					src.software.Add("security records")
				if("camera")
					src.software.Add("camera")
				if("atmosphere sensor")
					src.software.Add("atmosphere sensor")
				if("heartbeat sensor")
					src.software.Add("heartbeat sensor")
				if("security HUD")
					src.software.Add("security HUD")
				if("medical HUD")
					src.software.Add("medical HUD")
				if("universal translator")
					src.universal_speak = 1
					src.software.Add("universal translator")
				else
					//blahblah
		src.downloadSoftware()
	return

/*
/mob/living/silicon/pai/proc/ai_network_change()
	set category = "pAI Commands"
	set name = "Change Camera Network"
*/

//		Basic Features:
// 		Crew Manifest
//		Medical Records
//		Security Records
//		Camera Jack
//
//		Advanced Features:
//		Atmosphere Sensor
//		Heartbeat sensor
// 		Security HUD
//		Medical HUD (Also provides a health analyzer that will assess the user's health)
//		Universal Translator
//
//		Built-in Features:
//		Radio
//		PDA Messaging



// Physical Upgrades:
//	- Camera Uplink (Removes the need to be plugged in to a camera to access the network)


/mob/verb/makePAI(var/turf/t in view())
	var/obj/item/device/paicard/card = new(t)
	var/mob/living/silicon/pai/pai = new(card)
	pai.key = src.key

/mob/living/silicon/pai/verb/paiInterface()
	set category = "pAI Commands"
	set name = "Software Interface"

	var/dat = ""
	// Built-in
	dat += "<A href='byond://?src=\ref[src];radio=1'>Radio Configuration</A><br>"
	dat += "Text Messaging <br>"
	dat += "<br>"

	// Basic
	dat += "<b>Basic</b> <br>"
	for(var/s in src.software)
		if(s == "crew manifest")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Crew Manifest</a> <br>"
		if(s == "medical records")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Medical Records</a> <br>"
		if(s == "security records")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Security Records</a> <br>"
		if(s == "camera")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Camera Jack</a> <br>"
	dat += "<br>"

	// Advanced
	dat += "<b>Advanced</b> <br>"
	for(var/s in src.software)
		if(s == "atmosphere sensor")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Atmospheric Sensor</a> <br>"
		if(s == "heartbeat sensor")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Heartbeat Sensor</a> <br>"
		if(s == "security HUD")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Facial Recognition Suite</a> <br>"
		if(s == "medical HUD")
			dat += "<a href='byond://?src=\ref[src];softFunction=[s]'>Medical Analysis Suite</a> <br>"
		if(s == "universal translator")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Universal Translator</a>[(src.universal_speak) ? "<font color=#347C17>Enabled</font>" : "<font color=#800517>Disabled</font>"] <br>"
	dat += "<br>"
	dat += "<br>"
	dat += "<a href='byond://?src=\ref[src];buy=1'>Download additional software</a>"

	src << browse(dat, "window=pai")
	onclose(src, "pai")


/mob/living/silicon/pai/proc/downloadSoftware()
	var/dat = ""

	dat += "<h2>CentComm pAI Module Subversion Network</h2><br>"
	dat += "<pre>Remaining Available Memory: [src.ram]</pre><br>"
	dat += "<p style=\"text-align:center\"><b>Trunks available for checkout</b><br>"

	for(var/s in available_software)
		if(!software.Find(s))
			var/cost = src.available_software[s]
			var/displayName = uppertext(s)
			dat += "<a href='byond://?src=\ref[src];buy=[s]'>[displayName]</a> ([cost]) <br>"
		else
			var/displayName = lowertext(s)
			dat += "[displayName] <pre>(Download Complete)</pre><br>"
	dat += "</p>"
	//src << browse(dat, "window=paibuy")
	//onclose(src, "paibuy")
	return dat



/mob/living/silicon/pai/proc/softwareManifest()
	var/dat = ""
	dat += "<h2>Crew Manifest</h2><br><br>"
	for (var/datum/data/record/t in data_core.general)
		dat += "[t.fields["name"]] - [t.fields["rank"]]<br>"
	//src << browse(dat, "window=paimanifest")
	//onclose(src, "paimanifest")
	return dat

/mob/living/silicon/pai/proc/softwareMedicalRecords()
	world << "softwareMedicalRecords() got called"
	var/dat = ""

	if(medScreen == 0)
		dat += "<B>Record List</B>:<HR>"
		for(var/datum/data/record/R in data_core.general)
			dat += text("<A href='?src=\ref[];med_rec=\ref[];softFunction=medical records;medFunction=view'>[]: []<BR>", src, R, R.fields["id"], R.fields["name"])
			//Foreach goto(132)
		dat += text("<HR><A href='?src=\ref[];screen=0;softFunction=medical records'>Back</A>", src)
	if(medScreen == 1)
		dat += "<CENTER><B>Medical Record</B></CENTER><BR>"
		if ((istype(src.medicalActive1, /datum/data/record) && data_core.general.Find(src.medicalActive1)))
			dat += text("Name: [] ID: []<BR>\nSex: <A href='?src=\ref[];field=sex'>[]</A><BR>\nAge: <A href='?src=\ref[];field=age'>[]</A><BR>\nFingerprint: <A href='?src=\ref[];field=fingerprint'>[]</A><BR>\nPhysical Status: <A href='?src=\ref[];field=p_stat'>[]</A><BR>\nMental Status: <A href='?src=\ref[];field=m_stat'>[]</A><BR>",
			 src.medicalActive1.fields["name"], src.medicalActive1.fields["id"], src, src.medicalActive1.fields["sex"], src, src.medicalActive1.fields["age"], src, src.medicalActive1.fields["fingerprint"], src, src.medicalActive1.fields["p_stat"], src, src.medicalActive1.fields["m_stat"])
		else
			dat += "<pre>Requested medical record not found.</pre><BR>"
		if ((istype(src.medicalActive2, /datum/data/record) && data_core.medical.Find(src.medicalActive2)))
			dat += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=\ref[];field=b_type'>[]</A><BR>\nDNA: <A href='?src=\ref[];field=b_dna'>[]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=\ref[];field=mi_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=mi_dis_d'>[]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=\ref[];field=ma_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=ma_dis_d'>[]</A><BR>\n<BR>\nAllergies: <A href='?src=\ref[];field=alg'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=alg_d'>[]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=\ref[];field=cdi'>[]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=\ref[];field=cdi_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src, src.medicalActive2.fields["b_type"], src, src.medicalActive2.fields["b_dna"], src, src.medicalActive2.fields["mi_dis"], src, src.medicalActive2.fields["mi_dis_d"], src, src.medicalActive2.fields["ma_dis"], src, src.medicalActive2.fields["ma_dis_d"], src, src.medicalActive2.fields["alg"], src, src.medicalActive2.fields["alg_d"], src, src.medicalActive2.fields["cdi"], src, src.medicalActive2.fields["cdi_d"], src, src.medicalActive2.fields["notes"])
			/*
			var/counter = 1
			while(src.medicalActive2.fields[text("com_[]", counter)])
				dat += text("[]<BR><A href='?src=\ref[];del_c=[]'>Delete Entry</A><BR><BR>", src.medicalActive2.fields[text("com_[]", counter)], src, counter)
				counter++
			*/
		else
			dat += "<pre>Requested medical record not found.</pre><BR>"
		dat += text("<BR>\n<A href='?src=\ref[];softFunction=medical records;screen=0'>Back</A><BR>", src)
	//src << browse(dat, "window=paiMedical")
	return dat


// ****** THIS IS WHERE YOU LEFT OFF. LOOK IN TO FIGURING OUT WHAT medicalActive1 IS AND HOW TO APPROPRIATE IT TO THE PAI *******
//			ALSO CONSIDER ADDING A POWER MONITOR PACKAGE. HEARTBEAT SENSOR MIGHT BE COOL IF IT PULSED AN OVERLAY WITH A ROUGH LOCATION OF WHERE A MOB IS STANDING.
//			REMEMBER THAT YOU STILL NEED TO DO LOGIN AND LOGOUT.DM
//			MAYBE ADD A CORRUPTION (HEALTH) VAR FOR CYBERSPACE STUFF. AND SOME LAWS THAT CAN GET HACKED
//			YOU STILL HAVEN'T ADDED A WAY TO TRACK WHO THE PAI IS BOUND TO, EITHER. GET ON THAT