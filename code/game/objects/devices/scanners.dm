
/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
PLANT ANALYZER
MASS SPECTROMETER

*/

/obj/item/device/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = "t-ray[on]"

	if(on)
		processing_items.Add(src)


/obj/item/device/t_scanner/process()
	if(!on)
		processing_items.Remove(src)
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
					M.invisibility = 2

/obj/item/device/detective_scanner/attackby(obj/item/weapon/f_card/W as obj, mob/user as mob)
	..()

	if (istype(W, /obj/item/weapon/f_card))
		if (W.fingerprints)
			return
		if (src.amount == 20)
			return
		if (W.amount + src.amount > 20)
			src.amount = 20
			W.amount = W.amount + src.amount - 20
		else
			src.amount += W.amount
			//W = null
			del(W)
		src.add_fingerprint(user)
		if (W)
			W.add_fingerprint(user)
	return

/obj/item/device/detective_scanner/attack_self(mob/user as mob)

	src.printing = !( src.printing )
	if(src.printing)
		user << "\blue Printing turned on"
	else
		user << "\blue Printing turned off"
	src.icon_state = text("forensic[]", src.printing)
	add_fingerprint(user)
	return

/obj/item/device/detective_scanner/attack(mob/living/carbon/human/M as mob, mob/user as mob)

	if (( !( istype(M.dna, /datum/dna) ) || M.gloves) )
		user << "\blue No fingerprints found on [M]"
	else
		if ((src.amount < 1 && src.printing))
			user << text("\blue Fingerprints scanned on [M]. Need more cards to print.")
			src.printing = 0
		src.icon_state = text("forensic[]", src.printing)
		if (src.printing)
			src.amount--
			var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( user.loc )
			F.amount = 1
			F.fingerprints = md5(M.dna.uni_identity)
			F.icon_state = "fingerprint1"
			F.name = text("FPrintC- '[M.name]'")
			user << "\blue Done printing."
		user << text("\blue [M]'s Fingerprints: [md5(M.dna.uni_identity)]")
	if ( !(M.blood_DNA) )
		user << "\blue No blood found on [M]"
	else
		user << "\blue Blood found on [M]. Analysing..."
		spawn(15)
			user << "\blue Blood type: [M.blood_type]\nDNA: [M.blood_DNA]"
	return

/obj/item/device/detective_scanner/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)

	src.add_fingerprint(user)
	if (istype(A, /obj/decal/cleanable/blood) || istype(A, /obj/rune))
		if(A.blood_DNA)
			user << "\blue Blood type: [A.blood_type]\nDNA: [A.blood_DNA]"
		if(A:virus)
			user << "\red Warning, virus found in the blood! Name: [A:virus.name]"
	else if (A.blood_DNA)
		user << "\blue Blood found on [A]. Analysing..."
		sleep(15)
		user << "\blue Blood type: [A.blood_type]\nDNA: [A.blood_DNA]"
	else
		user << "\blue No blood found on [A]."
	if (!( A.fingerprints ))
		user << "\blue Unable to locate any fingerprints on [A]!"
		return 0
	else
		if ((src.amount < 1 && src.printing))
			user << "\blue Fingerprints found. Need more cards to print."
			src.printing = 0
	src.icon_state = text("forensic[]", src.printing)
	if (src.printing)
		src.amount--
		var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( user.loc )
		F.amount = 1
		F.fingerprints = A.fingerprints
		F.icon_state = "fingerprint1"
		user << "\blue Done printing."
	var/list/L = params2list(A.fingerprints)
	user << text("\blue Isolated [L.len] fingerprints.")
	for(var/i in L)
		user << text("\blue \t [i]")
		//Foreach goto(186)
	return

/obj/item/device/healthanalyzer/attack(mob/M as mob, mob/user as mob)
	if ((user.mutations & 16 || user.brainloss >= 60) && prob(50))
		user << text("\red You try to analyze the floor's vitals!")
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [user] has analyzed the floor's vitals!"), 1)
		user.show_message(text("\blue Analyzing Results for The floor:\n\t Overall Status: Healthy"), 1)
		user.show_message(text("\blue \t Damage Specifics: [0]-[0]-[0]-[0]"), 1)
		user.show_message("\blue Key: Suffocation/Toxin/Burns/Brute", 1)
		user.show_message("\blue Body Temperature: ???", 1)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	for(var/mob/O in viewers(M, null))
		O.show_message(text("\red [] has analyzed []'s vitals!", user, M), 1)
		//Foreach goto(67)
	var/fake_oxy = max(rand(1,40), M.oxyloss, (300 - (M.toxloss + M.fireloss + M.bruteloss)))
	if(M.changeling_fakedeath || M.reagents.has_reagent("zombiepowder"))
		user.show_message(text("\blue Analyzing Results for []:\n\t Overall Status: []", M, "dead"), 1)
		user.show_message(text("\blue \t Damage Specifics: []-[]-[]-[]", fake_oxy < 50 ? "\red [fake_oxy]" : fake_oxy , M.toxloss > 50 ? "\red [M.toxloss]" : M.toxloss, M.fireloss > 50 ? "\red[M.fireloss]" : M.fireloss, M.bruteloss > 50 ? "\red[M.bruteloss]" : M.bruteloss), 1)
	else
		user.show_message(text("\blue Analyzing Results for []:\n\t Overall Status: []", M, (M.stat > 1 ? "dead" : text("[]% healthy", M.health))), 1)
		user.show_message(text("\blue \t Damage Specifics: []-[]-[]-[]", M.oxyloss > 50 ? "\red [M.oxyloss]" : M.oxyloss, M.toxloss > 50 ? "\red [M.toxloss]" : M.toxloss, M.fireloss > 50 ? "\red[M.fireloss]" : M.fireloss, M.bruteloss > 50 ? "\red[M.bruteloss]" : M.bruteloss), 1)
	user.show_message("\blue Key: Suffocation/Toxin/Burns/Brute", 1)
	user.show_message("\blue Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)", 1)
	if(M.changeling_fakedeath || M.reagents.has_reagent("zombiepowder"))
		user.show_message(text("\blue [] | [] | [] | []", fake_oxy > 50 ? "\red Severe oxygen deprivation detected\blue" : "Subject bloodstream oxygen level normal", M.toxloss > 50 ? "\red Dangerous amount of toxins detected\blue" : "Subject bloodstream toxin level minimal", M.fireloss > 50 ? "\red Severe burn damage detected\blue" : "Subject burn injury status O.K", M.bruteloss > 50 ? "\red Severe anatomical damage detected\blue" : "Subject brute-force injury status O.K"), 1)
	else
		user.show_message(text("\blue [] | [] | [] | []", M.oxyloss > 50 ? "\red Severe oxygen deprivation detected\blue" : "Subject bloodstream oxygen level normal", M.toxloss > 50 ? "\red Dangerous amount of toxins detected\blue" : "Subject bloodstream toxin level minimal", M.fireloss > 50 ? "\red Severe burn damage detected\blue" : "Subject burn injury status O.K", M.bruteloss > 50 ? "\red Severe anatomical damage detected\blue" : "Subject brute-force injury status O.K"), 1)
	if (M.cloneloss)
		user.show_message(text("\red Subject appears to have been imperfectly cloned."), 1)
	if (M.virus)
		user.show_message(text("\red <b>Warning: Virus Detected.</b>\nName: [M.virus.name].\nType: [M.virus.spread].\nStage: [M.virus.stage]/[M.virus.max_stages].\nPossible Cure: [M.virus.cure]"))
	if (M.reagents:get_reagent_amount("inaprovaline"))
		user.show_message(text("\blue Bloodstream Analysis located [M.reagents:get_reagent_amount("inaprovaline")] units of rejuvenation chemicals."), 1)
	if (M.brainloss >= 100 || istype(M, /mob/living/carbon/human) && M:brain_op_stage == 4.0)
		user.show_message(text("\red Subject is brain dead."), 1)
	else if (M.brainloss >= 60)
		user.show_message(text("\red Severe brain damage detected. Subject likely to have mental retardation."), 1)
	else if (M.brainloss >= 10)
		user.show_message(text("\red Significant brain damage detected. Subject may have had a concussion."), 1)
	src.add_fingerprint(user)
	return

/obj/item/device/analyzer/attack_self(mob/user as mob)

	if (user.stat)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
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

/obj/item/device/mass_spectrometer/New()
	..()
	var/datum/reagents/R = new/datum/reagents(5)
	reagents = R
	R.my_atom = src

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

