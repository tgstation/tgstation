/obj/item/weapon/scanner_module
	name = "dummy scanmodule"
	desc = "Just an empty cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = 1

	m_amt = 50
	g_amt = 50

	origin_tech = "magnets=1;engineering=1"

	var/range = 1
	var/scan_name = "dummy scan"
	var/scan_on_attack_self = 0

/obj/item/weapon/scanner_module/proc/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)

	if(get_dist(A, user) > range || !(A in view(world.view, user)))
		scnr.add_log("<span class='notice'>[A] is not in range.</span>", user)
		return 0
	scnr.add_log("<span class='info'><B>[scan_name]</B></span>", user)
	return 1

//MEDBAY SCANNER MODULE
/obj/item/weapon/scanner_module/health_module
	name = "health scanmodule"
	desc = "A scanner module that displays and analyzes the health of the scanned human"
	scan_name = "Health Scan Results:"
	origin_tech = "engineering=2;biotech=2"

/obj/item/weapon/scanner_module/health_module/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)

	if(!istype(A, /mob/living/))
		return

	if(!..())
		return

	var/mob/living/M = A
	//Damage specifics
	var/oxy_loss = M.getOxyLoss()
	var/tox_loss = M.getToxLoss()
	var/fire_loss = M.getFireLoss()
	var/brute_loss = M.getBruteLoss()
	var/mob_status = (M.stat > 1 ? "<font color='red'>Deceased</font>" : text("[]% healthy", M.health))

	if(M.status_flags & FAKEDEATH)
		mob_status = "<font color='red'>Deceased</font>"
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	scnr.add_log(text("<span class='notice'>Analyzing Results for []:\n\t Overall Status: []</span>", M, mob_status), user)
	scnr.add_log(text("<span class='notice'>\t Damage Specifics: <font color='blue'>[]</font>-<font color='green'>[]</font>-<font color='#FF8000'>[]</font>-<font color='red'>[]</font></span>", oxy_loss, tox_loss, fire_loss, brute_loss), user)

	scnr.add_log("<span class='notice'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font></span>", user)
	scnr.add_log("<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>", user)

	// Time of death
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		scnr.add_log("<span class='notice'>Time of Death:</span> [M.tod]", user)

	// Organ damage report
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_organs(1,1)
		scnr.add_log("<span class='notice'>Localized Damage, <font color='#FF8000'>Burn</font>/<font color='red'>Brute</font>:</span>", user)
		if(length(damaged)>0)
			for(var/obj/item/organ/limb/org in damaged)
				scnr.add_log(text("<span class='notice'>\t []: []-[]", capitalize(org.getDisplayName()), (org.burn_dam > 0) ? "<font color='#FF8000'>[org.burn_dam]</font>" : 0, (org.brute_dam > 0) ? "<font color='red'>[org.brute_dam]</font></span>" : 0), user)
		else
			scnr.add_log("<span class='notice'>\t Limbs are OK.</span>", user)

	// Damage descriptions

	scnr.add_log(text("<span class='notice'>[] | [] | [] | []</span>", oxy_loss > 50 ? "\red Severe oxygen deprivation detected\blue" : "Subject bloodstream oxygen level normal", tox_loss > 50 ? "\red Dangerous amount of toxins detected\blue" : "Subject bloodstream toxin level minimal", fire_loss > 50 ? "\red Severe burn damage detected\blue" : "Subject burn injury status O.K", brute_loss > 50 ? "\red Severe anatomical damage detected\blue" : "Subject brute-force injury status O.K"), user)

	if(M.getStaminaLoss())
		scnr.add_log(text("<span class='info'>Subject appears to be suffering from fatigue.</span>"), user)

	if (M.getCloneLoss())
		scnr.add_log(text("<span class='alert'>Subject appears to have been imperfectly cloned.</span>"), user)



	if (M.reagents && M.reagents.get_reagent_amount("inaprovaline"))
		scnr.add_log(text("<span class='notice'>Bloodstream Analysis located [M.reagents:get_reagent_amount("inaprovaline")] units of rejuvenation chemicals.</span>"), user)
	if (M.getBrainLoss() >= 100 || !M.getorgan(/obj/item/organ/brain))
		scnr.add_log(text("<span class='alert'>Subject brain function is non-existant.</span>"), user)
	else if (M.getBrainLoss() >= 60)
		scnr.add_log(text("<span class='warning'>Severe brain damage detected. Subject likely to have mental retardation.</span>"), user)
	else if (M.getBrainLoss() >= 10)
		scnr.add_log(text("<span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span>"), user)

/obj/item/weapon/scanner_module/health_module/L1

/obj/item/weapon/scanner_module/health_module/L2
	name = "advanced health scanmodule"
	origin_tech = "engineering=3;biotech=3"
	range = 8

//VIRUS SCANNER MODULE
/obj/item/weapon/scanner_module/virus_module
	name = "virus scanmodule"
	scan_name = "Diseases:"
	desc = "A scanner module that displays diseases"
	origin_tech = "engineering=2;biotech=2"

/obj/item/weapon/scanner_module/virus_module/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)
	if(!istype(A, /mob/living/))
		return

	if(!..())
		return

	var/virus_detected = 0
	var/mob/living/M = A

	for(var/datum/disease/D in M.viruses)
		if(!D.hidden[SCANNER])
			scnr.add_log(text("<span class='warning'><b>Warning: [D.form] Detected</b>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</span>"), user)
			virus_detected = 1
	if(!virus_detected)
		scnr.add_log("<span class='notice'> No disease detected</span>")
	return

/obj/item/weapon/scanner_module/virus_module/L1

/obj/item/weapon/scanner_module/virus_module/L2
	name = "advanced virus scanmodule"
	origin_tech = "engineering=3;biotech=3"
	range = 8

//ATMOS SCANNER MODULE
/obj/item/weapon/scanner_module/atmos_module
	name = "atmosphere scanmodule"
	range = 1
	scan_name = "Atmosphere Scan Results:"
	scan_on_attack_self = 1
	desc = "A scanner module that analyzes the atmosphere or the gasses in a container"
	origin_tech = "engineering=2;materials=2"

/obj/item/weapon/scanner_module/atmos_module/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)

	var/turf/location = A
	if (!( istype(location, /turf) ))
		location = A.loc
		if (!location || !( istype(location, /turf) ))
			return

	if(!..())
		return

	//check if scannable object
	if(istype(A, /obj/item/weapon/flamethrower))
		var/obj/item/weapon/flamethrower/F = A
		if(F.ptank)
			atmosmodule_scan(F.ptank.air_contents, user, scnr)
		return

	if (istype(A, /obj/item/weapon/tank))
		var/obj/item/weapon/tank/T = A
		atmosmodule_scan(T.air_contents, user, scnr)
		return

	if (istype(A, /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/T = A
		atmosmodule_scan(T.air_contents, user, scnr)
		return

	if (istype(A, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/T = A
		atmosmodule_scan(T.parent.air, user, scnr)
		return

	if (istype(A, /obj/machinery/power/rad_collector))
		var/obj/machinery/power/rad_collector/T = A
		if(T.P)
			atmosmodule_scan(T.P.air_contents, user, scnr)
		return

	//scan turf atmos
	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		scnr.add_log("<span class='notice'> Pressure: [round(pressure,0.1)] kPa </span>", user)
	else
		scnr.add_log("<span class='warning'> Pressure: [round(pressure,0.1)] kPa </span>", user)
	if(total_moles)
		var/o2_concentration = environment.oxygen/total_moles
		var/n2_concentration = environment.nitrogen/total_moles
		var/co2_concentration = environment.carbon_dioxide/total_moles
		var/plasma_concentration = environment.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		if(abs(n2_concentration - N2STANDARD) < 20)
			scnr.add_log("<span class='notice'> Nitrogen: [round(n2_concentration*100)]% </span>", user)
		else
			scnr.add_log("<span class='alert'> Nitrogen: [round(n2_concentration*100)]% </span>", user)

		if(abs(o2_concentration - O2STANDARD) < 2)
			scnr.add_log("<span class='notice'> Oxygen: [round(o2_concentration*100)]% </span>", user)
		else
			scnr.add_log("<span class='alert'> Oxygen: [round(o2_concentration*100)]% </span>", user)

		if(co2_concentration > 0.01)
			scnr.add_log("<span class='alert'> CO2: [round(co2_concentration*100)]% </span>", user)
		else
			scnr.add_log("<span class='notice'> CO2: [round(co2_concentration*100)]% </span>", user)

		if(plasma_concentration > 0.01)
			scnr.add_log("<span class='alert'> Plasma: [round(plasma_concentration*100)]% </span>", user)

		if(unknown_concentration > 0.01)
			scnr.add_log("<span class='alert'> Unknown: [round(unknown_concentration*100)]% </span>", user)

		scnr.add_log("<span class='notice'> Temperature: [round(environment.temperature-T0C)]&deg;C </span>", user)

	return

/obj/item/weapon/scanner_module/atmos_module/L1

/obj/item/weapon/scanner_module/atmos_module/L2
	name = "advanced atmosphere scanmodule"
	origin_tech = "engineering=3;materials=3"
	range = 8


/obj/item/weapon/scanner_module/atmos_module/proc/atmosmodule_scan(var/datum/gas_mixture/air_contents, mob/user, var/obj/item/device/scanner/scnr)
	var/pressure = air_contents.return_pressure()
	var/total_moles = air_contents.total_moles()

	if(total_moles>0)
		var/o2_concentration = air_contents.oxygen/total_moles
		var/n2_concentration = air_contents.nitrogen/total_moles
		var/co2_concentration = air_contents.carbon_dioxide/total_moles
		var/plasma_concentration = air_contents.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		scnr.add_log("<span class='notice'> Pressure: [round(pressure,0.1)] kPa </span>", user)
		scnr.add_log("<span class='notice'> Nitrogen: [round(n2_concentration*100)]% </span>", user)

		scnr.add_log("<span class='notice'> Oxygen: [round(o2_concentration*100)]% </span>", user)

		scnr.add_log("<span class='notice'> CO2: [round(co2_concentration*100)]% </span>", user)

		scnr.add_log("<span class='notice'> Plasma: [round(plasma_concentration*100)]% </span>", user)

		if(unknown_concentration>0.01)
			scnr.add_log("<span class='alert'> Unknown: [round(unknown_concentration*100)]% </span>", user)

		scnr.add_log("<span class='notice'> Temperature: [round(air_contents.temperature-T0C)]&deg;C </span>", user)

	else
		scnr.add_log("<span class='notice'> No atmosphere detected! </span>", user)
	return

//BLOOD DNA MODULE
/obj/item/weapon/scanner_module/blood_dna_module
	name = "blood scanmodule"
	range = 1
	scan_name = "Blood:"
	desc = "A scanner module that determines the DNA after scanning blood"
	origin_tech = "engineering=2;biotech=3"

/obj/item/weapon/scanner_module/blood_dna_module/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)
	if(!..())
		return

	var/blood_detected = 0
	if(A.blood_DNA && A.blood_DNA.len)
		var/list/blood = A.blood_DNA.Copy()
		for(var/B in blood)
			scnr.add_log("Type: <font color='red'>[blood[B]]</font> DNA: <font color='red'>[B]</font>", user)
			blood_detected = 1

	if(ismob(A))
		return;


	// Only get reagents from non-mobs.
	if(A.reagents && A.reagents.reagent_list.len)

		for(var/datum/reagent/R in A.reagents.reagent_list)
			reagents[R.name] = R.volume

			// Get blood data from the blood reagent.
			if(istype(R, /datum/reagent/blood))

				if(R.data["blood_DNA"] && R.data["blood_type"])
					var/blood_DNA = R.data["blood_DNA"]
					var/blood_type = R.data["blood_type"]
					scnr.add_log("Type: <font color='red'>[blood_type]</font> DNA: <font color='red'>[blood_DNA]</font>", user)
					blood_detected = 1
	if(!blood_detected)
		scnr.add_log("<span class='notice'>No blood detected.</span>", user)
	return

/obj/item/weapon/scanner_module/blood_dna_module/L1

/obj/item/weapon/scanner_module/blood_dna_module/L2
	name = "advanced blood scanmodule"
	origin_tech = "engineering=3;biotech=3"
	range = 8

//REAGENT MODULE
/obj/item/weapon/scanner_module/reagent_module
	name = "reagent scanmodule"
	range = 1
	scan_name = "Detected Reagents:"
	desc = "A scanner module that analyzes reagents and their amounts in a scanned container"
	origin_tech = "engineering=3;materials=2"

/obj/item/weapon/scanner_module/reagent_module/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)
	if(ismob(A))
		return

	if(!..())
		return

	var/reagent_detected = 0

	// Only get reagents from non-mobs.
	if(A.reagents && A.reagents.reagent_list.len)

		for(var/datum/reagent/R in A.reagents.reagent_list)
			scnr.add_log("<span class='notice'>[R.name] ([R.volume] units)</span>", user)
			reagent_detected = 1

	if(!reagent_detected)
		scnr.add_log("<span class='notice'>No reagents detected.</span>", user)
	return

/obj/item/weapon/scanner_module/reagent_module/L1

/obj/item/weapon/scanner_module/reagent_module/L2
	name = "advanced reagent scanmodule"
	range = 8
	origin_tech = "engineering=4;materials=3"

//BLOOD REAGENT MODULE
/obj/item/weapon/scanner_module/blood_reagent_module
	name = "blood reagent scanner module"
	range = 1
	scan_name = "Detected Reagent Traces in Blood:"
	desc = "A scanner module that analyzes traces of reagents found in blood"
	var/on_mobs = 0
	origin_tech = "magnets=2;biotech=2"

/obj/item/weapon/scanner_module/blood_reagent_module/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)
	if(!..())
		return

	var/reagent_detected = 0
	var/blood_found = 0

	if(ismob(A) && on_mobs)
		if(A.reagents && A.reagents.reagent_list.len)
			for(var/datum/reagent/R in A.reagents.reagent_list)
				scnr.add_log("<span class='notice'>[R.name] ([R.volume] units)</span>", user)
				reagent_detected = 1
				blood_found = 1


	if(!ismob(A))
		// Only get reagents from non-mobs.
		if(A.reagents && A.reagents.reagent_list.len)

			for(var/datum/reagent/R in A.reagents.reagent_list)
				var/list/blood_traces = list()
				// Get blood data from the blood reagent.
				if(istype(R, /datum/reagent/blood))
					blood_found = 1
					if(R.data["blood_DNA"] && R.data["blood_type"])
						blood_traces = params2list(R.data["trace_chem"])
				for(var/T in blood_traces)
					scnr.add_log("<span class='notice'>[T] ([blood_traces[T]] units)</span>", user)
					reagent_detected = 1

	if(!blood_found)
		scnr.add_log("<span class='notice'>No blood detected.</span>", user)
		return
	if(!reagent_detected)
		scnr.add_log("<span class='notice'>No reagents detected.</span>", user)
	return

/obj/item/weapon/scanner_module/blood_reagent_module/L1
	on_mobs = 0
	name = "blood reagent scanmodule"
	range = 1

/obj/item/weapon/scanner_module/blood_reagent_module/L2
	on_mobs = 1
	name = "advanced blood reagent scanmodule"
	origin_tech = "magnets=3;biotech=3"
	range = 1
/obj/item/weapon/scanner_module/blood_reagent_module/L3
	on_mobs = 1
	name = "bluespace blood reagent scanmodule"
	origin_tech = "magnets=4;biotech=3"
	range = 8

//FINGERPRINT MODULE
/obj/item/weapon/scanner_module/fingerprint_module
	name = "fingerprint scanmodule"
	range = 1
	scan_name = "Detected Fingerprints:"
	desc = "A scanner module that detects fingerprints on the scanned object"
	origin_tech = "magnets=3;engineering=3"

/obj/item/weapon/scanner_module/fingerprint_module/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)
	if(!..())
		return

	var/prints_detected = 0
	if(ishuman(A))

		var/mob/living/carbon/human/H = A
		if (istype(H.dna, /datum/dna) && !H.gloves)
			scnr.add_log("<span class='notice'>[md5(H.dna.uni_identity)]</span>", user)
			prints_detected = 1

	else if(!ismob(A))
		if(A.fingerprints && A.fingerprints.len)
			for(var/finger in A.fingerprints)
				scnr.add_log("<span class='notice'>[finger]</span>", user)
				prints_detected = 1

	if(!prints_detected)
		scnr.add_log("<span class='notice'>No prints detected</span>", user)

	return
/obj/item/weapon/scanner_module/fingerprint_module/L1

/obj/item/weapon/scanner_module/fingerprint_module/L2
	name = "advanced fingerprint scanmodule"
	range = 8
	origin_tech = "magnets=4;engineering=4"

//FIBER MODULE
/obj/item/weapon/scanner_module/fiber_module
	name = "fiber scanmodule"
	range = 1
	scan_name = "Detected Fibers:"
	desc = "A scanner module that detects fibers of clothing on the scanned object"
	origin_tech = "magnets=3;engineering=3"

/obj/item/weapon/scanner_module/fiber_module/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)
	if(!..())
		return

	var/fibers_detected = 0

	if(A.suit_fibers && A.suit_fibers.len)
		for(var/fiber in A.suit_fibers)
			scnr.add_log("[fiber]", user)
			fibers_detected = 1

	if(!fibers_detected)
		scnr.add_log("<span class='notice'>No fibers detected</span>", user)

	return

/obj/item/weapon/scanner_module/fiber_module/L1

/obj/item/weapon/scanner_module/fiber_module/L2
	name = "advanced fiber scanmodule"
	range = 8
	origin_tech = "magnets=4;engineering=4"


//Electric MODULE
/obj/item/weapon/scanner_module/electric_module
	name = "electric scanmodule"
	range = 1
	scan_name = "Cable Scan:"
	desc = "A scanner module that connects to a power cable and reads the available power"
	origin_tech = "power=2;engineering=2"

/obj/item/weapon/scanner_module/electric_module/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)

	if(!istype(A, /obj/structure/cable))
		return

	if(!..())
		return

	var/obj/structure/cable/C = A

	var/datum/powernet/PN = C.get_powernet()		// find the powernet

	if(PN && (PN.avail > 0))		// is it powered?
		scnr.add_log("<span class='notice'>[PN.avail]W in power network.</span>", user)
	else
		scnr.add_log("<span class='notice'>The cable is not powered.</span>", user)

	return

/obj/item/weapon/scanner_module/electric_module/L1

/obj/item/weapon/scanner_module/electric_module/L2
	name = "advanced electric scanmodule"
	range = 8
	origin_tech = "power=3;engineering=3"

//MINING MODULE
/obj/item/weapon/scanner_module/mining_module
	name = "mining scanmodule"
	range = 1
	scan_name = "Mining Scan in progress"
	scan_on_attack_self = 1
	desc = "A scanner module that checks surrounding rock for useful minerals, it can also be used to stop gibtonite detonations. Requires you to wear mesons to work properly"
	var/cooldown = 0
	var/cooldowntime = 100
	origin_tech = "magnets=2;engineering=3"

/obj/item/weapon/scanner_module/mining_module/scan(var/atom/A, var/mob/user, var/obj/item/device/scanner/scnr)
	if(cooldown)
		return

	if(!..())
		return

	if(!user.client)
		return
	if(!cooldown)
		cooldown = 1
		spawn(cooldowntime)
			cooldown = 0
		var/client/C = user.client
		var/list/L = list()
		var/turf/simulated/mineral/M
		for(M in range(7, user))
			if(M.scan_state)
				L += M
		if(!L.len)
			scnr.add_log("<span class='notice'>Nothing was detected nearby.</span>", user)
			return
		else
			for(M in L)
				var/turf/T = get_turf(M)
				var/image/I = image('icons/turf/walls.dmi', loc = T, icon_state = M.scan_state, layer = 18)
				C.images += I
				spawn(cooldowntime/2)
					if(C)
						C.images -= I

	return
/obj/item/weapon/scanner_module/mining_module/L1
	cooldowntime = 100
/obj/item/weapon/scanner_module/mining_module/L2
	name = "advanced mining scanmodule"
	cooldowntime = 40
	origin_tech = "magnets=3;engineering=4"

