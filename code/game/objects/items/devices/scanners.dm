
/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
MASS SPECTROMETER

*/
/obj/item/device/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	var/on = 0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	w_class = 2
	item_state = "electronic"
	m_amt = 150
	origin_tech = "magnets=1;engineering=1"

/obj/item/device/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = "t-ray[on]"

	if(on)
		processing_objects.Add(src)


/obj/item/device/t_scanner/process()
	if(!on)
		processing_objects.Remove(src)
		return null

	for(var/turf/T in range(1, src.loc) )

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
						if(U.intact)
							O.invisibility = 101

		var/mob/living/M = locate() in T
		if(M && M.invisibility == 2)
			M.invisibility = 0
			spawn(2)
				if(M)
					M.invisibility = INVISIBILITY_LEVEL_TWO


/obj/item/device/healthanalyzer
	name = "health analyzer"
	icon_state = "health"
	item_state = "analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1;

/obj/item/device/healthanalyzer/attack(mob/living/M as mob, mob/living/user as mob)

	// Clumsiness/brain damage check
	if ((CLUMSY in user.mutations || user.getBrainLoss() >= 60) && prob(50))
		user << text("<span class='notice'>You stupidly try to analyze the floor's vitals!</span>")
		user.visible_message(text("<span class='alert'>[user] has analyzed the floor's vitals!</span>"))
		user.show_message(text("<span class='notice'>Analyzing Results for The floor:\n\t Overall Status: Healthy"), 1)
		user.show_message(text("<span class='notice'>\t Damage Specifics: <font color='blue'>0</font>-<font color='green'>0</font>-<font color='#FF8000'>0</font>-<font color='red'>0</font></span>"), 1)
		user.show_message("<span class='notice'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font></span>", 1)
		user.show_message("<span class='notice'>Body Temperature: ???</span>", 1)
		return


	user.visible_message(text("<span class='alert'>[] has analyzed []'s vitals!</span>", user, M))

	healthscan(user, M, mode)

	src.add_fingerprint(user)
	return

// Used by the PDA medical scanner too
/proc/healthscan(var/mob/living/user, var/mob/living/M, var/mode = 1)

	//Damage specifics
	var/oxy_loss = M.getOxyLoss()
	var/tox_loss = M.getToxLoss()
	var/fire_loss = M.getFireLoss()
	var/brute_loss = M.getBruteLoss()
	var/mob_status = (M.stat > 1 ? "<font color='red'>Deceased</font>" : text("[]% healthy", M.health - M.halloss))

	if(M.status_flags & FAKEDEATH)
		mob_status = "<font color='red'>Deceased</font>"
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	user.show_message(text("<span class='notice'>Analyzing Results for []:\n\t Overall Status: []</span>", M, mob_status), 1)
	user.show_message(text("<span class='notice'>\t Damage Specifics: <font color='blue'>[]</font>-<font color='green'>[]</font>-<font color='#FF8000'>[]</font>-<font color='red'>[]</font></span>", oxy_loss, tox_loss, fire_loss, brute_loss), 1)

	user.show_message("<span class='notice'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font></span>", 1)
	user.show_message("<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>", 1)

	// Time of death
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		user.show_message("<span class='notice'>Time of Death:</span> [M.tod]")

	// Organ damage report
	if(istype(M, /mob/living/carbon/human) && mode == 1)
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_organs(1,1)
		user.show_message("<span class='notice'>Localized Damage, <font color='#FF8000'>Burn</font>/<font color='red'>Brute</font>:</span>",1)
		if(length(damaged)>0)
			for(var/obj/item/organ/limb/org in damaged)
				user.show_message(text("<span class='notice'>\t []: []-[]", capitalize(org.getDisplayName()), (org.burn_dam > 0) ? "<font color='#FF8000'>[org.burn_dam]</font>" : 0, (org.brute_dam > 0) ? "<font color='red'>[org.brute_dam]</font></span>" : 0), 1)
		else
			user.show_message("<span class='notice'>\t Limbs are OK.</span>",1)

	// Damage descriptions

	user.show_message(text("<span class='notice'>[] | [] | [] | []</span>", oxy_loss > 50 ? "\red Severe oxygen deprivation detected\blue" : "Subject bloodstream oxygen level normal", tox_loss > 50 ? "\red Dangerous amount of toxins detected\blue" : "Subject bloodstream toxin level minimal", fire_loss > 50 ? "\red Severe burn damage detected\blue" : "Subject burn injury status O.K", brute_loss > 50 ? "\red Severe anatomical damage detected\blue" : "Subject brute-force injury status O.K"), 1)

	if (M.getCloneLoss())
		user.show_message(text("<span class='alert'>Subject appears to have been imperfectly cloned.</span>"), 1)

	for(var/datum/disease/D in M.viruses)
		if(!D.hidden[SCANNER])
			user.show_message(text("<span class='warning'><b>Warning: [D.form] Detected</b>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</span>"))

	if (M.reagents && M.reagents.get_reagent_amount("inaprovaline"))
		user.show_message(text("<span class='notice'>Bloodstream Analysis located [M.reagents:get_reagent_amount("inaprovaline")] units of rejuvenation chemicals.</span>"), 1)
	if (M.getBrainLoss() >= 100 || !M.getorgan(/obj/item/organ/brain))
		user.show_message(text("<span class='alert'>Subject brain function is non-existant.</span>"), 1)
	else if (M.getBrainLoss() >= 60)
		user.show_message(text("<span class='warning'>Severe brain damage detected. Subject likely to have mental retardation.</span>"), 1)
	else if (M.getBrainLoss() >= 10)
		user.show_message(text("<span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span>"), 1)

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			usr << "The scanner now shows specific limb damage."
		if(0)
			usr << "The scanner no longer shows limb damage."


/obj/item/device/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = 2.0
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"

/obj/item/device/analyzer/attack_self(mob/user as mob)

	if (user.stat)
		return

	var/turf/location = user.loc
	if (!( istype(location, /turf) ))
		return

	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	user.show_message("\blue <B>Results:</B>", 1)
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		user.show_message("\blue Pressure: [round(pressure,0.1)] kPa", 1)
	else
		user.show_message("\red Pressure: [round(pressure,0.1)] kPa", 1)
	if(total_moles)
		var/o2_concentration = environment.oxygen/total_moles
		var/n2_concentration = environment.nitrogen/total_moles
		var/co2_concentration = environment.carbon_dioxide/total_moles
		var/plasma_concentration = environment.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		if(abs(n2_concentration - N2STANDARD) < 20)
			user.show_message("\blue Nitrogen: [round(n2_concentration*100)]%", 1)
		else
			user.show_message("\red Nitrogen: [round(n2_concentration*100)]%", 1)

		if(abs(o2_concentration - O2STANDARD) < 2)
			user.show_message("\blue Oxygen: [round(o2_concentration*100)]%", 1)
		else
			user.show_message("\red Oxygen: [round(o2_concentration*100)]%", 1)

		if(co2_concentration > 0.01)
			user.show_message("\red CO2: [round(co2_concentration*100)]%", 1)
		else
			user.show_message("\blue CO2: [round(co2_concentration*100)]%", 1)

		if(plasma_concentration > 0.01)
			user.show_message("\red Plasma: [round(plasma_concentration*100)]%", 1)

		if(unknown_concentration > 0.01)
			user.show_message("\red Unknown: [round(unknown_concentration*100)]%", 1)

		user.show_message("\blue Temperature: [round(environment.temperature-T0C)]&deg;C", 1)

	src.add_fingerprint(user)
	return

/obj/item/device/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2.0
	flags = FPRINT | TABLEPASS| CONDUCT | OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=2;biotech=2"
	var/details = 0
	var/recent_fail = 0

/obj/item/device/mass_spectrometer/New()
	..()
	create_reagents(5)

/obj/item/device/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/device/mass_spectrometer/attack_self(mob/user as mob)
	if (user.stat)
		return
	if (crit_fail)
		user << "\red This device has critically failed and is no longer functional!"
		return
	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				reagents.clear_reagents()
				user << "\red The sample was contaminated! Please insert another sample"
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				break
		var/dat = "Trace Chemicals Found: "
		for(var/R in blood_traces)
			if(prob(reliability))
				if(details)
					dat += "[R] ([blood_traces[R]] units) "
				else
					dat += "[R] "
				recent_fail = 0
			else
				if(recent_fail)
					crit_fail = 1
					reagents.clear_reagents()
					return
				else
					recent_fail = 1
		user << "[dat]"
		reagents.clear_reagents()
	return

/obj/item/device/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"