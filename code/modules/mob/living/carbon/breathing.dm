//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing(times_fired)
	if((times_fired % 4) == 2 || failed_last_breath)
		breathe() //Breathe per 4 ticks, unless suffocating
		if(failed_last_breath)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "suffocation", /datum/mood_event/suffocation)
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "suffocation")
	else if(isobj(loc))
		var/obj/location_as_object = loc
		location_as_object.handle_internal_lifeform(src, 0)

//Second link in a breath chain, calls check_breath()
/mob/living/carbon/proc/breathe()
	if(reagents.has_reagent("lexorin"))
		return
	if(istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return

	if(!getorganslot(ORGAN_SLOT_BREATHING_TUBE))
		if(health <= HEALTH_THRESHOLD_FULLCRIT || (pulledby && pulledby.grab_state >= GRAB_KILL))
			losebreath++  //You can't breath at all when in critical or when being choked, so you're going to miss a breath
		else if(health <= crit_threshold)
			losebreath += 0.25 //You're having trouble breathing in soft crit, so you'll miss a breath one in four times

	//Suffocate
	if(losebreath >= 1) //You've missed a breath, take oxy damage
		losebreath--
		if(prob(10))
			emote("gasp")
		if(istype(loc, /obj/))
			var/obj/O = loc
			O.handle_internal_lifeform(src, 0)
		check_breath(null)
	else
		//Breathe from internal
		var/datum/gas_mixture/breath = get_breath_from_internal(BREATH_VOLUME)

		if(isnull(breath)) //if 0 pressure internals
			if(isobj(loc))
				var/obj/O = loc
				breath = O.handle_internal_lifeform(src, BREATH_VOLUME)
			else if(isturf(loc))
				breath = loc.remove_air( loc.return_air().total_moles() * BREATH_PERCENTAGE )
		else if(isobj(loc))
			var/obj/O = loc
			O.handle_internal_lifeform(src, 0)

		check_breath(breath)

		if(breath)
			loc.assume_air(breath)
			air_update_turf()

#define PARTIAL_PRESSURE_OF(G) (breath_gases[G][MOLES] * R_IDEAL_GAS_EQUATION * breath.temperature / BREATH_VOLUME)

//Third link in a breath chain, calls handle_breath_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	var/lungs = getorganslot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		adjustOxyLoss(2)

	//CRIT
	if(!breath || !lungs || !breath.total_moles())
		if(lungs && reagents.has_reagent("epinephrine"))
			return
		adjustOxyLoss(1)

		failed_last_breath = 1
		throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		return FALSE

	var/list/breath_gases = breath.gases
	breath.assert_gases(/datum/gas/oxygen, /datum/gas/plasma, /datum/gas/carbon_dioxide, /datum/gas/nitrous_oxide, /datum/gas/bz)

	//OXYGEN
	var/oxygen_used = 0
	var/o2_pp = PARTIAL_PRESSURE_OF(/datum/gas/oxygen)

	if(o2_pp < CARBON_SAFE_OXY_MIN) //Not enough oxygen
		if(prob(20))
			emote("gasp")
		if(o2_pp > 0)
			var/ratio = 1 - o2_pp/CARBON_SAFE_OXY_MIN
			adjustOxyLoss(min(5*ratio, 3))
			failed_last_breath = 1
			oxygen_used = breath_gases[/datum/gas/oxygen][MOLES]*ratio
		else
			adjustOxyLoss(3)
			failed_last_breath = 1
		throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)

	else //Enough oxygen
		failed_last_breath = 0
		if(health >= crit_threshold)
			adjustOxyLoss(-5)
		oxygen_used = breath_gases[/datum/gas/oxygen][MOLES]
		clear_alert("not_enough_oxy")

	breath_gases[/datum/gas/oxygen][MOLES] -= oxygen_used
	breath_gases[/datum/gas/carbon_dioxide][MOLES] += oxygen_used

	//CARBON DIOXIDE
	if(PARTIAL_PRESSURE_OF(/datum/gas/carbon_dioxide) > CARBON_SAFE_CO2_MAX)
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
	if(PARTIAL_PRESSURE_OF(/datum/gas/plasma) > CARBON_SAFE_TOX_MAX)
		var/ratio = 10 * breath_gases[/datum/gas/plasma][MOLES] / CARBON_SAFE_TOX_MAX
		adjustToxLoss(CLAMP(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		throw_alert("too_much_tox", /obj/screen/alert/too_much_tox)
	else
		clear_alert("too_much_tox")

	//NITROUS OXIDE
	if(breath_gases[/datum/gas/nitrous_oxide])
		var/pp = PARTIAL_PRESSURE_OF(/datum/gas/nitrous_oxide)
		if(pp > CARBON_SA_PARA_MIN)
			Unconscious(60)
			if(pp > CARBON_SA_SLEEP_MIN)
				Sleeping(max(AmountSleeping() + 40, 200))
		else if(pp > 0.01)
			if(prob(20))
				emote(pick("giggle","laugh"))
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")

	//BZ (Facepunch port of their Agent B)
	if(breath_gases[/datum/gas/bz])
		var/pp = PARTIAL_PRESSURE_OF(/datum/gas/bz)
		if(pp > 1)
			hallucination += 10
		else if(pp > 0.01)
			hallucination += 5

	//TRITIUM
	if(breath_gases[/datum/gas/tritium])
		radiation += PARTIAL_PRESSURE_OF(/datum/gas/tritium) / 10

	//NITRYL
	if(breath_gases[/datum/gas/nitryl])
		adjustFireLoss(PARTIAL_PRESSURE_OF(/datum/gas/nitryl) / 4)

	//MIASMA
	if(breath_gases[/datum/gas/miasma])
		var/pp = PARTIAL_PRESSURE_OF(/datum/gas/miasma)

		if(prob(1 * pp))
			var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(2,3)
			miasma_disease.name = "Unknown"
			ForceContractDisease(miasma_disease, TRUE, TRUE)

		//Miasma side effects
		switch(pp)
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
				if(prob(15))
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
					to_chat(src, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
					if(prob(33))
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

	handle_breath_temperature(breath)

	return TRUE

#undef PARTIAL_PRESSURE_OF

//Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	return

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(!internal)
		return
	if(internal.loc != src)
		internal = null
		update_internals_hud_icon(0)
		return
	if(!getorganslot(ORGAN_SLOT_BREATHING_TUBE))
		if(!wear_mask || !(wear_mask.clothing_flags & MASKINTERNALS))
			internal = null
			update_internals_hud_icon(0)
			return

	update_internals_hud_icon(1)
	//will return FALSE instead of null, to differentiate no internals and empty internals
	return internal.remove_air_volume(volume_needed) || FALSE
