/mob/living/carbon/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	if(damageoverlaytemp)
		damageoverlaytemp = 0
		update_damage_hud()

	if(HAS_TRAIT(src, TRAIT_STASIS))
		. = ..()
		reagents?.handle_stasis_chems(src, seconds_per_tick, times_fired)
	else
		//Reagent processing needs to come before breathing, to prevent edge cases.
		handle_dead_metabolization(seconds_per_tick, times_fired) //Dead metabolization first since it can modify life metabolization.
		handle_organs(seconds_per_tick, times_fired)

		. = ..()
		if(QDELETED(src))
			return

		if(.) //not dead
			handle_blood(seconds_per_tick, times_fired)

		if(stat != DEAD)
			handle_brain_damage(seconds_per_tick, times_fired)

	if(stat != DEAD)
		handle_bodyparts(seconds_per_tick, times_fired)

	if(. && mind) //. == not dead
		for(var/key in mind.addiction_points)
			var/datum/addiction/addiction = SSaddiction.all_addictions[key]
			addiction.process_addiction(src, seconds_per_tick, times_fired)
	if(stat != DEAD)
		return TRUE

///////////////
// BREATHING //
///////////////

// Start of a breath chain, calls [carbon/proc/breathe()]
/mob/living/carbon/handle_breathing(seconds_per_tick, times_fired)
	var/next_breath = 4
	var/obj/item/organ/lungs/L = get_organ_slot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/heart/H = get_organ_slot(ORGAN_SLOT_HEART)
	if(L)
		if(L.damage > L.high_threshold)
			next_breath--
	if(H)
		if(H.damage > H.high_threshold)
			next_breath--

	if((times_fired % next_breath) == 0 || failed_last_breath)
		breathe(seconds_per_tick, times_fired) //Breathe per 4 ticks if healthy, down to 2 if our lungs or heart are damaged, unless suffocating
		if(failed_last_breath)
			add_mood_event("suffocation", /datum/mood_event/suffocation)
		else
			clear_mood_event("suffocation")
	else
		if(isobj(loc))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src,0)

// Second link in a breath chain, calls [carbon/proc/check_breath()]
/mob/living/carbon/proc/breathe(seconds_per_tick, times_fired)
	var/obj/item/organ/lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	var/is_on_internals = FALSE

	if(SEND_SIGNAL(src, COMSIG_CARBON_ATTEMPT_BREATHE, seconds_per_tick, times_fired) & COMSIG_CARBON_BLOCK_BREATH)
		return

	SEND_SIGNAL(src, COMSIG_CARBON_PRE_BREATHE, seconds_per_tick, times_fired)

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(!get_organ_slot(ORGAN_SLOT_BREATHING_TUBE))
		if(health <= HEALTH_THRESHOLD_FULLCRIT || (pulledby?.grab_state >= GRAB_KILL) || (lungs?.organ_flags & ORGAN_FAILING))
			losebreath++  //You can't breath at all when in critical or when being choked, so you're going to miss a breath

		else if(health <= crit_threshold)
			losebreath += 0.25 //You're having trouble breathing in soft crit, so you'll miss a breath one in four times

	//Suffocate
	if(losebreath >= 1) //You've missed a breath, take oxy damage
		losebreath--
		if(prob(10))
			emote("gasp")
		if(isobj(loc))
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
			is_on_internals = TRUE

			if(isobj(loc))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	if(check_breath(breath) && is_on_internals)
		try_breathing_sound(breath)

	if(breath)
		loc.assume_air(breath)

//Tries to play the carbon a breathing sound when using internals, also invokes check_breath
/mob/living/carbon/proc/try_breathing_sound(breath)
	var/should_be_on =  canon_client?.prefs?.read_preference(/datum/preference/toggle/sound_breathing)
	if(should_be_on && !breathing_loop.timer_id && canon_client?.mob.can_hear())
		breathing_loop.start()
	else if((!should_be_on && breathing_loop.timer_id) || !canon_client?.mob.can_hear())
		breathing_loop.stop()

/mob/living/carbon/proc/has_smoke_protection()
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return TRUE
	return FALSE

/**
 * This proc tests if the lungs can breathe, if the mob can breathe a given gas mixture, and throws/clears gas alerts.
 * If there are moles of gas in the given gas mixture, side-effects may be applied/removed on the mob.
 * This proc expects a lungs organ in order to breathe successfully, but does not defer any work to it.
 *
 * Returns TRUE if the breath was successful, or FALSE if otherwise.
 *
 * Arguments:
 * * breath: A gas mixture to test, or null.
 */
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	. = TRUE

	if(HAS_TRAIT(src, TRAIT_GODMODE))
		failed_last_breath = FALSE
		clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		return

	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return

	// Breath may be null, so use a fallback "empty breath" for convenience.
	if(!breath)
		/// Fallback "empty breath" for convenience.
		var/static/datum/gas_mixture/immutable/empty_breath = new(BREATH_VOLUME)
		breath = empty_breath

	// Ensure gas volumes are present.
	breath.assert_gases(/datum/gas/bz, /datum/gas/carbon_dioxide, /datum/gas/freon, /datum/gas/plasma, /datum/gas/pluoxium, /datum/gas/miasma, /datum/gas/nitrous_oxide, /datum/gas/nitrium, /datum/gas/oxygen)

	/// The list of gases in the breath.
	var/list/breath_gases = breath.gases
	/// Indicates if there are moles of gas in the breath.
	var/has_moles = breath.total_moles() != 0

	var/obj/item/organ/lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	// Indicates if lungs can breathe without gas.
	var/can_breathe_vacuum = FALSE
	if(lungs)
		// Breathing with lungs.
		// Check for vacuum-adapted lungs.
		can_breathe_vacuum = HAS_TRAIT(lungs, TRAIT_SPACEBREATHING)
	else
		// Lungs are missing! Can't breathe.
		// Simulates breathing zero moles of gas.
		has_moles = FALSE
		// Extra damage, let God sort ’em out!
		adjustOxyLoss(2)

	/// Minimum O2 before suffocation.
	var/safe_oxygen_min = 16
	/// Maximum CO2 before side-effects.
	var/safe_co2_max = 10
	/// Maximum Plasma before side-effects.
	var/safe_plas_max = 0.05
	/// Maximum Pluoxum before side-effects.
	var/gas_stimulation_min = 0.002 // For Pluoxium
	// Vars for N2O induced euphoria, stun, and sleep.
	var/n2o_euphoria = EUPHORIA_LAST_FLAG
	var/n2o_para_min = 1
	var/n2o_sleep_min = 5

	// Partial pressures in our breath
	// Main gases.
	var/pluoxium_pp = 0
	var/o2_pp = 0
	var/plasma_pp = 0
	var/co2_pp = 0
	// Trace gases ordered alphabetically.
	var/bz_pp = 0
	var/freon_pp = 0
	var/n2o_pp = 0
	var/nitrium_pp = 0
	var/miasma_pp = 0

	// Check for moles of gas and handle partial pressures / special conditions.
	if(has_moles)
		// Breath has more than 0 moles of gas.
		// Partial pressures of "main gases".
		pluoxium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/pluoxium][MOLES])
		o2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen][MOLES] + (PLUOXIUM_PROPORTION * pluoxium_pp))
		plasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma][MOLES])
		co2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide][MOLES])
		// Partial pressures of "trace" gases.
		bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz][MOLES])
		freon_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/freon][MOLES])
		miasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/miasma][MOLES])
		n2o_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrous_oxide][MOLES])
		nitrium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrium][MOLES])

	// Breath has 0 moles of gas.
	else if(can_breathe_vacuum)
		// The mob can breathe anyways. What are you? Some bottom-feeding, scum-sucking algae eater?
		failed_last_breath = FALSE
		// Vacuum-adapted lungs regenerate oxyloss even when breathing nothing.
		if(health >= crit_threshold)
			adjustOxyLoss(-5)
	else
		// Can't breathe! Lungs are missing, and/or breath is empty.
		. = FALSE
		failed_last_breath = TRUE

	//-- PLUOXIUM --//
	// Behaves like Oxygen with 8X efficacy, but metabolizes into a reagent.
	if(pluoxium_pp)
		// Inhale Pluoxium. Exhale nothing.
		breath_gases[/datum/gas/pluoxium][MOLES] = 0
		// Metabolize to reagent.
		if(pluoxium_pp > gas_stimulation_min)
			var/existing = reagents.get_reagent_amount(/datum/reagent/pluoxium)
			reagents.add_reagent(/datum/reagent/pluoxium, max(0, 1 - existing))

	//-- OXYGEN --//
	// Carbons need only Oxygen to breathe properly.
	var/oxygen_used = 0
	// Minimum Oxygen effects. "Too little oxygen!"
	if(!can_breathe_vacuum && (o2_pp < safe_oxygen_min))
		// Breathe insufficient amount of O2.
		oxygen_used = handle_suffocation(o2_pp, safe_oxygen_min, breath_gases[/datum/gas/oxygen][MOLES])
		if(!HAS_TRAIT(src, TRAIT_ANOSMIA))
			throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
	else
		// Enough oxygen to breathe.
		failed_last_breath = FALSE
		clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		if(o2_pp)
			// Inhale O2.
			oxygen_used = breath_gases[/datum/gas/oxygen][MOLES]
			// Heal mob if not in crit.
			if(health >= crit_threshold)
				adjustOxyLoss(-5)
	// Exhale equivalent amount of CO2.
	if(o2_pp)
		breath_gases[/datum/gas/oxygen][MOLES] -= oxygen_used
		breath_gases[/datum/gas/carbon_dioxide][MOLES] += oxygen_used

	//-- CARBON DIOXIDE --//
	// Maximum CO2 effects. "Too much CO2!"
	if(co2_pp > safe_co2_max)
		// CO2 side-effects.
		// Give the mob a chance to notice.
		if(prob(20))
			emote("cough")
		// If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if((world.time - co2overloadtime) > 12 SECONDS)
			if(!HAS_TRAIT(src, TRAIT_ANOSMIA))
				throw_alert(ALERT_TOO_MUCH_CO2, /atom/movable/screen/alert/too_much_co2)
			Unconscious(6 SECONDS)
			// Lets hurt em a little, let them know we mean business.
			adjustOxyLoss(3)
			// They've been in here 30s now, start to kill them for their own good!
			if((world.time - co2overloadtime) > 30 SECONDS)
				adjustOxyLoss(8)
	else
		// Reset side-effects.
		co2overloadtime = 0
		clear_alert(ALERT_TOO_MUCH_CO2)

	//-- PLASMA --//
	// Maximum Plasma effects. "Too much Plasma!"
	if(plasma_pp > safe_plas_max)
		// Plasma side-effects.
		var/ratio = (breath_gases[/datum/gas/plasma][MOLES] / safe_plas_max) * 10
		adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		if(!HAS_TRAIT(src, TRAIT_ANOSMIA))
			throw_alert(ALERT_TOO_MUCH_PLASMA, /atom/movable/screen/alert/too_much_plas)
	else
		// Reset side-effects.
		clear_alert(ALERT_TOO_MUCH_PLASMA)

	//-- TRACES --//
	// If there's some other funk in the air lets deal with it here.

	//-- BZ --//
	// (Facepunch port of their Agent B)
	if(bz_pp)
		if(bz_pp > 1)
			adjust_hallucinations(20 SECONDS)
		else if(bz_pp > 0.01)
			adjust_hallucinations(10 SECONDS)

	//-- FREON --//
	if(freon_pp)
		adjustFireLoss(freon_pp * 0.25)

	//-- MIASMA --//
	if(!miasma_pp)
	// Clear moodlet if no miasma at all.
		clear_mood_event("smell")
	else
		// Miasma side-effects.
		if (HAS_TRAIT(src, TRAIT_ANOSMIA)) //We can't feel miasma without sense of smell
			return
		switch(miasma_pp)
			if(0.25 to 5)
				// At lower pp, give out a little warning
				clear_mood_event("smell")
				if(prob(5))
					to_chat(src, span_notice("There is an unpleasant smell in the air."))
			if(5 to 20)
				//At somewhat higher pp, warning becomes more obvious
				if(prob(15))
					to_chat(src, span_warning("You smell something horribly decayed inside this room."))
					add_mood_event("smell", /datum/mood_event/disgust/bad_smell)
			if(15 to 30)
				//Small chance to vomit. By now, people have internals on anyway
				if(prob(5))
					to_chat(src, span_warning("The stench of rotting carcasses is unbearable!"))
					add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
					vomit(VOMIT_CATEGORY_DEFAULT)
			if(30 to INFINITY)
				//Higher chance to vomit. Let the horror start
				if(prob(25))
					to_chat(src, span_warning("The stench of rotting carcasses is unbearable!"))
					add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
					vomit(VOMIT_CATEGORY_DEFAULT)
			else
				clear_mood_event("smell")

	//-- NITROUS OXIDE --//
	if(n2o_pp > n2o_para_min)
		// More N2O, more severe side-effects. Causes stun/sleep.
		n2o_euphoria = EUPHORIA_ACTIVE
		if(!HAS_TRAIT(src, TRAIT_ANOSMIA))
			throw_alert(ALERT_TOO_MUCH_N2O, /atom/movable/screen/alert/too_much_n2o)
		// give them one second of grace to wake up and run away a bit!
		if(!HAS_TRAIT(src, TRAIT_SLEEPIMMUNE))
			Unconscious(6 SECONDS)
		// Enough to make the mob sleep.
		if(n2o_pp > n2o_sleep_min)
			Sleeping(max(AmountSleeping() + 40, 200))
	else if(n2o_pp > 0.01)
		// No alert for small amounts, but the mob randomly feels euphoric.
		if(prob(20))
			n2o_euphoria = EUPHORIA_ACTIVE
			emote(pick("giggle","laugh"))
		else
			n2o_euphoria = EUPHORIA_INACTIVE
	else
	// Reset side-effects, for zero or extremely small amounts of N2O.
		n2o_euphoria = EUPHORIA_INACTIVE
		clear_alert(ALERT_TOO_MUCH_N2O)

	//-- NITRIUM --//
	if(nitrium_pp)
		var/need_mob_update = FALSE
		if(nitrium_pp > 0.5)
			need_mob_update += adjustFireLoss(nitrium_pp * 0.15, updating_health = FALSE)
		if(nitrium_pp > 5)
			need_mob_update += adjustToxLoss(nitrium_pp * 0.05, updating_health = FALSE)
		if(need_mob_update)
			updatehealth()

	// Handle chemical euphoria mood event, caused by N2O.
	if (n2o_euphoria == EUPHORIA_ACTIVE)
		add_mood_event("chemical_euphoria", /datum/mood_event/chemical_euphoria)
	else if (n2o_euphoria == EUPHORIA_INACTIVE)
		clear_mood_event("chemical_euphoria")
	// Activate mood on first flag, remove on second, do nothing on third.

	if(has_moles)
		handle_breath_temperature(breath)

	breath.garbage_collect()

/// Applies suffocation side-effects to a given Human, scaling based on ratio of required pressure VS "true" pressure.
/// If pressure is greater than 0, the return value will represent the amount of gas successfully breathed.
/mob/living/carbon/proc/handle_suffocation(breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	// Can't suffocate without minimum breath pressure.
	if(!safe_breath_min)
		return
	// Mob is suffocating.
	failed_last_breath = TRUE
	// Give them a chance to notice something is wrong.
	if(prob(20))
		emote("gasp")
	// Mob is at critical health, check if they can be damaged further.
	if(health < crit_threshold)
		// Mob is immune to damage at critical health.
		if(HAS_TRAIT(src, TRAIT_NOCRITDAMAGE))
			return
		// Reagents like Epinephrine stop suffocation at critical health.
		if(reagents.has_reagent(/datum/reagent/medicine/epinephrine, needs_metabolizing = TRUE))
			return
	// Low pressure.
	if(breath_pp)
		var/ratio = safe_breath_min / breath_pp
		adjustOxyLoss(min(5 * ratio, 3))
		return true_pp * ratio / 6
	// Zero pressure.
	if(health >= crit_threshold)
		adjustOxyLoss(3)
	else
		adjustOxyLoss(1)

/// Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	// The air you breathe out should match your body temperature
	breath.temperature = bodytemperature

/// Attempts to take a breath from the external or internal air tank.
/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(invalid_internals())
		// Unexpectely lost breathing apparatus and ability to breathe from the internal air tank.
		cutoff_internals()
		return
	if (external)
		. = external.remove_air_volume(volume_needed)
	else if (internal)
		. = internal.remove_air_volume(volume_needed)
	else
		// Return without taking a breath if there is no air tank.
		return
	// To differentiate between no internals and active, but empty internals.
	return . || FALSE

/mob/living/carbon/proc/handle_blood(seconds_per_tick, times_fired)
	return

/mob/living/carbon/proc/handle_bodyparts(seconds_per_tick, times_fired)
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		. |= limb.on_life(seconds_per_tick, times_fired)

/mob/living/carbon/proc/handle_organs(seconds_per_tick, times_fired)
	if(stat == DEAD)
		if(reagents && (reagents.has_reagent(/datum/reagent/toxin/formaldehyde, 1) || reagents.has_reagent(/datum/reagent/cryostylane))) // No organ decay if the body contains formaldehyde.
			return
		for(var/obj/item/organ/organ in organs)
			// On-death is where organ decay is handled
			if(organ?.owner) // organ + owner can be null due to reagent metabolization causing organ shuffling
				organ.on_death(seconds_per_tick, times_fired)
			// We need to re-check the stat every organ, as one of our others may have revived us
			if(stat != DEAD)
				break
		return

	// NOTE: organs_slot is sorted by GLOB.organ_process_order on insertion
	for(var/slot in organs_slot)
		// We don't use get_organ_slot here because we know we have the organ we want, since we're iterating the list containing em already
		// This code is hot enough that it's just not worth the time
		var/obj/item/organ/organ = organs_slot[slot]
		if(organ?.owner) // This exist mostly because reagent metabolization can cause organ reshuffling
			organ.on_life(seconds_per_tick, times_fired)


/mob/living/carbon/handle_diseases(seconds_per_tick, times_fired)
	for(var/datum/disease/disease as anything in diseases)
		if(QDELETED(disease)) //Got cured/deleted while the loop was still going.
			continue
		if(stat != DEAD || disease.process_dead)
			disease.stage_act(seconds_per_tick, times_fired)

/mob/living/carbon/handle_wounds(seconds_per_tick, times_fired)
	for(var/datum/wound/wound as anything in all_wounds)
		if(!wound.processes) // meh
			continue
		wound.handle_process(seconds_per_tick, times_fired)

/mob/living/carbon/handle_mutations(time_since_irradiated, seconds_per_tick, times_fired)
	if(!dna?.temporary_mutations.len)
		return

	for(var/mut in dna.temporary_mutations)
		if(dna.temporary_mutations[mut] < world.time)
			if(mut == UI_CHANGED)
				if(dna.previous["UI"])
					dna.unique_identity = merge_text(dna.unique_identity,dna.previous["UI"])
					updateappearance(mutations_overlay_update=1)
					dna.previous.Remove("UI")
				dna.temporary_mutations.Remove(mut)
				continue
			if(mut == UF_CHANGED)
				if(dna.previous["UF"])
					dna.unique_features = merge_text(dna.unique_features,dna.previous["UF"])
					updateappearance(mutcolor_update=1, mutations_overlay_update=1)
					dna.previous.Remove("UF")
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
		if(HM?.timeout)
			dna.remove_mutation(HM.type)

/**
 * Handles calling metabolization for dead people.
 * Due to how reagent metabolization code works this couldn't be done anywhere else.
 *
 * Arguments:
 * - seconds_per_tick: The amount of time that has elapsed since the last tick.
 * - times_fired: The number of times SSmobs has ticked.
 */
/mob/living/carbon/proc/handle_dead_metabolization(seconds_per_tick, times_fired)
	if(stat != DEAD)
		return
	reagents?.metabolize(src, seconds_per_tick, times_fired, can_overdose = TRUE, liverless = TRUE, dead = TRUE) // Your liver doesn't work while you're dead.

/// Base carbon environment handler, adds natural stabilization
/mob/living/carbon/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/areatemp = get_temperature(environment)

	if(stat != DEAD) // If you are dead your body does not stabilize naturally
		natural_bodytemperature_stabilization(environment, seconds_per_tick, times_fired)

	else if(!on_fire && areatemp < bodytemperature) // lowers your dead body temperature to room temperature over time
		adjust_bodytemperature((areatemp - bodytemperature), use_insulation=FALSE, use_steps=TRUE)

	if(!on_fire || areatemp > bodytemperature) // If we are not on fire or the area is hotter
		adjust_bodytemperature((areatemp - bodytemperature), use_insulation=TRUE, use_steps=TRUE)

/**
 * Used to stabilize the body temperature back to normal on living mobs
 *
 * Arguments:
 * - [environemnt][/datum/gas_mixture]: The environment gas mix
 * - seconds_per_tick: The amount of time that has elapsed since the last tick
 * - times_fired: The number of times SSmobs has ticked
 */
/mob/living/carbon/proc/natural_bodytemperature_stabilization(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/areatemp = get_temperature(environment)
	var/body_temperature_difference = get_body_temp_normal() - bodytemperature
	var/natural_change = 0

	// We are very cold, increase body temperature
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
	adjust_bodytemperature(natural_change * seconds_per_tick)

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
	if(HAS_TRAIT(src, TRAIT_HYPOTHERMIC) && amount > 0) //Prevent warming up
		return
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
		bodytemperature = clamp(bodytemperature + amount, min_temp, max_temp)


///////////
//Stomach//
///////////

/mob/living/carbon/get_fullness()
	var/fullness = nutrition

	var/obj/item/organ/stomach/belly = get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!belly) //nothing to see here if we do not have a stomach
		return fullness

	for(var/bile in belly.reagents.reagent_list)
		var/datum/reagent/bits = bile
		if(istype(bits, /datum/reagent/consumable))
			var/datum/reagent/consumable/goodbit = bile
			fullness += goodbit.get_nutriment_factor(src) * goodbit.volume / goodbit.metabolization_rate
			continue
		fullness += 0.6 * bits.volume / bits.metabolization_rate //not food takes up space

	return fullness

/mob/living/carbon/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	. = ..()
	if(.)
		return
	var/obj/item/organ/stomach/belly = get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!belly)
		return FALSE
	return belly.reagents.has_reagent(reagent, amount, needs_metabolizing)

/////////
//LIVER//
/////////

///Check to see if we have the liver, if not automatically gives you last-stage effects of lacking a liver.

/mob/living/carbon/proc/handle_liver(seconds_per_tick, times_fired)
	if(isnull(has_dna()))
		return

	var/obj/item/organ/liver/liver = get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver)
		return

	reagents.end_metabolization(src, keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
	reagents.metabolize(src, seconds_per_tick, times_fired, can_overdose = TRUE, liverless = TRUE)

	if(HAS_TRAIT(src, TRAIT_STABLELIVER) || HAS_TRAIT(src, TRAIT_LIVERLESS_METABOLISM))
		return

	adjustToxLoss(0.6 * seconds_per_tick, forced = TRUE)
	adjustOrganLoss(pick(ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS, ORGAN_SLOT_STOMACH, ORGAN_SLOT_EYES, ORGAN_SLOT_EARS), 0.5* seconds_per_tick)

/mob/living/carbon/proc/undergoing_liver_failure()
	var/obj/item/organ/liver/liver = get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver?.organ_flags & ORGAN_FAILING)
		return TRUE

////////////////
//BRAIN DAMAGE//
////////////////

/mob/living/carbon/proc/handle_brain_damage(seconds_per_tick, times_fired)
	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_life(seconds_per_tick, times_fired)

/////////////////////////////////////
//MONKEYS WITH TOO MUCH CHOLOESTROL//
/////////////////////////////////////

/mob/living/carbon/proc/can_heartattack()
	if(!needs_heart())
		return FALSE
	var/obj/item/organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || IS_ROBOTIC_ORGAN(heart))
		return FALSE
	return TRUE

/mob/living/carbon/proc/needs_heart()
	if(HAS_TRAIT(src, TRAIT_STABLEHEART))
		return FALSE
	if(dna && dna.species && (HAS_TRAIT(src, TRAIT_NOBLOOD) || isnull(dna.species.mutantheart))) //not all carbons have species!
		return FALSE
	return TRUE

/*
 * The mob is having a heart attack
 *
 * NOTE: this is true if the mob has no heart and needs one, which can be surprising,
 * you are meant to use it in combination with can_heartattack for heart attack
 * related situations (i.e not just cardiac arrest)
 */
/mob/living/carbon/proc/undergoing_cardiac_arrest()
	var/obj/item/organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(istype(heart) && heart.is_beating())
		return FALSE
	else if(!needs_heart())
		return FALSE
	return TRUE

/**
 * Causes the mob to either start or stop having a heart attack.
 *
 * status - Pass TRUE to start a heart attack, or FALSE to stop one.
 *
 * Returns TRUE if heart status was changed (heart attack -> no heart attack, or visa versa)
 */
/mob/living/carbon/proc/set_heartattack(status)
	if(status && !can_heartattack())
		return FALSE

	var/obj/item/organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(!istype(heart))
		return FALSE

	if(status)
		return heart.Stop()

	return heart.Restart()
