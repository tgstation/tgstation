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
	data["door_jack"] = hacking_cable || null
	data["emagged"] = emagged
	data["image"] = card.emotion_icon
	data["languages"] = languages_granted
	data["master"] = list()
	data["pda"] = list()
	data["ram"] = ram
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
		if("buy")
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
		if("camera_zoom")
			aicamera.adjust_zoom(usr)
		if("change_image")
			var/newImage = tgui_input_list(usr, "Select your new display image.", "Display Image", sort_list(list("Happy", "Cat", "Extremely Happy", "Face", "Laugh", "Off", "Sad", "Angry", "What", "Sunglasses")))
			switch(newImage)
				if(null)
					card.emotion_icon = "null"
				if("Extremely Happy")
					card.emotion_icon = "extremely-happy"
				else
					card.emotion_icon = "[lowertext(newImage)]"
			card.update_appearance()
		if("check_dna")
			if(!master_dna)
				to_chat(src, span_warning("You do not have a master DNA to compare to!"))
				return FALSE
			if(iscarbon(card.loc))
				CheckDNA(card.loc, src) //you should only be able to check when directly in hand, muh immersions?
			else
				to_chat(src, span_warning("You are not being carried by anyone!"))
				return FALSE // FALSE ? If you return here you won't call paiinterface() below
		if("crew_manifest")
			ai_roster()
		if("door_jack")
			if(params["jack"] == "jack")
				if(hacking_cable?.machine)
					hackdoor = hacking_cable.machine
					hackloop()
			if(params["jack"]  == "cancel")
				hackdoor = null
				QDEL_NULL(hacking_cable)
			if(params["jack"]  == "cable")
				extendcable()
		if("encryption_keys")
			encryptmod = !encryptmod
			radio.subspace_transmission = !radio.subspace_transmission
		if("host_scan")
			if(params["scan"] == "scan")
				hostscan()
			if(params["scan"] == "wounds")
				hostscan.attack_self(usr)
			if(params["scan"] == "limbs")
				hostscan.toggle_mode()
		if("internal_gps")
			if(!internal_gps)
				internal_gps = new(src)
			internal_gps.attack_self(src)
		if("loudness_booster")
			if(!internal_instrument)
				internal_instrument = new(src)
			internal_instrument.interact(src) // Open Instrument
		if("medical_hud")
			medHUD = !medHUD
			if(medHUD)
				var/datum/atom_hud/med = GLOB.huds[med_hud]
				med.add_hud_to(src)
			else
				var/datum/atom_hud/med = GLOB.huds[med_hud]
				med.remove_hud_from(src)
		if("medical_records") // Accessing medical records
			medicalActive1 = find_record("id", params, GLOB.data_core.general)
			if(medicalActive1)
				medicalActive2 = find_record("id", params, GLOB.data_core.medical)
			if(!medicalActive2)
				medicalActive1 = null
				to_chat(usr, span_notice("Unable to locate requested security record. Record may have been deleted, or never have existed."))
		if("newscaster")
			newscaster.ui_interact(src)
		if("pda")
			if(!isnull(aiPDA))
				return FALSE
			if(params["pda"] == "power")
				aiPDA.toff = !aiPDA.toff
			if(params["pda"] == "silent")
				aiPDA.silent = !aiPDA.silent
			if(params["pda"] == "message")
				cmd_send_pdamesg(usr)
		if("photography_module")
			aicamera.toggle_camera_mode(usr)
		if("printer_module")
			aicamera.paiprint(usr)
		if("radio")
			radio.attack_self(src)
		if("remote_signaler")
			signaler.ui_interact(src)
		if("security_hud")
			secHUD = !secHUD
			if(secHUD)
				var/datum/atom_hud/sec = GLOB.huds[sec_hud]
				sec.add_hud_to(src)
			else
				var/datum/atom_hud/sec = GLOB.huds[sec_hud]
				sec.remove_hud_from(src)
		if("security_records")
			securityActive1 = find_record("id", params, GLOB.data_core.general)
			if(securityActive1)
				securityActive2 = find_record("id", params, GLOB.data_core.security)
			if(!securityActive2)
				securityActive1 = null
				to_chat(usr, span_notice("Unable to locate requested security record. Record may have been deleted, or never have existed."))
		if("universal_translator")
			if(!languages_granted)
				grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_SOFTWARE)
				languages_granted = TRUE
	return

/mob/living/silicon/pai/proc/CheckDNA(mob/living/carbon/M, mob/living/silicon/pai/P)
	if(!istype(M))
		return
	to_chat(P, span_notice("Requesting a DNA sample."))
	var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
	if(answer == "Yes")
		M.visible_message(span_notice("[M] presses [M.p_their()] thumb against [P]."),\
						span_notice("You press your thumb against [P]."),\
						span_notice("[P] makes a sharp clicking sound as it extracts DNA material from [M]."))
		if(!M.has_dna())
			to_chat(P, "<b>No DNA detected.</b>")
			return
		to_chat(P, "<font color = red><h3>[M]'s UE string : [M.dna.unique_enzymes]</h3></font>")
		if(M.dna.unique_enzymes == P.master_dna)
			to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
		else
			to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
	else
		to_chat(P, span_warning("[M] does not seem like [M.p_theyre()] going to provide a DNA sample willingly."))

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

// Host Scan supporting proc
/mob/living/silicon/pai/proc/hostscan()
	var/mob/living/silicon/pai/pAI = usr
	var/mob/living/carbon/holder = get(pAI.card.loc, /mob/living/carbon)
	if(holder)
		pAI.hostscan.attack(holder, pAI)
	else
		to_chat(usr, span_warning("You are not being carried by anyone!"))
		return FALSE

// Extend cable supporting proc
/mob/living/silicon/pai/proc/extendcable()
	QDEL_NULL(hacking_cable) //clear any old cables
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

// Door Jack - supporting proc
/mob/living/silicon/pai/proc/hackloop()
	var/mob/living/silicon/pai/pai = usr
	pai.visible_message(span_notice("Brute-force security override in progress..."), span_notice("You begin overriding the airlock security protocols."), span_hear("You hear the faint buzzing coming from inside a door."))
	var/turf/T = get_turf(src)
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(T.loc)
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force security override in progress in [T.loc].</b></font>")
		else
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force security override in progress. Unable to pinpoint location.</b></font>")
	hacking = TRUE
