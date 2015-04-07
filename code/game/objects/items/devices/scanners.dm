
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
	slot_flags = SLOT_BELT
	w_class = 2
	item_state = "electronic"
	m_amt = 150
	origin_tech = "magnets=1;engineering=1"

/obj/item/device/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = copytext(icon_state, 1, length(icon_state))+"[on]"

	if(on)
		SSobj.processing |= src


/obj/item/device/t_scanner/process()
	if(!on)
		SSobj.processing.Remove(src)
		return null
	scan()

/obj/item/device/t_scanner/proc/scan()

	for(var/turf/T in range(2, src.loc) )

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
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 1.0
	throw_speed = 3
	throw_range = 7
	m_amt = 200
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1
	var/scanchems = 0

/obj/item/device/healthanalyzer/attack_self(mob/user)
	if(!scanchems)
		user << "<span class = 'notice'>You switch the health analyzer to scan chemical contents.</span>"
		scanchems = 1
	else
		user << "<span class = 'notice'>You switch the health analyzer to check physical health.</span>"
		scanchems = 0
	return
/obj/item/device/healthanalyzer/attack(mob/living/M as mob, mob/living/carbon/human/user as mob)

	// Clumsiness/brain damage check
	if ((user.disabilities & CLUMSY || user.getBrainLoss() >= 60) && prob(50))
		user << "<span class='notice'>You stupidly try to analyze the floor's vitals!</span>"
		user.visible_message("<span class='warning'>[user] has analyzed the floor's vitals!</span>")
		user.show_message("<span class='notice'>Analyzing Results for The floor:\n\t Overall Status: Healthy", 1)
		user.show_message("<span class='notice'>\t Damage Specifics: <font color='blue'>0</font>-<font color='green'>0</font>-<font color='#FF8000'>0</font>-<font color='red'>0</font></span>", 1)
		user.show_message("<span class='notice'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font></span>", 1)
		user.show_message("<span class='notice'>Body Temperature: ???</span>", 1)
		return


	user.visible_message("<span class='notice'>[user] has analyzed [M]'s vitals.</span>")

	if(!scanchems)
		healthscan(user, M, mode)
	else
		chemscan(user, M)

	src.add_fingerprint(user)
	return

// Used by the PDA medical scanner too
/proc/healthscan(var/mob/living/user, var/mob/living/M, var/mode = 1)

	//Damage specifics
	var/oxy_loss = M.getOxyLoss()
	var/tox_loss = M.getToxLoss()
	var/fire_loss = M.getFireLoss()
	var/brute_loss = M.getBruteLoss()
	var/mob_status = (M.stat > 1 ? "<font color='red'>Deceased</font>" : "[M.health]% healthy")

	if(M.status_flags & FAKEDEATH)
		mob_status = "<font color='red'>Deceased</font>"
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.heart_attack)
			user.show_message("<span class='userdanger'>Subject suffering from heart attack: Apply defibrillator immediately.</span>")
	user.show_message(text("<span class='notice'>Analyzing Results for []:\n\t Overall Status: []</span>", M, mob_status), 1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna)// Show target's species, if they have one
			user.show_message("<span class='notice'>Species: <b>[H.dna.species.name]</b></span>", 1)
		else // Otherwise we can assume that they are a regular human
			user.show_message("<span class='notice'>Species: <b>Human</b></span>", 1)
	user.show_message("<span class='notice'>\t Damage Specifics: <font color='blue'>[oxy_loss]</font>-<font color='green'>[tox_loss]</font>-<font color='#FF8000'>[fire_loss]</font>-<font color='red'>[brute_loss]</font></span>", 1)
	user.show_message("<span class='notice'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font></span>", 1)
	user.show_message("<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>", 1)

	// Time of death
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		user.show_message("<span class='notice'>Time of Death:</span> [M.tod]", 1)

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

	user.show_message(text("<span class='notice'>[] | [] | [] | []</span>", oxy_loss > 50 ? "<span class='warning'> Severe oxygen deprivation detected</span>" : "<span class='info'>Subject bloodstream oxygen level normal</span>", tox_loss > 50 ? "<span class='warning'> Dangerous amount of toxins detected</span>" : "<span class='info'>Subject bloodstream toxin level minimal</span>", fire_loss > 50 ? "<span class='warning'> Severe burn damage detected</span>" : "<span class='info'>Subject burn injury status O.K</span>", brute_loss > 50 ? "<span class='warning'> Severe tissue damage detected</span>" : "<span class='info'>Subject brute-force injury status O.K</span>"), 1)

	if(M.getStaminaLoss())
		user.show_message("<span class='info'>Subject appears to be suffering from fatigue.</span>", 1)

	if (M.getCloneLoss())
		user.show_message("<span class='warning'>Subject appears to have [M.getCloneLoss() > 30 ? "severe" : "minor"] cellular damage.</span>", 1)

	for(var/datum/disease/D in M.viruses)
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			user.show_message("<span class='warning'><b>Warning: [D.form] Detected</b>\nName: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]</span>", 1)

	if (M.reagents && M.reagents.get_reagent_amount("epinephrine"))
		user.show_message("<span class='notice'>Bloodstream Analysis located [M.reagents:get_reagent_amount("epinephrine")] units of rejuvenation chemicals.</span>", 1)
	if (M.getBrainLoss() >= 100 || !M.getorgan(/obj/item/organ/brain))
		user.show_message("<span class='warning'>Subject brain function is non-existant.</span>", 1)
	else if (M.getBrainLoss() >= 60)
		user.show_message("<span class='warning'>Severe brain damage detected. Subject likely to have mental retardation.</span>", 1)
	else if (M.getBrainLoss() >= 10)
		user.show_message("<span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span>", 1)

	// Blood Level
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.vessel)
			if(H.blood_max)
				user.show_message("<span class='danger'>Subject is bleeding!</span>")
			var/blood_volume = round(H.vessel.get_reagent_amount("blood"))
			var/blood_percent =  blood_volume / 560
			var/blood_type = H.dna.blood_type
			blood_percent *= 100
			if(blood_volume <= 500 && blood_volume > 336)
				user.show_message("<span class='danger'>Warning: Blood Level LOW: [blood_percent]% [blood_volume]cl.</span> <span class='notice'>Type: [blood_type]</span>")
			else if(blood_volume <= 336)
				user.show_message("<span class='danger'>Warning: Blood Level CRITICAL: [blood_percent]% [blood_volume]cl.</span> <span class='notice'>Type: [blood_type]</span>")
			else
				user.show_message("<span class='notice'>Blood Level Normal: [blood_percent]% [blood_volume]cl. Type: [blood_type]</span>")

/proc/chemscan(var/mob/living/user, var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.reagents)
			if(H.reagents.reagent_list.len)
				user.show_message("<span class='notice'>Subject contains the following reagents:</span>")
				for(var/datum/reagent/R in H.reagents.reagent_list)
					user.show_message("<span class='notice'>[R.volume]u of [R.name][R.overdosed == 1 ? "</span> - <span class = 'boldannounce'>OVERDOSING</span>" : ".</span>"]")
			else
				user.show_message("<span class = 'notice'>Subject contains no reagents.</span>")
			if(H.reagents.addiction_list.len)
				user.show_message("<span class='boldannounce'>Subject is addicted to the following reagents:</span>")
				for(var/datum/reagent/R in H.reagents.addiction_list)
					user.show_message("<span class='danger'>[R.name]</span>")
			else
				user.show_message("<span class='notice'>Subject is not addicted to any reagents.</span>")

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	if(usr.stat || !usr.canmove || usr.restrained())
		return

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
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
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

	user.show_message("<span class='info'> <B>Results:</B></span>", 1)
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		user.show_message("<span class='info'> Pressure: [round(pressure,0.1)] kPa</span>", 1)
	else
		user.show_message("<span class='warning'> Pressure: [round(pressure,0.1)] kPa</span>", 1)
	if(total_moles)
		var/o2_concentration = environment.oxygen/total_moles
		var/n2_concentration = environment.nitrogen/total_moles
		var/co2_concentration = environment.carbon_dioxide/total_moles
		var/plasma_concentration = environment.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		if(abs(n2_concentration - N2STANDARD) < 20)
			user.show_message("<span class='info'> Nitrogen: [round(n2_concentration*100)]%</span>", 1)
		else
			user.show_message("<span class='warning'> Nitrogen: [round(n2_concentration*100)]%</span>", 1)

		if(abs(o2_concentration - O2STANDARD) < 2)
			user.show_message("<span class='info'> Oxygen: [round(o2_concentration*100)]%</span>", 1)
		else
			user.show_message("<span class='warning'> Oxygen: [round(o2_concentration*100)]%</span>", 1)

		if(co2_concentration > 0.01)
			user.show_message("<span class='warning'> CO2: [round(co2_concentration*100)]%</span>", 1)
		else
			user.show_message("<span class='info'> CO2: [round(co2_concentration*100)]%</span>", 1)

		if(plasma_concentration > 0.01)
			user.show_message("<span class='info'> Plasma: [round(plasma_concentration*100)]%</span>", 1)

		if(unknown_concentration > 0.01)
			user.show_message("<span class='warning'> Unknown: [round(unknown_concentration*100)]%</span>", 1)

		user.show_message("<span class='info'> Temperature: [round(environment.temperature-T0C)]&deg;C</span>", 1)

	src.add_fingerprint(user)
	return

/obj/item/device/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2.0
	flags = CONDUCT | OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
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
		user << "<span class='warning'> This device has critically failed and is no longer functional!</span>"
		return
	if (!user.IsAdvancedToolUser())
		user << "<span class='warning'> You don't have the dexterity to do this!</span>"
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				reagents.clear_reagents()
				user.show_message("<span class='warning'> The sample was contaminated! Please insert another sample.</span>", 1)
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				break
		var/dat = "<i><b>Trace Chemicals Found:</b>"
		if(!blood_traces.len)
			dat += "<br>None"
		else
			for(var/R in blood_traces)
				if(prob(reliability))
					dat += "<br>[chemical_reagents_list[R]]"

					if(details)
						dat += " ([blood_traces[R]] units)"

					recent_fail = 0
				else
					if(recent_fail)
						crit_fail = 1
						reagents.clear_reagents()
						return
					else
						recent_fail = 1
		dat += "</i>"
		user << dat
		reagents.clear_reagents()
	return

/obj/item/device/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"

/obj/item/device/slime_scanner
	name = "slime scanner"
	icon_state = "adv_spectrometer"
	item_state = "analyzer"
	origin_tech = "biotech=1"
	w_class = 2.0
	flags = CONDUCT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	m_amt = 30
	g_amt = 20

/obj/item/device/slime_scanner/attack(mob/living/M as mob, mob/living/user as mob)
	if (!isslime(M))
		user.show_message("<span class='warning'>This device can only scan slimes!</span>", 1)
		return
	var/mob/living/simple_animal/slime/T = M
	user.show_message("Slime scan results:", 1)
	user.show_message(text("[T.colour] [] slime", T.is_adult ? "adult" : "baby"), 1)
	user.show_message(text("Nutrition: [T.nutrition]/[]", T.get_max_nutrition()), 1)
	if (T.nutrition < T.get_starve_nutrition())
		user.show_message("<span class='warning'>Warning: slime is starving!</span>", 1)
	else if (T.nutrition < T.get_hunger_nutrition())
		user.show_message("<span class='warning'>Warning: slime is hungry</span>", 1)
	user.show_message("Electric change strength: [T.powerlevel]", 1)
	user.show_message("Health: [T.health]", 1)
	if (T.slime_mutation[4] == T.colour)
		user.show_message("This slime does not evolve any further.", 1)
	else
		if (T.slime_mutation[3] == T.slime_mutation[4])
			if (T.slime_mutation[2] == T.slime_mutation[1])
				user.show_message("Possible mutation: [T.slime_mutation[3]]", 1)
				user.show_message("Genetic destability: [T.mutation_chance/2]% chance of mutation on splitting", 1)
			else
				user.show_message("Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)", 1)
				user.show_message("Genetic destability: [T.mutation_chance]% chance of mutation on splitting", 1)
		else
			user.show_message("Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]", 1)
			user.show_message("Genetic destability: [T.mutation_chance]% chance of mutation on splitting", 1)
	if (T.cores > 1)
		user.show_message("Anomalious slime core amount detected", 1)
	user.show_message("Growth progress: [T.amount_grown]/10", 1)
