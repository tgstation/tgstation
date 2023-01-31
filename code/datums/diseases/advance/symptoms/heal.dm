/datum/symptom/heal
	name = "Basic Healing (does nothing)" //warning for adminspawn viruses
	desc = "You should not be seeing this."
	stealth = 0
	resistance = 0
	stage_speed = 0
	transmittable = 0
	level = 0 //not obtainable
	base_message_chance = 20 //here used for the overlays
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/passive_message = "" //random message to infected but not actively healing people


/datum/symptom/heal/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			var/effectiveness = CanHeal(A)
			if(!effectiveness)
				if(passive_message && prob(2) && passive_message_condition(M))
					to_chat(M, passive_message)
				return
			else
				Heal(M, A, effectiveness)
	return

/datum/symptom/heal/proc/CanHeal(datum/disease/advance/A)
	return power

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	return TRUE

/datum/symptom/heal/proc/passive_message_condition(mob/living/M)
	return TRUE

/*Starlight Condensation
 * Slightly reduces stealth
 * Reduces resistance
 * No change to stage speed
 * Slightly increases transmissibility
 * Bonus: Heals host when exposed to starlight
*/

/datum/symptom/heal/starlight
	name = "Starlight Condensation"
	desc = "The virus reacts to direct starlight, producing regenerative chemicals. Works best against toxin-based damage."
	stealth = -1
	resistance = -2
	stage_speed = 0
	transmittable = 1
	level = 6
	passive_message = "<span class='notice'>You miss the feeling of starlight on your skin.</span>"
	var/nearspace_penalty = 0.3
	threshold_descs = list(
		"Stage Speed 6" = "Increases healing speed.",
		"Transmission 6" = "Removes penalty for only being close to space.",
	)

#define STARLIGHT_CAN_HEAL 2
#define STARLIGHT_CAN_HEAL_WITH_PENALTY 1
#define STARLIGHT_CANNOT_HEAL 0
#define STARLIGHT_MAX_RANGE 2

/datum/symptom/heal/starlight/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalTransmittable() >= 6)
		nearspace_penalty = 1
	if(A.totalStageSpeed() >= 6)
		power = 2

/datum/symptom/heal/starlight/proc/CanTileHealDirectional(turf/turf_to_check, direction)
	if(direction == ZTRAIT_UP)
		turf_to_check = turf_to_check.above()
		if(!turf_to_check)
			return STARLIGHT_CANNOT_HEAL
	var/area/area_to_check = get_area(turf_to_check)
	var/levels_of_glass = 0 // Since starlight condensation only works 2 tiles to the side anyways, it shouldn't work with like 100 z-levels of glass
	while(levels_of_glass <= STARLIGHT_MAX_RANGE)
		// Outdoors covers lavaland and unroofed areas but with tiles under,
		// while space covers normal space and those caused by explosions,
		// if there is a floor tile when checking above, that means
		// a roof exists so the outdoors should only work downwards
		if(isspaceturf(turf_to_check) || (area_to_check.outdoors && direction == ZTRAIT_DOWN))
			if (levels_of_glass)
				return STARLIGHT_CAN_HEAL_WITH_PENALTY // Glass gives a penalty.
			return STARLIGHT_CAN_HEAL // No glass = can heal fully.

		// Our turf is transparent, but it's NOT openspace - it's something like glass which reduces power
		if(istransparentturf(turf_to_check) && !(istype(turf_to_check, /turf/open/openspace)))
			levels_of_glass += 1

		// Our turf is transparent OR openspace - we can check higher or lower z-levels
		if(istransparentturf(turf_to_check) || istype(turf_to_check, /turf/open/openspace))
			// Check above or below us
			if(direction == ZTRAIT_UP)
				turf_to_check = turf_to_check.above()
			else
				turf_to_check = turf_to_check.below()

			// If we found a turf above or below us,
			// then we can rerun the loop on the newly found turf / area
			// (Probably, with +1 to levels_of_glass)
			if(turf_to_check)
				area_to_check = get_area(turf_to_check)
				continue

			// If we didn't find a turf above or below us -
			// Checking below, we assume that space is below us (as we're standing on station)
			// Checking above, we check that the area is "outdoors" before assuming if it is space or not.
			else
				if(direction == ZTRAIT_DOWN || (direction == ZTRAIT_UP && area_to_check.outdoors))
					if (levels_of_glass)
						return STARLIGHT_CAN_HEAL_WITH_PENALTY
					return STARLIGHT_CAN_HEAL

		return STARLIGHT_CANNOT_HEAL // Hit a non-space, Non-transparent turf - no healsies

/datum/symptom/heal/starlight/proc/CanTileHeal(turf/original_turf, satisfied_with_penalty)
	var/current_heal_level = CanTileHealDirectional(original_turf, ZTRAIT_DOWN)
	if(current_heal_level == STARLIGHT_CAN_HEAL)
		return current_heal_level
	if(current_heal_level && satisfied_with_penalty) // do not care if there is a healing penalty or no
		return current_heal_level
	var/heal_level_from_above = CanTileHealDirectional(original_turf, ZTRAIT_UP)
	if(heal_level_from_above > current_heal_level)
		return heal_level_from_above
	else
		return current_heal_level

/datum/symptom/heal/starlight/CanHeal(datum/disease/advance/A)
	var/mob/living/affected_mob = A.affected_mob
	var/turf/turf_of_mob = get_turf(affected_mob)
	switch(CanTileHeal(turf_of_mob, FALSE))
		if(STARLIGHT_CAN_HEAL_WITH_PENALTY)
			return power * nearspace_penalty
		if(STARLIGHT_CAN_HEAL)
			return power
	for(var/turf/turf_to_check in view(affected_mob, STARLIGHT_MAX_RANGE))
		if(CanTileHeal(turf_to_check, TRUE))
			return power * nearspace_penalty

#undef STARLIGHT_CAN_HEAL
#undef STARLIGHT_CAN_HEAL_WITH_PENALTY
#undef STARLIGHT_CANNOT_HEAL
#undef STARLIGHT_MAX_RANGE

/datum/symptom/heal/starlight/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = actual_power
	if(M.getToxLoss() && prob(5))
		to_chat(M, span_notice("Your skin tingles as the starlight seems to heal you."))

	M.adjustToxLoss(-(4 * heal_amt)) //most effective on toxins

	var/list/parts = M.get_damaged_bodyparts(1,1, BODYTYPE_ORGANIC)

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, BODYTYPE_ORGANIC))
			M.update_damage_overlays()
	return 1

/datum/symptom/heal/starlight/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss() || M.getToxLoss())
		return TRUE
	return FALSE

/*Toxolysis
 * No change to stealth
 * Reduces resistance
 * Increases stage speed
 * Reduces transmissibility
 * Bonus: Removes all reagents from the host
*/
/datum/symptom/heal/chem
	name = "Toxolysis"
	stealth = 0
	resistance = -2
	stage_speed = 2
	transmittable = -2
	level = 7
	var/food_conversion = FALSE
	desc = "The virus rapidly breaks down any foreign chemicals in the bloodstream."
	threshold_descs = list(
		"Resistance 7" = "Increases chem removal speed.",
		"Stage Speed 6" = "Consumed chemicals nourish the host.",
	)

/datum/symptom/heal/chem/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 6)
		food_conversion = TRUE
	if(A.totalResistance() >= 7)
		power = 2

/datum/symptom/heal/chem/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.type, actual_power)
		if(food_conversion)
			M.adjust_nutrition(0.3)
		if(prob(2))
			to_chat(M, span_notice("You feel a mild warmth as your blood purifies itself."))
	return 1


/*Metabolic Boost
 * Slightly reduces stealth
 * Reduces resistance
 * Increases stage speed
 * Slightly increases transmissibility
 * Bonus: Doubles the rate of chemical metabolisation
 * Increases nutrition loss rate
*/
/datum/symptom/heal/metabolism
	name = "Metabolic Boost"
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmittable = 1
	level = 7
	var/triple_metabolism = FALSE
	var/reduced_hunger = FALSE
	desc = "The virus causes the host's metabolism to accelerate rapidly, making them process chemicals twice as fast,\
		but also causing increased hunger."
	threshold_descs = list(
		"Stealth 3" = "Reduces hunger rate.",
		"Stage Speed 10" = "Chemical metabolization is tripled instead of doubled.",
	)

/datum/symptom/heal/metabolism/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 10)
		triple_metabolism = TRUE
	if(A.totalStealth() >= 3)
		reduced_hunger = TRUE

/datum/symptom/heal/metabolism/Heal(mob/living/carbon/C, datum/disease/advance/A, actual_power)
	if(!istype(C))
		return
	var/metabolic_boost = triple_metabolism ? 2 : 1
	C.reagents.metabolize(C, metabolic_boost * SSMOBS_DT, 0, can_overdose=TRUE) //this works even without a liver; it's intentional since the virus is metabolizing by itself
	C.overeatduration = max(C.overeatduration - 4 SECONDS, 0)
	var/lost_nutrition = 9 - (reduced_hunger * 5)
	C.adjust_nutrition(-lost_nutrition * HUNGER_FACTOR) //Hunger depletes at 10x the normal speed
	if(prob(2))
		to_chat(C, span_notice("You feel an odd gurgle in your stomach, as if it was working much faster than normal."))
	return 1
/*Nocturnal Regeneration
 * Increases stealth
 * Slightly reduces resistance
 * Reduces stage speed
 * Slightly reduces transmissibility
 * Bonus: Heals brute damage when in the dark
*/
/datum/symptom/heal/darkness
	name = "Nocturnal Regeneration"
	desc = "The virus is able to mend the host's flesh when in conditions of low light, repairing physical damage. More effective against brute damage."
	stealth = 2
	resistance = -1
	stage_speed = -2
	transmittable = -1
	level = 6
	passive_message = "<span class='notice'>You feel tingling on your skin as light passes over it.</span>"
	threshold_descs = list(
		"Stage Speed 8" = "Doubles healing speed.",
	)

/datum/symptom/heal/darkness/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 8)
		power = 2

/datum/symptom/heal/darkness/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	var/light_amount = 0
	if(isturf(M.loc)) //else, there's considered to be no light
		var/turf/T = M.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			return power

/datum/symptom/heal/darkness/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1,BODYTYPE_ORGANIC)

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, span_notice("The darkness soothes and mends your wounds."))

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len * 0.5, BODYTYPE_ORGANIC)) //more effective on brute
			M.update_damage_overlays()
	return 1

/datum/symptom/heal/darkness/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE
/*Regen Coma
 * No effect on stealth
 * Increases resistance
 * Reduces stage speed greatly
 * Decreases transmissibility
 * Bonus: Puts the host into a coma when severely hurt, healing them
*/
/datum/symptom/heal/coma
	name = "Regenerative Coma"
	desc = "The virus causes the host to fall into a death-like coma when severely damaged, then rapidly fixes the damage."
	stealth = 0
	resistance = 2
	stage_speed = -3
	transmittable = -2
	level = 8
	passive_message = "<span class='notice'>The pain from your wounds makes you feel oddly sleepy...</span>"
	var/deathgasp = FALSE
	var/stabilize = FALSE
	var/active_coma = FALSE //to prevent multiple coma procs
	threshold_descs = list(
		"Stealth 2" = "Host appears to die when falling into a coma.",
		"Resistance 4" = "The virus also stabilizes the host while they are in critical condition.",
		"Stage Speed 7" = "Increases healing speed.",
	)

/datum/symptom/heal/coma/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 7)
		power = 1.5
	if(A.totalResistance() >= 4)
		stabilize = TRUE
	if(A.totalStealth() >= 2)
		deathgasp = TRUE

/datum/symptom/heal/coma/on_stage_change(datum/disease/advance/A)  //mostly copy+pasted from the code for self-respiration's TRAIT_NOBREATH stuff
	. = ..()
	if(!.)
		return FALSE
	if(A.stage >= 4 && stabilize)
		ADD_TRAIT(A.affected_mob, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)
	else
		REMOVE_TRAIT(A.affected_mob, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)
	return TRUE

/datum/symptom/heal/coma/End(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(active_coma)
		uncoma()
	REMOVE_TRAIT(A.affected_mob, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)

/datum/symptom/heal/coma/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(HAS_TRAIT(M, TRAIT_DEATHCOMA))
		return power
	if(M.IsSleeping())
		return power * 0.25 //Voluntary unconsciousness yields lower healing.
	switch(M.stat)
		if(UNCONSCIOUS, HARD_CRIT)
			return power * 0.9
		if(SOFT_CRIT)
			return power * 0.5
	if(M.getBruteLoss() + M.getFireLoss() >= 70 && !active_coma)
		to_chat(M, span_warning("You feel yourself slip into a regenerative coma..."))
		active_coma = TRUE
		addtimer(CALLBACK(src, PROC_REF(coma), M), 60)


/datum/symptom/heal/coma/proc/coma(mob/living/M)
	M.fakedeath("regenerative_coma", !deathgasp)
	addtimer(CALLBACK(src, PROC_REF(uncoma), M), 300)


/datum/symptom/heal/coma/proc/uncoma(mob/living/M)
	if(QDELETED(M) || !active_coma)
		return
	active_coma = FALSE
	M.cure_fakedeath("regenerative_coma")


/datum/symptom/heal/coma/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 4 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, BODYTYPE_ORGANIC))
			M.update_damage_overlays()

	if(active_coma && M.getBruteLoss() + M.getFireLoss() == 0)
		uncoma(M)

	return 1

/datum/symptom/heal/coma/passive_message_condition(mob/living/M)
	if((M.getBruteLoss() + M.getFireLoss()) > 30)
		return TRUE
	return FALSE

/datum/symptom/heal/water
	name = "Tissue Hydration"
	desc = "The virus uses excess water inside and outside the body to repair damaged tissue cells. More effective when using holy water and against burns."
	stealth = 0
	resistance = -1
	stage_speed = 0
	transmittable = 1
	level = 6
	passive_message = "<span class='notice'>Your skin feels oddly dry...</span>"
	var/absorption_coeff = 1
	threshold_descs = list(
		"Resistance 5" = "Water is consumed at a much slower rate.",
		"Stage Speed 7" = "Increases healing speed.",
	)

/datum/symptom/heal/water/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 7)
		power = 2
	if(A.totalResistance() >= 5)
		absorption_coeff = 0.25

/datum/symptom/heal/water/CanHeal(datum/disease/advance/A)
	. = 0
	var/mob/living/M = A.affected_mob
	if(M.fire_stacks < 0)
		M.adjust_fire_stacks(min(absorption_coeff, -M.fire_stacks))
		. += power
	if(M.reagents.has_reagent(/datum/reagent/water/holywater, needs_metabolizing = FALSE))
		M.reagents.remove_reagent(/datum/reagent/water/holywater, 0.5 * absorption_coeff)
		. += power * 0.75
	else if(M.reagents.has_reagent(/datum/reagent/water, needs_metabolizing = FALSE))
		M.reagents.remove_reagent(/datum/reagent/water, 0.5 * absorption_coeff)
		. += power * 0.5

/datum/symptom/heal/water/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1, BODYTYPE_ORGANIC) //more effective on burns

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, span_notice("You feel yourself absorbing the water around you to soothe your damaged skin."))

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len * 0.5, heal_amt/parts.len, BODYTYPE_ORGANIC))
			M.update_damage_overlays()

	return 1

/datum/symptom/heal/water/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/// Determines the rate at which Plasma Fixation heals based on the amount of plasma in the air
#define HEALING_PER_MOL 1.1
/// Determines the rate at which Plasma Fixation heals based on the amount of plasma being breathed through internals
#define HEALING_PER_BREATH_PRESSURE 0.05
/// Determines the highest amount you can be healed for when breathing plasma from internals
#define MAX_HEAL_COEFFICIENT_INTERNALS 0.75
/// Determines the highest amount you can be healed for from pulling plasma from the environment
#define MAX_HEAL_COEFFICIENT_ENVIRONMENT 0.5
/// Determines the highest amount you can be healed for when there is plasma in the bloodstream
#define MAX_HEAL_COEFFICIENT_BLOODSTREAM 0.75
/// This is the base heal amount before being multiplied by the healing coefficients
#define BASE_HEAL_PLASMA_FIXATION 4

/datum/symptom/heal/plasma
	name = "Plasma Fixation"
	desc = "The virus draws plasma from the atmosphere and from inside the body to heal and stabilize body temperature."
	stealth = 0
	resistance = 3
	stage_speed = -2
	transmittable = -2
	level = 8
	passive_message = "<span class='notice'>You feel an odd attraction to plasma.</span>"
	var/temp_rate = 1
	threshold_descs = list(
		"Transmission 6" = "Increases temperature adjustment rate.",
		"Stage Speed 7" = "Increases healing speed.",
	)

/datum/symptom/heal/plasma/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 7)
		power = 2
	if(A.totalTransmittable() >= 6)
		temp_rate = 4

// We do this to prevent liver damage from injecting plasma when plasma fixation virus reaches stage 4 and beyond
/datum/symptom/heal/plasma/on_stage_change(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return FALSE
		
	if(advanced_disease.stage >= 4)
		ADD_TRAIT(advanced_disease.affected_mob, TRAIT_PLASMA_LOVER_METABOLISM, DISEASE_TRAIT)
	else 
		REMOVE_TRAIT(advanced_disease.affected_mob, TRAIT_PLASMA_LOVER_METABOLISM, DISEASE_TRAIT)
	return TRUE

/datum/symptom/heal/plasma/End(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return
		
	REMOVE_TRAIT(advanced_disease.affected_mob, TRAIT_PLASMA_LOVER_METABOLISM, DISEASE_TRAIT)

// Check internals breath, environmental plasma, and plasma in bloodstream to determine the heal power
/datum/symptom/heal/plasma/CanHeal(datum/disease/advance/advanced_disease)
	var/mob/living/diseased_mob = advanced_disease.affected_mob
	var/datum/gas_mixture/environment
	var/list/gases

	. = 0

	// Check internals
	///  the amount of mols in a breath is significantly lower than in the environment so we are just going to use the tank's
	///  distribution pressure as an abstraction rather than calculate it using the ideal gas equation.
	///  balanced around a tank set to 4kpa = about 0.2 healing power. maxes out at 0.75 healing power, or 15kpa.
	if(iscarbon(diseased_mob))
		var/mob/living/carbon/breather = diseased_mob
		var/obj/item/tank/internals/internals_tank = breather.internal
		if(internals_tank)
			var/datum/gas_mixture/tank_contents = internals_tank.return_air()
			if(tank_contents && round(tank_contents.return_pressure())) // make sure the tank is not empty or 0 pressure
				if(tank_contents.gases[/datum/gas/plasma])
					// higher tank distribution pressure leads to more healing, but once you get to about 15kpa you reach the max
					. += power * min(MAX_HEAL_COEFFICIENT_INTERNALS, internals_tank.distribute_pressure * HEALING_PER_BREATH_PRESSURE)
	// Check environment			
	if(diseased_mob.loc)
		environment = diseased_mob.loc.return_air()
	if(environment)
		gases = environment.gases
		if(gases[/datum/gas/plasma])
			. += power * min(MAX_HEAL_COEFFICIENT_INTERNALS, gases[/datum/gas/plasma][MOLES] * HEALING_PER_MOL)
	// Check for reagents in bloodstream
	if(diseased_mob.reagents.has_reagent(/datum/reagent/toxin/plasma, needs_metabolizing = TRUE))
		. += power * MAX_HEAL_COEFFICIENT_BLOODSTREAM //Determines how much the symptom heals if injected or ingested

/datum/symptom/heal/plasma/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = BASE_HEAL_PLASMA_FIXATION * actual_power

	if(prob(5))
		to_chat(M, span_notice("You feel yourself absorbing plasma inside and around you..."))

	var/target_temp = M.get_body_temp_normal()
	if(M.bodytemperature > target_temp)
		M.adjust_bodytemperature(-20 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT, target_temp)
		if(prob(5))
			to_chat(M, span_notice("You feel less hot."))
	else if(M.bodytemperature < (M.get_body_temp_normal() + 1))
		M.adjust_bodytemperature(20 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT, 0, target_temp)
		if(prob(5))
			to_chat(M, span_notice("You feel warmer."))

	M.adjustToxLoss(-heal_amt)

	var/list/parts = M.get_damaged_bodyparts(1,1, BODYTYPE_ORGANIC)
	if(!parts.len)
		return
	if(prob(5))
		to_chat(M, span_notice("The pain from your wounds fades rapidly."))
	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, BODYTYPE_ORGANIC))
			M.update_damage_overlays()
	return 1

///Plasma End
#undef HEALING_PER_MOL
#undef HEALING_PER_BREATH_PRESSURE
#undef MAX_HEAL_COEFFICIENT_INTERNALS
#undef MAX_HEAL_COEFFICIENT_ENVIRONMENT
#undef MAX_HEAL_COEFFICIENT_BLOODSTREAM
#undef BASE_HEAL_PLASMA_FIXATION

/datum/symptom/heal/radiation
	name = "Radioactive Resonance"
	desc = "The virus uses radiation to fix damage through dna mutations."
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmittable = -3
	level = 6
	symptom_delay_min = 1
	symptom_delay_max = 1
	passive_message = "<span class='notice'>Your skin glows faintly for a moment.</span>"
	var/cellular_damage = FALSE
	threshold_descs = list(
		"Transmission 6" = "Additionally heals cellular damage.",
		"Resistance 7" = "Increases healing speed.",
	)

/datum/symptom/heal/radiation/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 7)
		power = 2
	if(A.totalTransmittable() >= 6)
		cellular_damage = TRUE

/datum/symptom/heal/radiation/CanHeal(datum/disease/advance/A)
	return HAS_TRAIT(A.affected_mob, TRAIT_IRRADIATED) ? power : 0

/datum/symptom/heal/radiation/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = actual_power

	if(cellular_damage)
		M.adjustCloneLoss(-heal_amt * 0.5)

	M.adjustToxLoss(-(2 * heal_amt))

	var/list/parts = M.get_damaged_bodyparts(1,1, BODYTYPE_ORGANIC)

	if(!parts.len)
		return

	if(prob(4))
		to_chat(M, span_notice("Your skin glows faintly, and you feel your wounds mending themselves."))

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, BODYTYPE_ORGANIC))
			M.update_damage_overlays()
	return 1
