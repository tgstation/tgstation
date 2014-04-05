/obj/item/weapon/scanner_module
	name = "dummy scanner module"
	desc = "Just an empty cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = 1

	var/range = 1
	var/scan_name = "dummy scan"

/obj/item/weapon/scanner_module/proc/scan(var/atom/A, var/mob/user)

	if(get_dist(A, user) > range)
		user.show_message(text("<span class='notice'>[] is not in range.</span>", A), 1)
		return 0

	user.show_message(text("<span class='info'><B>[]</B></span>", scan_name), 1)
	return 1

//MEDBAY SCANNER MODULE
/obj/item/weapon/scanner_module/health_module
	name = "health scanner module"
	scan_name = "Health Scan Results:"

/obj/item/weapon/scanner_module/health_module/scan(var/atom/A, var/mob/user)

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

	user.show_message(text("<span class='notice'>Analyzing Results for []:\n\t Overall Status: []</span>", M, mob_status), 1)
	user.show_message(text("<span class='notice'>\t Damage Specifics: <font color='blue'>[]</font>-<font color='green'>[]</font>-<font color='#FF8000'>[]</font>-<font color='red'>[]</font></span>", oxy_loss, tox_loss, fire_loss, brute_loss), 1)

	user.show_message("<span class='notice'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font></span>", 1)
	user.show_message("<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>", 1)

	// Time of death
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		user.show_message("<span class='notice'>Time of Death:</span> [M.tod]")

	// Organ damage report
	if(istype(M, /mob/living/carbon/human))
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

	if(M.getStaminaLoss())
		user.show_message(text("<span class='info'>Subject appears to be suffering from fatigue.</span>"), 1)

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

//ATMOS SCANNER MODULE
/obj/item/weapon/scanner_module/atmos_module
	name = "atmosphere scanner module"
	range = 1
	scan_name = "Atmosphere Scan Results:"

/obj/item/weapon/scanner_module/atmos_module/scan(var/atom/A, var/mob/user)

	var/turf/location = A
	if (!( istype(location, /turf) ))
		return

	if(!..())
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

	return

//BLOOD DNA MODULE
/obj/item/weapon/scanner_module/blood_dna_module
	name = "blood scanner module"
	range = 1
	scan_name = "Blood:"

/obj/item/weapon/scanner_module/blood_dna_module/scan(var/atom/A, var/mob/user)
	if(!..())
		return

	var/blood_detected = 0
	if(A.blood_DNA && A.blood_DNA.len)
		var/list/blood = A.blood_DNA.Copy()
		for(var/B in blood)
			user.show_message("Type: <font color='red'>[blood[B]]</font> DNA: <font color='red'>[B]</font>")
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
					user.show_message("Type: <font color='red'>[blood_type]</font> DNA: <font color='red'>[blood_DNA]</font>")
					blood_detected = 1
	if(!blood_detected)
		user.show_message("<span class='notice'>No blood detected.</span>", 1)
	return
