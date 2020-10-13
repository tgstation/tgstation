/mob/living/carbon/Life()

	if(notransform)
		return

	if(damageoverlaytemp)
		damageoverlaytemp = 0
		update_damage_hud()

	if(!IS_IN_STASIS(src))

		//Reagent processing needs to come before breathing, to prevent edge cases.
		handle_organs()

		. = ..()

		if (QDELETED(src))
			return

		if(.) //not dead
			handle_blood()

		if(stat != DEAD)
			handle_brain_damage()

	else
		. = ..()

	if(stat == DEAD)
		stop_sound_channel(CHANNEL_HEARTBEAT)
		LoadComponent(/datum/component/rot/corpse)
	else
		var/bprv = handle_bodyparts()
		if(bprv & BODYPART_LIFE_UPDATE_HEALTH)
			update_stamina() //needs to go before updatehealth to remove stamcrit
			updatehealth()

	check_cremation()

	//Updates the number of stored chemicals for powers
	handle_changeling()

	if(stat != DEAD)
		return 1

///////////////
// BREATHING //
///////////////

//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing(times_fired)
	var/next_breath = 4
	var/obj/item/organ/lungs/L = getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/heart/H = getorganslot(ORGAN_SLOT_HEART)
	if(L)
		if(L.damage > L.high_threshold)
			next_breath--
	if(H)
		if(H.damage > H.high_threshold)
			next_breath--

	if((times_fired % next_breath) == 0 || failed_last_breath)
		breathe() //Breathe per 4 ticks if healthy, down to 2 if our lungs or heart are damaged, unless suffocating
		if(failed_last_breath)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "suffocation", /datum/mood_event/suffocation)
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "suffocation")
	else
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src,0)

//Second link in a breath chain, calls check_breath()
/mob/living/carbon/proc/breathe()
	var/obj/item/organ/lungs = getorganslot(ORGAN_SLOT_LUNGS)
	if(has_reagent(/datum/reagent/toxin/lexorin, needs_metabolizing = TRUE))
		return
	if(istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(!getorganslot(ORGAN_SLOT_BREATHING_TUBE))
		if(health <= HEALTH_THRESHOLD_FULLCRIT || (pulledby && pulledby.grab_state >= GRAB_KILL) || HAS_TRAIT(src, TRAIT_MAGIC_CHOKE) || (lungs && lungs.organ_flags & ORGAN_FAILING))
			losebreath++  //You can't breath at all when in critical or when being choked, so you're going to miss a breath

		else if(health <= crit_threshold)
			losebreath += 0.25 //You're having trouble breathing in soft crit, so you'll miss a breath one in four times

	//Suffocate
	if(losebreath >= 1) //You've missed a breath, take oxy damage
		losebreath--
		if(prob(10))
			emote("gasp")
		if(istype(loc, /obj/))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src,0)
	else
		//Breathe from internal
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(isnull(breath)) //in case of 0 pressure internals

			if(isobj(loc)) //Breathe from loc as object
				var/obj/loc_as_obj = loc
				breath = loc_as_obj.handle_internal_lifeform(src, BREATH_VOLUME)

			else if(isturf(loc)) //Breathe from loc as turf
				var/breath_moles = 0
				if(environment)
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)
		else //Breathe from loc as obj again
			if(istype(loc, /obj/))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	check_breath(breath)

	if(breath)
		loc.assume_air(breath)
		air_update_turf()

/mob/living/carbon/proc/has_smoke_protection()
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return TRUE
	return FALSE


//Third link in a breath chain, calls handle_breath_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		failed_last_breath = FALSE
		clear_alert("not_enough_oxy")
		return FALSE
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return FALSE

	var/obj/item/organ/lungs = getorganslot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		adjustOxyLoss(2)

	//CRIT
	if(!breath || (breath.total_moles() == 0) || !lungs)
		if(has_reagent(/datum/reagent/medicine/epinephrine, needs_metabolizing = TRUE) && lungs)
			return FALSE
		adjustOxyLoss(1)

		failed_last_breath = TRUE
		throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		return FALSE

	var/safe_oxy_min = 16
	var/safe_co2_max = 10
	var/safe_tox_max = 0.05
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	var/list/breath_gases = breath.gases
	breath.assert_gases(/datum/gas/oxygen, /datum/gas/plasma, /datum/gas/carbon_dioxide, /datum/gas/nitrous_oxide, /datum/gas/bz)
	var/O2_partialpressure = (breath_gases[/datum/gas/oxygen][MOLES]/breath.total_moles())*breath_pressure
	var/Toxins_partialpressure = (breath_gases[/datum/gas/plasma][MOLES]/breath.total_moles())*breath_pressure
	var/CO2_partialpressure = (breath_gases[/datum/gas/carbon_dioxide][MOLES]/breath.total_moles())*breath_pressure


	//OXYGEN
	if(O2_partialpressure < safe_oxy_min) //Not enough oxygen
		if(prob(20))
			emote("gasp")
		if(O2_partialpressure > 0)
			var/ratio = 1 - O2_partialpressure/safe_oxy_min
			adjustOxyLoss(min(5*ratio, 3))
			failed_last_breath = TRUE
			oxygen_used = breath_gases[/datum/gas/oxygen][MOLES]*ratio
		else
			adjustOxyLoss(3)
			failed_last_breath = TRUE
		throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)

	else //Enough oxygen
		failed_last_breath = FALSE
		if(health >= crit_threshold)
			adjustOxyLoss(-5)
		oxygen_used = breath_gases[/datum/gas/oxygen][MOLES]
		clear_alert("not_enough_oxy")

	breath_gases[/datum/gas/oxygen][MOLES] -= oxygen_used
	breath_gases[/datum/gas/carbon_dioxide][MOLES] += oxygen_used

	//CARBON DIOXIDE
	if(CO2_partialpressure > safe_co2_max)
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Unconscious(60)
			adjustOxyLoss(3)
			if(world.time - co2overloadtime > 300)
				adjustOxyLoss(8)
		if(prob(20))
			emote("cough")

	else
		co2overloadtime = 0

	//TOXINS/PLASMA
	if(Toxins_partialpressure > safe_tox_max)
		var/ratio = (breath_gases[/datum/gas/plasma][MOLES]/safe_tox_max) * 10
		adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		throw_alert("too_much_tox", /obj/screen/alert/too_much_tox)
	else
		clear_alert("too_much_tox")

	//NITROUS OXIDE
	if(breath_gases[/datum/gas/nitrous_oxide])
		var/SA_partialpressure = (breath_gases[/datum/gas/nitrous_oxide][MOLES]/breath.total_moles())*breath_pressure
		if(SA_partialpressure > SA_para_min)
			Unconscious(60)
			if(SA_partialpressure > SA_sleep_min)
				Sleeping(max(AmountSleeping() + 40, 200))
		else if(SA_partialpressure > 0.01)
			if(prob(20))
				emote(pick("giggle","laugh"))
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
		if(SA_partialpressure > safe_tox_max*3)
			var/ratio = (breath_gases[/datum/gas/nitrous_oxide][MOLES]/safe_tox_max)
			adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
			throw_alert("too_much_tox", /obj/screen/alert/too_much_tox)
		else
			clear_alert("too_much_tox")
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")

	//BZ (Facepunch port of their Agent B)
	if(breath_gases[/datum/gas/bz])
		var/bz_partialpressure = (breath_gases[/datum/gas/bz][MOLES]/breath.total_moles())*breath_pressure
		if(bz_partialpressure > 1)
			hallucination += 10
		else if(bz_partialpressure > 0.01)
			hallucination += 5

	//TRITIUM
	if(breath_gases[/datum/gas/tritium])
		var/tritium_partialpressure = (breath_gases[/datum/gas/tritium][MOLES]/breath.total_moles())*breath_pressure
		radiation += tritium_partialpressure/10

	//NITRYL
	if(breath_gases[/datum/gas/nitryl])
		var/nitryl_partialpressure = (breath_gases[/datum/gas/nitryl][MOLES]/breath.total_moles())*breath_pressure
		adjustFireLoss(nitryl_partialpressure/4)

	//FREON
	if(breath_gases[/datum/gas/freon])
		var/freon_partialpressure = (breath_gases[/datum/gas/freon][MOLES]/breath.total_moles())*breath_pressure
		adjustFireLoss(freon_partialpressure * 0.25)

	//MIASMA
	if(breath_gases[/datum/gas/miasma])
		var/miasma_partialpressure = (breath_gases[/datum/gas/miasma][MOLES]/breath.total_moles())*breath_pressure

		if(prob(1 * miasma_partialpressure))
			var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(2,3)
			miasma_disease.name = "Unknown"
			ForceContractDisease(miasma_disease, TRUE, TRUE)

		//Miasma side effects
		switch(miasma_partialpressure)
			if(0.25 to 5)
				// At lower pp, give out a little warning
				SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")
				if(prob(5))
					to_chat(src, "<span class='notice'>There is an unpleasant smell in the air.</span>")
			if(5 to 20)
				//At somewhat higher pp, warning becomes more obvious
				if(prob(15))
					to_chat(src, "<span class='warning'>You smell something horribly decayed inside this room.</span>")
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/bad_smell)
			if(15 to 30)
				//Small chance to vomit. By now, people have internals on anyway
				if(prob(5))
					to_chat(src, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
					vomit()
			if(30 to INFINITY)
				//Higher chance to vomit. Let the horror start
				if(prob(25))
					to_chat(src, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
					vomit()
			else
				SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")

	//Clear all moods if no miasma at all
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")

	breath.garbage_collect()

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

	return TRUE

//Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	// The air you breathe out should match your body temperature
	breath.temperature = bodytemperature

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if(internal.loc != src)
			internal = null
			update_internals_hud_icon(0)
		else if ((!wear_mask || !(wear_mask.clothing_flags & MASKINTERNALS)) && !getorganslot(ORGAN_SLOT_BREATHING_TUBE))
			internal = null
			update_internals_hud_icon(0)
		else
			update_internals_hud_icon(1)
			. = internal.remove_air_volume(volume_needed)
			if(!.)
				return FALSE //to differentiate between no internals and active, but empty internals

/mob/living/carbon/proc/handle_blood()
	return

/mob/living/carbon/proc/handle_bodyparts()
	var/stam_regen = FALSE
	if(stam_regen_start_time <= world.time)
		stam_regen = TRUE
		if(HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA))
			. |= BODYPART_LIFE_UPDATE_HEALTH //make sure we remove the stamcrit
	for(var/I in bodyparts)
		var/obj/item/bodypart/BP = I
		if(BP.needs_processing)
			. |= BP.on_life(stam_regen)

/mob/living/carbon/proc/handle_organs()
	if(stat != DEAD)
		for(var/V in internal_organs)
			var/obj/item/organ/O = V
			if(O.owner) // This exist mostly because reagent metabolization can cause organ reshuffling
				O.on_life()
	else
		if(has_reagent(/datum/reagent/toxin/formaldehyde, 1)) // No organ decay if the body contains formaldehyde.
			return
		for(var/V in internal_organs)
			var/obj/item/organ/O = V
			O.on_death() //Needed so organs decay while inside the body.

/mob/living/carbon/handle_diseases()
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(prob(D.infectivity))
			D.spread()

		if(stat != DEAD || D.process_dead)
			D.stage_act()

/mob/living/carbon/handle_wounds()
	for(var/thing in all_wounds)
		var/datum/wound/W = thing
		if(W.processes) // meh
			W.handle_process()

//todo generalize this and move hud out
/mob/living/carbon/proc/handle_changeling()
	if(mind && hud_used?.lingchemdisplay)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.regenerate()
			hud_used.lingchemdisplay.invisibility = 0
			hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(changeling.chem_charges)]</font></div>"
		else
			hud_used.lingchemdisplay.invisibility = INVISIBILITY_ABSTRACT


/mob/living/carbon/handle_mutations_and_radiation()
	if(dna?.temporary_mutations.len)
		for(var/mut in dna.temporary_mutations)
			if(dna.temporary_mutations[mut] < world.time)
				if(mut == UI_CHANGED)
					if(dna.previous["UI"])
						dna.uni_identity = merge_text(dna.uni_identity,dna.previous["UI"])
						updateappearance(mutations_overlay_update=1)
						dna.previous.Remove("UI")
					dna.temporary_mutations.Remove(mut)
					continue
				if(mut == UE_CHANGED)
					if(dna.previous["name"])
						real_name = dna.previous["name"]
						name = real_name
						dna.previous.Remove("name")
					if(dna.previous["UE"])
						dna.unique_enzymes = dna.previous["UE"]
						dna.previous.Remove("UE")
					if(dna.previous["blood_type"])
						dna.blood_type = dna.previous["blood_type"]
						dna.previous.Remove("blood_type")
					dna.temporary_mutations.Remove(mut)
					continue
		for(var/datum/mutation/human/HM in dna.mutations)
			if(HM?.timed)
				dna.remove_mutation(HM.type)

	radiation -= min(radiation, RAD_LOSS_PER_TICK)
	if(radiation > RAD_MOB_SAFE)
		adjustToxLoss(log(radiation-RAD_MOB_SAFE)*RAD_TOX_COEFFICIENT)


/*
Alcohol Poisoning Chart
Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
In addition, severe effects won't always trigger unless the drink is poisonously strong
All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance

0: Non-alcoholic
1-10: Barely classifiable as alcohol - occassional slurring
11-20: Slight alcohol content - slurring
21-30: Below average - imbiber begins to look slightly drunk
31-40: Just below average - no unique effects
41-50: Average - mild disorientation, imbiber begins to look drunk
51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
71-80: High alcohol content - blurry vision, imbiber completely shitfaced
81-90: Extremely high alcohol content - light brain damage, passing out
91-100: Dangerously toxic - swift death
*/
#define BALLMER_POINTS 5

//this updates all special effects: stun, sleeping, knockdown, druggy, stuttering, etc..
/mob/living/carbon/handle_status_effects()
	..()

	var/restingpwr = 1 + 4 * resting

	//Dizziness
	if(dizziness)
		var/client/C = client
		var/pixel_x_diff = 0
		var/pixel_y_diff = 0
		var/temp
		var/saved_dizz = dizziness
		if(C)
			var/oldsrc = src
			var/amplitude = dizziness*(sin(dizziness * world.time) + 1) // This shit is annoying at high strength
			src = null
			spawn(0)
				if(C)
					temp = amplitude * sin(saved_dizz * world.time)
					pixel_x_diff += temp
					C.pixel_x += temp
					temp = amplitude * cos(saved_dizz * world.time)
					pixel_y_diff += temp
					C.pixel_y += temp
					sleep(3)
					if(C)
						temp = amplitude * sin(saved_dizz * world.time)
						pixel_x_diff += temp
						C.pixel_x += temp
						temp = amplitude * cos(saved_dizz * world.time)
						pixel_y_diff += temp
						C.pixel_y += temp
					sleep(3)
					if(C)
						C.pixel_x -= pixel_x_diff
						C.pixel_y -= pixel_y_diff
			src = oldsrc
		dizziness = max(dizziness - restingpwr, 0)

	if(drowsyness)
		drowsyness = max(drowsyness - restingpwr, 0)
		blur_eyes(2)
		if(prob(5))
			AdjustSleeping(100)

	//Jitteriness
	if(jitteriness)
		do_jitter_animation(jitteriness)
		jitteriness = max(jitteriness - restingpwr, 0)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "jittery", /datum/mood_event/jittery)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "jittery")

	if(stuttering)
		stuttering = max(stuttering-1, 0)

	if(slurring)
		slurring = max(slurring-1,0)

	if(cultslurring)
		cultslurring = max(cultslurring-1, 0)

	if(silent)
		silent = max(silent-1, 0)

	if(druggy)
		adjust_drugginess(-1)

	if(hallucination)
		handle_hallucinations()

	if(drunkenness)
		drunkenness = max(drunkenness - (drunkenness * 0.04) - 0.01, 0)
		if(drunkenness >= 6)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "drunk", /datum/mood_event/drunk)
			if(prob(25))
				slurring += 2
			jitteriness = max(jitteriness - 3, 0)
			throw_alert("drunk", /obj/screen/alert/drunk)
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "drunk")
			clear_alert("drunk")

		if(drunkenness >= 11 && slurring < 5)
			slurring += 1.2

		if(mind && (mind.assigned_role == "Scientist" || mind.assigned_role == "Research Director"))
			if(SSresearch.science_tech)
				if(drunkenness >= 12.9 && drunkenness <= 13.8)
					drunkenness = round(drunkenness, 0.01)
					var/ballmer_percent = 0
					if(drunkenness == 13.35) // why run math if I dont have to
						ballmer_percent = 1
					else
						ballmer_percent = (-abs(drunkenness - 13.35) / 0.9) + 1
					if(prob(5))
						say(pick_list_replacements(VISTA_FILE, "ballmer_good_msg"), forced = "ballmer")
					SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = BALLMER_POINTS * ballmer_percent))
				if(drunkenness > 26) // by this point you're into windows ME territory
					if(prob(5))
						SSresearch.science_tech.remove_point_list(list(TECHWEB_POINT_TYPE_GENERIC = BALLMER_POINTS))
						say(pick_list_replacements(VISTA_FILE, "ballmer_windows_me_msg"), forced = "ballmer")

		if(drunkenness >= 41)
			if(prob(25))
				add_confusion(2)
			Dizzy(10)

		if(drunkenness >= 51)
			if(prob(3))
				add_confusion(15)
				vomit() // vomiting clears toxloss, consider this a blessing
			Dizzy(25)

		if(drunkenness >= 61)
			if(prob(50))
				blur_eyes(5)

		if(drunkenness >= 71)
			blur_eyes(5)

		if(drunkenness >= 81)
			adjustToxLoss(1)
			if(prob(5) && !stat)
				to_chat(src, "<span class='warning'>Maybe you should lie down for a bit...</span>")

		if(drunkenness >= 91)
			adjustToxLoss(1)
			adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.4)
			if(prob(20) && !stat)
				if(SSshuttle.emergency.mode == SHUTTLE_DOCKED && is_station_level(z)) //QoL mainly
					to_chat(src, "<span class='warning'>You're so tired... but you can't miss that shuttle...</span>")
				else
					to_chat(src, "<span class='warning'>Just a quick nap...</span>")
					Sleeping(900)

		if(drunkenness >= 101)
			adjustToxLoss(2) //Let's be honest you shouldn't be alive by now

/// Base carbon environment handler, adds natural stabilization
/mob/living/carbon/handle_environment(datum/gas_mixture/environment)
	var/areatemp = get_temperature(environment)

	if(stat != DEAD) // If you are dead your body does not stabilize naturally
		natural_bodytemperature_stabilization(environment)

	if(!on_fire || areatemp > bodytemperature) // If we are not on fire or the area is hotter
		adjust_bodytemperature((areatemp - bodytemperature), use_insulation=TRUE, use_steps=TRUE)

/**
 * Used to stabilize the body temperature back to normal on living mobs
 *
 * vars:
 * * environment The environment gas mix
 */
/mob/living/carbon/proc/natural_bodytemperature_stabilization(datum/gas_mixture/environment)
	var/areatemp = get_temperature(environment)
	var/body_temperature_difference = get_body_temp_normal() - bodytemperature
	var/natural_change = 0

	// We are very cold, increate body temperature
	if(bodytemperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
		natural_change = max((body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR), \
			BODYTEMP_AUTORECOVERY_MINIMUM)

	// we are cold, reduce the minimum increment and do not jump over the difference
	else if(bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT && bodytemperature < get_body_temp_normal())
		natural_change = max(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, \
			min(body_temperature_difference, BODYTEMP_AUTORECOVERY_MINIMUM / 4))

	// We are hot, reduce the minimum increment and do not jump below the difference
	else if(bodytemperature > get_body_temp_normal() && bodytemperature <= BODYTEMP_HEAT_DAMAGE_LIMIT)
		natural_change = min(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, \
			max(body_temperature_difference, -(BODYTEMP_AUTORECOVERY_MINIMUM / 4)))

	// We are very hot, reduce the body temperature
	else if(bodytemperature >= BODYTEMP_HEAT_DAMAGE_LIMIT)
		natural_change = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)

	var/thermal_protection = 1 - get_insulation_protection(areatemp) // invert the protection
	if(areatemp > bodytemperature) // It is hot here
		if(bodytemperature < get_body_temp_normal())
			// Our bodytemp is below normal we are cold, insulation helps us retain body heat
			// and will reduce the heat we lose to the environment
			natural_change = (thermal_protection + 1) * natural_change
		else
			// Our bodytemp is above normal and sweating, insulation hinders out ability to reduce heat
			// but will reduce the amount of heat we get from the environment
			natural_change = (1 / (thermal_protection + 1)) * natural_change
	else // It is cold here
		if(!on_fire) // If on fire ignore ignore local temperature in cold areas
			if(bodytemperature < get_body_temp_normal())
				// Our bodytemp is below normal, insulation helps us retain body heat
				// and will reduce the heat we lose to the environment
				natural_change = (thermal_protection + 1) * natural_change
			else
				// Our bodytemp is above normal and sweating, insulation hinders out ability to reduce heat
				// but will reduce the amount of heat we get from the environment
				natural_change = (1 / (thermal_protection + 1)) * natural_change

	// Apply the natural stabilization changes
	adjust_bodytemperature(natural_change)

/**
 * Get the insulation that is appropriate to the temperature you're being exposed to.
 * All clothing, natural insulation, and traits are combined returning a single value.
 *
 * required temperature The Temperature that you're being exposed to
 *
 * return the percentage of protection as a value from 0 - 1
**/
/mob/living/carbon/proc/get_insulation_protection(temperature)
	return (temperature > bodytemperature) ? get_heat_protection(temperature) : get_cold_protection(temperature)

/// This returns the percentage of protection from heat as a value from 0 - 1
/// temperature is the temperature you're being exposed to
/mob/living/carbon/proc/get_heat_protection(temperature)
	return heat_protection

/// This returns the percentage of protection from cold as a value from 0 - 1
/// temperature is the temperature you're being exposed to
/mob/living/carbon/proc/get_cold_protection(temperature)
	return cold_protection

/**
 * Have two mobs share body heat between each other.
 * Account for the insulation and max temperature change range for the mob
 *
 * vars:
 * * M The mob/living/carbon that is sharing body heat
 */
/mob/living/carbon/proc/share_bodytemperature(mob/living/carbon/M)
	var/temp_diff = bodytemperature - M.bodytemperature
	if(temp_diff > 0) // you are warm share the heat of life
		M.adjust_bodytemperature((temp_diff * 0.5), use_insulation=TRUE, use_steps=TRUE) // warm up the giver
		adjust_bodytemperature((temp_diff * -0.5), use_insulation=TRUE, use_steps=TRUE) // cool down the reciver

	else // they are warmer leech from them
		adjust_bodytemperature((temp_diff * -0.5) , use_insulation=TRUE, use_steps=TRUE) // warm up the reciver
		M.adjust_bodytemperature((temp_diff * 0.5), use_insulation=TRUE, use_steps=TRUE) // cool down the giver

/**
 * Adjust the body temperature of a mob
 * expanded for carbon mobs allowing the use of insulation and change steps
 *
 * vars:
 * * amount The amount of degrees to change body temperature by
 * * min_temp (optional) The minimum body temperature after adjustment
 * * max_temp (optional) The maximum body temperature after adjustment
 * * use_insulation (optional) modifies the amount based on the amount of insulation the mob has
 * * use_steps (optional) Use the body temp divisors and max change rates
 * * capped (optional) default True used to cap step mode
 */
/mob/living/carbon/adjust_bodytemperature(amount, min_temp=0, max_temp=INFINITY, use_insulation=FALSE, use_steps=FALSE, capped=TRUE)
	// apply insulation to the amount of change
	if(use_insulation)
		amount *= (1 - get_insulation_protection(bodytemperature + amount))

	// Use the bodytemp divisors to get the change step, with max step size
	if(use_steps)
		amount = (amount > 0) ? (amount / BODYTEMP_HEAT_DIVISOR) : (amount / BODYTEMP_COLD_DIVISOR)
		// Clamp the results to the min and max step size
		if(capped)
			amount = (amount > 0) ? min(amount, BODYTEMP_HEATING_MAX) : max(amount, BODYTEMP_COOLING_MAX)

	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = clamp(bodytemperature + amount,min_temp,max_temp)


///////////
//Stomach//
///////////

/mob/living/carbon/get_fullness()
	var/fullness = nutrition

	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(!belly) //nothing to see here if we do not have a stomach
		return fullness

	for(var/bile in belly.reagents.reagent_list)
		var/datum/reagent/bits = bile
		if(istype(bits, /datum/reagent/consumable))
			var/datum/reagent/consumable/goodbit = bile
			fullness += goodbit.nutriment_factor * goodbit.volume / goodbit.metabolization_rate
			continue
		fullness += 0.6 * bits.volume / bits.metabolization_rate //not food takes up space

	return fullness

/mob/living/carbon/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	. = ..()
	if(.)
		return
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(!belly)
		return FALSE
	return belly.reagents.has_reagent(reagent, amount, needs_metabolizing)

/mob/living/carbon/remove_reagent(reagent, custom_amount, safety)
	if(!custom_amount)
		custom_amount = get_reagent_amount(reagent)
	var/amount_body = reagents.get_reagent_amount(reagent)
	if(custom_amount <= amount_body)
		reagents.remove_reagent(reagent, custom_amount, safety)
		return	TRUE
	reagents.remove_reagent(reagent, amount_body, safety)
	custom_amount -= amount_body
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(!belly)
		return FALSE
	belly.reagents.remove_reagent(reagent, custom_amount, safety)
	return TRUE

/mob/living/carbon/get_reagent_amount(reagent)
	. = ..()
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(!belly)
		return
	. += belly.reagents.get_reagent_amount(reagent)

/////////
//LIVER//
/////////

///Decides if the liver is failing or not.
/mob/living/carbon/proc/handle_liver()
	if(!dna)
		return
	var/obj/item/organ/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	if(!liver)
		liver_failure()

/mob/living/carbon/proc/undergoing_liver_failure()
	var/obj/item/organ/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	if(liver && (liver.organ_flags & ORGAN_FAILING))
		return TRUE

/mob/living/carbon/proc/liver_failure()
	end_metabolization(keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
	reagents.metabolize(src, can_overdose=FALSE, liverless = TRUE)
	if(HAS_TRAIT(src, TRAIT_STABLELIVER) || HAS_TRAIT(src, TRAIT_NOMETABOLISM))
		return
	adjustToxLoss(4, TRUE,  TRUE)
	if(prob(30))
		to_chat(src, "<span class='warning'>You feel a stabbing pain in your abdomen!</span>")

/**
 * Ends metabolization on the mob
 *
 * This stop all reagents in the body and organs from metabolizing
 * Vars:
 * * keep_liverless (bool)(optional)(default:TRUE) Will keep working without a liver
 */
/mob/living/carbon/proc/end_metabolization(keep_liverless = TRUE)
	reagents.end_metabolization(src, keep_liverless = keep_liverless)
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(belly)
		belly.reagents.end_metabolization(src, keep_liverless = keep_liverless)

/////////////
//CREMATION//
/////////////
/mob/living/carbon/proc/check_cremation()
	//Only cremate while actively on fire
	if(!on_fire)
		return

	//Only starts when the chest has taken full damage
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!(chest.get_damage() >= chest.max_damage))
		return

	//Burn off limbs one by one
	var/obj/item/bodypart/limb
	var/list/limb_list = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/still_has_limbs = FALSE
	for(var/zone in limb_list)
		limb = get_bodypart(zone)
		if(limb)
			still_has_limbs = TRUE
			if(limb.get_damage() >= limb.max_damage)
				limb.cremation_progress += rand(2,5)
				if(limb.cremation_progress >= 100)
					if(limb.status == BODYPART_ORGANIC) //Non-organic limbs don't burn
						limb.drop_limb()
						limb.visible_message("<span class='warning'>[src]'s [limb.name] crumbles into ash!</span>")
						qdel(limb)
					else
						limb.drop_limb()
						limb.visible_message("<span class='warning'>[src]'s [limb.name] detaches from [p_their()] body!</span>")
	if(still_has_limbs)
		return

	//Burn the head last
	var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
	if(head)
		if(head.get_damage() >= head.max_damage)
			head.cremation_progress += rand(2,5)
			if(head.cremation_progress >= 100)
				if(head.status == BODYPART_ORGANIC) //Non-organic limbs don't burn
					head.drop_limb()
					head.visible_message("<span class='warning'>[src]'s head crumbles into ash!</span>")
					qdel(head)
				else
					head.drop_limb()
					head.visible_message("<span class='warning'>[src]'s head detaches from [p_their()] body!</span>")
		return

	//Nothing left: dust the body, drop the items (if they're flammable they'll burn on their own)
	chest.cremation_progress += rand(2,5)
	if(chest.cremation_progress >= 100)
		visible_message("<span class='warning'>[src]'s body crumbles into a pile of ash!</span>")
		dust(TRUE, TRUE)

////////////////
//BRAIN DAMAGE//
////////////////

/mob/living/carbon/proc/handle_brain_damage()
	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_life()

/////////////////////////////////////
//MONKEYS WITH TOO MUCH CHOLOESTROL//
/////////////////////////////////////

/mob/living/carbon/proc/can_heartattack()
	if(!needs_heart())
		return FALSE
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(!heart || (heart.organ_flags & ORGAN_SYNTHETIC))
		return FALSE
	return TRUE

/mob/living/carbon/proc/needs_heart()
	if(HAS_TRAIT(src, TRAIT_STABLEHEART))
		return FALSE
	if(dna && dna.species && (NOBLOOD in dna.species.species_traits)) //not all carbons have species!
		return FALSE
	return TRUE

/*
 * The mob is having a heart attack
 *
 * NOTE: this is true if the mob has no heart and needs one, which can be suprising,
 * you are meant to use it in combination with can_heartattack for heart attack
 * related situations (i.e not just cardiac arrest)
 */
/mob/living/carbon/proc/undergoing_cardiac_arrest()
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(istype(heart) && heart.beating)
		return FALSE
	else if(!needs_heart())
		return FALSE
	return TRUE

/mob/living/carbon/proc/set_heartattack(status)
	if(!can_heartattack())
		return FALSE

	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(!istype(heart))
		return

	heart.beating = !status
