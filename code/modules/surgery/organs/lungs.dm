/obj/item/organ/internal/lungs
	name = "lungs"
	icon_state = "lungs"
	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY * 0.9 // fails around 16.5 minutes, lungs are one of the last organs to die (of the ones we have)

	low_threshold_passed = "<span class='warning'>You feel short of breath.</span>"
	high_threshold_passed = "<span class='warning'>You feel some sort of constriction around your chest as your breathing becomes shallow and rapid.</span>"
	now_fixed = "<span class='warning'>Your lungs seem to once again be able to hold air.</span>"
	low_threshold_cleared = "<span class='info'>You can breathe normally again.</span>"
	high_threshold_cleared = "<span class='info'>The constriction around your chest loosens as your breathing calms down.</span>"

	var/failed = FALSE
	var/operated = FALSE //whether we can still have our damages fixed through surgery


	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/medicine/salbutamol = 5)

	//Breath damage
	//These thresholds are checked against what amounts to total_mix_pressure * (gas_type_mols/total_mols)
	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_nitro_min = 0
	var/safe_nitro_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_plasma_min = 0
	///How much breath partial pressure is a safe amount of plasma. 0 means that we are immune to plasma.
	var/safe_plasma_max = 0.05
	var/n2o_para_min = 1 //Sleeping agent
	var/n2o_sleep_min = 5 //Sleeping agent
	var/BZ_trip_balls_min = 1 //BZ gas
	var/BZ_brain_damage_min = 10 //Give people some room to play around without killing the station
	var/gas_stimulation_min = 0.002 // For, Pluoxium, Nitrium and Freon
	///Minimum amount of healium to make you unconscious for 4 seconds
	var/healium_para_min = 3
	///Minimum amount of healium to knock you down for good
	var/healium_sleep_min = 6
	///Minimum amount of helium to affect speech
	var/helium_speech_min = 5
	//Whether helium speech effects are currently active
	var/helium_speech = FALSE
	///Whether these lungs react negatively to miasma
	var/suffers_miasma = TRUE

	var/oxy_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/oxy_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/oxy_damage_type = OXY
	var/nitro_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/nitro_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/nitro_damage_type = OXY
	var/co2_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/co2_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/co2_damage_type = OXY
	var/plas_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/plas_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/plas_damage_type = TOX

	var/tritium_irradiation_moles_min = 1
	var/tritium_irradiation_moles_max = 15
	var/tritium_irradiation_probability_min = 10
	var/tritium_irradiation_probability_max = 60

	var/cold_message = "your face freezing and an icicle forming"
	var/cold_level_1_threshold = 260
	var/cold_level_2_threshold = 200
	var/cold_level_3_threshold = 120
	var/cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	var/cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	var/cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	var/cold_damage_type = BURN

	var/hot_message = "your face burning and a searing heat"
	var/heat_level_1_threshold = 360
	var/heat_level_2_threshold = 400
	var/heat_level_3_threshold = 1000
	var/heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_1
	var/heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	var/heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	var/heat_damage_type = BURN

	var/crit_stabilizing_reagent = /datum/reagent/medicine/epinephrine

///Simply exists so that you don't keep any alerts from your previous lack of lungs.
/obj/item/organ/internal/lungs/Insert(mob/living/carbon/receiver, special = FALSE, drop_if_replaced = TRUE)
	receiver.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
	receiver.clear_alert(ALERT_NOT_ENOUGH_CO2)
	receiver.clear_alert(ALERT_NOT_ENOUGH_NITRO)
	receiver.clear_alert(ALERT_NOT_ENOUGH_PLASMA)
	receiver.clear_alert(ALERT_NOT_ENOUGH_N2O)
	return ..()

/**
 * This proc tests if the lungs can breathe, if they can breathe a given gas mixture, and throws/clears gas alerts.
 * If there are moles of gas in the given gas mixture, side-effects may be applied/removed on the mob.
 * If a required gas (such as Oxygen) is missing from the breath, then it calls [proc/handle_suffocation].
 *
 * Returns TRUE if the breath was successful, or FALSE if otherwise.
 *
 * Arguments:
 * * breath: A gas mixture to test, or null.
 * * breather: A carbon mob that is using the lungs to breathe.
 */
/obj/item/organ/internal/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/breather)
	. = TRUE

	if(breather.status_flags & GODMODE)
		breather.failed_last_breath = FALSE
		breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		return

	if(HAS_TRAIT(breather, TRAIT_NOBREATH))
		return

	// Breath may be null, so use a fallback "empty breath" for convenience.
	if(!breath)
		/// Fallback "empty breath" for convenience.
		var/static/datum/gas_mixture/immutable/empty_breath = new(BREATH_VOLUME)
		breath = empty_breath

	// Ensure gas volumes are present.
	for(var/gas_id in GLOB.meta_gas_info)
		breath.assert_gas(gas_id)

	// Indicates if there are moles of gas in the breath.
	var/has_moles = breath.total_moles() != 0

	// The list of gases in the breath.
	var/list/breath_gases = breath.gases

	// Indicates if lungs can breathe without gas.
	var/can_breathe_vacuum = HAS_TRAIT(src, TRAIT_SPACEBREATHING)
	// Re-usable var used to remove a limited volume of each gas from the given gas mixture.
	var/gas_breathed = 0
	// Vars for N2O/healium induced euphoria, stun, and sleep.
	var/n2o_euphoria = EUPHORIA_LAST_FLAG
	var/healium_euphoria = EUPHORIA_LAST_FLAG

	// Partial pressures in the breath.
	// Main Gases
	var/pluoxium_pp = 0
	var/o2_pp = 0
	var/n2_pp = 0
	var/co2_pp = 0
	var/plasma_pp = 0
	// Trace Gases, ordered alphabetically.
	var/bz_pp = 0
	var/freon_pp = 0
	var/healium_pp = 0
	var/helium_pp = 0
	var/halon_pp = 0
	var/hypernob_pp = 0
	var/miasma_pp = 0
	var/n2o_pp = 0
	var/nitrium_pp = 0
	var/trit_pp = 0
	var/zauker_pp = 0

	// Check for moles of gas and handle partial pressures / special conditions.
	if(has_moles)
		// Breath has more than 0 moles of gas.
		// Route gases through mask filter if breather is wearing one.
		if(istype(breather.wear_mask) && (breather.wear_mask.clothing_flags & GAS_FILTERING) && breather.wear_mask.has_filter)
			breath = breather.wear_mask.consume_filter(breath)
			breath_gases = breath.gases
		// Partial pressures of "main" gases.
		pluoxium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/pluoxium][MOLES])
		o2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen][MOLES]) + (8 * pluoxium_pp)
		n2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrogen][MOLES])
		co2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide][MOLES])
		plasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma][MOLES])
		// Partial pressures of "trace" gases.
		bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz][MOLES])
		freon_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/freon][MOLES])
		halon_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/halon][MOLES])
		healium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/healium][MOLES])
		helium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/helium][MOLES])
		hypernob_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/hypernoblium][MOLES])
		miasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/miasma][MOLES])
		n2o_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrous_oxide][MOLES])
		nitrium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrium][MOLES])
		trit_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/tritium][MOLES])
		zauker_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/zauker][MOLES])

	// Breath has 0 moles of gas.
	else if(can_breathe_vacuum)
		// The lungs can breathe anyways. What are you? Some bottom-feeding, scum-sucking algae eater?
		breather.failed_last_breath = FALSE
		// Vacuum-adapted lungs regenerate oxyloss even when breathing nothing.
		if(breather.health >= breather.crit_threshold)
			breather.adjustOxyLoss(-5)
	else
		// Can't breathe!
		. = FALSE
		breather.failed_last_breath = TRUE

	// Handle subtypes' breath processing
	handle_gas_override(breather, breath_gases, 0)

	//-- MAIN GASES --//

	//-- PLUOXIUM --//
	// Behaves like Oxygen with 8X efficacy, but metabolizes into a reagent.
	if(pluoxium_pp)
		// Inhale Pluoxium. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/pluoxium)
		// Metabolize to reagent.
		if(pluoxium_pp > gas_stimulation_min)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/pluoxium)
			breather.reagents.add_reagent(/datum/reagent/pluoxium, max(0, 1 - existing))

	//-- OXYGEN --//
	// Maximum Oxygen effects. "Too much O2!"
	// If too much Oxygen is poisonous.
	if(safe_oxygen_max)
		if(o2_pp && (o2_pp > safe_oxygen_max))
			// O2 side-effects.
			var/ratio = (breath_gases[/datum/gas/oxygen][MOLES] / safe_oxygen_max) * 10
			breather.apply_damage_type(clamp(ratio, oxy_breath_dam_min, oxy_breath_dam_max), oxy_damage_type)
			breather.throw_alert(ALERT_TOO_MUCH_OXYGEN, /atom/movable/screen/alert/too_much_oxy)
		else
			// Reset side-effects.
			breather.clear_alert(ALERT_TOO_MUCH_OXYGEN)

	// Minimum Oxygen effects.
	// If the lungs need Oxygen to breathe properly, O2 is exchanged with CO2.
	if(safe_oxygen_min)
		// Suffocation side-effects.
		if(!can_breathe_vacuum && (o2_pp < safe_oxygen_min))
			breather.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
			// Inhale insufficient amount of O2, exhale CO2.
			if(o2_pp)
				gas_breathed = handle_suffocation(breather, o2_pp, safe_oxygen_min, breath_gases[/datum/gas/oxygen][MOLES])
				breathe_gas_volume(breath_gases, /datum/gas/oxygen, /datum/gas/carbon_dioxide, volume = gas_breathed)
		else
			// Enough oxygen to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
			// Inhale Oxygen, exhale equivalent amount of CO2.
			if(o2_pp)
				breathe_gas_volume(breath_gases, /datum/gas/oxygen, /datum/gas/carbon_dioxide)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)

	//-- NITROGEN --//
	// Maximum Nitrogen effects. "Too much N2!"
	if(safe_nitro_max)
		if(n2_pp && (n2_pp > safe_nitro_max))
			// N2 side-effects.
			var/ratio = (breath_gases[/datum/gas/nitrogen][MOLES]/safe_nitro_max) * 10
			breather.apply_damage_type(clamp(ratio, nitro_breath_dam_min, nitro_breath_dam_max), nitro_damage_type)
			breather.throw_alert(ALERT_TOO_MUCH_NITRO, /atom/movable/screen/alert/too_much_nitro)
		else
			// Reset side-effects.
			breather.clear_alert(ALERT_TOO_MUCH_NITRO)

	// Minimum Nitrogen effects.
	// If the lungs need Nitrogen to breathe properly, N2 is exchanged with CO2.
	if(safe_nitro_min)
		// Suffocation side-effects.
		if(!can_breathe_vacuum && (n2_pp < safe_nitro_min))
			breather.throw_alert(ALERT_NOT_ENOUGH_NITRO, /atom/movable/screen/alert/not_enough_nitro)
			// Inhale insufficient amount of N2, exhale CO2.
			if(n2_pp)
				gas_breathed = handle_suffocation(breather, n2_pp, safe_nitro_min, breath_gases[/datum/gas/nitrogen][MOLES])
				breathe_gas_volume(breath_gases, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, volume = gas_breathed)
		else
			// Enough nitrogen to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_NITRO)
			// Inhale N2, exhale equivalent amount of CO2. Look ma, sideways breathing!
			if(n2_pp)
				breathe_gas_volume(breath_gases, /datum/gas/nitrogen, /datum/gas/carbon_dioxide)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)

	//-- CARBON DIOXIDE --//
	// Maximum CO2 effects. "Too much CO2!"
	if(safe_co2_max)
		if(co2_pp && (co2_pp > safe_co2_max))
			// CO2 side-effects.
			// Give the mob a chance to notice.
			if(prob(20))
				breather.emote("cough")
			// If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			if(!breather.co2overloadtime)
				breather.co2overloadtime = world.time
			else if((world.time - breather.co2overloadtime) > 12 SECONDS)
				breather.throw_alert(ALERT_TOO_MUCH_CO2, /atom/movable/screen/alert/too_much_co2)
				breather.Unconscious(6 SECONDS)
				// Lets hurt em a little, let them know we mean business.
				breather.apply_damage_type(3, co2_damage_type)
				// They've been in here 30s now, start to kill them for their own good!
				if((world.time - breather.co2overloadtime) > 30 SECONDS)
					breather.apply_damage_type(8, co2_damage_type)
		else
			// Reset side-effects.
			breather.co2overloadtime = 0
			breather.clear_alert(ALERT_TOO_MUCH_CO2)

	// Minimum CO2 effects.
	// If the lungs need CO2 to breathe properly, CO2 is exchanged with O2.
	if(safe_co2_min)
		// Suffocation side-effects.
		if(!can_breathe_vacuum && (co2_pp < safe_co2_min))
			breather.throw_alert(ALERT_NOT_ENOUGH_CO2, /atom/movable/screen/alert/not_enough_co2)
			// Inhale insufficient amount of CO2, exhale O2.
			if(co2_pp)
				gas_breathed = handle_suffocation(breather, co2_pp, safe_co2_min, breath_gases[/datum/gas/carbon_dioxide][MOLES])
				breathe_gas_volume(breath_gases, /datum/gas/carbon_dioxide, /datum/gas/oxygen, volume = gas_breathed)
		else
			// Enough CO2 to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_CO2)
			// Inhale CO2, exhale equivalent amount of O2. Look ma, reverse breathing!
			if(co2_pp)
				breathe_gas_volume(breath_gases, /datum/gas/carbon_dioxide, /datum/gas/oxygen)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)

	//-- PLASMA --//
	// Maximum Plasma effects. "Too much Plasma!"
	if(safe_plasma_max)
		if(plasma_pp && (plasma_pp > safe_plasma_max))
			// Plasma side-effects.
			var/ratio = (breath_gases[/datum/gas/plasma][MOLES] / safe_plasma_max) * 10
			breather.apply_damage_type(clamp(ratio, plas_breath_dam_min, plas_breath_dam_max), plas_damage_type)
			breather.throw_alert(ALERT_TOO_MUCH_PLASMA, /atom/movable/screen/alert/too_much_plas)
		else
			// Reset side-effects.
			breather.clear_alert(ALERT_TOO_MUCH_PLASMA)

	// Minimum Plasma effects.
	// If the lungs need Plasma to breathe properly, Plasma is exchanged with CO2.
	if(safe_plasma_min)
		// Suffocation side-effects.
		if(!can_breathe_vacuum && (plasma_pp < safe_plasma_min))
			breather.throw_alert(ALERT_NOT_ENOUGH_PLASMA, /atom/movable/screen/alert/not_enough_plas)
			// Breathe insufficient amount of Plasma, exhale CO2.
			if(plasma_pp)
				gas_breathed = handle_suffocation(breather, plasma_pp, safe_plasma_min, breath_gases[/datum/gas/plasma][MOLES])
				breathe_gas_volume(breath_gases, /datum/gas/plasma, /datum/gas/carbon_dioxide, volume = gas_breathed)
		else
			// Enough Plasma to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_PLASMA)
			// Inhale Plasma, exhale equivalent amount of CO2.
			if(plasma_pp)
				breathe_gas_volume(breath_gases, /datum/gas/plasma, /datum/gas/carbon_dioxide)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)


	//-- TRACES --//
	// If there's some other shit in the air lets deal with it here.

	//-- BZ --//
	if(bz_pp)
		if(bz_pp > BZ_trip_balls_min)
			breather.adjust_hallucinations(20 SECONDS)
			breather.reagents.add_reagent(/datum/reagent/bz_metabolites, 5)
		if(bz_pp > BZ_brain_damage_min && prob(33))
			breather.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150, ORGAN_ORGANIC)

	//-- FREON --//
	if(freon_pp)
		// Inhale Freon. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/freon)
		if (freon_pp > gas_stimulation_min)
			breather.reagents.add_reagent(/datum/reagent/freon, 1)
		if (prob(freon_pp))
			to_chat(breather, span_alert("Your mouth feels like it's burning!"))
		if (freon_pp > 40)
			breather.emote("gasp")
			breather.adjustFireLoss(15)
			if (prob(freon_pp / 2))
				to_chat(breather, span_alert("Your throat closes up!"))
				breather.set_silence_if_lower(6 SECONDS)
		else
			breather.adjustFireLoss(freon_pp / 4)

	//-- HALON --//
	if(halon_pp)
		// Inhale Halon. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/halon)
		// Metabolize to reagent.
		if(halon_pp > gas_stimulation_min)
			breather.adjustOxyLoss(5)
			breather.reagents.add_reagent(/datum/reagent/halon, max(0, 1 - breather.reagents.get_reagent_amount(/datum/reagent/halon)))

	//-- HEALIUM --//
	// Sleeping gas with healing properties.
	if(!healium_pp)
		// Reset side-effects.
		healium_euphoria = EUPHORIA_INACTIVE
	else
		// Inhale Healium. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/healium)
		// Euphoria side-effect.
		if(healium_pp > gas_stimulation_min)
			if(prob(15))
				to_chat(breather, span_alert("Your head starts spinning and your lungs burn!"))
				healium_euphoria = EUPHORIA_ACTIVE
				breather.emote("gasp")
		else
			healium_euphoria = EUPHORIA_INACTIVE
		// Stun/Sleep side-effects.
		if(healium_pp > healium_para_min)
			// Random chance to stun mob. Timing not in seconds to have a much higher variation
			breather.Unconscious(rand(3 SECONDS, 5 SECONDS))
		// Metabolize to reagent when concentration is high enough.
		if(healium_pp > healium_sleep_min)
			breather.reagents.add_reagent(/datum/reagent/healium, max(0, 1 - breather.reagents.get_reagent_amount(/datum/reagent/healium)))

	//-- HELIUM --//
	// Activates helium speech when partial pressure gets high enough
	if(!helium_pp)
		helium_speech = FALSE
		UnregisterSignal(owner, COMSIG_MOB_SAY)
	else
		// Inhale Helium. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/helium)
		// Helium side-effects.
		if(helium_speech && (helium_pp <= helium_speech_min))
			helium_speech = FALSE
			UnregisterSignal(owner, COMSIG_MOB_SAY)
		else if(!helium_speech && (helium_pp > helium_speech_min))
			helium_speech = TRUE
			RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_helium_speech))

	//-- HYPER-NOBILUM --//
	if(hypernob_pp)
		// Inhale Hyber-Nobilum. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/hypernoblium)
		// Metabolize to reagent.
		if (hypernob_pp > gas_stimulation_min)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/hypernoblium)
			breather.reagents.add_reagent(/datum/reagent/hypernoblium,max(0, 1 - existing))

	//-- MIASMA --//
	if(!miasma_pp || !suffers_miasma)
		// Clear out moods when immune to miasma, or if there's no miasma at all.
		owner.clear_mood_event("smell")
	else
		// Inhale Miasma. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/miasma)
		// Miasma sickness
		if(prob(0.5 * miasma_pp))
			var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(max_symptoms = min(round(max(miasma_pp / 2, 1), 1), 6), max_level = min(round(max(miasma_pp, 1), 1), 8))
			// tl;dr the first argument chooses the smaller of miasma_pp/2 or 6(typical max virus symptoms), the second chooses the smaller of miasma_pp or 8(max virus symptom level)
			// Each argument has a minimum of 1 and rounds to the nearest value. Feel free to change the pp scaling I couldn't decide on good numbers for it.
			miasma_disease.name = "Unknown"
			miasma_disease.try_infect(owner)
		// Miasma side effects
		switch(miasma_pp)
			if(0.25 to 5)
				// At lower pp, give out a little warning
				owner.clear_mood_event("smell")
				if(prob(5))
					to_chat(owner, span_notice("There is an unpleasant smell in the air."))
			if(5 to 15)
				//At somewhat higher pp, warning becomes more obvious
				if(prob(15))
					to_chat(owner, span_warning("You smell something horribly decayed inside this room."))
					owner.add_mood_event("smell", /datum/mood_event/disgust/bad_smell)
			if(15 to 30)
				//Small chance to vomit. By now, people have internals on anyway
				if(prob(5))
					to_chat(owner, span_warning("The stench of rotting carcasses is unbearable!"))
					owner.add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
					owner.vomit()
			if(30 to INFINITY)
				//Higher chance to vomit. Let the horror start
				if(prob(15))
					to_chat(owner, span_warning("The stench of rotting carcasses is unbearable!"))
					owner.add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
					owner.vomit()
			else
				owner.clear_mood_event("smell")
		// In a full miasma atmosphere with 101.34 pKa, about 10 disgust per breath, is pretty low compared to threshholds
		// Then again, this is a purely hypothetical scenario and hardly reachable
		owner.adjust_disgust(0.1 * miasma_pp)

	//-- N2O --//
	// N2O side-effects. "Too much N2O!"
	// Small amount of N2O, small side-effects. Causes random euphoria and giggling.
	if (n2o_pp > n2o_para_min)
		// More N2O, more severe side-effects. Causes stun/sleep.
		n2o_euphoria = EUPHORIA_ACTIVE
		breather.throw_alert(ALERT_TOO_MUCH_N2O, /atom/movable/screen/alert/too_much_n2o)
		// 60 gives them one second to wake up and run away a bit!
		breather.Unconscious(6 SECONDS)
		// Enough to make the mob sleep.
		if(n2o_pp > n2o_sleep_min)
			breather.Sleeping(min(breather.AmountSleeping() + 100, 200))
	else if(n2o_pp > 0.01)
		// No alert for small amounts, but the mob randomly feels euphoric.
		breather.clear_alert(ALERT_TOO_MUCH_N2O)
		if(prob(20))
			n2o_euphoria = EUPHORIA_ACTIVE
			breather.emote(pick("giggle", "laugh"))
		else
			n2o_euphoria = EUPHORIA_INACTIVE
	else
		// Reset side-effects, for zero or extremely small amounts of N2O.
		n2o_euphoria = EUPHORIA_INACTIVE
		breather.clear_alert(ALERT_TOO_MUCH_N2O)

	//-- NITRIUM --//
	if (nitrium_pp)
		// Inhale Nitrium. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/nitrium)
		// Random chance to inflict side effects increases with pressure.
		if((prob(nitrium_pp) && (nitrium_pp > 15)))
			// Nitrium side-effect.
			breather.adjustOrganLoss(ORGAN_SLOT_LUNGS, nitrium_pp * 0.1)
			to_chat(breather, "<span class='notice'>You feel a burning sensation in your chest</span>")
		// Metabolize to reagents.
		if (nitrium_pp > 5)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/nitrium_low_metabolization)
			breather.reagents.add_reagent(/datum/reagent/nitrium_low_metabolization, max(0, 2 - existing))
		if (nitrium_pp > 10)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/nitrium_high_metabolization)
			breather.reagents.add_reagent(/datum/reagent/nitrium_high_metabolization, max(0, 1 - existing))

	//-- PROTO-NITRATE --//
	// Inert

	//-- TRITIUM --//
	if (trit_pp)
		// Inhale Tritium. Exhale nothing.
		gas_breathed = breathe_gas_volume(breath_gases, /datum/gas/tritium)
		// Tritium side-effects.
		var/ratio = gas_breathed * 15
		breather.adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		// If you're breathing in half an atmosphere of radioactive gas, you fucked up.
		if((trit_pp > tritium_irradiation_moles_min) && SSradiation.can_irradiate_basic(breather))
			var/lerp_scale = min(tritium_irradiation_moles_max, trit_pp - tritium_irradiation_moles_min) / (tritium_irradiation_moles_max - tritium_irradiation_moles_min)
			var/chance = LERP(tritium_irradiation_probability_min, tritium_irradiation_probability_max, lerp_scale)
			if (prob(chance))
				breather.AddComponent(/datum/component/irradiated)

	//-- ZAUKER --//
	if(zauker_pp)
		// Inhale Zauker. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/zauker)
		// Metabolize to reagent.
		if(zauker_pp > gas_stimulation_min)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/zauker)
			breather.reagents.add_reagent(/datum/reagent/zauker, max(0, 1 - existing))

	// Handle chemical euphoria mood event, caused by gases such as N2O or healium.
	if (n2o_euphoria == EUPHORIA_ACTIVE || healium_euphoria == EUPHORIA_ACTIVE)
		owner.add_mood_event("chemical_euphoria", /datum/mood_event/chemical_euphoria)
	else if (n2o_euphoria == EUPHORIA_INACTIVE && healium_euphoria == EUPHORIA_INACTIVE)
		owner.clear_mood_event("chemical_euphoria")
	// Activate mood on first flag, remove on second, do nothing on third.

	if(has_moles)
		handle_breath_temperature(breath, breather)

	breath.garbage_collect()

///override this for breath handling unique to lung subtypes, breath_gas is the list of gas in the breath while gas breathed is just what is being added or removed from that list, just as they are when this is called in check_breath()
/obj/item/organ/internal/lungs/proc/handle_gas_override(mob/living/carbon/human/breather, list/breath_gas, gas_breathed)
	return

/// Remove a volume of gas from the breath. Used to simulate absorbtion and interchange of gas in the lungs.
/// Removes all of the given gas type unless given a volume argument.
/// Returns the amount of gas theoretically removed.
/obj/item/organ/internal/lungs/proc/breathe_gas_volume(list/breath_gases, datum/gas/remove_gas, datum/gas/exchange_gas = null, volume = INFINITY)
	volume = min(volume, breath_gases[remove_gas][MOLES])
	breath_gases[remove_gas][MOLES] -= volume
	if(exchange_gas)
		breath_gases[exchange_gas][MOLES] += volume
	return volume

/// Applies suffocation side-effects to a given Human, scaling based on ratio of required pressure VS "true" pressure.
/// If pressure is greater than 0, the return value will represent the amount of gas successfully breathed.
/obj/item/organ/internal/lungs/proc/handle_suffocation(mob/living/carbon/human/suffocator = null, breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	// Can't suffocate without a Human, or without minimum breath pressure.
	if(!suffocator || !safe_breath_min)
		return
	// Mob is suffocating.
	suffocator.failed_last_breath = TRUE
	// Give them a chance to notice something is wrong.
	if(prob(20))
		suffocator.emote("gasp")
	// If mob is at critical health, check if they can be damaged further.
	if(suffocator.health < suffocator.crit_threshold)
		// Mob is immune to damage at critical health.
		if(HAS_TRAIT(suffocator, TRAIT_NOCRITDAMAGE))
			return
		// Reagents like Epinephrine stop suffocation at critical health.
		if(suffocator.reagents.has_reagent(crit_stabilizing_reagent, needs_metabolizing = TRUE))
			return
	// Low pressure.
	if(breath_pp)
		var/ratio = safe_breath_min / breath_pp
		suffocator.adjustOxyLoss(min(5 * ratio, HUMAN_MAX_OXYLOSS))
		return true_pp * ratio / 6
	// Zero pressure.
	if(suffocator.health >= suffocator.crit_threshold)
		suffocator.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
	else
		suffocator.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)


/obj/item/organ/internal/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/breather) // called by human/life, handles temperatures
	var/breath_temperature = breath.temperature

	if(!HAS_TRAIT(breather, TRAIT_RESISTCOLD)) // COLD DAMAGE
		var/cold_modifier = breather.dna.species.coldmod
		if(breath_temperature < cold_level_3_threshold)
			breather.apply_damage_type(cold_level_3_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			breather.apply_damage_type(cold_level_2_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			breather.apply_damage_type(cold_level_1_damage*cold_modifier, cold_damage_type)
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(breather, span_warning("You feel [cold_message] in your [name]!"))

	if(!HAS_TRAIT(breather, TRAIT_RESISTHEAT)) // HEAT DAMAGE
		var/heat_modifier = breather.dna.species.heatmod
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			breather.apply_damage_type(heat_level_1_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			breather.apply_damage_type(heat_level_2_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_3_threshold)
			breather.apply_damage_type(heat_level_3_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(breather, span_warning("You feel [hot_message] in your [name]!"))

	// The air you breathe out should match your body temperature
	breath.temperature = breather.bodytemperature

/obj/item/organ/internal/lungs/proc/handle_helium_speech(owner, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= SPAN_HELIUM

/obj/item/organ/internal/lungs/on_life(delta_time, times_fired)
	. = ..()
	if(failed && !(organ_flags & ORGAN_FAILING))
		failed = FALSE
		return
	if(damage >= low_threshold)
		var/do_i_cough = DT_PROB((damage < high_threshold) ? 2.5 : 5, delta_time) // between : past high
		if(do_i_cough)
			owner.emote("cough")
	if(organ_flags & ORGAN_FAILING && owner.stat == CONSCIOUS)
		owner.visible_message(span_danger("[owner] grabs [owner.p_their()] throat, struggling for breath!"), span_userdanger("You suddenly feel like you can't breathe!"))
		failed = TRUE

/obj/item/organ/internal/lungs/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantlungs

/obj/item/organ/internal/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon_state = "lungs-plasma"
	organ_traits = list(TRAIT_NOHUNGER) // A fresh breakfast of plasma is a great start to any morning.

	safe_oxygen_min = 0 //We don't breathe this
	safe_plasma_min = 4 //We breathe THIS!
	safe_plasma_max = 0

/obj/item/organ/internal/lungs/slime
	name = "vacuole"
	desc = "A large organelle designed to store oxygen and other important gasses."

	safe_plasma_max = 0 //We breathe this to gain POWER.

/obj/item/organ/internal/lungs/slime/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/breather_slime)
	. = ..()
	if (breath?.gases[/datum/gas/plasma])
		var/plasma_pp = breath.get_breath_partial_pressure(breath.gases[/datum/gas/plasma][MOLES])
		owner.blood_volume += (0.2 * plasma_pp) // 10/s when breathing literally nothing but plasma, which will suffocate you.

/obj/item/organ/internal/lungs/cybernetic
	name = "basic cybernetic lungs"
	desc = "A basic cybernetic version of the lungs found in traditional humanoid entities."
	icon_state = "lungs-c"
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.5

	var/emp_vulnerability = 80 //Chance of permanent effects if emp-ed.

/obj/item/organ/internal/lungs/cybernetic/tier2
	name = "cybernetic lungs"
	desc = "A cybernetic version of the lungs found in traditional humanoid entities. Allows for greater intakes of oxygen than organic lungs, requiring slightly less pressure."
	icon_state = "lungs-c-u"
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	safe_oxygen_min = 13
	emp_vulnerability = 40

/obj/item/organ/internal/lungs/cybernetic/tier3
	name = "upgraded cybernetic lungs"
	desc = "A more advanced version of the stock cybernetic lungs. Features the ability to filter out lower levels of plasma and carbon dioxide."
	icon_state = "lungs-c-u2"
	safe_plasma_max = 20
	safe_co2_max = 20
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	safe_oxygen_min = 13
	emp_vulnerability = 20

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 100

/obj/item/organ/internal/lungs/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		owner.losebreath += 20
		COOLDOWN_START(src, severe_cooldown, 30 SECONDS)
	if(prob(emp_vulnerability/severity)) //Chance of permanent effects
		organ_flags |= ORGAN_SYNTHETIC_EMP //Starts organ faliure - gonna need replacing soon.


/obj/item/organ/internal/lungs/lavaland
	name = "blackened frilled lungs" // blackened from necropolis exposure
	desc = "Exposure to the necropolis has mutated these lungs to breathe the air of Indecipheres, the lava-covered moon."
	icon_state = "lungs-ashwalker"

// Normal oxygen is 21 kPa partial pressure, but SS13 humans can tolerate down
// to 16 kPa. So it follows that ashwalkers, as humanoids, follow the same rules.
#define GAS_TOLERANCE 5

/obj/item/organ/internal/lungs/lavaland/Initialize(mapload)
	. = ..()

	var/datum/gas_mixture/immutable/planetary/mix = SSair.planetary[LAVALAND_DEFAULT_ATMOS]

	if(!mix?.total_moles()) // this typically means we didn't load lavaland, like if we're using #define LOWMEMORYMODE
		return

	// Take a "breath" of the air
	var/datum/gas_mixture/breath = mix.remove(mix.total_moles() * BREATH_PERCENTAGE)

	var/list/breath_gases = breath.gases

	breath.assert_gases(
		/datum/gas/oxygen,
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide,
		/datum/gas/nitrogen,
		/datum/gas/bz,
		/datum/gas/miasma,
	)

	var/oxygen_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen][MOLES])
	var/nitrogen_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrogen][MOLES])
	var/plasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma][MOLES])
	var/carbon_dioxide_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide][MOLES])
	var/bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz][MOLES])
	var/miasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/miasma][MOLES])

	safe_oxygen_min = max(0, oxygen_pp - GAS_TOLERANCE)
	safe_nitro_min = max(0, nitrogen_pp - GAS_TOLERANCE)
	safe_plasma_min = max(0, plasma_pp - GAS_TOLERANCE)

	// Increase plasma tolerance based on amount in base air
	safe_plasma_max += plasma_pp

	// CO2 is always a waste gas, so none is required, but ashwalkers
	// tolerate the base amount plus tolerance*2 (humans tolerate only 10 pp)

	safe_co2_max = carbon_dioxide_pp + GAS_TOLERANCE * 2

	// The lung tolerance against BZ is also increased the amount of BZ in the base air
	BZ_trip_balls_min += bz_pp
	BZ_brain_damage_min += bz_pp

	// Lungs adapted to a high miasma atmosphere do not process it, and breathe it back out
	if(miasma_pp)
		suffers_miasma = FALSE

#undef GAS_TOLERANCE

/obj/item/organ/internal/lungs/ethereal
	name = "aeration reticulum"
	desc = "These exotic lungs seem crunchier than most."
	icon_state = "lungs_ethereal"
	heat_level_1_threshold = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // 150C or 433k, in line with ethereal max safe body temperature
	heat_level_2_threshold = 473
	heat_level_3_threshold = 1073


/obj/item/organ/internal/lungs/ethereal/handle_gas_override(mob/living/carbon/human/breather, list/breath_gases, gas_breathed)
	// H2O electrolysis
	gas_breathed = breath_gases[/datum/gas/water_vapor][MOLES]
	breath_gases[/datum/gas/oxygen][MOLES] += gas_breathed
	breath_gases[/datum/gas/hydrogen][MOLES] += gas_breathed*2
	breath_gases[/datum/gas/water_vapor][MOLES] -= gas_breathed
