/*
CONTAINS:
T-RAY
HEALTH ANALYZER
GAS ANALYZER
MASS SPECTROMETER
REAGENT SCANNER
*/

/obj/item/device/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner that can pick up the faintest traces of energy, used to detect the invisible."
	icon_state = "t-ray0"
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = 2
	item_state = "electronic"
	starting_materials = list(MAT_IRON = 150, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = "magnets=1;engineering=1"

	var/on = 0
	var/base_state = "t-ray"
	var/ray_range = 1

/obj/item/device/t_scanner/Destroy()
	if(on)
		processing_objects.Remove(src)
	..()

/obj/item/device/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = "[base_state][on]"

	if(on)
		processing_objects.Add(src)


/obj/item/device/t_scanner/process()
	if(!on)
		processing_objects.Remove(src)
		return null

	for(var/turf/T in trange(ray_range, get_turf(src)))

		if(!T.intact)
			continue

		for(var/obj/O in T.contents)

			if(O.level != 1)
				continue

			if(O.invisibility == 101)
				O.invisibility = 0
				spawn(10)
					if(O)
						var/turf/U = O.loc
						if(U && U.intact)
							O.invisibility = 101
		for(var/mob/living/M in T.contents)
			var/oldalpha = M.alpha
			if(M.alpha < 255 && istype(M))
				M.alpha = 255
				spawn(10)
					if(M)
						M.alpha = oldalpha

		var/mob/living/M = locate() in T
		if(M && M.invisibility == 2)
			M.invisibility = 0
			spawn(10)
				if(M)
					M.invisibility = INVISIBILITY_LEVEL_TWO

/obj/item/device/healthanalyzer
	name = "health analyzer"
	icon_state = "health"
	item_state = "analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 1.0
	throw_speed = 5
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = "magnets=1;biotech=1"
	var/last_reading = null
	var/mode = 1

/obj/item/device/healthanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	if(!user.hallucinating())
		last_reading = healthanalyze(M, user, mode)
	else
		if((M.stat == DEAD || (M.status_flags & FAKEDEATH)))
			user.show_message("<span class='game say'><b>\The [src] beeps</b>, \"It's dead, Jim.\"</span>", MESSAGE_HEAR ,"<span class='notice'>\The [src] glows black.</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] glows [pick("red", "green", "blue", "pink")]! You wonder what that would mean.</span>")
	src.add_fingerprint(user)

/obj/item/device/healthanalyzer/attack_self(mob/living/user as mob)
	. = ..()
	if(.)
		return
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(last_reading)
		to_chat(user, "<span class='bnotice'>Accessing Prior Scan Result</span>")
		to_chat(user, last_reading)

//Note : Used directly by other objects. Could benefit of OOP, maybe ?
proc/healthanalyze(mob/living/M as mob, mob/living/user as mob, var/mode = 0, var/skip_checks = 0, var/silent = 0)
	var/message = ""
	if(!skip_checks)
		if(((M_CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
			user.visible_message("<span class='warning'>[user] analyzes the floor's vitals!</span>", \
			"<span class='warning'>You analyze the floor's vitals!</span>")
			playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
			to_chat(user, {"<span class='notice'>Analyzing Results for the floor:<br>Overall Status: Healthy</span>
Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font>
Damage Specifics: <font color='blue'>0</font> - <font color='green'>0</font> - <font color='#FFA500'>0</font> - <font color='red'>0</font>
<span class='notice'>Body Temperature: ???&deg;C (???&deg;F)</span>
<span class='notice'>Localized Damage, Brute/Burn:</span>
<span class='notice'>No limb damage detected.</span>
Subject bloodstream oxygen level normal | Subject bloodstream toxin level normal | Subject burn injury status clear | Subject brute injury status clear
Blood Level Unknown: ???% ???cl
Subject's pulse: ??? BPM"})
			return
	if(!silent)
		user.visible_message("<span class='notice'>[user] analyzes [M]'s vitals.</span>", \
		"<span class='notice'>You analyze [M]'s vitals.</span>")
		playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
	var/fake_oxy = max(rand(1, 40), M.getOxyLoss(), (300 - (M.getToxLoss() + M.getFireLoss() + M.getBruteLoss())))
	var/OX = M.getOxyLoss() > 50   ? "<b>[M.getOxyLoss()]</b>"   : M.getOxyLoss()
	var/TX = M.getToxLoss() > 50   ? "<b>[M.getToxLoss()]</b>"   : M.getToxLoss()
	var/BU = M.getFireLoss() > 50  ? "<b>[M.getFireLoss()]</b>"  : M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 ? "<b>[M.getBruteLoss()]</b>" : M.getBruteLoss()
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? "<b>[fake_oxy]</b>" : fake_oxy
		message += "<span class='notice'>Analyzing Results for [M]:<br>Overall Status: Dead</span><br>"
	else
		message += "<br><span class='notice'>Analyzing Results for [M]:<br>Overall Status: [M.stat > 1 ? "Dead" : "[M.health - M.halloss]% Healthy"]</span>"
	message += "<br>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font>"
	message += "<br>Damage Specifics: <font color='blue'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>"
	message += "<br><span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>"
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		message += "<br><span class='notice'>Time of Death: [M.tod]</span>"
	if(istype(M, /mob/living/carbon/human) && mode)
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_organs(1, 1)
		message += "<br><span class='notice'>Localized Damage, Brute/Burn:</span>"
		if(length(damaged))
			for(var/datum/organ/external/org in damaged)
				var/organ_msg = "<br>"
				organ_msg += capitalize(org.display_name)
				organ_msg += ": "
				organ_msg += "<font color='red'>[org.brute_dam ? org.brute_dam : 0]</font>"
				organ_msg += "/<font color='#FFA500'>[org.burn_dam ? org.burn_dam : 0]</font>"
				if(org.status & ORGAN_BLEEDING)
					organ_msg += "<span class='danger'>\[BLEEDING\]</span>"
				if(org.status & org.is_peg())
					organ_msg += "<span class='bnotice'>\[WOOD DETECTED?\]</span>"
				if(org.status & org.is_robotic())
					organ_msg += "<span class='bnotice'>\[METAL DETECTED?\]</span>"
				message += organ_msg
		else
			message += "<br><span class='notice'>No limb damage detected.</span>"

	OX = M.getOxyLoss() > 50 ? 	"<font color='blue'><b>Severe oxygen deprivation detected</b></font>"   : "Subject bloodstream oxygen level normal"
	TX = M.getToxLoss() > 50 ? 	"<font color='green'><b>Dangerous amount of toxins detected</b></font>" : "Subject bloodstream toxin level normal"
	BU = M.getFireLoss() > 50 ? 	"<font color='#FFA500'><b>Severe burn damage detected</b></font>"   : "Subject burn injury status clear"
	BR = M.getBruteLoss() > 50 ? "<font color='red'><b>Severe anatomical damage detected</b></font>"    : "Subject brute injury status clear"
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? "<font color='blue'><b>Severe oxygen deprivation detected</b></font>" : "Subject bloodstream oxygen level normal"
	message += ("<br>[OX] | [TX] | [BU] | [BR]")
	if(M.reagents.total_volume)
		message += "<br><span class='warning'>Warning: Unknown substance detected in subject's blood.</span>"
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.virus2.len)
			for(var/ID in C.virus2)
				if(ID in virusDB)
					var/datum/data/record/V = virusDB[ID]
					message += "<br><span class='warning'>Warning: Pathogen [V.fields["name"]] detected in subject's blood. Known antigen : [V.fields["antigen"]]</span>"
				//Canned out to make viruses much harder to notice, I suppose. Too bad we can't port a single functional virus code with visibility stats already
				//else
					//user.show_message(text("<span class='warning'>Warning: Unknown pathogen detected in subject's blood.</span>"))

	if(M.getCloneLoss())
		message += "<br><span class='warning'>Subject appears to have been imperfectly cloned.</span>"
	for(var/datum/disease/D in M.viruses)
		if(!D.hidden[SCANNER])
			message += "<br><span class='warning'><b>Warning: [D.form] Detected</b><br>Name: [D.name].<br>Type: [D.spread].<br>Stage: [D.stage]/[D.max_stages].<br>Possible Cure: [D.cure]</span>"
	if(M.reagents && M.reagents.get_reagent_amount("inaprovaline"))
		message += "<br><span class='notice'>Bloodstream Analysis located [M.reagents:get_reagent_amount("inaprovaline")] units of rejuvenation chemicals.</span>"
	if(M.has_brain_worms())
		message += "<br><span class='warning'>Strange MRI readout. Subject needs further scanning.</span>"
	else if(M.getBrainLoss() >= 100 || !M.has_brain())
		message += "<br><span class='warning'>No brain activity has been detected. Subject is braindead.</span>"
	else if(M.getBrainLoss() >= 60)
		message += "<br><span class='warning'>Severe brain damage detected. Subject likely to have mental retardation.</span>"
	else if(M.getBrainLoss() >= 10)
		message += "<br><span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/name in H.organs_by_name)
			var/datum/organ/external/e = H.organs_by_name[name]
			var/limb = e.display_name
			/*
			 * Doesn't belong here, only the advanced scanner can locate fractures
			if(e.is_broken())
				if((e.name == "l_arm") || (e.name == "r_arm") || (e.name == "l_leg") || (e.name == "r_leg")) //Only these limbs can be splinted
					message += "<br><span class='warning'>Unsecured fracture in subject's [limb]. Splinting recommended for transport.</span>"
			 */
			if(e.has_infected_wound())
				message += "<br><span class='warning'>Infected wound detected in subject's [limb]. Disinfection recommended.</span>"

		for(var/name in H.organs_by_name)
			var/datum/organ/external/e = H.organs_by_name[name]
			if(e.is_broken())
				message += text("<br><span class='warning'>Bone fractures detected. Advanced scan required for location.</span>")
				break
		for(var/datum/organ/external/e in H.organs)
			for(var/datum/wound/W in e.wounds)
				if(W.internal)
					message += text("<br><span class='danger'>Internal bleeding detected. Advanced scan required for location.</span>")
					break
		if(H.vessel)
			var/blood_volume = round(H.vessel.get_reagent_amount("blood"))
			var/blood_percent =  round((blood_volume / 560) * 100)
			switch(blood_volume)
				if(BLOOD_VOLUME_SAFE to 1000000000)
					message += "<br><span class='notice'>Blood Level Normal: [blood_percent]% ([blood_volume]cl)</span>"
				if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
					message += "<br><span class='warning'>Warning: Blood Level Low: [blood_percent]% [blood_volume]cl</span>" //Still about fine
				if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
					message += "<br><span class='danger'>Danger: Blood Level Serious: [blood_percent]% [blood_volume]cl</span>"
				if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
					message += "<br><span class='danger'>Danger: Blood Level Critical: [blood_percent]% [blood_volume]cl</span>"
				if(-1000000000 to BLOOD_VOLUME_SURVIVE)
					message += "<br><span class='danger'>Danger: Blood Level Fatal: [blood_percent]% [blood_volume]cl</span>"
		message += "<br><span class='notice'>Subject's pulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "blue"]'>[H.get_pulse(GETPULSE_TOOL)] BPM</font></span>"
	to_chat(user, message)//Here goes

	return message //To read last scan

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch mode"
	set category = "Object"

	mode = !mode
	to_chat(usr, "The scanner will [mode ? "now show specific limb damage" : "no longer show specific limb damage"].")

/obj/item/device/analyzer
	desc = "A hand-held environment scanner which reports data about gas mixtures."
	name = "atmospheric analyzer"
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = 2.0
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = "magnets=1;engineering=1"

/obj/item/device/analyzer/attack_self(mob/user as mob)

	. = ..()
	if(.)
		return

	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	var/turf/location = get_turf(user)

	if(!location) //Somehow
		return

	var/datum/gas_mixture/environment = location.return_air()

	user << output_gas_scan(environment, location, 1)

	src.add_fingerprint(user)
	return

//If human_standard is enabled, the message will be formatted to show which values are dangerous
/obj/item/device/analyzer/proc/output_gas_scan(var/datum/gas_mixture/scanned, var/atom/container, human_standard = 1)
	if(!scanned)
		return "<span class='warning'>No gas mixture found.</span>"
	scanned.update_values()
	var/pressure = scanned.return_pressure()
	var/total_moles = scanned.total_moles()
	var/message = ""
	if(!container || istype(container, /turf))
		message += "<span class='bnotice'>Results:</span>"
	else
		message += "<span class='bnotice'><B>\icon [container] Results of [container] scan:</span>"
	if(total_moles)
		message += "<br>[human_standard && abs(pressure - ONE_ATMOSPHERE) > 10 ? "<span class='bad'>" : "<span class='notice'>"] Pressure: [round(pressure, 0.1)] kPa</span>"
		var/o2_concentration = scanned.oxygen/total_moles
		var/n2_concentration = scanned.nitrogen/total_moles
		var/co2_concentration = scanned.carbon_dioxide/total_moles
		var/plasma_concentration = scanned.toxins/total_moles

		var/unknown_concentration =  1 - (o2_concentration + n2_concentration + co2_concentration + plasma_concentration)

		if(n2_concentration > 0.01)
			message += "<br>[human_standard && abs(n2_concentration - N2STANDARD) > 20 ? "<span class='bad'>" : "<span class='notice'>"] Nitrogen: [round(scanned.nitrogen, 0.1)] mol, [round(n2_concentration*100)]%</span>"
		if(o2_concentration > 0.01)
			message += "<br>[human_standard && abs(o2_concentration - O2STANDARD) > 2 ? "<span class='bad'>" : "<span class='notice'>"] Oxygen: [round(scanned.oxygen, 0.1)] mol, [round(o2_concentration*100)]%</span>"
		if(co2_concentration > 0.01)
			message += "<br>[human_standard ? "<span class='bad'>" : "<span class='notice'>"] CO2: [round(scanned.carbon_dioxide, 0.1)] mol, [round(co2_concentration*100)]%</span>"
		if(plasma_concentration > 0.01)
			message += "<br>[human_standard ? "<span class='bad'>" : "<span class='notice'>"] Plasma: [round(scanned.toxins, 0.1)] mol, [round(plasma_concentration*100)]%</span>"
		if(unknown_concentration > 0.01)
			message += "<br><span class='notice'>Unknown: [round(unknown_concentration*100)]%</span>"

		message += "<br>[human_standard && !(scanned.temperature in range(BODYTEMP_COLD_DAMAGE_LIMIT, BODYTEMP_HEAT_DAMAGE_LIMIT)) ? "<span class='bad'>" : "<span class='notice'>"] Temperature: [round(scanned.temperature-T0C)]&deg;C"
	else
		message += "<br><span class='warning'>No gasses detected[container && !istype(container, /turf) ? " in \the [container]." : ""]!</span>"
	return message

/obj/item/device/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2.0
	flags = FPRINT | OPENCONTAINER
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=2;biotech=2"
	var/details = 0

/obj/item/device/mass_spectrometer/New()
	. = ..()
	create_reagents(5)

/obj/item/device/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/device/mass_spectrometer/attack(mob/living/M as mob, mob/living/user as mob)
	if(!M.reagents)
		return
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(reagents.total_volume)
			to_chat(user, "<span class='warning'>This device already has a blood sample!</span>")
			return
		if(!user.dexterity_check())
			to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return
		if(!C.dna)
			return
		if(M_NOCLONE in C.mutations)
			return

		var/datum/reagent/B = C.take_blood(src, src.reagents.maximum_volume)
		if(B)
			src.reagents.reagent_list |= B
			src.reagents.update_total()
			src.on_reagent_change()
			src.reagents.handle_reactions()
			update_icon()
			user.visible_message("<span class='warning'>[user] takes a blood sample from [C].</span>", \
			"<span class='notice'>You take a blood sample from [C]</span>")
			playsound(get_turf(src), 'sound/items/hypospray.ogg', 50, 1) //It uses the same thing as the hypospray, in reverse. SCIENCE!

/obj/item/device/mass_spectrometer/attack_self(mob/user as mob)
	. = ..()
	if(.)
		return

	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				reagents.clear_reagents()
				to_chat(user, "<span class='warning'>The sample was contaminated! Please insert another sample.</span>")
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				break
		var/dat
		if(blood_traces.len)
			dat = "Trace Chemicals Found:"
			for(var/R in blood_traces)
				dat += "<br>[R] [details ? "([blood_traces[R]] units)":""]"
		else
			dat = "No trace chemicals found in the sample."
		to_chat(user, "<span class='notice'>[dat]</span>")
		reagents.clear_reagents()
	return

/obj/item/device/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"

/obj/item/device/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2.0
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=2;biotech=2"
	var/details = 0
	var/recent_fail = 0

/obj/item/device/reagent_scanner/afterattack(obj/O, mob/user as mob)
	. = ..()
	if(.)
		return
	if(!istype(O)) //Wrong type sent
		return
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(O.reagents)
		var/dat = ""
		if(O.reagents.reagent_list.len)
			for(var/datum/reagent/R in O.reagents.reagent_list)
				var/reagent_percent = (R.volume/O.reagents.total_volume)*100
				dat += "<br><span class='notice'>[R] [details ? "([R.volume] units, [reagent_percent]%)" : ""]</span>"
		if(dat)
			to_chat(user, "<span class='notice'>Chemicals found in \the [O]:[dat]</span>")
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in \the [O].</span>")

	return

/obj/item/device/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"
