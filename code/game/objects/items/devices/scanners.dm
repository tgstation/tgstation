<<<<<<< HEAD

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
	materials = list(MAT_METAL=150)
	origin_tech = "magnets=1;engineering=1"

/obj/item/device/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = copytext(icon_state, 1, length(icon_state))+"[on]"

	if(on)
		START_PROCESSING(SSobj, src)

/obj/item/device/t_scanner/proc/flick_sonar(obj/pipe)
	var/image/I = image('icons/effects/effects.dmi', pipe, "blip", pipe.layer+1)
	I.alpha = 128
	var/list/nearby = list()
	for(var/mob/M in viewers(pipe))
		if(M.client)
			nearby |= M.client
	flick_overlay(I,nearby,8)

/obj/item/device/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/device/t_scanner/proc/scan()

	for(var/turf/T in range(2, src.loc) )
		for(var/obj/O in T.contents)

			if(O.level != 1)
				continue

			var/mob/living/L = locate() in O

			if(O.invisibility == INVISIBILITY_MAXIMUM)
				O.invisibility = 0
				if(L)
					flick_sonar(O)
				spawn(10)
					if(O && O.loc)
						var/turf/U = O.loc
						if(U.intact)
							O.invisibility = INVISIBILITY_MAXIMUM
			else
				if(L)
					flick_sonar(O)


/obj/item/device/healthanalyzer
	name = "health analyzer"
	icon_state = "health"
	item_state = "analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 1
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=200)
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1
	var/scanmode = 0

/obj/item/device/healthanalyzer/attack_self(mob/user)
	if(!scanmode)
		user << "<span class='notice'>You switch the health analyzer to scan chemical contents.</span>"
		scanmode = 1
	else
		user << "<span class='notice'>You switch the health analyzer to check physical health.</span>"
		scanmode = 0

/obj/item/device/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)

	// Clumsiness/brain damage check
	if ((user.disabilities & CLUMSY || user.getBrainLoss() >= 60) && prob(50))
		user << "<span class='notice'>You stupidly try to analyze the floor's vitals!</span>"
		user.visible_message("<span class='warning'>[user] has analyzed the floor's vitals!</span>")
		user << "<span class='info'>Analyzing results for The floor:\n\tOverall status: <b>Healthy</b>"
		user << "<span class='info'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font></span>"
		user << "<span class='info'>\tDamage specifics: <font color='blue'>0</font>-<font color='green'>0</font>-<font color='#FF8000'>0</font>-<font color='red'>0</font></span>"
		user << "<span class='info'>Body temperature: ???</span>"
		return

	user.visible_message("<span class='notice'>[user] has analyzed [M]'s vitals.</span>")

	if(scanmode == 0)
		healthscan(user, M, mode)
	else if(scanmode == 1)
		chemscan(user, M)

	add_fingerprint(user)


// Used by the PDA medical scanner too
/proc/healthscan(mob/living/user, mob/living/M, mode = 1)
	if(user.stat || user.eye_blind)
		return
	//Damage specifics
	var/oxy_loss = M.getOxyLoss()
	var/tox_loss = M.getToxLoss()
	var/fire_loss = M.getFireLoss()
	var/brute_loss = M.getBruteLoss()
	var/mob_status = (M.stat > 1 ? "<span class='alert'><b>Deceased</b></span>" : "<b>[round(M.health/M.maxHealth,0.01)*100] % healthy</b>")

	if(M.status_flags & FAKEDEATH)
		mob_status = "<span class='alert'>Deceased</span>"
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.heart_attack && H.stat != DEAD)
			user << "<span class='danger'>Subject suffering from heart attack: Apply defibrillator immediately!</span>"
	user << "<span class='info'>Analyzing results for [M]:\n\tOverall status: [mob_status]</span>"

	// Damage descriptions
	if(brute_loss > 10)
		user << "\t<span class='alert'>[brute_loss > 50 ? "Severe" : "Minor"] tissue damage detected.</span>"
	if(fire_loss > 10)
		user << "\t<span class='alert'>[fire_loss > 50 ? "Severe" : "Minor"] burn damage detected.</span>"
	if(oxy_loss > 10)
		user << "\t<span class='info'><span class='alert'>[oxy_loss > 50 ? "Severe" : "Minor"] oxygen deprivation detected.</span>"
	if(tox_loss > 10)
		user << "\t<span class='alert'>[tox_loss > 50 ? "Critical" : "Dangerous"] amount of toxins detected.</span>"
	if(M.getStaminaLoss())
		user << "\t<span class='alert'>Subject appears to be suffering from fatigue.</span>"
	if (M.getCloneLoss())
		user << "\t<span class='alert'>Subject appears to have [M.getCloneLoss() > 30 ? "severe" : "minor"] cellular damage.</span>"
	if (M.reagents && M.reagents.get_reagent_amount("epinephrine"))
		user << "\t<span class='info'>Bloodstream analysis located [M.reagents:get_reagent_amount("epinephrine")] units of rejuvenation chemicals.</span>"
	if (M.getBrainLoss() >= 100 || !M.getorgan(/obj/item/organ/brain))
		user << "\t<span class='alert'>Subject brain function is non-existent.</span>"
	else if (M.getBrainLoss() >= 60)
		user << "\t<span class='alert'>Severe brain damage detected. Subject likely to have mental retardation.</span>"
	else if (M.getBrainLoss() >= 10)
		user << "\t<span class='alert'>Brain damage detected. Subject may have had a concussion.</span>"

	// Organ damage report
	if(istype(M, /mob/living/carbon/human) && mode == 1)
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_bodyparts(1,1)
		if(length(damaged)>0 || oxy_loss>0 || tox_loss>0 || fire_loss>0)
			user << "<span class='info'>\tDamage: <span class='info'><font color='red'>Brute</font></span>-<font color='#FF8000'>Burn</font>-<font color='green'>Toxin</font>-<font color='blue'>Suffocation</font>\n\t\tSpecifics: <font color='red'>[brute_loss]</font>-<font color='#FF8000'>[fire_loss]</font>-<font color='green'>[tox_loss]</font>-<font color='blue'>[oxy_loss]</font></span>"
			for(var/obj/item/bodypart/org in damaged)
				user << "\t\t<span class='info'>[capitalize(org.name)]: [(org.brute_dam > 0) ? "<font color='red'>[org.brute_dam]</font></span>" : "<font color='red'>0</font>"]-[(org.burn_dam > 0) ? "<font color='#FF8000'>[org.burn_dam]</font>" : "<font color='#FF8000'>0</font>"]"

	// Species and body temperature
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		user << "<span class='info'>Species: [H.dna.species.name]</span>"
	user << "<span class='info'>Body temperature: [round(M.bodytemperature-T0C,0.1)] &deg;C ([round(M.bodytemperature*1.8-459.67,0.1)] &deg;F)</span>"

	// Time of death
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		user << "<span class='info'>Time of Death:</span> [M.tod]"
		var/tdelta = round(world.time - M.timeofdeath)
		if(tdelta < (DEFIB_TIME_LIMIT * 10))
			user << "<span class='danger'>Subject died [tdelta / 10] seconds \
				ago, defibrillation may be possible!</span>"

	for(var/datum/disease/D in M.viruses)
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			user << "<span class='alert'><b>Warning: [D.form] detected</b>\nName: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]</span>"

	// Blood Level
	if(M.has_dna())
		var/mob/living/carbon/C = M
		var/blood_id = C.get_blood_id()
		if(blood_id)
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(H.bleed_rate)
					user << "<span class='danger'>Subject is bleeding!</span>"
			var/blood_percent =  round((C.blood_volume / BLOOD_VOLUME_NORMAL)*100)
			var/blood_type = C.dna.blood_type
			if(blood_id != "blood")//special blood substance
				blood_type = blood_id
			if(C.blood_volume <= BLOOD_VOLUME_SAFE && C.blood_volume > BLOOD_VOLUME_OKAY)
				user << "<span class='danger'>LOW blood level [blood_percent] %, [C.blood_volume] cl,</span> <span class='info'>type: [blood_type]</span>"
			else if(C.blood_volume <= BLOOD_VOLUME_OKAY)
				user << "<span class='danger'>CRITICAL blood level [blood_percent] %, [C.blood_volume] cl,</span> <span class='info'>type: [blood_type]</span>"
			else
				user << "<span class='info'>Blood level [blood_percent] %, [C.blood_volume] cl, type: [blood_type]</span>"

		var/implant_detect
		for(var/obj/item/organ/cyberimp/CI in C.internal_organs)
			if(CI.status == ORGAN_ROBOTIC)
				implant_detect += "[C.name] is modified with a [CI.name].<br>"
		if(implant_detect)
			user << "<span class='notice'>Detected cybernetic modifications:</span>"
			user << "<span class='notice'>[implant_detect]</span>"

/proc/chemscan(mob/living/user, mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.reagents)
			if(H.reagents.reagent_list.len)
				user << "<span class='notice'>Subject contains the following reagents:</span>"
				for(var/datum/reagent/R in H.reagents.reagent_list)
					user << "<span class='notice'>[R.volume] units of [R.name][R.overdosed == 1 ? "</span> - <span class='boldannounce'>OVERDOSING</span>" : ".</span>"]"
			else
				user << "<span class='notice'>Subject contains no reagents.</span>"
			if(H.reagents.addiction_list.len)
				user << "<span class='boldannounce'>Subject is addicted to the following reagents:</span>"
				for(var/datum/reagent/R in H.reagents.addiction_list)
					user << "<span class='danger'>[R.name]</span>"
			else
				user << "<span class='notice'>Subject is not addicted to any reagents.</span>"

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
	w_class = 2
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=30, MAT_GLASS=20)
	origin_tech = "magnets=1;engineering=1"

/obj/item/device/analyzer/attack_self(mob/user)

	add_fingerprint(user)

	if (user.stat || user.eye_blind)
		return

	var/turf/location = user.loc
	if(!istype(location))
		return

	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	user << "<span class='info'><B>Results:</B></span>"
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		user << "<span class='info'>Pressure: [round(pressure,0.1)] kPa</span>"
	else
		user << "<span class='alert'>Pressure: [round(pressure,0.1)] kPa</span>"
	if(total_moles)
		var/list/env_gases = environment.gases

		environment.assert_gases(arglist(hardcoded_gases))
		var/o2_concentration = env_gases["o2"][MOLES]/total_moles
		var/n2_concentration = env_gases["n2"][MOLES]/total_moles
		var/co2_concentration = env_gases["co2"][MOLES]/total_moles
		var/plasma_concentration = env_gases["plasma"][MOLES]/total_moles
		environment.garbage_collect()

		if(abs(n2_concentration - N2STANDARD) < 20)
			user << "<span class='info'>Nitrogen: [round(n2_concentration*100, 0.01)] %</span>"
		else
			user << "<span class='alert'>Nitrogen: [round(n2_concentration*100, 0.01)] %</span>"

		if(abs(o2_concentration - O2STANDARD) < 2)
			user << "<span class='info'>Oxygen: [round(o2_concentration*100, 0.01)] %</span>"
		else
			user << "<span class='alert'>Oxygen: [round(o2_concentration*100, 0.01)] %</span>"

		if(co2_concentration > 0.01)
			user << "<span class='alert'>CO2: [round(co2_concentration*100, 0.01)] %</span>"
		else
			user << "<span class='info'>CO2: [round(co2_concentration*100, 0.01)] %</span>"

		if(plasma_concentration > 0.005)
			user << "<span class='alert'>Plasma: [round(plasma_concentration*100, 0.01)] %</span>"
		else
			user << "<span class='info'>Plasma: [round(plasma_concentration*100, 0.01)] %</span>"


		for(var/id in env_gases)
			if(id in hardcoded_gases)
				continue
			var/gas_concentration = env_gases[id][MOLES]/total_moles
			user << "<span class='alert'>[env_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_concentration*100, 0.01)] %</span>"
		user << "<span class='info'>Temperature: [round(environment.temperature-T0C)] &deg;C</span>"


/obj/item/device/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2
	flags = CONDUCT | OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=150, MAT_GLASS=100)
	origin_tech = "magnets=2;biotech=1;plasmatech=2"
	var/details = 0

/obj/item/device/mass_spectrometer/New()
	..()
	create_reagents(5)

/obj/item/device/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/device/mass_spectrometer/attack_self(mob/user)
	if (user.stat || user.eye_blind)
		return
	if (!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				reagents.clear_reagents()
				user << "<span class='warning'>The sample was contaminated! Please insert another sample.</span>"
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				break
		var/dat = "<i><b>Trace Chemicals Found:</b>"
		if(!blood_traces.len)
			dat += "<br>None"
		else
			for(var/R in blood_traces)
				dat += "<br>[chemical_reagents_list[R]]"
				if(details)
					dat += " ([blood_traces[R]] units)"
		dat += "</i>"
		user << dat
		reagents.clear_reagents()


/obj/item/device/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=3;plasmatech=3"

/obj/item/device/slime_scanner
	name = "slime scanner"
	desc = "A device that analyzes a slime's internal composition and measures its stats."
	icon_state = "adv_spectrometer"
	item_state = "analyzer"
	origin_tech = "biotech=2"
	w_class = 2
	flags = CONDUCT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=30, MAT_GLASS=20)

/obj/item/device/slime_scanner/attack(mob/living/M, mob/living/user)
	if(user.stat || user.eye_blind)
		return
	if (!isslime(M))
		user << "<span class='warning'>This device can only scan slimes!</span>"
		return
	var/mob/living/simple_animal/slime/T = M
	user << "Slime scan results:"
	user << "[T.colour] [T.is_adult ? "adult" : "baby"] slime"
	user << "Nutrition: [T.nutrition]/[T.get_max_nutrition()]"
	if (T.nutrition < T.get_starve_nutrition())
		user << "<span class='warning'>Warning: slime is starving!</span>"
	else if (T.nutrition < T.get_hunger_nutrition())
		user << "<span class='warning'>Warning: slime is hungry</span>"
	user << "Electric change strength: [T.powerlevel]"
	user << "Health: [round(T.health/T.maxHealth,0.01)*100]"
	if (T.slime_mutation[4] == T.colour)
		user << "This slime does not evolve any further."
	else
		if (T.slime_mutation[3] == T.slime_mutation[4])
			if (T.slime_mutation[2] == T.slime_mutation[1])
				user << "Possible mutation: [T.slime_mutation[3]]"
				user << "Genetic destability: [T.mutation_chance/2] % chance of mutation on splitting"
			else
				user << "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)"
				user << "Genetic destability: [T.mutation_chance] % chance of mutation on splitting"
		else
			user << "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]"
			user << "Genetic destability: [T.mutation_chance] % chance of mutation on splitting"
	if (T.cores > 1)
		user << "Anomalious slime core amount detected"
	user << "Growth progress: [T.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]"
=======
/*
CONTAINS:
T-RAY
HEALTH ANALYZER
GAS ANALYZER
MASS SPECTROMETER
REAGENT SCANNER
*/

/obj/item/device/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner that can pick up the faintest traces of energy, used to detect the invisible."
	icon_state = "t-ray0"
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	starting_materials = list(MAT_IRON = 500, MAT_GLASS = 100)
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

/obj/item/device/t_scanner/advanced
	name = "\improper P-ray scanner"
	desc = "A petahertz-ray emitter and scanner that can pick up the faintest traces of energy, used to detect the invisible. Has a significantly better range than t-ray scanners."
	icon_state = "p-ray0"
	origin_tech = "magnets=3;engineering=3"

	base_state = "p-ray"
	ray_range = 3

/obj/item/device/healthanalyzer
	name = "health analyzer"
	icon_state = "health"
	item_state = "analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = W_CLASS_TINY
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
		if(M.isDead())
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
[(M.undergoing_hypothermia()) ?  "<span class='warning'>" : "<span class='notice'>"]Body Temperature: ???&deg;C (???&deg;F)</span>
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
	message += "<br>[(M.undergoing_hypothermia()) ?  "<span class='warning'>" : "<span class='notice'>"]Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>"
	if(M.tod && M.isDead())
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
	if(hardcore_mode_on && ishuman(M) && eligible_for_hardcore_mode(M))
		var/mob/living/carbon/human/H = M
		if(H.nutrition < STARVATION_MIN)
			message += "<br><span class='danger'>Warning: Severe lack of essential nutriments detected in subject's blood.</span>"

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
	if(M.reagents && M.reagents.get_reagent_amount(INAPROVALINE))
		message += "<br><span class='notice'>Bloodstream Analysis located [M.reagents:get_reagent_amount(INAPROVALINE)] units of rejuvenation chemicals.</span>"
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
				if((e.name == LIMB_LEFT_ARM) || (e.name == LIMB_RIGHT_ARM) || (e.name == LIMB_LEFT_LEG) || (e.name == LIMB_RIGHT_LEG)) //Only these limbs can be splinted
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
			if(e.cancer_stage > CANCER_STAGE_LARGE_TUMOR) //Health analyzers can detect large tumors and above in external limbs, if all else fails
				message += text("<br><span class='danger'>Serious cancerous growth detected. Advanced scan required for location.</span>")
				break
		if(H.vessel)
			var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
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
	w_class = W_CLASS_SMALL
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

	to_chat(user, output_gas_scan(environment, location, 1))

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
		message += "<span class='bnotice'><B>[bicon(container)] Results of [container] scan:</span></B>"
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
	w_class = W_CLASS_SMALL
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
			if(R.id != BLOOD)
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
	w_class = W_CLASS_SMALL
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
