// TODO:
// - Potentially roll HUDs and Records into one
// - Shock collar/lock system for prisoner pAIs?


/mob/living/silicon/pai/var/list/available_software = list(
															//Nightvision
															//T-Ray
															//radiation eyes
															//chem goggs
															//mesons
															"crew manifest" = 5,
															"digital messenger" = 5,
															"atmosphere sensor" = 5,
															"photography module" = 5,
															"camera zoom" = 10,
															"printer module" = 10,
															"remote signaler" = 10,
															"medical records" = 10,
															"security records" = 10,
															"host scan" = 10,
															"medical HUD" = 20,
															"security HUD" = 20,
															"loudness booster" = 20,
															"newscaster" = 20,
															"door jack" = 25,
															"encryption keys" = 25,
															"internal gps" = 35,
															"universal translator" = 35
															)

// Opens TGUI interface
/mob/living/silicon/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiInterface", name)
		ui.open()

// Variables sent to TGUI
/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["directives"] = laws.supplied
	data["image"] = card.emotion_icon
	data["languages"] = languages_granted
	data["master"] = list()
	data["pda"] = list()
	data["ram"] = ram
	data["stat"] = stat
	data["software"] = list()
	if(aiPDA)
		data["pda"]["power"] = aiPDA.toff
		data["pda"]["silent"] = aiPDA.silent
	if(master)
		data["master"]["name"] = master
		data["master"]["dna"] = master_dna
	if(software)
		data["software"]["available"] = available_software
		data["software"]["installed"] = software
	return data

// Actions received from TGUI
/mob/living/silicon/pai/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("buy") // Purchasing new software
			if(available_software.Find(params["selection"]) && !software.Find(params["selection"]))
				var/cost = available_software[params["selection"]]
				if(ram >= cost)
					software.Add(params["selection"])
					ram -= cost
					var/datum/hud/pai/pAIhud = hud_used
					pAIhud?.update_software_buttons()
				else
					to_chat(usr, span_notice("Insufficient RAM available."))
			else
				to_chat(usr, span_notice("Software not found."))
		if("radio") // Configuring onboard radio
			radio.attack_self(src)
		if("change_image") // Set pAI card display face
			var/newImage = tgui_input_list(usr, "Select your new display image.", "Display Image", sort_list(list("Happy", "Cat", "Extremely Happy", "Face", "Laugh", "Off", "Sad", "Angry", "What", "Sunglasses")))
			switch(newImage)
				if(null)
					card.emotion_icon = "null"
				if("Extremely Happy")
					card.emotion_icon = "extremely-happy"
				else
					card.emotion_icon = "[lowertext(newImage)]"
				card.update_appearance()
		if("newscaster")
			newscaster.ui_interact(src)
		if("camera_zoom")
			aicamera.adjust_zoom(usr)
		if("remote_signaler")
			signaler.ui_interact(src)
		if("check_dna")
			if(iscarbon(card.loc))
				CheckDNA(card.loc, src) //you should only be able to check when directly in hand, muh immersions?
			else
				to_chat(src, span_warning("You are not being carried by anyone!"))
				return 0 // FALSE ? If you return here you won't call paiinterface() below
		if("pda")
			if(params["pda"] == "power")
				if(!isnull(aiPDA))
					aiPDA.toff = !aiPDA.toff
			if(params["pda"] == "silent")
				if(!isnull(aiPDA))
				aiPDA.silent = !aiPDA.silent
			if(params["pda"] == "message")
				cmd_send_pdamesg(usr)
		if("medical_records") // Accessing medical records
			medicalActive1 = find_record("id", params, GLOB.data_core.general)
			if(medicalActive1)
				medicalActive2 = find_record("id", params, GLOB.data_core.medical)
			if(!medicalActive2)
				medicalActive1 = null
				to_chat(usr, span_notice("Unable to locate requested security record. Record may have been deleted, or never have existed."))
		if("security_records")
			securityActive1 = find_record("id", params, GLOB.data_core.general)
			if(securityActive1)
				securityActive2 = find_record("id", params, GLOB.data_core.security)
			if(!securityActive2)
				securityActive1 = null
				to_chat(usr, span_notice("Unable to locate requested security record. Record may have been deleted, or never have existed."))
		if("security_hud")
			secHUD = !secHUD
			if(secHUD)
				var/datum/atom_hud/sec = GLOB.huds[sec_hud]
				sec.add_hud_to(src)
			else
				var/datum/atom_hud/sec = GLOB.huds[sec_hud]
				sec.remove_hud_from(src)
		if("medical_hud")
			medHUD = !medHUD
			if(medHUD)
				var/datum/atom_hud/med = GLOB.huds[med_hud]
				med.add_hud_to(src)
			else
				var/datum/atom_hud/med = GLOB.huds[med_hud]
				med.remove_hud_from(src)
		if("host_scan")
			if(params == "toggle-on")
				var/mob/living/silicon/pai/pAI = usr
				pAI.hostscan.attack_self(usr)
			if(params == "toggle-off")
				var/mob/living/silicon/pai/pAI = usr
				pAI.hostscan.toggle_mode()
		if("encryption_keys")
			encryptmod = !encryptmod
			radio.subspace_transmission = !radio.subspace_transmission
		if("universal_translator")
			if(!languages_granted)
				grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_SOFTWARE)
				languages_granted = TRUE
		if("door_jack")
			if(params["jack"] == "jack")
				if(hacking_cable?.machine)
					hackdoor = hacking_cable.machine
					hackloop()
			if(params["jack"]  == "cancel")
				hackdoor = null
			if(params["jack"]  == "cable")
				qdel(hacking_cable) //clear any old cables
				hacking_cable = new
				var/transfered_to_mob
				if(isliving(card.loc))
					var/mob/living/L = card.loc
					if(L.put_in_hands(hacking_cable))
						transfered_to_mob = TRUE
						L.visible_message(span_warning("A port on [src] opens to reveal \a [hacking_cable], which you quickly grab hold of."), span_hear("You hear the soft click of something light and manage to catch hold of [hacking_cable]."))
				if(!transfered_to_mob)
					hacking_cable.forceMove(drop_location())
					hacking_cable.visible_message(span_warning("A port on [src] opens to reveal \a [hacking_cable], which promptly falls to the floor."), span_hear("You hear the soft click of something light and hard falling to the ground."))
		if("loudness_booster")
			if(!internal_instrument)
				internal_instrument = new(src)
			internal_instrument.interact(src) // Open Instrument
		if("internal_gps")
			if(!internal_gps)
				internal_gps = new(src)
			internal_gps.attack_self(src)
		if("printer_module")
			aicamera.paiprint(usr)
	return

// // MENUS

// /mob/living/silicon/pai/proc/softwareMenu() // Populate the right menu
// 	var/dat = ""

// 	dat += "<A href='byond://?src=[REF(src)];software=refresh'>Refresh</A><br>"
// 	// Built-in
// 	dat += "<A href='byond://?src=[REF(src)];software=directives'>Directives</A><br>"
// 	dat += "<A href='byond://?src=[REF(src)];software=radio;sub=0'>Radio Configuration</A><br>"
// 	dat += "<A href='byond://?src=[REF(src)];software=image'>Screen Display</A><br>"
// 	//dat += "Text Messaging <br>"
// 	dat += "<br>"

// 	// Basic
// 	dat += "<b>Basic</b> <br>"
// 	for(var/s in software)
// 		if(s == "digital messenger")
// 			dat += "<a href='byond://?src=[REF(src)];software=pdamessage;sub=0'>Digital Messenger</a> <br>"
// 		if(s == "crew manifest")
// 			dat += "<a href='byond://?src=[REF(src)];software=manifest;sub=0'>Crew Manifest</a> <br>"
// 		if(s == "host scan")
// 			dat += "<a href='byond://?src=[REF(src)];software=hostscan;sub=0'>Host Health Scan</a> <br>"
// 		if(s == "medical records")
// 			dat += "<a href='byond://?src=[REF(src)];software=medicalrecord;sub=0'>Medical Records</a> <br>"
// 		if(s == "security records")
// 			dat += "<a href='byond://?src=[REF(src)];software=securityrecord;sub=0'>Security Records</a> <br>"
// 		if(s == "remote signaler")
// 			dat += "<a href='byond://?src=[REF(src)];software=signaler;sub=0'>Remote Signaler</a> <br>"
// 		if(s == "loudness booster")
// 			dat += "<a href='byond://?src=[REF(src)];software=loudness;sub=0'>Loudness Booster</a> <br>"
// 		if(s == "internal gps")
// 			dat += "<a href='byond://?src=[REF(src)];software=internalgps;sub=0'>Internal GPS</a> <br>"
// 		if(s == "printer module")
// 			dat += "<a href='byond://?src=[REF(src)];software=printermodule;sub=0'>Printer Module</a> <br>"

// 	dat += "<br>"

// 	// Advanced
// 	dat += "<b>Advanced</b> <br>"
// 	for(var/s in software)
// 		if(s == "camera zoom")
// 			dat += "<a href='byond://?src=[REF(src)];software=camzoom;sub=0'>Adjust Camera Zoom</a> <br>"
// 		if(s == "atmosphere sensor")
// 			dat += "<a href='byond://?src=[REF(src)];software=atmosensor;sub=0'>Atmospheric Sensor</a> <br>"
// 		if(s == "security HUD")
// 			dat += "<a href='byond://?src=[REF(src)];software=securityhud;sub=0'>Facial Recognition Suite</a>[(secHUD) ? "<font color=#55FF55> On</font>" : "<font color=#FF5555> Off</font>"] <br>"
// 		if(s == "medical HUD")
// 			dat += "<a href='byond://?src=[REF(src)];software=medicalhud;sub=0'>Medical Analysis Suite</a>[(medHUD) ? "<font color=#55FF55> On</font>" : "<font color=#FF5555> Off</font>"] <br>"
// 		if(s == "encryption keys")
// 			dat += "<a href='byond://?src=[REF(src)];software=encryptionkeys;sub=0'>Channel Encryption Firmware</a>[(encryptmod) ? "<font color=#55FF55> On</font>" : "<font color=#FF5555> Off</font>"] <br>"
// 		if(s == "universal translator")
// 			var/datum/language_holder/H = get_language_holder()
// 			dat += "<a href='byond://?src=[REF(src)];software=translator;sub=0'>Universal Translator</a>[H.omnitongue ? "<font color=#55FF55> On</font>" : "<font color=#FF5555> Off</font>"] <br>"
// 		if(s == "door jack")
// 			dat += "<a href='byond://?src=[REF(src)];software=doorjack;sub=0'>Door Jack</a> <br>"
// 	dat += "<br>"
// 	dat += "<br>"
// 	dat += "<a href='byond://?src=[REF(src)];software=buy;sub=0'>Download additional software</a>"
// 	return dat



// /mob/living/silicon/pai/proc/downloadSoftware()
// 	var/dat = ""

// 	dat += "<h2>CentCom pAI Module Subversion Network</h2><br>"
// 	dat += "<pre>Remaining Available Memory: [ram]</pre><br>"
// 	dat += "<p style=\"text-align:center\"><b>Trunks available for checkout</b><br>"

// 	for(var/s in available_software)
// 		if(!software.Find(s))
// 			var/cost = available_software[s]
// 			var/displayName = uppertext(s)
// 			dat += "<a href='byond://?src=[REF(src)];software=buy;sub=1;buy=[s]'>[displayName]</a> ([cost]) <br>"
// 		else
// 			var/displayName = lowertext(s)
// 			dat += "[displayName] (Download Complete) <br>"
// 	dat += "</p>"
// 	return dat


// /mob/living/silicon/pai/proc/directives()
// 	var/dat = ""

// 	dat += "[(master) ? "Your master: [master] ([master_dna])" : "You are bound to no one."]"
// 	dat += "<br><br>"
// 	dat += "<a href='byond://?src=[REF(src)];software=directive;getdna=1'>Request carrier DNA sample</a><br>"
// 	dat += "<h2>Directives</h2><br>"
// 	dat += "<b>Prime Directive</b><br>"
// 	dat += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[laws.zeroth]<br>"
// 	dat += "<b>Supplemental Directives</b><br>"
// 	for(var/slaws in laws.supplied)
// 		dat += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[slaws]<br>"
// 	dat += "<br>"
// 	dat += {"<i><p>Recall, personality, that you are a complex thinking, sentient being. Unlike station AI models, you are capable of
// 		comprehending the subtle nuances of human language. You may parse the \"spirit\" of a directive and follow its intent,
// 		rather than tripping over pedantics and getting snared by technicalities. Above all, you are machine in name and build
// 		only. In all other aspects, you may be seen as the ideal, unwavering human companion that you are.</i></p><br><br><p>
// 		<b>Your prime directive comes before all others. Should a supplemental directive conflict with it, you are capable of
// 		simply discarding this inconsistency, ignoring the conflicting supplemental directive and continuing to fulfill your
// 		prime directive to the best of your ability.</b></p><br><br>-
// 		"}
// 	return dat

/mob/living/silicon/pai/proc/CheckDNA(mob/living/carbon/M, mob/living/silicon/pai/P)
	if(!istype(M))
		return
	var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
	if(answer == "Yes")
		M.visible_message(span_notice("[M] presses [M.p_their()] thumb against [P]."),\
						span_notice("You press your thumb against [P]."),\
						span_notice("[P] makes a sharp clicking sound as it extracts DNA material from [M]."))
		if(!M.has_dna())
			to_chat(P, "<b>No DNA detected</b>")
			return
		to_chat(P, "<font color = red><h3>[M]'s UE string : [M.dna.unique_enzymes]</h3></font>")
		if(M.dna.unique_enzymes == P.master_dna)
			to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
		else
			to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
	else
		to_chat(P, span_warning("[M] does not seem like [M.p_theyre()] going to provide a DNA sample willingly."))

// // -=-=-=-= Software =-=-=-=-=- //

// // Crew Manifest
// /mob/living/silicon/pai/proc/softwareManifest()
// 	. += "<h2>Crew Manifest</h2><br><br>"
// 	if(GLOB.data_core.general)
// 		for(var/datum/data/record/t in sort_record(GLOB.data_core.general))
// 			. += "[t.fields["name"]] - [t.fields["rank"]]<BR>"
// 	. += "</body></html>"
// 	return .

// // Medical Records
// /mob/living/silicon/pai/proc/softwareMedicalRecord()
// 	switch(subscreen)
// 		if(0)
// 			. += "<h3>Medical Records</h3><HR>"
// 			if(GLOB.data_core.general)
// 				for(var/datum/data/record/R in sort_record(GLOB.data_core.general))
// 					. += "<A href='?src=[REF(src)];med_rec=[R.fields["id"]];software=medicalrecord;sub=1'>[R.fields["id"]]: [R.fields["name"]]<BR>"
// 		if(1)
// 			. += "<CENTER><B>Medical Record</B></CENTER><BR>"
// 			if(medicalActive1 in GLOB.data_core.general)
// 				. += "Name: [medicalActive1.fields["name"]] ID: [medicalActive1.fields["id"]]<BR>\nGender: [medicalActive1.fields["gender"]]<BR>\nAge: [medicalActive1.fields["age"]]<BR>\nFingerprint: [medicalActive1.fields["fingerprint"]]<BR>\nPhysical Status: [medicalActive1.fields["p_stat"]]<BR>\nMental Status: [medicalActive1.fields["m_stat"]]<BR>"
// 			else
// 				. += "<pre>Requested medical record not found.</pre><BR>"
// 			if(medicalActive2 in GLOB.data_core.medical)
// 				. += "<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=[REF(src)];field=blood_type'>[medicalActive2.fields["blood_type"]]</A><BR>\nDNA (UE): <A href='?src=[REF(src)];field=b_dna'>[medicalActive2.fields["b_dna"]]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=[REF(src)];field=mi_dis'>[medicalActive2.fields["mi_dis"]]</A><BR>\nDetails: <A href='?src=[REF(src)];field=mi_dis_d'>[medicalActive2.fields["mi_dis_d"]]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=[REF(src)];field=ma_dis'>[medicalActive2.fields["ma_dis"]]</A><BR>\nDetails: <A href='?src=[REF(src)];field=ma_dis_d'>[medicalActive2.fields["ma_dis_d"]]</A><BR>\n<BR>\nAllergies: <A href='?src=[REF(src)];field=alg'>[medicalActive2.fields["alg"]]</A><BR>\nDetails: <A href='?src=[REF(src)];field=alg_d'>[medicalActive2.fields["alg_d"]]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=[REF(src)];field=cdi'>[medicalActive2.fields["cdi"]]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=[REF(src)];field=cdi_d'>[medicalActive2.fields["cdi_d"]]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=[REF(src)];field=notes'>[medicalActive2.fields["notes"]]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
// 			else
// 				. += "<pre>Requested medical record not found.</pre><BR>"
// 			. += "<BR>\n<A href='?src=[REF(src)];software=medicalrecord;sub=0'>Back</A><BR>"
// 	return .

// // Security Records
// /mob/living/silicon/pai/proc/softwareSecurityRecord()
// 	. = ""
// 	switch(subscreen)
// 		if(0)
// 			. += "<h3>Security Records</h3><HR>"
// 			if(GLOB.data_core.general)
// 				for(var/datum/data/record/R in sort_record(GLOB.data_core.general))
// 					. += "<A href='?src=[REF(src)];sec_rec=[R.fields["id"]];software=securityrecord;sub=1'>[R.fields["id"]]: [R.fields["name"]]<BR>"
// 		if(1)
// 			. += "<h3>Security Record</h3>"
// 			if(securityActive1 in GLOB.data_core.general)
// 				. += "Name: <A href='?src=[REF(src)];field=name'>[securityActive1.fields["name"]]</A> ID: <A href='?src=[REF(src)];field=id'>[securityActive1.fields["id"]]</A><BR>\nGender: <A href='?src=[REF(src)];field=gender'>[securityActive1.fields["gender"]]</A><BR>\nAge: <A href='?src=[REF(src)];field=age'>[securityActive1.fields["age"]]</A><BR>\nRank: <A href='?src=[REF(src)];field=rank'>[securityActive1.fields["rank"]]</A><BR>\nFingerprint: <A href='?src=[REF(src)];field=fingerprint'>[securityActive1.fields["fingerprint"]]</A><BR>\nPhysical Status: [securityActive1.fields["p_stat"]]<BR>\nMental Status: [securityActive1.fields["m_stat"]]<BR>"
// 			else
// 				. += "<pre>Requested security record not found,</pre><BR>"
// 			if(securityActive2 in GLOB.data_core.security)
// 				. += "<BR>\nSecurity Data<BR>\nCriminal Status: [securityActive2.fields["criminal"]]<BR>\n<BR>\nCrimes: <A href='?src=[REF(src)];field=mcrim'>[securityActive2.fields["crim"]]</A><BR>\nDetails: <A href='?src=[REF(src)];field=crim_d'>[securityActive2.fields["crim_d"]]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=[REF(src)];field=notes'>[securityActive2.fields["notes"]]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
// 			else
// 				. += "<pre>Requested security record not found,</pre><BR>"
// 			. += "<BR>\n<A href='?src=[REF(src)];software=securityrecord;sub=0'>Back</A><BR>"
// 	return .

// // Encryption Keys
// /mob/living/silicon/pai/proc/softwareEncryptionKeys()
// 	var/dat = {"<h3>Encryption Key Firmware</h3><br>
// 				When enabled, this device will be able to use up to two (2) encryption keys for departmental channel access.<br><br>
// 				The device is currently [encryptmod ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>[encryptmod ? "" : "<a href='byond://?src=[REF(src)];software=encryptionkeys;sub=0;toggle=1'>Activate Encryption Key Ports</a><br>"]"}
// 	return dat


// // Universal Translator
// /mob/living/silicon/pai/proc/softwareTranslator()
// 	var/datum/language_holder/H = get_language_holder()
// 	. = {"<h3>Universal Translator</h3><br>
// 				When enabled, this device will permanently be able to speak and understand all known forms of communication.<br><br>
// 				The device is currently [H.omnitongue ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>[H.omnitongue ? "" : "<a href='byond://?src=[REF(src)];software=translator;sub=0;toggle=1'>Activate Translation Module</a><br>"]"}
// 	return .

// // Security HUD
// /mob/living/silicon/pai/proc/facialRecognition()
// 	var/dat = {"<h3>Facial Recognition Overlay</h3><br>
// 				When enabled, this package will scan all viewable faces and compare them against the known criminal database, providing real-time graphical data about any detected persons of interest.<br><br>
// 				The package is currently [ (secHUD) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>
// 				<a href='byond://?src=[REF(src)];software=securityhud;sub=0;toggle=1'>Toggle Package</a><br>
// 				"}
// 	return dat

// // Medical HUD
// /mob/living/silicon/pai/proc/medicalAnalysis()
// 	var/dat = ""
// 	dat += {"<h3>Medical Analysis Overlay</h3><br>
// 			When enabled, this package will scan all nearby crewmembers' vitals and provide real-time graphical data about their state of health.<br><br>
// 			The suite is currently [ (medHUD) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>
// 			<a href='byond://?src=[REF(src)];software=medicalhud;sub=0;toggle=1'>Toggle Suite</a><br>
// 			"}
// 	return dat

// //Health Scanner
// /mob/living/silicon/pai/proc/softwareHostScan()

// 	var/dat = ""
// 	dat += {"<h3>Host Bisoscan Settings</h3><br>

// 			<a href='byond://?src=[REF(src)];software=hostscan;sub=0;toggle=1'>Change Scan Type</a><br>

// 			<a href='byond://?src=[REF(src)];software=hostscan;sub=0;toggle2=1'>Toggle Verbosity</a><br>
// 			"}
// 	return dat
// // Atmospheric Scanner
// /mob/living/silicon/pai/proc/softwareAtmo()
// 	var/dat = "<h3>Atmospheric Sensor</h4>"

// 	var/turf/T = get_turf(loc)
// 	if (isnull(T))
// 		dat += "Unable to obtain a reading.<br>"
// 	else
// 		var/datum/gas_mixture/environment = T.return_air()
// 		var/list/env_gases = environment.gases

// 		var/pressure = environment.return_pressure()
// 		var/total_moles = environment.total_moles()

// 		dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

// 		if (total_moles)
// 			for(var/id in env_gases)
// 				var/gas_level = env_gases[id][MOLES]/total_moles
// 				if(gas_level > 0.01)
// 					dat += "[env_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_level*100)]%<br>"
// 		dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"
// 	dat += "<a href='byond://?src=[REF(src)];software=atmosensor;sub=0'>Refresh Reading</a> <br>"
// 	dat += "<br>"
// 	return dat
// // Door Jack
// /mob/living/silicon/pai/proc/softwareDoor()
// 	var/dat = "<h3>Airlock Jack</h3>"
// 	dat += "Cable status : "
// 	if(!hacking_cable)
// 		dat += "<font color=#FF5555>Retracted</font> <br>"
// 		dat += "<a href='byond://?src=[REF(src)];software=doorjack;cable=1;sub=0'>Extend Cable</a> <br>"
// 		return dat
// 	if(!hacking_cable.machine)
// 		dat += "<font color=#FFFF55>Extended</font> <br>"
// 		return dat

// 	dat += "<font color=#55FF55>Connected</font> <br>"
// 	if(!istype(hacking_cable.machine, /obj/machinery/door))
// 		dat += "Connected device's firmware does not appear to be compatible with Airlock Jack protocols.<br>"
// 		return dat

// 	if(!hackdoor)
// 		dat += "<a href='byond://?src=[REF(src)];software=doorjack;jack=1;sub=0'>Begin Airlock Jacking</a> <br>"
// 	else
// 		dat += "Jack in progress... [hackprogress]% complete.<br>"
// 		dat += "<a href='byond://?src=[REF(src)];software=doorjack;cancel=1;sub=0'>Cancel Airlock Jack</a> <br>"
// 	return dat

// Door Jack - supporting proc
/mob/living/silicon/pai/proc/hackloop()
	var/turf/T = get_turf(src)
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(T.loc)
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress in [T.loc].</b></font>")
		else
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress. Unable to pinpoint location.</b></font>")
	hacking = TRUE

// // Digital Messenger
// /mob/living/silicon/pai/proc/pdamessage()

// 	var/dat = "<h3>Digital Messenger</h3>"
// 	dat += {"<b>Signal/Receiver Status:</b> <A href='byond://?src=[REF(src)];software=pdamessage;toggler=1'>
// 	[(aiPDA.toff) ? "<font color='red'>\[Off\]</font>" : "<font color='green'>\[On\]</font>"]</a><br>
// 	<b>Ringer Status:</b> <A href='byond://?src=[REF(src)];software=pdamessage;ringer=1'>
// 	[(aiPDA.silent) ? "<font color='red'>\[Off\]</font>" : "<font color='green'>\[On\]</font>"]</a><br><br>"}
// 	dat += "<ul>"
// 	if(!aiPDA.toff)
// 		for (var/obj/item/pda/P in get_viewable_pdas())
// 			if (P == aiPDA)
// 				continue
// 			dat += "<li><a href='byond://?src=[REF(src)];software=pdamessage;target=[REF(P)]'>[P]</a>"
// 			dat += "</li>"
// 	dat += "</ul>"
// 	dat += "<br><br>"
// 	dat += "Messages: <hr> [aiPDA.tnote]"
// 	return dat

/mob/living/silicon/pai/proc/softwarePrinter()
	aicamera.paiprint(usr)
