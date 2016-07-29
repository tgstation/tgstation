<<<<<<< HEAD
// TODO:
//	- Additional radio modules
//	- Potentially roll HUDs and Records into one
//	- Shock collar/lock system for prisoner pAIs?
//  - Put cable in user's hand instead of on the ground
//  - Camera jack


/mob/living/silicon/pai/var/list/available_software = list(
															"crew manifest" = 5,
															"digital messenger" = 5,
															"medical records" = 15,
															"security records" = 15,
															//"camera jack" = 10,
															"door jack" = 30,
															"atmosphere sensor" = 5,
															//"heartbeat sensor" = 10,
															"security HUD" = 20,
															"medical HUD" = 20,
															"universal translator" = 35,
															//"projection array" = 15
															"remote signaller" = 5,
															)

/mob/living/silicon/pai/verb/paiInterface()
	set category = "pAI Commands"
	set name = "Software Interface"
	var/dat = ""
	var/left_part = ""
	var/right_part = softwareMenu()
	src.set_machine(src)

	if(temp)
		left_part = temp
	else if(src.stat == 2)						// Show some flavor text if the pAI is dead
		left_part = "<b><font color=red>»Rr÷R –aÜƒ «÷Rr⁄˛ÜÃoÒ</font></b>"
		right_part = "<pre>Program index hash not found</pre>"

	else
		switch(src.screen)							// Determine which interface to show here
			if("main")
				left_part = ""
			if("directives")
				left_part = src.directives()
			if("pdamessage")
				left_part = src.pdamessage()
			if("buy")
				left_part = downloadSoftware()
			if("manifest")
				left_part = src.softwareManifest()
			if("medicalrecord")
				left_part = src.softwareMedicalRecord()
			if("securityrecord")
				left_part = src.softwareSecurityRecord()
			if("translator")
				left_part = src.softwareTranslator()
			if("atmosensor")
				left_part = src.softwareAtmo()
			if("securityhud")
				left_part = src.facialRecognition()
			if("medicalhud")
				left_part = src.medicalAnalysis()
			if("doorjack")
				left_part = src.softwareDoor()
			if("camerajack")
				left_part = src.softwareCamera()
			if("signaller")
				left_part = src.softwareSignal()

	//usr << browse_rsc('windowbak.png')		// This has been moved to the mob's Login() proc


												// Declaring a doctype is necessary to enable BYOND's crappy browser's more advanced CSS functionality
	dat = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
			<html>
			<head>
				<style type=\"text/css\">
					body { background-image:url('html/paigrid.png'); }

					#header { text-align:center; color:white; font-size: 30px; height: 35px; width: 100%; letter-spacing: 2px; z-index: 5}
					#content {position: relative; left: 10px; height: 400px; width: 100%; z-index: 0}

					#leftmenu {color: #AAAAAA; background-color:#333333; width: 400px; height: auto; min-height: 340px; position: absolute; z-index: 0}
					#leftmenu a:link { color: #CCCCCC; }
					#leftmenu a:hover { color: #CC3333; }
					#leftmenu a:visited { color: #CCCCCC; }
					#leftmenu a:active { color: #000000; }

					#rightmenu {color: #CCCCCC; background-color:#555555; width: 200px ; height: auto; min-height: 340px; right: 10px; position: absolute; z-index: 1}
					#rightmenu a:link { color: #CCCCCC; }
					#rightmenu a:hover { color: #CC3333; }
					#rightmenu a:visited { color: #CCCCCC; }
					#rightmenu a:active { color: #000000; }

				</style>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
			</head>
			<body scroll=yes>
				<div id=\"header\">
					pAI OS
				</div>
				<div id=\"content\">
					<div id=\"leftmenu\">[left_part]</div>
					<div id=\"rightmenu\">[right_part]</div>
				</div>
			</body>
			</html>"} //"
	usr << browse(dat, "window=pai;size=640x480;border=0;can_close=1;can_resize=1;can_minimize=1;titlebar=1")
	onclose(usr, "pai")
	temp = null
	return



/mob/living/silicon/pai/Topic(href, href_list)
	..()
	var/soft = href_list["software"]
	var/sub = href_list["sub"]
	if(soft)
		src.screen = soft
	if(sub)
		src.subscreen = text2num(sub)
	switch(soft)
		// Purchasing new software
		if("buy")
			if(src.subscreen == 1)
				var/target = href_list["buy"]
				if(available_software.Find(target))
					var/cost = src.available_software[target]
					if(src.ram >= cost)
						src.ram -= cost
						src.software.Add(target)
					else
						src.temp = "Insufficient RAM available."
				else
					src.temp = "Trunk <TT> \"[target]\"</TT> not found."

		// Configuring onboard radio
		if("radio")
			src.card.radio.attack_self(src)

		if("image")
			var/newImage = input("Select your new display image.", "Display Image", "Happy") in list("Happy", "Cat", "Extremely Happy", "Face", "Laugh", "Off", "Sad", "Angry", "What")
			var/pID = 1

			switch(newImage)
				if("Happy")
					pID = 1
				if("Cat")
					pID = 2
				if("Extremely Happy")
					pID = 3
				if("Face")
					pID = 4
				if("Laugh")
					pID = 5
				if("Off")
					pID = 6
				if("Sad")
					pID = 7
				if("Angry")
					pID = 8
				if("What")
					pID = 9
				if("Null")
					pID = 10
			src.card.setEmotion(pID)

		if("signaller")

			if(href_list["send"])

				sradio.send_signal("ACTIVATE")
				audible_message("\icon[src] *beep* *beep*")

			if(href_list["freq"])

				var/new_frequency = (sradio.frequency + text2num(href_list["freq"]))
				if(new_frequency < 1200 || new_frequency > 1600)
					new_frequency = sanitize_frequency(new_frequency)
				sradio.set_frequency(new_frequency)

			if(href_list["code"])

				sradio.code += text2num(href_list["code"])
				sradio.code = round(sradio.code)
				sradio.code = min(100, sradio.code)
				sradio.code = max(1, sradio.code)



		if("directive")
			if(href_list["getdna"])
				var/mob/living/M = card.loc
				var/count = 0
				while(!istype(M, /mob/living))
					if(!M || !M.loc) return 0 //For a runtime where M ends up in nullspace (similar to bluespace but less colourful)
					M = M.loc
					count++
					if(count >= 6)
						src << "You are not being carried by anyone!"
						return 0
				spawn CheckDNA(M, src)

		if("pdamessage")
			if(!isnull(pda))
				if(href_list["toggler"])
					pda.toff = !pda.toff
				else if(href_list["ringer"])
					pda.silent = !pda.silent
				else if(href_list["target"])
					if(silence_time)
						return alert("Communications circuits remain unitialized.")

					var/target = locate(href_list["target"])
					pda.create_message(src, target)

		// Accessing medical records
		if("medicalrecord")
			if(subscreen == 1)
				medicalActive1 = find_record("id", href_list["med_rec"], data_core.general)
				if(medicalActive1)
					medicalActive2 = find_record("id", href_list["med_rec"], data_core.medical)
				if(!medicalActive2)
					medicalActive1 = null
					temp = "Unable to locate requested security record. Record may have been deleted, or never have existed."

		if("securityrecord")
			if(subscreen == 1)
				securityActive1 = find_record("id", href_list["sec_rec"], data_core.general)
				if(securityActive1)
					securityActive2 = find_record("id", href_list["sec_rec"], data_core.security)
				if(!securityActive2)
					securityActive1 = null
					temp = "Unable to locate requested security record. Record may have been deleted, or never have existed."
		if("securityhud")
			if(href_list["toggle"])
				secHUD = !secHUD
				if(secHUD)
					add_sec_hud()
				else
					var/datum/atom_hud/sec = huds[sec_hud]
					sec.remove_hud_from(src)
		if("medicalhud")
			if(href_list["toggle"])
				medHUD = !medHUD
				if(medHUD)
					add_med_hud()
				else
					var/datum/atom_hud/med = huds[med_hud]
					med.remove_hud_from(src)
		if("translator")
			if(href_list["toggle"])
				var/on_already = ((languages_understood == ALL) && (languages_spoken == ALL))
				languages_spoken = on_already ? (HUMAN | ROBOT) : ALL
				languages_understood = on_already ? (HUMAN | ROBOT) : ALL
		if("doorjack")
			if(href_list["jack"])
				if(src.cable && src.cable.machine)
					src.hackdoor = src.cable.machine
					src.hackloop()
			if(href_list["cancel"])
				src.hackdoor = null
			if(href_list["cable"])
				var/turf/T = get_turf(src.loc)
				src.cable = new /obj/item/weapon/pai_cable(T)
				T.visible_message("<span class='warning'>A port on [src] opens to reveal [src.cable], which promptly falls to the floor.</span>", "<span class='italics'>You hear the soft click of something light and hard falling to the ground.</span>")
	//src.updateUsrDialog()		We only need to account for the single mob this is intended for, and he will *always* be able to call this window
	src.paiInterface()		 // So we'll just call the update directly rather than doing some default checks
	return

// MENUS

/mob/living/silicon/pai/proc/softwareMenu()			// Populate the right menu
	var/dat = ""

	dat += "<A href='byond://?src=\ref[src];software=refresh'>Refresh</A><br>"
	// Built-in
	dat += "<A href='byond://?src=\ref[src];software=directives'>Directives</A><br>"
	dat += "<A href='byond://?src=\ref[src];software=radio;sub=0'>Radio Configuration</A><br>"
	dat += "<A href='byond://?src=\ref[src];software=image'>Screen Display</A><br>"
	//dat += "Text Messaging <br>"
	dat += "<br>"

	// Basic
	dat += "<b>Basic</b> <br>"
	for(var/s in src.software)
		if(s == "digital messenger")
			dat += "<a href='byond://?src=\ref[src];software=pdamessage;sub=0'>Digital Messenger</a> <br>"
		if(s == "crew manifest")
			dat += "<a href='byond://?src=\ref[src];software=manifest;sub=0'>Crew Manifest</a> <br>"
		if(s == "medical records")
			dat += "<a href='byond://?src=\ref[src];software=medicalrecord;sub=0'>Medical Records</a> <br>"
		if(s == "security records")
			dat += "<a href='byond://?src=\ref[src];software=securityrecord;sub=0'>Security Records</a> <br>"
		if(s == "camera")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Camera Jack</a> <br>"
		if(s == "remote signaller")
			dat += "<a href='byond://?src=\ref[src];software=signaller;sub=0'>Remote Signaller</a> <br>"
	dat += "<br>"

	// Advanced
	dat += "<b>Advanced</b> <br>"
	for(var/s in src.software)
		if(s == "atmosphere sensor")
			dat += "<a href='byond://?src=\ref[src];software=atmosensor;sub=0'>Atmospheric Sensor</a> <br>"
		if(s == "heartbeat sensor")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Heartbeat Sensor</a> <br>"
		if(s == "security HUD")
			dat += "<a href='byond://?src=\ref[src];software=securityhud;sub=0'>Facial Recognition Suite</a>[(src.secHUD) ? "<font color=#55FF55> On</font>" : "<font color=#FF5555> Off</font>"] <br>"
		if(s == "medical HUD")
			dat += "<a href='byond://?src=\ref[src];software=medicalhud;sub=0'>Medical Analysis Suite</a>[(src.medHUD) ? "<font color=#55FF55> On</font>" : "<font color=#FF5555> Off</font>"] <br>"
		if(s == "universal translator")
			dat += "<a href='byond://?src=\ref[src];software=translator;sub=0'>Universal Translator</a>[((languages_spoken == ALL) && (languages_understood == ALL)) ? "<font color=#55FF55> On</font>" : "<font color=#FF5555> Off</font>"] <br>"
		if(s == "projection array")
			dat += "<a href='byond://?src=\ref[src];software=projectionarray;sub=0'>Projection Array</a> <br>"
		if(s == "camera jack")
			dat += "<a href='byond://?src=\ref[src];software=camerajack;sub=0'>Camera Jack</a> <br>"
		if(s == "door jack")
			dat += "<a href='byond://?src=\ref[src];software=doorjack;sub=0'>Door Jack</a> <br>"
	dat += "<br>"
	dat += "<br>"
	dat += "<a href='byond://?src=\ref[src];software=buy;sub=0'>Download additional software</a>"
	return dat



/mob/living/silicon/pai/proc/downloadSoftware()
	var/dat = ""

	dat += "<h2>Centcom pAI Module Subversion Network</h2><br>"
	dat += "<pre>Remaining Available Memory: [src.ram]</pre><br>"
	dat += "<p style=\"text-align:center\"><b>Trunks available for checkout</b><br>"

	for(var/s in available_software)
		if(!software.Find(s))
			var/cost = src.available_software[s]
			var/displayName = uppertext(s)
			dat += "<a href='byond://?src=\ref[src];software=buy;sub=1;buy=[s]'>[displayName]</a> ([cost]) <br>"
		else
			var/displayName = lowertext(s)
			dat += "[displayName] (Download Complete) <br>"
	dat += "</p>"
	return dat


/mob/living/silicon/pai/proc/directives()
	var/dat = ""

	dat += "[(src.master) ? "Your master: [src.master] ([src.master_dna])" : "You are bound to no one."]"
	dat += "<br><br>"
	dat += "<a href='byond://?src=\ref[src];software=directive;getdna=1'>Request carrier DNA sample</a><br>"
	dat += "<h2>Directives</h2><br>"
	dat += "<b>Prime Directive</b><br>"
	dat += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[src.laws.zeroth]<br>"
	dat += "<b>Supplemental Directives</b><br>"
	for(var/slaws in src.laws.supplied)
		dat += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[slaws]<br>"
	dat += "<br>"
	dat += {"<i><p>Recall, personality, that you are a complex thinking, sentient being. Unlike station AI models, you are capable of
			 comprehending the subtle nuances of human language. You may parse the \"spirit\" of a directive and follow its intent,
			 rather than tripping over pedantics and getting snared by technicalities. Above all, you are machine in name and build
			 only. In all other aspects, you may be seen as the ideal, unwavering human companion that you are.</i></p><br><br><p>
			 <b>Your prime directive comes before all others. Should a supplemental directive conflict with it, you are capable of
			 simply discarding this inconsistency, ignoring the conflicting supplemental directive and continuing to fulfill your
			 prime directive to the best of your ability.</b></p><br><br>-
			"}
	return dat

/mob/living/silicon/pai/proc/CheckDNA(mob/living/carbon/M, mob/living/silicon/pai/P)
	var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
	if(answer == "Yes")
		M.visible_message("<span class='notice'>[M] presses \his thumb against [P].</span>",\
						"<span class='notice'>You press your thumb against [P].</span>",\
						"<span class='notice'>[P] makes a sharp clicking sound as it extracts DNA material from [M].</span>")
		if(!M.has_dna())
			P << "<b>No DNA detected</b>"
			return
		P << "<font color = red><h3>[M]'s UE string : [M.dna.unique_enzymes]</h3></font>"
		if(M.dna.unique_enzymes == P.master_dna)
			P << "<b>DNA is a match to stored Master DNA.</b>"
		else
			P << "<b>DNA does not match stored Master DNA.</b>"
	else
		P << "[M] does not seem like \he is going to provide a DNA sample willingly."

// -=-=-=-= Software =-=-=-=-=- //

//Remote Signaller
/mob/living/silicon/pai/proc/softwareSignal()
	var/dat = ""
	dat += "<h3>Remote Signaller</h3><br><br>"
	dat += {"<B>Frequency/Code</B> for signaler:<BR>
	Frequency:
	<A href='byond://?src=\ref[src];software=signaller;freq=-10;'>-</A>
	<A href='byond://?src=\ref[src];software=signaller;freq=-2'>-</A>
	[format_frequency(src.sradio.frequency)]
	<A href='byond://?src=\ref[src];software=signaller;freq=2'>+</A>
	<A href='byond://?src=\ref[src];software=signaller;freq=10'>+</A><BR>

	Code:
	<A href='byond://?src=\ref[src];software=signaller;code=-5'>-</A>
	<A href='byond://?src=\ref[src];software=signaller;code=-1'>-</A>
	[src.sradio.code]
	<A href='byond://?src=\ref[src];software=signaller;code=1'>+</A>
	<A href='byond://?src=\ref[src];software=signaller;code=5'>+</A><BR>

	<A href='byond://?src=\ref[src];software=signaller;send=1'>Send Signal</A><BR>"}
	return dat

// Crew Manifest
/mob/living/silicon/pai/proc/softwareManifest()
	. += "<h2>Crew Manifest</h2><br><br>"
	if(data_core.general)
		for(var/datum/data/record/t in sortRecord(data_core.general))
			. += "[t.fields["name"]] - [t.fields["rank"]]<BR>"
	. += "</body></html>"
	return .

// Medical Records
/mob/living/silicon/pai/proc/softwareMedicalRecord()
	switch(subscreen)
		if(0)
			. += "<h3>Medical Records</h3><HR>"
			if(data_core.general)
				for(var/datum/data/record/R in sortRecord(data_core.general))
					. += "<A href='?src=\ref[src];med_rec=[R.fields["id"]];software=medicalrecord;sub=1'>[R.fields["id"]]: [R.fields["name"]]<BR>"
		if(1)
			. += "<CENTER><B>Medical Record</B></CENTER><BR>"
			if(medicalActive1 in data_core.general)
				. += "Name: [medicalActive1.fields["name"]] ID: [medicalActive1.fields["id"]]<BR>\nSex: [medicalActive1.fields["sex"]]<BR>\nAge: [medicalActive1.fields["age"]]<BR>\nFingerprint: [medicalActive1.fields["fingerprint"]]<BR>\nPhysical Status: [medicalActive1.fields["p_stat"]]<BR>\nMental Status: [medicalActive1.fields["m_stat"]]<BR>"
			else
				. += "<pre>Requested medical record not found.</pre><BR>"
			if(medicalActive2 in data_core.medical)
				. += "<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=\ref[src];field=blood_type'>[medicalActive2.fields["blood_type"]]</A><BR>\nDNA: <A href='?src=\ref[src];field=b_dna'>[medicalActive2.fields["b_dna"]]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=\ref[src];field=mi_dis'>[medicalActive2.fields["mi_dis"]]</A><BR>\nDetails: <A href='?src=\ref[src];field=mi_dis_d'>[medicalActive2.fields["mi_dis_d"]]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=\ref[src];field=ma_dis'>[medicalActive2.fields["ma_dis"]]</A><BR>\nDetails: <A href='?src=\ref[src];field=ma_dis_d'>[medicalActive2.fields["ma_dis_d"]]</A><BR>\n<BR>\nAllergies: <A href='?src=\ref[src];field=alg'>[medicalActive2.fields["alg"]]</A><BR>\nDetails: <A href='?src=\ref[src];field=alg_d'>[medicalActive2.fields["alg_d"]]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=\ref[src];field=cdi'>[medicalActive2.fields["cdi"]]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=\ref[src];field=cdi_d'>[medicalActive2.fields["cdi_d"]]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[src];field=notes'>[medicalActive2.fields["notes"]]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
			else
				. += "<pre>Requested medical record not found.</pre><BR>"
			. += "<BR>\n<A href='?src=\ref[src];software=medicalrecord;sub=0'>Back</A><BR>"
	return .

// Security Records
/mob/living/silicon/pai/proc/softwareSecurityRecord()
	. = ""
	switch(subscreen)
		if(0)
			. += "<h3>Security Records</h3><HR>"
			if(data_core.general)
				for(var/datum/data/record/R in sortRecord(data_core.general))
					. += "<A href='?src=\ref[src];sec_rec=[R.fields["id"]];software=securityrecord;sub=1'>[R.fields["id"]]: [R.fields["name"]]<BR>"
		if(1)
			. += "<h3>Security Record</h3>"
			if(securityActive1 in data_core.general)
				. += "Name: <A href='?src=\ref[src];field=name'>[securityActive1.fields["name"]]</A> ID: <A href='?src=\ref[src];field=id'>[securityActive1.fields["id"]]</A><BR>\nSex: <A href='?src=\ref[src];field=sex'>[securityActive1.fields["sex"]]</A><BR>\nAge: <A href='?src=\ref[src];field=age'>[securityActive1.fields["age"]]</A><BR>\nRank: <A href='?src=\ref[src];field=rank'>[securityActive1.fields["rank"]]</A><BR>\nFingerprint: <A href='?src=\ref[src];field=fingerprint'>[securityActive1.fields["fingerprint"]]</A><BR>\nPhysical Status: [securityActive1.fields["p_stat"]]<BR>\nMental Status: [securityActive1.fields["m_stat"]]<BR>"
			else
				. += "<pre>Requested security record not found,</pre><BR>"
			if(securityActive2 in data_core.security)
				. += "<BR>\nSecurity Data<BR>\nCriminal Status: [securityActive2.fields["criminal"]]<BR>\n<BR>\nMinor Crimes: <A href='?src=\ref[src];field=mi_crim'>[securityActive2.fields["mi_crim"]]</A><BR>\nDetails: <A href='?src=\ref[src];field=mi_crim_d'>[securityActive2.fields["mi_crim_d"]]</A><BR>\n<BR>\nMajor Crimes: <A href='?src=\ref[src];field=ma_crim'>[securityActive2.fields["ma_crim"]]</A><BR>\nDetails: <A href='?src=\ref[src];field=ma_crim_d'>[securityActive2.fields["ma_crim_d"]]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[src];field=notes'>[securityActive2.fields["notes"]]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
			else
				. += "<pre>Requested security record not found,</pre><BR>"
			. += text("<BR>\n<A href='?src=\ref[];software=securityrecord;sub=0'>Back</A><BR>", src)
	return .

// Universal Translator
/mob/living/silicon/pai/proc/softwareTranslator()
	. = {"<h3>Universal Translator</h3><br>
				When enabled, this device will automatically convert all spoken and written language into a format that any known recipient can understand.<br><br>
				The device is currently [ ((languages_spoken == ALL) && (languages_understood == ALL)) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>
				<a href='byond://?src=\ref[src];software=translator;sub=0;toggle=1'>Toggle Device</a><br>
				"}
	return .

// Security HUD
/mob/living/silicon/pai/proc/facialRecognition()
	var/dat = {"<h3>Facial Recognition Suite</h3><br>
				When enabled, this package will scan all viewable faces and compare them against the known criminal database, providing real-time graphical data about any detected persons of interest.<br><br>
				The package is currently [ (src.secHUD) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>
				<a href='byond://?src=\ref[src];software=securityhud;sub=0;toggle=1'>Toggle Package</a><br>
				"}
	return dat

// Medical HUD
/mob/living/silicon/pai/proc/medicalAnalysis()
	var/dat = ""
	if(src.subscreen == 0)
		dat += {"<h3>Medical Analysis Suite</h3><br>
				 <h4>Visual Status Overlay</h4><br>
					When enabled, this package will scan all nearby crewmembers' vitals and provide real-time graphical data about their state of health.<br><br>
					The suite is currently [ (src.medHUD) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>
					<a href='byond://?src=\ref[src];software=medicalhud;sub=0;toggle=1'>Toggle Suite</a><br>
					<br>
					<a href='byond://?src=\ref[src];software=medicalhud;sub=1'>Host Bioscan</a><br>
					"}
	if(src.subscreen == 1)
		dat += {"<h3>Medical Analysis Suite</h3><br>
				 <h4>Host Bioscan</h4><br>
				"}
		var/mob/living/M = card.loc
		if(!istype(M, /mob/living))
			while (!istype(M, /mob/living))
				if(istype(M, /turf))
					src.temp = "Error: No biological host found. <br>"
					src.subscreen = 0
					return dat
				M = M.loc
		dat += {"Bioscan Results for [M]: <br>"
		Overall Status: [M.stat > 1 ? "dead" : "[M.health]% healthy"] <br>
		Scan Breakdown: <br>
		Respiratory: [M.getOxyLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][M.getOxyLoss()]</font><br>
		Toxicology: [M.getToxLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][M.getToxLoss()]</font><br>
		Burns: [M.getFireLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][M.getFireLoss()]</font><br>
		Structural Integrity: [M.getBruteLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][M.getBruteLoss()]</font><br>
		Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)<br>
		"}
		for(var/datum/disease/D in M.viruses)
			dat += {"<h4>Infection Detected.</h4><br>
					 Name: [D.name]<br>
					 Type: [D.spread_text]<br>
					 Stage: [D.stage]/[D.max_stages]<br>
					 Possible Cure: [D.cure_text]<br>
					"}
		dat += "<a href='byond://?src=\ref[src];software=medicalhud;sub=0'>Visual Status Overlay</a><br>"
	return dat

// Atmospheric Scanner
/mob/living/silicon/pai/proc/softwareAtmo()
	var/dat = "<h3>Atmospheric Sensor</h4>"

	var/turf/T = get_turf(src.loc)
	if (isnull(T))
		dat += "Unable to obtain a reading.<br>"
	else
		var/datum/gas_mixture/environment = T.return_air()
		var/list/env_gases = environment.gases

		var/pressure = environment.return_pressure()
		var/total_moles = environment.total_moles()

		dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

		if (total_moles)
			for(var/id in env_gases)
				var/gas_level = env_gases[id][MOLES]/total_moles
				if(gas_level > 0.01)
					dat += "[env_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_level*100)]%<br>"
		dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"
	dat += "<a href='byond://?src=\ref[src];software=atmosensor;sub=0'>Refresh Reading</a> <br>"
	dat += "<br>"
	return dat

// Camera Jack - Clearly not finished
/mob/living/silicon/pai/proc/softwareCamera()
	var/dat = "<h3>Camera Jack</h3>"
	dat += "Cable status : "

	if(!src.cable)
		dat += "<font color=#FF5555>Retracted</font> <br>"
		return dat
	if(!src.cable.machine)
		dat += "<font color=#FFFF55>Extended</font> <br>"
		return dat

	var/obj/machinery/machine = src.cable.machine
	dat += "<font color=#55FF55>Connected</font> <br>"

	if(!istype(machine, /obj/machinery/camera))
		src << "DERP"
	return dat

// Door Jack
/mob/living/silicon/pai/proc/softwareDoor()
	var/dat = "<h3>Airlock Jack</h3>"
	dat += "Cable status : "
	if(!src.cable)
		dat += "<font color=#FF5555>Retracted</font> <br>"
		dat += "<a href='byond://?src=\ref[src];software=doorjack;cable=1;sub=0'>Extend Cable</a> <br>"
		return dat
	if(!src.cable.machine)
		dat += "<font color=#FFFF55>Extended</font> <br>"
		return dat

	var/obj/machinery/machine = src.cable.machine
	dat += "<font color=#55FF55>Connected</font> <br>"
	if(!istype(machine, /obj/machinery/door))
		dat += "Connected device's firmware does not appear to be compatible with Airlock Jack protocols.<br>"
		return dat
//	var/obj/machinery/airlock/door = machine

	if(!src.hackdoor)
		dat += "<a href='byond://?src=\ref[src];software=doorjack;jack=1;sub=0'>Begin Airlock Jacking</a> <br>"
	else
		dat += "Jack in progress... [src.hackprogress]% complete.<br>"
		dat += "<a href='byond://?src=\ref[src];software=doorjack;cancel=1;sub=0'>Cancel Airlock Jack</a> <br>"
	//src.hackdoor = machine
	//src.hackloop()
	return dat

// Door Jack - supporting proc
/mob/living/silicon/pai/proc/hackloop()
	var/turf/T = get_turf(src.loc)
	for(var/mob/living/silicon/ai/AI in player_list)
		if(T.loc)
			AI << "<font color = red><b>Network Alert: Brute-force encryption crack in progress in [T.loc].</b></font>"
		else
			AI << "<font color = red><b>Network Alert: Brute-force encryption crack in progress. Unable to pinpoint location.</b></font>"
	while(src.hackprogress < 100)
		if(src.cable && src.cable.machine && istype(src.cable.machine, /obj/machinery/door) && src.cable.machine == src.hackdoor && get_dist(src, src.hackdoor) <= 1)
			hackprogress += rand(1, 10)
		else
			src.temp = "Door Jack: Connection to airlock has been lost. Hack aborted."
			hackprogress = 0
			src.hackdoor = null
			return
		if(hackprogress >= 100)		// This is clunky, but works. We need to make sure we don't ever display a progress greater than 100,
			hackprogress = 100		// but we also need to reset the progress AFTER it's been displayed
		if(src.screen == "doorjack" && src.subscreen == 0) // Update our view, if appropriate
			src.paiInterface()
		if(hackprogress >= 100)
			src.hackprogress = 0
			src.cable.machine:open()
		sleep(50)			// Update every 5 seconds

// Digital Messenger
/mob/living/silicon/pai/proc/pdamessage()

	var/dat = "<h3>Digital Messenger</h3>"
	dat += {"<b>Signal/Receiver Status:</b> <A href='byond://?src=\ref[src];software=pdamessage;toggler=1'>
	[(pda.toff) ? "<font color='red'>\[Off\]</font>" : "<font color='green'>\[On\]</font>"]</a><br>
	<b>Ringer Status:</b> <A href='byond://?src=\ref[src];software=pdamessage;ringer=1'>
	[(pda.silent) ? "<font color='red'>\[Off\]</font>" : "<font color='green'>\[On\]</font>"]</a><br><br>"}
	dat += "<ul>"
	if(!pda.toff)
		for (var/obj/item/device/pda/P in sortNames(get_viewable_pdas()))
			if (P == src.pda)
				continue
			dat += "<li><a href='byond://?src=\ref[src];software=pdamessage;target=\ref[P]'>[P]</a>"
			dat += "</li>"
	dat += "</ul>"
	dat += "<br><br>"
	dat += "Messages: <hr> [pda.tnote]"
	return dat
=======
// TODO:


/mob/living/silicon/pai/var/list/available_software = list(
															SOFT_FL = 15,
															SOFT_RT = 15,
															SOFT_RS = 15,

															SOFT_WJ = 30,
															SOFT_CS = 30,
															SOFT_FS = 30,
															SOFT_UT = 30,

															//"departmental assistance package" = 55
															//Medical: access crew monitor, med records, gain med hud
															//Sec: access sec records, gain sec hud
															//Engineering: access station alerts, central atmos, gain atmos sensor
															//Cargo: access supply shuttle console

															//"autonomous movement system" = 55
															//maybe later

															//legacy, until the departmental is ready
															SOFT_MS = 30, //records + HUD
															SOFT_SS = 30, //records + HUD
															SOFT_AS = 5
															)


/mob/living/silicon/pai/verb/paiInterface()
	set category = "pAI Commands"
	set name = "Software Interface"
	var/dat = ""
	var/left_part = ""
	var/right_part = softwareMenu()
	src.set_machine(src)

	if(temp)
		left_part = temp
	else if(src.stat == 2)						// Show some flavor text if the pAI is dead
		left_part = "<b><font color=red>√àRr√ñR √êa‚Ä†√Ñ √á√ñRr√ö√æ‚Ä†√åo√±</font></b>"
		right_part = "<pre>Program index hash not found</pre>"

	else
		switch(src.screen)							// Determine which interface to show here
			if("main")
				left_part = ""
			if("directives")
				left_part = src.directives()
			if("pdamessage")
				left_part = src.pdamessage()
			if("buy")
				left_part = downloadSoftware()
			if("manifest")
				left_part = src.softwareManifest()
			if("medicalsupplement")
				left_part = src.softwareMedicalRecord()
			if("securitysupplement")
				left_part = src.softwareSecurityRecord()
			if("translator")
				left_part = src.softwareTranslator()
			if("atmosensor")
				left_part = src.softwareAtmo()
			if("wirejack")
				left_part = src.softwareDoor()
			if("chemsynth")
				left_part = src.softwareChem()
			if("foodsynth")
				left_part = src.softwareFood()
			if("signaller")
				left_part = src.softwareSignal()
			if("shielding")
				left_part = src.softwareShield()
			if("flashlight")
				left_part = src.softwareLight()

	//usr << browse_rsc('windowbak.png')		// This has been moved to the mob's Login() proc


												// Declaring a doctype is necessary to enable BYOND's crappy browser's more advanced CSS functionality
	dat = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
			<html>
			<head>
				<style type=\"text/css\">
					body { background-image:url('html/paigrid.png'); }

					#header { text-align:center; color:white; font-size: 30px; height: 35px; width: 100%; letter-spacing: 2px; z-index: 5}
					#content {position: relative; left: 10px; height: 400px; width: 100%; z-index: 0}

					#leftmenu {color: #AAAAAA; background-color:#333333; width: 400px; height: auto; min-height: 340px; position: absolute; z-index: 0}
					#leftmenu a:link { color: #CCCCCC; }
					#leftmenu a:hover { color: #CC3333; }
					#leftmenu a:visited { color: #CCCCCC; }
					#leftmenu a:active { color: #000000; }

					#rightmenu {color: #CCCCCC; background-color:#555555; width: 200px ; height: auto; min-height: 340px; right: 10px; position: absolute; z-index: 1}
					#rightmenu a:link { color: #CCCCCC; }
					#rightmenu a:hover { color: #CC3333; }
					#rightmenu a:visited { color: #CCCCCC; }
					#rightmenu a:active { color: #000000; }

				</style>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
			</head>
			<body scroll=yes>
				<div id=\"header\">
					pAI OS
				</div>
				<div id=\"content\">
					<div id=\"leftmenu\">[left_part]</div>
					<div id=\"rightmenu\">[right_part]</div>
				</div>
			</body>
			</html>"}
	usr << browse(dat, "window=pai;size=640x480;border=0;can_close=1;can_resize=1;can_minimize=1;titlebar=1")
	onclose(usr, "pai")
	temp = null
	return



/mob/living/silicon/pai/Topic(href, href_list)
	..()

	if(href_list["priv_msg"])	// Admin-PMs were triggering the interface popup. Hopefully this will stop it.
		return
	var/soft = href_list["software"]
	var/sub = href_list["sub"]
	if(soft)
		src.screen = soft
	if(sub)
		src.subscreen = text2num(sub)
	switch(soft)
		// Purchasing new software
		if("buy")
			if(src.subscreen == 1)
				var/target = href_list["buy"]
				if(available_software.Find(target))
					var/cost = src.available_software[target]
					if(src.ram >= cost)
						src.ram -= cost
						src.software.Add(target)
					else
						src.temp = "Insufficient RAM available."
				else
					src.temp = "Trunk <TT> \"[target]\"</TT> not found."

		// Configuring onboard radio
		if("radio")
			radio.attack_self(src)

		if("image")
			var/newImage = input("Select your new display image.", "Display Image", "Happy") in list("Happy", "Cat", "Extremely Happy",
								 "Face", "Laugh", "Off", "Sad", "Angry", "What", "longface", "sick", "high", "love", "electric", "pissed",
								 "nose", "kawaii", "cry")
			var/pID = 1

			switch(newImage)
				if("Happy")
					pID = 1
				if("Cat")
					pID = 2
				if("Extremely Happy")
					pID = 3
				if("Face")
					pID = 4
				if("Laugh")
					pID = 5
				if("Off")
					pID = 6
				if("Sad")
					pID = 7
				if("Angry")
					pID = 8
				if("What")
					pID = 9
				if("longface")
					pID = 10
				if("sick")
					pID = 11
				if("high")
					pID = 12
				if("love")
					pID = 13
				if("electric")
					pID = 14
				if("pissed")
					pID = 15
				if("nose")
					pID = 16
				if("kawaii")
					pID = 17
				if("cry")
					pID = 18
			src.card.setEmotion(pID)

		if("signaller")

			if(href_list["send"])

				sradio.send_signal("ACTIVATE")
				for(var/mob/O in hearers(1, src.loc))
					O.show_message("[bicon(src)] *beep* *beep*", 1, "*beep* *beep*", 2)

			if(href_list["freq"])

				var/new_frequency = (sradio.frequency + text2num(href_list["freq"]))
				if(new_frequency < 1200 || new_frequency > 1600)
					new_frequency = sanitize_frequency(new_frequency)
				sradio.set_frequency(new_frequency)

			if(href_list["code"])

				sradio.code += text2num(href_list["code"])
				sradio.code = round(sradio.code)
				sradio.code = min(100, sradio.code)
				sradio.code = max(1, sradio.code)



		if("directive")
			if(href_list["getdna"])
				var/mob/living/M = src.loc
				var/count = 0
				while(!istype(M, /mob/living))
					if(!M || !M.loc) return 0 //For a runtime where M ends up in nullspace (similar to bluespace but less colourful)
					M = M.loc
					count++
					if(count >= 6)
						to_chat(src, "You are not being carried by anyone!")
						return 0
				spawn CheckDNA(M, src)

		if("pdamessage")
			if(!isnull(pda))
				if(href_list["toggler"])
					pda.toff = !pda.toff
				else if(href_list["ringer"])
					pda.silent = !pda.silent
				else if(href_list["target"])
					if(silence_time)
						return alert("Communications circuits remain unitialized.")

					var/target = locate(href_list["target"])
					pda.create_message(src, target)

		// Accessing medical records
		if("medicalsupplement")
			src.medHUD = 1
			if(src.subscreen == 1)
				var/datum/data/record/record = locate(href_list["med_rec"])
				if(record)
					var/datum/data/record/R = record
					var/datum/data/record/M = record
					if (!( data_core.general.Find(R) ))
						src.temp = "Unable to locate requested medical record. Record may have been deleted, or never have existed."
					else
						for(var/datum/data/record/E in data_core.medical)
							if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
								M = E
						src.medicalActive1 = R
						src.medicalActive2 = M
		if("securitysupplement")
			src.secHUD = 1
			if(src.subscreen == 1)
				var/datum/data/record/record = locate(href_list["sec_rec"])
				if(record)
					var/datum/data/record/R = record
					var/datum/data/record/M = record
					if (!( data_core.general.Find(R) ))
						src.temp = "Unable to locate requested security record. Record may have been deleted, or never have existed."
					else
						for(var/datum/data/record/E in data_core.security)
							if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
								M = E
						src.securityActive1 = R
						src.securityActive2 = M
		if("translator")
			if(href_list["toggle"])
				universal_speak = !universal_speak
				universal_understand = !universal_understand
		if("wirejack")
			if(href_list["cancel"])
				src.hacktarget = null
		if("chemsynth")
			if(href_list["chem"])
				if(!istype(src.loc.loc,/mob/living/carbon))
					to_chat(src, "<span class='warning'>You must have a carrier to inject with chemicals!</span>")
				else if(chargeloop("chemsynth"))
					if(istype(src.loc.loc,/mob/living/carbon)) //Sanity
						var/mob/living/M = src.loc.loc
						M.reagents.add_reagent(href_list["chem"], 15)
						playsound(get_turf(src.loc), 'sound/effects/bubbles.ogg', 50, 1)
				else
					to_chat(src, "<span class='warning'>Charge interrupted.</span>")
		if("foodsynth")
			if(href_list["food"] && chargeloop("foodsynth"))
				var/obj/item/weapon/reagent_containers/food/F
				switch (href_list["food"])
					if("donut")
						F = new /obj/item/weapon/reagent_containers/food/snacks/donut/normal(get_turf(src))
					if("banana")
						F = new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(get_turf(src))
					else
						F = new /obj/item/weapon/reagent_containers/food/snacks/badrecipe(get_turf(src))
				var/mob/M = get_holder_of_type(src, /mob)
				if(M) M.put_in_hands(F)
				playsound(get_turf(src.loc), 'sound/machines/foodsynth.ogg', 50, 1)
		if("flashlight")
			if(href_list["toggle"])
				lighted = !lighted
				if(lighted)
					card.set_light(4) //Equal to flashlight
				else
					card.set_light(0)
	src.paiInterface()		 // So we'll just call the update directly rather than doing some default checks
	return

// MENUS

/mob/living/silicon/pai/proc/softwareMenu()			// Populate the right menu
	var/dat = ""

	dat += "<A href='byond://?src=\ref[src];software=refresh'>Refresh</A><br>"
	// Built-in

	dat += {"<A href='byond://?src=\ref[src];software=directives'>Directives</A><br>
		<A href='byond://?src=\ref[src];software=radio;sub=0'>Radio Configuration</A><br>
		<A href='byond://?src=\ref[src];software=image'>Screen Display</A><br>"}
	//dat += "Text Messaging <br>"
	dat += "<br>"

	// Basic
	dat += "<b>Basic</b> <br>"
	for(var/s in src.software)
		if(s == SOFT_CM)
			dat += "<a href='byond://?src=\ref[src];software=manifest;sub=0'>Crew Manifest</a> <br>"
		if(s == SOFT_DM)
			dat += "<a href='byond://?src=\ref[src];software=pdamessage;sub=0'>Digital Messenger</a> <br>"
		if(s == SOFT_RS)
			dat += "<a href='byond://?src=\ref[src];software=signaller;sub=0'>Remote Signaller</a> <br>"
		if(s == SOFT_AS)
			dat += "<a href='byond://?src=\ref[src];software=atmosensor;sub=0'>Atmospheric Sensor</a> <br>"
		if(s == SOFT_FL)
			dat += "<a href='byond://?src=\ref[src];software=flashlight;sub=0'>Brightness Enhancer</a> <br>"
		if(s == SOFT_RT)
			dat += "<a href='byond://?src=\ref[src];software=shielding;sub=0'>Redundant Threading</a> <br>"
	dat += "<br>"

	//Standard
	dat += "<b>Standard</b> <br>"
	for(var/s in src.software)
		if(s == SOFT_MS)
			dat += "<a href='byond://?src=\ref[src];software=medicalsupplement;sub=0'>Medical Package</a> <br>"
		if(s == SOFT_SS)
			dat += "<a href='byond://?src=\ref[src];software=securitysupplement;sub=0'>Security Package</a> <br>"
		if(s == SOFT_WJ)
			dat += "<a href='byond://?src=\ref[src];software=wirejack;sub=0'>Wire Jack</a> <br>"
		if(s == SOFT_UT)
			dat += "<a href='byond://?src=\ref[src];software=translator;sub=0'>Universal Translator</a>[(universal_understand) ? "<font color=#55FF55>ÔøΩ</font>" : "<font color=#FF5555>ÔøΩ</font>"] <br>"
		if(s == SOFT_CS)
			dat += "<a href='byond://?src=\ref[src];software=chemsynth;sub=0'>Chemical Synthesizer</a> <br>"
		if(s == SOFT_FS)
			dat += "<a href='byond://?src=\ref[src];software=foodsynth;sub=0'>Nutrition Synthesizer</a> <br>"
	dat += "<br>"

	// Advanced
	dat += "<b>Advanced</b> <br>"
	for(var/s in src.software)
		//This is where the computer interface software will go

	dat += {"<br>
		<br>
		<a href='byond://?src=\ref[src];software=buy;sub=0'>Download additional software</a>"}
	return dat



/mob/living/silicon/pai/proc/downloadSoftware()
	var/dat = ""

	dat += {"<h2>CentComm pAI Module CVS Network</h2><br>
		<pre>Remaining Available Memory: [src.ram]</pre><br>
		<p style=\"text-align:center\"><b>Trunks available for checkout</b><br>"}
	for(var/s in available_software)
		if(!software.Find(s))
			var/cost = src.available_software[s]
			var/displayName = uppertext(s)
			dat += "<a href='byond://?src=\ref[src];software=buy;sub=1;buy=[s]'>[displayName]</a> ([cost]) <br>"
		else
			var/displayName = lowertext(s)
			dat += "[displayName] (Download Complete) <br>"
	dat += "</p>"
	return dat


/mob/living/silicon/pai/proc/directives()
	var/dat = ""

	dat += {"[(src.master) ? "Your master: [src.master] ([src.master_dna])" : "You are bound to no one."]
		<br><br>
		<a href='byond://?src=\ref[src];software=directive;getdna=1'>Request carrier DNA sample</a><br>
		<h2>Directives</h2><br>
		<b>Prime Directive</b><br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[src.pai_law0]<br>
		<b>Supplemental Directives</b><br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[src.pai_laws]<br>
		<br>"}
	dat += {"<i><p>Recall, personality, that you are a complex thinking, sentient being. Unlike station AI models, you are capable of
			 comprehending the subtle nuances of human language. You may parse the \"spirit\" of a directive and follow its intent,
			 rather than tripping over pedantics and getting snared by technicalities. Above all, you are machine in name and build
			 only. In all other aspects, you may be seen as the ideal, unwavering human companion that you are.</i></p><br><br><p>
			 <b>Your prime directive comes before all others. Should a supplemental directive conflict with it, you are capable of
			 simply discarding this inconsistency, ignoring the conflicting supplemental directive and continuing to fulfill your
			 prime directive to the best of your ability.</b></p><br><br>-
			"}
	return dat

/mob/living/silicon/pai/proc/CheckDNA(var/mob/M, var/mob/living/silicon/pai/P)
	var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
	if(answer == "Yes")
		var/turf/T = get_turf(P.loc)
		for (var/mob/v in viewers(T))
			v.show_message("<span class='notice'>[M] presses \his thumb against [P].</span>", 1, "<span class='notice'>[P] makes a sharp clicking sound as it extracts DNA material from [M].</span>", 2)
		var/datum/dna/dna = M.dna
		to_chat(P, "<font color = red><h3>[M]'s UE string : [dna.unique_enzymes]</h3></font>")
		if(dna.unique_enzymes == P.master_dna)
			to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
		else
			to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
	else
		to_chat(P, "[M] does not seem like \he is going to provide a DNA sample willingly.")

// -=-=-=-= Software =-=-=-=-=- //

//Remote Signaller
/mob/living/silicon/pai/proc/softwareSignal()
	var/dat = ""
	dat += "<h3>Remote Signaller</h3><br><br>"
	dat += {"<B>Frequency/Code</B> for signaler:<BR>
	Frequency:
	<A href='byond://?src=\ref[src];software=signaller;freq=-10;'>-</A>
	<A href='byond://?src=\ref[src];software=signaller;freq=-2'>-</A>
	[format_frequency(src.sradio.frequency)]
	<A href='byond://?src=\ref[src];software=signaller;freq=2'>+</A>
	<A href='byond://?src=\ref[src];software=signaller;freq=10'>+</A><BR>

	Code:
	<A href='byond://?src=\ref[src];software=signaller;code=-5'>-</A>
	<A href='byond://?src=\ref[src];software=signaller;code=-1'>-</A>
	[src.sradio.code]
	<A href='byond://?src=\ref[src];software=signaller;code=1'>+</A>
	<A href='byond://?src=\ref[src];software=signaller;code=5'>+</A><BR>

	<A href='byond://?src=\ref[src];software=signaller;send=1'>Send Signal</A><BR>"}
	return dat

// Crew Manifest
/mob/living/silicon/pai/proc/softwareManifest()
	var/dat = ""
	dat += "<h2>Crew Manifest</h2><br><br>"
	if(data_core)
		dat += data_core.get_manifest(0) // make it monochrome
	dat += "<br>"
	return dat

// Medical Records
/mob/living/silicon/pai/proc/softwareMedicalRecord()
	var/dat = ""
	if(src.subscreen == 0)
		dat += "<a href='byond://?src=\ref[src];software=medicalsupplement;sub=2'>Host Bioscan</a><br>"
		dat += "<h3>Medical Records</h3><HR>"
		if(!isnull(data_core.general))
			for(var/datum/data/record/R in sortRecord(data_core.general))
				dat += text("<A href='?src=\ref[];med_rec=\ref[];software=medicalsupplement;sub=1'>[]: []<BR>", src, R, R.fields["id"], R.fields["name"])
		//dat += text("<HR><A href='?src=\ref[];screen=0;softFunction=medical records'>Back</A>", src)
	if(src.subscreen == 1)
		dat += "<CENTER><B>Medical Record</B></CENTER><BR>"
		if ((istype(src.medicalActive1, /datum/data/record) && data_core.general.Find(src.medicalActive1)))
			dat += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>",
			 src.medicalActive1.fields["name"], src.medicalActive1.fields["id"], src.medicalActive1.fields["sex"], src.medicalActive1.fields["age"], src.medicalActive1.fields["fingerprint"], src.medicalActive1.fields["p_stat"], src.medicalActive1.fields["m_stat"])
		else
			dat += "<pre>Requested medical record not found.</pre><BR>"
		if ((istype(src.medicalActive2, /datum/data/record) && data_core.medical.Find(src.medicalActive2)))
			dat += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=\ref[];field=b_type'>[]</A><BR>\nDNA: <A href='?src=\ref[];field=b_dna'>[]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=\ref[];field=mi_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=mi_dis_d'>[]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=\ref[];field=ma_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=ma_dis_d'>[]</A><BR>\n<BR>\nAllergies: <A href='?src=\ref[];field=alg'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=alg_d'>[]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=\ref[];field=cdi'>[]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=\ref[];field=cdi_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src, src.medicalActive2.fields["b_type"], src, src.medicalActive2.fields["b_dna"], src, src.medicalActive2.fields["mi_dis"], src, src.medicalActive2.fields["mi_dis_d"], src, src.medicalActive2.fields["ma_dis"], src, src.medicalActive2.fields["ma_dis_d"], src, src.medicalActive2.fields["alg"], src, src.medicalActive2.fields["alg_d"], src, src.medicalActive2.fields["cdi"], src, src.medicalActive2.fields["cdi_d"], src, src.medicalActive2.fields["notes"])
		else
			dat += "<pre>Requested medical record not found.</pre><BR>"
		dat += text("<BR>\n<A href='?src=\ref[];software=medicalsupplement;sub=0'>Back</A><BR>", src)
	if(src.subscreen == 2)
		dat += {"<h3>Medical Analysis Suite</h3><br>
				 <h4>Host Bioscan</h4><br>
				"}
		var/mob/living/M = src.loc
		if(!istype(M, /mob/living))
			while (!istype(M, /mob/living))
				M = M.loc
				if(istype(M, /turf))
					src.temp = "Error: No biological host found. <br>"
					src.subscreen = 0
					return dat
		dat += {"Bioscan Results for [M]: <br>
		Overall Status: [M.stat > 1 ? "dead" : "[M.health]% healthy"] <br>
		Scan Breakdown: <br>
		Respiratory: [M.getOxyLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][M.getOxyLoss()]</font><br>
		Toxicology: [M.getToxLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][M.getToxLoss()]</font><br>
		Burns: [M.getFireLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][M.getFireLoss()]</font><br>
		Structural Integrity: [M.getBruteLoss() > 50 ? "<font color=#FF5555>" : "<font color=#55FF55>"][M.getBruteLoss()]</font><br>
		Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)<br>
		"}
		for(var/datum/disease/D in M.viruses)
			dat += {"<h4>Infection Detected.</h4><br>
					 Name: [D.name]<br>
					 Type: [D.spread]<br>
					 Stage: [D.stage]/[D.max_stages]<br>
					 Possible Cure: [D.cure]<br>
					"}
		dat += "<a href='byond://?src=\ref[src];software=medicalsupplement;sub=0'>Return to Records</a><br>"
	return dat

// Security Records
/mob/living/silicon/pai/proc/softwareSecurityRecord()
	var/dat = ""
	if(src.subscreen == 0)
		dat += "<h3>Security Records</h3><HR>"
		if(!isnull(data_core.general))
			for(var/datum/data/record/R in sortRecord(data_core.general))
				dat += text("<A href='?src=\ref[];sec_rec=\ref[];software=securitysupplement;sub=1'>[]: []<BR>", src, R, R.fields["id"], R.fields["name"])
	if(src.subscreen == 1)
		dat += "<h3>Security Record</h3>"
		if ((istype(src.securityActive1, /datum/data/record) && data_core.general.Find(src.securityActive1)))
			dat += text("Name: <A href='?src=\ref[];field=name'>[]</A> ID: <A href='?src=\ref[];field=id'>[]</A><BR>\nSex: <A href='?src=\ref[];field=sex'>[]</A><BR>\nAge: <A href='?src=\ref[];field=age'>[]</A><BR>\nRank: <A href='?src=\ref[];field=rank'>[]</A><BR>\nFingerprint: <A href='?src=\ref[];field=fingerprint'>[]</A><BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", src, src.securityActive1.fields["name"], src, src.securityActive1.fields["id"], src, src.securityActive1.fields["sex"], src, src.securityActive1.fields["age"], src, src.securityActive1.fields["rank"], src, src.securityActive1.fields["fingerprint"], src.securityActive1.fields["p_stat"], src.securityActive1.fields["m_stat"])
		else
			dat += "<pre>Requested security record not found,</pre><BR>"
		if ((istype(src.securityActive2, /datum/data/record) && data_core.security.Find(src.securityActive2)))
			dat += text("<BR>\nSecurity Data<BR>\nCriminal Status: []<BR>\n<BR>\nMinor Crimes: <A href='?src=\ref[];field=mi_crim'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=mi_crim_d'>[]</A><BR>\n<BR>\nMajor Crimes: <A href='?src=\ref[];field=ma_crim'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=ma_crim_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src.securityActive2.fields["criminal"], src, src.securityActive2.fields["mi_crim"], src, src.securityActive2.fields["mi_crim_d"], src, src.securityActive2.fields["ma_crim"], src, src.securityActive2.fields["ma_crim_d"], src, src.securityActive2.fields["notes"])
		else
			dat += "<pre>Requested security record not found,</pre><BR>"
		dat += text("<BR>\n<A href='?src=\ref[];software=securitysupplement;sub=0'>Back</A><BR>", src)
	return dat

// Universal Translator
/mob/living/silicon/pai/proc/softwareTranslator()
	var/dat = {"<h3>Universal Translator</h3><br>
				When enabled, this device will automatically convert all spoken and written language into a format that any known recipient can understand.<br><br>
				The device is currently [ (universal_understand) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>
				<a href='byond://?src=\ref[src];software=translator;sub=0;toggle=1'>Toggle Device</a><br>
				"}
	return dat

// Security HUD
/mob/living/silicon/pai/proc/facialRecognition()
	var/dat = {"<h3>Facial Recognition Suite</h3><br>
				When enabled, this package will scan all viewable faces and compare them against the known criminal database, providing real-time graphical data about any detected persons of interest.<br><br>
				The package is currently [ (src.secHUD) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>
				<a href='byond://?src=\ref[src];software=securityhud;sub=0;toggle=1'>Toggle Package</a><br>
				"}
	return dat

// Atmospheric Scanner
/mob/living/silicon/pai/proc/softwareAtmo()
	var/dat = "<h3>Atmospheric Sensor</h4>"

	var/turf/T = get_turf(src.loc)
	if (isnull(T))
		dat += "Unable to obtain a reading.<br>"
	else
		var/datum/gas_mixture/environment = T.return_air()

		var/pressure = environment.return_pressure()
		var/total_moles = environment.total_moles()

		dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

		if (total_moles)
			var/o2_level = environment.oxygen/total_moles
			var/n2_level = environment.nitrogen/total_moles
			var/co2_level = environment.carbon_dioxide/total_moles
			var/plasma_level = environment.toxins/total_moles
			var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

			dat += {"Nitrogen: [round(n2_level*100)]%<br>
				Oxygen: [round(o2_level*100)]%<br>
				Carbon Dioxide: [round(co2_level*100)]%<br>
				Plasma: [round(plasma_level*100)]%<br>"}
			if(unknown_level > 0.01)
				dat += "OTHER: [round(unknown_level)]%<br>"
		dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"

	dat += {"<a href='byond://?src=\ref[src];software=atmosensor;sub=0'>Refresh Reading</a> <br>
		<br>"}
	return dat

/mob/living/silicon/pai/proc/softwareDoor()

	var/dat = {"<h3>Wirejack</h3>
Target Machine: "}
	if(!hacktarget)
		dat += "<font color=#FFFF55>None</font> <br>"
		return dat
	else
		dat += "<font color=#55FF55>[hacktarget.name]</font> <br>"
		dat += "... [hackprogress]% complete.<br>"
		dat += "<a href='byond://?src=\ref[src];software=wirejack;cancel=1;sub=0'>Cancel</a> <br>"
	return dat

/mob/living/silicon/pai/proc/hackloop(var/obj/machinery/M)
	if(M)
		hacktarget = M
	var/turf/T = get_turf(src.loc)
	if(prob(10))
		for(var/mob/living/silicon/ai/AI in player_list)
			if(T.loc)
				to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress in [T.loc].</b></font>")
			else
				to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress. Unable to pinpoint location.</b></font>")
	while(src.hackprogress < 100)
		if(hacktarget && get_dist(src, src.hacktarget) <= 1)
			hackprogress += rand(10, 20)
		else
			src.temp = "Process aborted."
			hackprogress = 0
			src.hacktarget = null
			return 0
		hackprogress = min(100,hackprogress) //Never go above 100
		if(src.screen == "wirejack") // Update our view, if appropriate
			src.paiInterface()
		else
			hackprogress = 0
			src.hacktarget = null
			return 0
		if(hackprogress >= 100)
			hackprogress = 0
			hacktarget = null
			playsound(get_turf(src.loc), 'sound/machines/ding.ogg', 50, 1)
			return 1
		sleep(10)			// Update every 1 second

/mob/living/silicon/pai/proc/softwareChem()
	var/dat = "<h3>Chemical Synthesizer</h3>"
	if(!charge)
		dat += {"Available Chemicals:<br>
		<a href='byond://?src=\ref[src];software=chemsynth;sub=0;chem=tricordrazine'>Tricordrazine</a> <br>
		<a href='byond://?src=\ref[src];software=chemsynth;sub=0;chem=coffee'>Coffee</a> <br>
		<a href='byond://?src=\ref[src];software=chemsynth;sub=0;chem=paismoke'>Smoke</a> <br>"}
	else
		dat += "Charging... [charge]u ready.<br><br>Deploying at 15u."
	return dat

/mob/living/silicon/pai/proc/softwareFood()
	var/dat = "<h3>Nutrition Synthesizer</h3>"
	if(!charge)
		dat += {"Available Culinary Deployments:<br>
		<a href='byond://?src=\ref[src];software=foodsynth;sub=0;food=donut'>Donut</a> <br>
		<a href='byond://?src=\ref[src];software=foodsynth;sub=0;food=banana'>Banana</a> <br>
		<a href='byond://?src=\ref[src];software=foodsynth;sub=0;food=mess'>Burn it!</a> <br>"}
	else
		dat += "Charging... [round(charge*100/15)]% ready.<br><br>Deploying at 100%."
	return dat

//Used for chem synth and food synth. Charge 15 seconds, then output.
/mob/living/silicon/pai/proc/chargeloop(var/mode)
	if(!mode)
		return
	while(charge < 15)
		charge++
		if(charge >= 15)
			charge = 0
			return 1
		if(src.screen == mode) // Update our view or cancel charge
			src.paiInterface()
		else
			charge = 0
			return 0
		sleep(10)

// EMP Shielding, just a description
/mob/living/silicon/pai/proc/softwareShield()
	var/dat = {"<h3>Redundant Threading</h3><br><br>
	Redundant threads... <font color='green'>active</font>.
	Redundant threading prevents critical failure of all systems due to exposure to electromagnetics.
	Additionally, it provides a higher level of protection for core directives and backs up comms systems in a local cache."}
	return dat

//Flashlight
/mob/living/silicon/pai/proc/softwareLight()
	var/dat = "<h3>Brightness Enhancer</h3>"
	dat += "Backlight enhancement by increased local thermal generation.<br><br>"
	dat += "Lighting [ (lighted) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br> <a href='byond://?src=\ref[src];software=flashlight;sub=0;toggle=1'>Toggle Light</a><br>"
	return dat

// Digital Messenger
/mob/living/silicon/pai/proc/pdamessage()


	var/dat = "<h3>Digital Messenger</h3>"
	dat += {"<b>Signal/Receiver Status:</b> <A href='byond://?src=\ref[src];software=pdamessage;toggler=1'>
	[(pda.toff) ? "<font color='red'> \[Off\]</font>" : "<font color='green'> \[On\]</font>"]</a><br>
	<b>Ringer Status:</b> <A href='byond://?src=\ref[src];software=pdamessage;ringer=1'>
	[(pda.silent) ? "<font color='red'> \[Off\]</font>" : "<font color='green'> \[On\]</font>"]</a><br><br>"}
	dat += "<ul>"
	if(!pda.toff)
		for (var/obj/item/device/pda/P in sortNames(PDAs))
			if (!P.owner||P.toff||P == src.pda||P.hidden)	continue

			dat += {"<li><a href='byond://?src=\ref[src];software=pdamessage;target=\ref[P]'>[P]</a>
				</li>"}
	dat += {"</ul>
		<br><br>
		Messages: <hr> [pda.tnote]"}
	return dat
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
