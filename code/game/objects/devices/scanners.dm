
/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
PLANT ANALYZER
MASS SPECTROMETER

*/
/obj/item/device/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	var/on = 0
	flags = FPRINT|ONBELT|TABLEPASS
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
					M.invisibility = 2


/obj/item/device/detective_scanner
	name = "Scanner"
	desc = "Used to scan objects for DNA and fingerprints."
	icon_state = "forensic1"
	var/amount = 20.0
//	var/printing = 0.0
	var/list/stored = list()
	w_class = 3.0
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT | USEDELAY


	attackby(obj/item/weapon/f_card/W as obj, mob/user as mob)
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

//	attack_self(mob/user as mob)
//		src.printing = !( src.printing )
//		if(src.printing)
//			user << "\blue Printing turned on"
//		else
//			user << "\blue Printing turned off"
//		src.icon_state = text("forensic[]", src.printing)
//		add_fingerprint(user)
//		return

	attack(mob/living/carbon/human/M as mob, mob/user as mob)
		if (!ishuman(M))
			user << "\red [M] is not human and cannot have the fingerprints."
			return 0
		if (( !( istype(M.dna, /datum/dna) ) || M.gloves) )
			user << "\blue No fingerprints found on [M]"
			return 0
		else
			if (src.amount < 1)
				user << text("\blue Fingerprints scanned on [M]. Need more cards to print.")
//				src.printing = 0
//			src.icon_state = text("forensic[]", src.printing)
//			if (src.printing)
			else
				src.amount--
				var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( user.loc )
				F.amount = 1
				F.fingerprints += md5(M.dna.uni_identity)
				F.icon_state = "fingerprint1"
				F.name = text("FPrintC- '[M.name]'")

				user << "\blue Done printing."
			user << text("\blue [M]'s Fingerprints: [md5(M.dna.uni_identity)]")
		if ( !M.blood_DNA || !M.blood_DNA.len )
			user << "\blue No blood found on [M]"
			if(M.blood_DNA)
				del(M.blood_DNA)
		else
			user << "\blue Blood found on [M]. Analysing..."
			spawn(15)
				for(var/i = 1, i <= M.blood_DNA.len, i++)
					var/list/templist = M.blood_DNA[i]
					user << "\blue Blood type: [templist[2]]\nDNA: [templist[1]]"
		return

	afterattack(atom/A as obj|turf|area, mob/user as mob)
		if(!(locate(A) in oview(1,user)))
			return
		if(src.loc != user)
			return 0
		if(istype(A,/obj/machinery/computer/forensic_scanning)) //breaks shit.
			return
		if(istype(A,/obj/item/weapon/f_card))
			user << "Haha, nice try.  Cheater.  (It would break stuff anyways.)"
			return
		if(!A.fingerprints)
			A.fingerprints = list()
		src.add_fingerprint(user)
		if (istype(A, /obj/effect/decal/cleanable/blood) || istype(A, /obj/effect/rune))
			if(!isnull(A.blood_DNA))
				for(var/i = 1, i <= A.blood_DNA.len, i++)
					var/list/templist = A.blood_DNA[i]
					user << "\blue Blood type: [templist[2]]\nDNA: [templist[1]]"
			return
		var/duplicate = 0
		if ((!A.fingerprints || !A.fingerprints.len) && !A.suit_fibers && !A.blood_DNA)
			user << "\blue Unable to locate any fingerprints, materials, fibers, or blood on [A]!"
			return 0
		else if (A.blood_DNA)
			user << "\blue Blood found on [A]. Analysing..."
			sleep(15)
			if(!duplicate)
				duplicate = 1
				var/i = add_data(A)
				if(i)
					user << "\blue Blood already in memory."
			for(var/i = 1, i < (A.blood_DNA.len + 1), i++)
				var/list/templist = A.blood_DNA[i]
				user << "\blue Blood type: [templist[2]]\nDNA: [templist[1]]"
		else
			user << "\blue No Blood Located"
		if(!A.fingerprints || !A.fingerprints.len)
			user << "\blue No Fingerprints Located."
			if(A.fingerprints)
				del(A.fingerprints)
		else
			user << text("\blue Isolated [A.fingerprints.len] fingerprints: Data Stored: Scan with Hi-Res Forensic Scanner to retrieve.")
			if(!duplicate)
				duplicate = 1
				var/i = add_data(A)
				if(i)
					user << "\blue Fingerprints already in memory."
		if(!A.suit_fibers)
			user << "\blue No Fibers/Materials Located."
		else
			user << "\blue Fibers/Materials Data Stored: Scan with Hi-Res Forensic Scanner to retrieve."

			if(!duplicate)
				duplicate = 1
				var/i = add_data(A)
				if(i)
					user << "\blue Fibers/Materials already in memory."
	//	else
	//		if ((src.amount < 1 && src.printing))
	//			user << "\blue Fingerprints found. Need more cards to print."
	//			src.printing = 0
	//	src.icon_state = text("forensic[]", src.printing)
	//	if (src.printing)
	//		src.amount--
	//		var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( user.loc )
	//		F.amount = 1
	//		F.fingerprints = A.fingerprints
	//		F.icon_state = "fingerprint1"
	//		user << "\blue Done printing."
	//	for(var/i in L)
	//		user << text("\blue \t [i]")
	//		//Foreach goto(186)
		return

	proc/add_data(atom/A as mob|obj|turf|area)
		var/merged = 0
		if(!stored || !stored.len)
			stored = list()
		for(var/i = 1, i < (stored.len + 1), i++)	//Lets see if the object is already in there!
			var/list/temp = stored[i]
			var/atom/checker = temp[1]
			var/atom_checker_scan = (A.original_atom ? checker.original_atom[1] == A.original_atom[1] : 0)
			if(checker.original_atom[1] == A || atom_checker_scan)	//It is!  Merge!
				merged = 1
				var/list/prints = temp[2]
				if(!prints)
					prints = list()
				if(A.fingerprints && A.fingerprints.len)
					for(var/j = 1, j <= A.fingerprints.len, j++)	//Fingerprints~~~
						var/list/print_test1 = params2list(A.fingerprints[j])
						var/test_print1 = print_test1[num2text(1)]
						var/found = 0
						for(var/k = 1, k <= prints.len, k++)	//Lets see if the print is already in there
							var/list/print_test2 = params2list(prints[k])
							var/test_print2 = print_test2[num2text(1)]
							if(test_print2 == test_print1)	//It is!  Merge!
								prints[k] = test_print2 + "&" + stringmerge(print_test2[num2text(2)],print_test1[num2text(2)])
								found = 1
								break	//We found it, we're done here.
						if(!found)	//It isn't!  Add!
							prints += A.fingerprints[j]
				var/list/fibers = temp[3]
				if(!fibers)
					fibers = list()
				if(A.suit_fibers && A.suit_fibers.len)
					for(var/j = 1, j <= A.suit_fibers.len, j++)	//Fibers~~~
						if(!fibers.Find(A.suit_fibers[j]))	//It isn't!  Add!
							fibers += A.suit_fibers[j]
				var/list/blood = temp[4]
				if(!blood)
					blood = list()
				if(A.blood_DNA && A.blood_DNA.len)
					for(var/j = 1, j <= A.blood_DNA.len, j++)	//Blood~~~
						if(!blood.Find(A.blood_DNA[j]))	//It isn't!  Add!
							blood += A.blood_DNA[j]
				var/list/sum_list[4]	//Pack it back up!
				sum_list[1] = checker
				sum_list[2] = prints
				sum_list[3] = fibers
				sum_list[4] = blood
				stored[i] = sum_list	//Store it!
				break	//We found it, we're done here.
		if(!merged)	//Uh, oh!  New data point!
			var/list/sum_list[4]	//Pack it back up!
			sum_list[1] = A.get_duplicate(src)
			sum_list[2] = A.fingerprints
			sum_list[3] = A.suit_fibers
			sum_list[4] = A.blood_DNA
			stored.len++
			stored[stored.len] = sum_list
		return merged


/obj/item/device/healthanalyzer
	name = "Health Analyzer"
	icon_state = "health"
	item_state = "analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	throwforce = 3
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1;

/obj/item/device/healthanalyzer/attack(mob/M as mob, mob/user as mob)
	if ((user.mutations & CLUMSY || user.getBrainLoss() >= 60) && prob(50))
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
	var/fake_oxy = max(rand(1,40), M.getOxyLoss(), (300 - (M.getToxLoss() + M.getFireLoss() + M.getBruteLoss())))
	if((M.reagents && M.reagents.has_reagent("zombiepowder")) || (M.changeling && M.changeling.changeling_fakedeath))
		user.show_message(text("\blue Analyzing Results for []:\n\t Overall Status: []", M, "dead"), 1)
		user.show_message(text("\blue \t Damage Specifics: []-[]-[]-[]", fake_oxy < 50 ? "\red [fake_oxy]" : fake_oxy , M.getToxLoss() > 50 ? "\red [M.getToxLoss()]" : M.getToxLoss(), M.getFireLoss() > 50 ? "\red[M.getFireLoss()]" : M.getFireLoss(), M.getBruteLoss() > 50 ? "\red[M.getBruteLoss()]" : M.getBruteLoss()), 1)
	else
		user.show_message(text("\blue Analyzing Results for []:\n\t Overall Status: []", M, (M.stat > 1 ? "dead" : text("[]% healthy", M.health - M.halloss))), 1)
		user.show_message(text("\blue \t Damage Specifics: []-[]-[]-[]", M.getOxyLoss() > 50 ? "\red [M.getOxyLoss()]" : M.getOxyLoss(), M.getToxLoss() > 50 ? "\red [M.getToxLoss()]" : M.getToxLoss(), M.getFireLoss() > 50 ? "\red[M.getFireLoss()]" : M.getFireLoss(), M.getBruteLoss() > 50 ? "\red[M.getBruteLoss()]" : M.getBruteLoss()), 1)
	user.show_message("\blue Key: Suffocation/Toxin/Burns/Brute", 1)
	user.show_message("\blue Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)", 1)
	if(mode == 1 && istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_organs(1,1)
		user.show_message("\blue Localized Damage, Brute/Burn:",1)
		if(length(damaged)>0)
			for(var/datum/organ/external/org in damaged)
				user.show_message(text("\blue \t []: []\blue-[]",capitalize(org.getDisplayName()),(org.brute_dam > 0)?"\red [org.brute_dam]":0,(org.burn_dam > 0)?"\red [org.burn_dam]":0),1)
		else
			user.show_message("\blue \t Limbs are OK.",1)

	if((M.changeling && M.changeling.changeling_fakedeath) ||  (M.reagents && M.reagents.has_reagent("zombiepowder")))
		user.show_message(text("\blue [] | [] | [] | []", fake_oxy > 50 ? "\red Severe oxygen deprivation detected\blue" : "Subject bloodstream oxygen level normal", M.getToxLoss() > 50 ? "\red Dangerous amount of toxins detected\blue" : "Subject bloodstream toxin level minimal", M.getFireLoss() > 50 ? "\red Severe burn damage detected\blue" : "Subject burn injury status O.K", M.getBruteLoss() > 50 ? "\red Severe anatomical damage detected\blue" : "Subject brute-force injury status O.K"), 1)
	else
		user.show_message(text("\blue [] | [] | [] | []", M.getOxyLoss() > 50 ? "\red Severe oxygen deprivation detected\blue" : "Subject bloodstream oxygen level normal", M.getToxLoss() > 50 ? "\red Dangerous amount of toxins detected\blue" : "Subject bloodstream toxin level minimal", M.getFireLoss() > 50 ? "\red Severe burn damage detected\blue" : "Subject burn injury status O.K", M.getBruteLoss() > 50 ? "\red Severe anatomical damage detected\blue" : "Subject brute-force injury status O.K"), 1)
	if (M.getCloneLoss())
		user.show_message(text("\red Subject appears to have been imperfectly cloned."), 1)
	for(var/datum/disease/D in M.viruses)
		if(!D.hidden[SCANNER])
			user.show_message(text("\red <b>Warning: [D.form] Detected</b>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]"))
	if (M.reagents && M.reagents.get_reagent_amount("inaprovaline"))
		user.show_message(text("\blue Bloodstream Analysis located [M.reagents:get_reagent_amount("inaprovaline")] units of rejuvenation chemicals."), 1)
	if (M.getBrainLoss() >= 100 || istype(M, /mob/living/carbon/human) && M:brain_op_stage == 4.0)
		user.show_message(text("\red Subject is brain dead."), 1)
	else if (M.getBrainLoss() >= 60)
		user.show_message(text("\red Severe brain damage detected. Subject likely to have mental retardation."), 1)
	else if (M.getBrainLoss() >= 10)
		user.show_message(text("\red Significant brain damage detected. Subject may have had a concussion."), 1)
	src.add_fingerprint(user)
	return

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
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"

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

