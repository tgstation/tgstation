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
	else if(src.stat == DEAD)						// Show some flavor text if the pAI is dead
		left_part = "<b><font color=red>�Rr�R �a�� ��Rr����o�</font></b>"
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
			if(subscreen == 1)
				var/target = href_list["buy"]
				if(available_software.Find(target) && !software.Find(target))
					var/cost = src.available_software[target]
					if(ram >= cost)
						software.Add(target)
						ram -= cost
					else
						temp = "Insufficient RAM available."
				else
					temp = "Trunk <TT> \"[target]\"</TT> not found."

		// Configuring onboard radio
		if("radio")
			radio.attack_self(src)

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
			card.setEmotion(pID)

		if("signaller")

			if(href_list["send"])

				sradio.send_signal("ACTIVATE")
				audible_message("[icon2html(src, world)] *beep* *beep*")

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
				while(!isliving(M))
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
					if(silent)
						return alert("Communications circuits remain unitialized.")

					var/target = locate(href_list["target"])
					pda.create_message(src, target)

		// Accessing medical records
		if("medicalrecord")
			if(subscreen == 1)
				medicalActive1 = find_record("id", href_list["med_rec"], GLOB.data_core.general)
				if(medicalActive1)
					medicalActive2 = find_record("id", href_list["med_rec"], GLOB.data_core.medical)
				if(!medicalActive2)
					medicalActive1 = null
					temp = "Unable to locate requested security record. Record may have been deleted, or never have existed."

		if("securityrecord")
			if(subscreen == 1)
				securityActive1 = find_record("id", href_list["sec_rec"], GLOB.data_core.general)
				if(securityActive1)
					securityActive2 = find_record("id", href_list["sec_rec"], GLOB.data_core.security)
				if(!securityActive2)
					securityActive1 = null
					temp = "Unable to locate requested security record. Record may have been deleted, or never have existed."
		if("securityhud")
			if(href_list["toggle"])
				secHUD = !secHUD
				if(secHUD)
					add_sec_hud()
				else
					var/datum/atom_hud/sec = GLOB.huds[sec_hud]
					sec.remove_hud_from(src)
		if("medicalhud")
			if(href_list["toggle"])
				medHUD = !medHUD
				if(medHUD)
					add_med_hud()
					
				else
					var/datum/atom_hud/med = GLOB.huds[med_hud]
					med.remove_hud_from(src)
		if("translator")
			if(href_list["toggle"])
				if(!(flags_2 & OMNITONGUE_2))
					grant_all_languages(TRUE)
					// this is PERMAMENT.
		if("doorjack")
			if(href_list["jack"])
				if(src.cable && src.cable.machine)
					src.hackdoor = src.cable.machine
					src.hackloop()
			if(href_list["cancel"])
				src.hackdoor = null
			if(href_list["cable"])
				var/turf/T = get_turf(src.loc)
				cable = new /obj/item/pai_cable(T)
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
			var/translator_on = (flags_2 & OMNITONGUE_2)
			dat += "<a href='byond://?src=\ref[src];software=translator;sub=0'>Universal Translator</a>[translator_on ? "<font color=#55FF55> On</font>" : "<font color=#FF5555> Off</font>"] <br>"
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

	dat += "<h2>CentCom pAI Module Subversion Network</h2><br>"
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
	for(var/slaws in laws.supplied)
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
		M.visible_message("<span class='notice'>[M] presses [M.p_their()] thumb against [P].</span>",\
						"<span class='notice'>You press your thumb against [P].</span>",\
						"<span class='notice'>[P] makes a sharp clicking sound as it extracts DNA material from [M].</span>")
		if(!M.has_dna())
			to_chat(P, "<b>No DNA detected</b>")
			return
		to_chat(P, "<font color = red><h3>[M]'s UE string : [M.dna.unique_enzymes]</h3></font>")
		if(M.dna.unique_enzymes == P.master_dna)
			to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
		else
			to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
	else
		to_chat(P, "[M] does not seem like [M.p_they()] [M.p_are()] going to provide a DNA sample willingly.")

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
	if(GLOB.data_core.general)
		for(var/datum/data/record/t in sortRecord(GLOB.data_core.general))
			. += "[t.fields["name"]] - [t.fields["rank"]]<BR>"
	. += "</body></html>"
	return .

// Medical Records
/mob/living/silicon/pai/proc/softwareMedicalRecord()
	switch(subscreen)
		if(0)
			. += "<h3>Medical Records</h3><HR>"
			if(GLOB.data_core.general)
				for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
					. += "<A href='?src=\ref[src];med_rec=[R.fields["id"]];software=medicalrecord;sub=1'>[R.fields["id"]]: [R.fields["name"]]<BR>"
		if(1)
			. += "<CENTER><B>Medical Record</B></CENTER><BR>"
			if(medicalActive1 in GLOB.data_core.general)
				. += "Name: [medicalActive1.fields["name"]] ID: [medicalActive1.fields["id"]]<BR>\nSex: [medicalActive1.fields["sex"]]<BR>\nAge: [medicalActive1.fields["age"]]<BR>\nFingerprint: [medicalActive1.fields["fingerprint"]]<BR>\nPhysical Status: [medicalActive1.fields["p_stat"]]<BR>\nMental Status: [medicalActive1.fields["m_stat"]]<BR>"
			else
				. += "<pre>Requested medical record not found.</pre><BR>"
			if(medicalActive2 in GLOB.data_core.medical)
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
			if(GLOB.data_core.general)
				for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
					. += "<A href='?src=\ref[src];sec_rec=[R.fields["id"]];software=securityrecord;sub=1'>[R.fields["id"]]: [R.fields["name"]]<BR>"
		if(1)
			. += "<h3>Security Record</h3>"
			if(securityActive1 in GLOB.data_core.general)
				. += "Name: <A href='?src=\ref[src];field=name'>[securityActive1.fields["name"]]</A> ID: <A href='?src=\ref[src];field=id'>[securityActive1.fields["id"]]</A><BR>\nSex: <A href='?src=\ref[src];field=sex'>[securityActive1.fields["sex"]]</A><BR>\nAge: <A href='?src=\ref[src];field=age'>[securityActive1.fields["age"]]</A><BR>\nRank: <A href='?src=\ref[src];field=rank'>[securityActive1.fields["rank"]]</A><BR>\nFingerprint: <A href='?src=\ref[src];field=fingerprint'>[securityActive1.fields["fingerprint"]]</A><BR>\nPhysical Status: [securityActive1.fields["p_stat"]]<BR>\nMental Status: [securityActive1.fields["m_stat"]]<BR>"
			else
				. += "<pre>Requested security record not found,</pre><BR>"
			if(securityActive2 in GLOB.data_core.security)
				. += "<BR>\nSecurity Data<BR>\nCriminal Status: [securityActive2.fields["criminal"]]<BR>\n<BR>\nMinor Crimes: <A href='?src=\ref[src];field=mi_crim'>[securityActive2.fields["mi_crim"]]</A><BR>\nDetails: <A href='?src=\ref[src];field=mi_crim_d'>[securityActive2.fields["mi_crim_d"]]</A><BR>\n<BR>\nMajor Crimes: <A href='?src=\ref[src];field=ma_crim'>[securityActive2.fields["ma_crim"]]</A><BR>\nDetails: <A href='?src=\ref[src];field=ma_crim_d'>[securityActive2.fields["ma_crim_d"]]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[src];field=notes'>[securityActive2.fields["notes"]]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
			else
				. += "<pre>Requested security record not found,</pre><BR>"
			. += text("<BR>\n<A href='?src=\ref[];software=securityrecord;sub=0'>Back</A><BR>", src)
	return .

// Universal Translator
/mob/living/silicon/pai/proc/softwareTranslator()
	var/translator_on = (flags_2 & OMNITONGUE_2)
	. = {"<h3>Universal Translator</h3><br>
				When enabled, this device will permamently be able to speak and understand all known forms of communication.<br><br>
				The device is currently [translator_on ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>[translator_on ? "" : "<a href='byond://?src=\ref[src];software=translator;sub=0;toggle=1'>Activate Translation Module</a><br>"]"}
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
		if(!isliving(M))
			while(!isliving(M))
				if(isturf(M))
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
		for(var/thing in M.viruses)
			var/datum/disease/D = thing
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
		to_chat(src, "DERP")
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
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(T.loc)
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress in [T.loc].</b></font>")
		else
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress. Unable to pinpoint location.</b></font>")
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
			var/obj/machinery/door/D = cable.machine
			D.open()
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
