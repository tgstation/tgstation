/obj/item/verbs/borer/attached_chest/verb/borer_speak(var/message as text)
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your bretheren"

	if(!message)
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.borer_speak(message)

/obj/item/verbs/borer/attached_chest/verb/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.evolve()

/obj/item/verbs/borer/attached_chest/verb/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.secrete_chemicals()

/obj/item/verbs/borer/attached_chest/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.abandon_host()

/obj/item/verbs/borer/attached_chest/verb/advanced_analyze_host()
	set category = "Alien"
	set name = "Advanced Host Analysis"
	set desc = "An in-depth check of the host's physical status."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.advanced_analyze_host()

/mob/living/simple_animal/borer/proc/advanced_analyze_host()
	set name = "Advanced Host Analysis"
	set desc = "An in-depth check of the host's physical status."
	set category = "Alien"

	if(!check_can_do())
		return

	to_chat(src, "<span class='info'>You listen to the song of your host's nervous system, hunting for dischordant notes...</span>")
	spawn(5 SECONDS)
		var/dat
		dat = format_host_data(get_host_data())
		src << browse(dat, "window=borerscan;size=430x600")
		return

/mob/living/simple_animal/borer/proc/get_host_data()
	if (!host)
		return
	if(!istype(host, /mob/living/carbon/human))
		to_chat(src, "<span class='warning'>You can't seem to interpret your host's strange biology.</span>")
		return
	var/mob/living/carbon/human/H = host
	var/list/host_data = list(
		"stat" = H.stat,
		"health" = H.health,
		"virus_present" = H.virus2.len,
		"rads" = H.radiation,
		"cloneloss" = H.getCloneLoss(),
		"brainloss" = H.getBrainLoss(),
		"paralysis" = H.paralysis,
		"bodytemp" = H.bodytemperature,
		"borer_present_head" = H.has_brain_worms(),
		"borer_present_chest" = H.has_brain_worms(LIMB_CHEST),
		"borer_present_r_arm" = H.has_brain_worms(LIMB_RIGHT_ARM),
		"borer_present_l_arm" = H.has_brain_worms(LIMB_LEFT_ARM),
		"borer_present_r_leg" = H.has_brain_worms(LIMB_RIGHT_LEG),
		"borer_present_l_leg" = H.has_brain_worms(LIMB_LEFT_LEG),
		"inaprovaline_amount" = H.reagents.get_reagent_amount(INAPROVALINE),
		"dexalin_amount" = H.reagents.get_reagent_amount(DEXALIN),
		"stoxin_amount" = H.reagents.get_reagent_amount(STOXIN),
		"bicaridine_amount" = H.reagents.get_reagent_amount(BICARIDINE),
		"dermaline_amount" = H.reagents.get_reagent_amount(DERMALINE),
		"blood_amount" = H.vessel.get_reagent_amount(BLOOD),
		"all_chems" = H.reagents.reagent_list,
		"btype" = H.dna.b_type,
		"disabilities" = H.sdisabilities,
		"tg_diseases_list" = H.viruses,
		"lung_ruptured" = H.is_lung_ruptured(),
		"external_organs" = H.organs.Copy(),
		"internal_organs" = H.internal_organs.Copy()
		)
	return host_data


/mob/living/simple_animal/borer/proc/format_host_data(var/list/occ)
	var/dat = "<font color='blue'><b>Host Statistics:</b></font><br>"
	var/aux
	switch (occ["stat"])
		if(0)
			aux = "Conscious"
		if(1)
			aux = "Unconscious"
		else
			aux = "Dead"
	dat += text("[]\tHealth %: [] ([])</font><br>", (occ["health"] > 50 ? "<font color='blue'>" : "<font color='red'>"), occ["health"], aux)
	if(occ["virus_present"])
		dat += "<font color='red'>Viral pathogen detected in blood stream.</font><br>"
	dat += text("[]\tRadiation Level %: []</font><br>", (occ["rads"] < 10 ?"<font color='blue'>" : "<font color='red'>"), occ["rads"])
	dat += text("[]\tGenetic Tissue Damage %: []</font><br>", (occ["cloneloss"] < 1 ?"<font color='blue'>" : "<font color='red'>"), occ["cloneloss"])
	dat += text("[]\tApprox. Brain Damage %: []</font><br>", (occ["brainloss"] < 1 ?"<font color='blue'>" : "<font color='red'>"), occ["brainloss"])
	dat += text("Paralysis Summary %: [] ([] seconds left!)<br>", occ["paralysis"], round(occ["paralysis"] / 4))
	dat += text("Body Temperature: [occ["bodytemp"]-T0C]&deg;C ([occ["bodytemp"]*1.8-459.67]&deg;F)<br><HR>")

	if(occ["borer_present_head"])
		var/mob/living/simple_animal/borer/B = occ["borer_present_head"]
		dat += "Borer known as [B.truename] present in frontal lobe.<br>"
	if(occ["borer_present_chest"])
		var/mob/living/simple_animal/borer/B = occ["borer_present_chest"]
		dat += "Borer known as [B.truename] present in chest cavity.<br>"
	if(occ["borer_present_r_arm"])
		var/mob/living/simple_animal/borer/B = occ["borer_present_r_arm"]
		dat += "Borer known as [B.truename] present in right arm.<br>"
	if(occ["borer_present_l_arm"])
		var/mob/living/simple_animal/borer/B = occ["borer_present_l_arm"]
		dat += "Borer known as [B.truename] present in left arm.<br>"
	if(occ["borer_present_r_leg"])
		var/mob/living/simple_animal/borer/B = occ["borer_present_r_leg"]
		dat += "Borer known as [B.truename] present in right leg.<br>"
	if(occ["borer_present_l_leg"])
		var/mob/living/simple_animal/borer/B = occ["borer_present_l_leg"]
		dat += "Borer known as [B.truename] present in left leg.<br>"

	dat += text("[]\tBlood Level %: [] ([] units)</FONT><BR>", (occ["blood_amount"] > 448 ?"<font color='blue'>" : "<font color='red'>"), occ["blood_amount"]*100 / 560, occ["blood_amount"])

	dat += text("<font color='blue'>\tBlood Type: []</FONT><BR>", occ["btype"])

	dat += text("Inaprovaline: [] units<BR>", occ["inaprovaline_amount"])
	dat += text("Soporific: [] units<BR>", occ["stoxin_amount"])
	dat += text("[]\tDermaline: [] units</FONT><BR>", (occ["dermaline_amount"] < 30 ? "<font color='black'>" : "<font color='red'>"), occ["dermaline_amount"])
	dat += text("[]\tBicaridine: [] units<BR>", (occ["bicaridine_amount"] < 30 ? "<font color='black'>" : "<font color='red'>"), occ["bicaridine_amount"])
	dat += text("[]\tDexalin: [] units<BR>", (occ["dexalin_amount"] < 30 ? "<font color='black'>" : "<font color='red'>"), occ["dexalin_amount"])

	for(var/datum/reagent/R in occ["all_chems"])
		if(R.id == BLOOD || R.id == INAPROVALINE || R.id == STOXIN || R.id == DERMALINE || R.id == BICARIDINE || R.id == DEXALIN) continue //no repeats
		else
			dat += text("<font color='black'>Detected</font> <font color='blue'>[R.volume]</font> <font color='black'>units of</font> <font color='blue'>[R.name]</font><BR>")
	for(var/datum/disease/D in occ["tg_diseases_list"])
		if(!D.hidden[SCANNER])
			dat += text("<BR><font color='red'><B>Warning: [D.form] Detected</B>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</FONT><BR>")

	dat += "<HR><table border='1'>"
	dat += "<tr>"
	dat += "<th>Organ</th>"
	dat += "<th>Burn Damage</th>"
	dat += "<th>Brute Damage</th>"
	dat += "<th>Other Wounds</th>"
	dat += "</tr>"

	for(var/datum/organ/external/e in occ["external_organs"])
		var/AN = ""
		var/open = ""
		var/infected = ""
		var/imp = ""
		var/bled = ""
		var/robot = ""
		var/splint = ""
		var/internal_bleeding = ""
		var/lung_ruptured = ""

		dat += "<tr>"

		for(var/datum/wound/W in e.wounds)
			if(W.internal)
				internal_bleeding = "<br>Internal bleeding"
				break
		if(istype(e, /datum/organ/external/chest) && occ["lung_ruptured"])
			lung_ruptured = "Lung ruptured:"
		if(e.status & ORGAN_SPLINTED)
			splint = "Splinted:"
		if(e.status & ORGAN_BLEEDING)
			bled = "Bleeding:"
		if(e.status & ORGAN_BROKEN)
			AN = "[e.broken_description]:"
		if(e.status & ORGAN_ROBOT)
			robot = "Prosthetic:"
		if(e.open)
			open = "Open:"

		switch (e.germ_level)
			if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
				infected = "Mild Infection:"
			if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infected = "Mild Infection+:"
			if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infected = "Mild Infection++:"
			if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
				infected = "Acute Infection:"
			if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infected = "Acute Infection+:"
			if (INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 400)
				infected = "Acute Infection++:"
			if (INFECTION_LEVEL_THREE to INFINITY)
				infected = "Septic:"

		var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/loyalty, /obj/item/weapon/implant/tracking)
		if(e.implants.len)
			var/unknown_body = 0
			for(var/I in e.implants)
				if(is_type_in_list(I,known_implants))
					imp += "[I] implanted:"
				else if(!istype(I, /mob/living/simple_animal/borer))
					unknown_body++
			if(unknown_body || e.hidden)
				imp += "Unknown body present:"

		if(!AN && !open && !infected & !imp)
			AN = "None:"
		if(!(e.status & ORGAN_DESTROYED))
			dat += "<td>[e.display_name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured]</td>"
		else
			dat += "<td>[e.display_name]</td><td>-</td><td>-</td><td>Not Found</td>"
		dat += "</tr>"

	for(var/datum/organ/internal/i in occ["internal_organs"])
		var/mech = ""
		if(i.robotic == 1)
			mech = "Assisted:"
		if(i.robotic == 2)
			mech = "Mechanical:"

		var/infection = "None"
		switch (i.germ_level)
			if (1 to INFECTION_LEVEL_ONE + 200)
				infection = "Mild Infection:"
			if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infection = "Mild Infection+:"
			if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infection = "Mild Infection++:"
			if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
				infection = "Acute Infection:"
			if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infection = "Acute Infection+:"
			if (INFECTION_LEVEL_TWO + 300 to INFINITY)
				infection = "Acute Infection++:"

		dat += "<tr>"
		dat += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>[infection]:[mech]</td><td></td>"
		dat += "</tr>"
	dat += "</table>"

	if(occ["sdisabilities"] & BLIND)
		dat += text("<font color='red'>Cataracts detected.</font><BR>")
	if(occ["sdisabilities"] & NEARSIGHTED)
		dat += text("<font color='red'>Retinal misalignment detected.</font><BR>")
	return dat

/obj/item/verbs/borer/attached_chest/brute_resist/verb/brute_resist()
	set category = "Alien"
	set name = "Brute Damage Resistance"
	set desc = "Expend chemicals constantly in order to mitigate brute damage done to your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.brute_resist()

/mob/living/simple_animal/borer/proc/brute_resist()
	set category = "Alien"
	set name = "Brute Damage Resistance"
	set desc = "Expend chemicals constantly in order to mitigate brute damage done to your host."

	var/damage_reduction = 0.25

	if(!check_can_do(0))
		return

	if(channeling && !channeling_brute_resist)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to elevate your host's physical damage resistance.")
		channeling = 0
		channeling_brute_resist = 0
	else if(chemicals < 5)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		to_chat(src, "You begin to focus your efforts on elevating your host's resistance to physical damage.")
		channeling = 1
		channeling_brute_resist = 1
		host.brute_damage_modifier -= damage_reduction
		spawn()
			var/time_spent_channeling = 0
			while(chemicals >=5 && channeling && channeling_brute_resist)
				chemicals -= 5
				time_spent_channeling++
				sleep(10)
			host.brute_damage_modifier += damage_reduction
			channeling = 0
			channeling_brute_resist = 0
			var/showmessage = 0
			if(chemicals < 5)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
			else
				showmessage = 1
			passout(time_spent_channeling, showmessage)

/obj/item/verbs/borer/attached_chest/burn_resist/verb/burn_resist()
	set category = "Alien"
	set name = "Burn Damage Resistance"
	set desc = "Expend chemicals constantly in order to mitigate burn damage done to your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.burn_resist()

/mob/living/simple_animal/borer/proc/burn_resist()
	set category = "Alien"
	set name = "Burn Damage Resistance"
	set desc = "Expend chemicals constantly in order to mitigate burn damage done to your host."

	var/damage_reduction = 0.25

	if(!check_can_do(0))
		return

	if(channeling && !channeling_burn_resist)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to elevate your host's physical damage resistance.")
		channeling = 0
		channeling_burn_resist = 0
	else if(chemicals < 5)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		to_chat(src, "You begin to focus your efforts on elevating your host's resistance to physical damage.")
		channeling = 1
		channeling_burn_resist = 1
		host.burn_damage_modifier -= damage_reduction
		spawn()
			var/time_spent_channeling = 0
			while(chemicals >=5 && channeling && channeling_burn_resist)
				chemicals -= 5
				time_spent_channeling++
				sleep(10)
			host.burn_damage_modifier += damage_reduction
			channeling = 0
			channeling_burn_resist = 0
			var/showmessage = 0
			if(chemicals < 5)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
			else
				showmessage = 1
			passout(time_spent_channeling, showmessage)