

//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection()
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD 0.3
#define THERMAL_PROTECTION_CHEST 0.15
#define THERMAL_PROTECTION_GROIN 0.15
#define THERMAL_PROTECTION_LEG_LEFT 0.075
#define THERMAL_PROTECTION_LEG_RIGHT 0.075
#define THERMAL_PROTECTION_FOOT_LEFT 0.025
#define THERMAL_PROTECTION_FOOT_RIGHT 0.025
#define THERMAL_PROTECTION_ARM_LEFT 0.075
#define THERMAL_PROTECTION_ARM_RIGHT 0.075
#define THERMAL_PROTECTION_HAND_LEFT 0.025
#define THERMAL_PROTECTION_HAND_RIGHT 0.025

/mob/living/carbon/human/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	. = ..()

	if(QDELETED(src))
		return FALSE

	// Body temperature stability and damage
	dna.species.handle_body_temperature(src, seconds_per_tick, times_fired)
	if(HAS_TRAIT(src, TRAIT_STASIS))
		for(var/datum/wound/iter_wound as anything in all_wounds)
			iter_wound.on_stasis(seconds_per_tick, times_fired)
		return stat != DEAD

	if(stat == DEAD)
		return FALSE

	// Handle active mutations
	for(var/datum/mutation/mutation as anything in dna.mutations)
		mutation.on_life(seconds_per_tick, times_fired)

	// Heart attack stuff
	handle_heart(seconds_per_tick, times_fired)
	// Handles liver failure effects, if we lack a liver
	handle_liver(seconds_per_tick, times_fired)
	// For special species interactions
	dna.species.spec_life(src, seconds_per_tick, times_fired)
	// Radiation stuff
	handle_radiation(seconds_per_tick, times_fired)
	return stat != DEAD

/mob/living/carbon/human/calculate_affecting_pressure(pressure)
	var/chest_covered = !get_bodypart(BODY_ZONE_CHEST)
	var/head_covered = !get_bodypart(BODY_ZONE_HEAD)
	var/hands_covered = !get_bodypart(BODY_ZONE_L_ARM) && !get_bodypart(BODY_ZONE_R_ARM)
	var/feet_covered = !get_bodypart(BODY_ZONE_L_LEG) && !get_bodypart(BODY_ZONE_R_LEG)
	for(var/obj/item/clothing/equipped in get_equipped_items(INCLUDE_ABSTRACT))
		if(!chest_covered && (equipped.body_parts_covered & CHEST) && (equipped.clothing_flags & STOPSPRESSUREDAMAGE))
			chest_covered = TRUE
		if(!head_covered && (equipped.body_parts_covered & HEAD) && (equipped.clothing_flags & STOPSPRESSUREDAMAGE))
			head_covered = TRUE
		if(!hands_covered && (equipped.body_parts_covered & HANDS|ARMS) && (equipped.clothing_flags & STOPSPRESSUREDAMAGE))
			hands_covered = TRUE
		if(!feet_covered && (equipped.body_parts_covered & FEET|LEGS) && (equipped.clothing_flags & STOPSPRESSUREDAMAGE))
			feet_covered = TRUE

	if(chest_covered && head_covered && hands_covered && feet_covered)
		return ONE_ATMOSPHERE
	if(ismovable(loc))
		/// If we're in a space with 0.5 content pressure protection, it averages the values, for example.
		var/atom/movable/occupied_space = loc
		return (occupied_space.contents_pressure_protection * ONE_ATMOSPHERE + (1 - occupied_space.contents_pressure_protection) * pressure)
	return pressure

/mob/living/carbon/human/breathe()
	if(!HAS_TRAIT(src, TRAIT_NOBREATH))
		return ..()

/mob/living/carbon/human/check_breath(datum/gas_mixture/breath)
	var/obj/item/organ/lungs/human_lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	if(human_lungs)
		return human_lungs.check_breath(breath, src)

	if(health >= crit_threshold)
		adjustOxyLoss(HUMAN_MAX_OXYLOSS + 1)
	else if(!HAS_TRAIT(src, TRAIT_NOCRITDAMAGE))
		adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

	failed_last_breath = TRUE

	var/datum/species/human_species = dna.species

	switch(human_species.breathid)
		if(GAS_O2)
			throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
		if(GAS_PLASMA)
			throw_alert(ALERT_NOT_ENOUGH_PLASMA, /atom/movable/screen/alert/not_enough_plas)
		if(GAS_CO2)
			throw_alert(ALERT_NOT_ENOUGH_CO2, /atom/movable/screen/alert/not_enough_co2)
		if(GAS_N2)
			throw_alert(ALERT_NOT_ENOUGH_NITRO, /atom/movable/screen/alert/not_enough_nitro)
	return FALSE

/// Environment handlers for species
/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	// If we are in a cryo bed do not process life functions
	if(istype(loc, /obj/machinery/cryo_cell))
		return

	dna.species.handle_environment(src, environment, seconds_per_tick, times_fired)

/**
 * Adjust the core temperature of a mob
 *
 * vars:
 * * amount The amount of degrees to change body temperature by
 * * min_temp (optional) The minimum body temperature after adjustment
 * * max_temp (optional) The maximum body temperature after adjustment
 */
/mob/living/carbon/human/proc/adjust_coretemperature(amount, min_temp=0, max_temp=INFINITY)
	set_coretemperature(clamp(coretemperature + amount, min_temp, max_temp))

/mob/living/carbon/human/proc/set_coretemperature(value)
	SEND_SIGNAL(src, COMSIG_HUMAN_CORETEMP_CHANGE, coretemperature, value)
	coretemperature = value

/**
 * get_body_temperature Returns the body temperature with any modifications applied
 *
 * This applies the result from proc/get_body_temp_normal_change() against the bodytemp_normal
 * for the species and returns the result
 *
 * arguments:
 * * apply_change (optional) Default True This applies the changes to body temperature normal
 */
/mob/living/carbon/human/get_body_temp_normal(apply_change=TRUE)
	if(!apply_change)
		return dna.species.bodytemp_normal
	return dna.species.bodytemp_normal + get_body_temp_normal_change()

/mob/living/carbon/human/get_body_temp_heat_damage_limit()
	return dna.species.bodytemp_heat_damage_limit

/mob/living/carbon/human/get_body_temp_cold_damage_limit()
	return dna.species.bodytemp_cold_damage_limit

/mob/living/carbon/human/proc/get_thermal_protection()
	var/thermal_protection = 0 //Simple check to estimate how protected we are against multiple temperatures
	if(wear_suit)
		if((wear_suit.heat_protection & CHEST) && (wear_suit.max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT))
			thermal_protection += (wear_suit.max_heat_protection_temperature * 0.7)
	if(head)
		if((head.heat_protection & HEAD) && (head.max_heat_protection_temperature >= FIRE_HELM_MAX_TEMP_PROTECT))
			thermal_protection += (head.max_heat_protection_temperature * THERMAL_PROTECTION_HEAD)
	thermal_protection = round(thermal_protection)
	return thermal_protection

//END FIRE CODE

//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, CHEST, GROIN, etc. See setup.dm for the full list)
/mob/living/carbon/human/proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = 0
	//Handle normal clothing
	if(head)
		if(head.max_heat_protection_temperature && head.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= head.heat_protection
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature && wear_suit.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_suit.heat_protection
	if(w_uniform)
		if(w_uniform.max_heat_protection_temperature && w_uniform.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= w_uniform.heat_protection
	if(shoes)
		if(shoes.max_heat_protection_temperature && shoes.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= shoes.heat_protection
	if(gloves)
		if(gloves.max_heat_protection_temperature && gloves.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= gloves.heat_protection
	if(wear_mask)
		if(wear_mask.max_heat_protection_temperature && wear_mask.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_mask.heat_protection

	return thermal_protection_flags

/mob/living/carbon/human/get_heat_protection(temperature)
	var/thermal_protection_flags = get_heat_protection_flags(temperature)
	var/thermal_protection = heat_protection

	// Apply clothing items protection
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & CHEST)
			thermal_protection += THERMAL_PROTECTION_CHEST
		if(thermal_protection_flags & GROIN)
			thermal_protection += THERMAL_PROTECTION_GROIN
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT

	return min(1, round(thermal_protection, 0.001))

//See proc/get_heat_protection_flags(temperature) for the description of this proc.
/mob/living/carbon/human/proc/get_cold_protection_flags(temperature)
	var/thermal_protection_flags = 0
	//Handle normal clothing

	if(head)
		if(head.min_cold_protection_temperature && head.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= head.cold_protection
	if(wear_suit)
		if(wear_suit.min_cold_protection_temperature && wear_suit.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_suit.cold_protection
	if(w_uniform)
		if(w_uniform.min_cold_protection_temperature && w_uniform.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= w_uniform.cold_protection
	if(shoes)
		if(shoes.min_cold_protection_temperature && shoes.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= shoes.cold_protection
	if(gloves)
		if(gloves.min_cold_protection_temperature && gloves.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= gloves.cold_protection
	if(wear_mask)
		if(wear_mask.min_cold_protection_temperature && wear_mask.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_mask.cold_protection

	return thermal_protection_flags

/mob/living/carbon/human/get_cold_protection(temperature)
	// There is an occasional bug where the temperature is miscalculated in areas with small amounts of gas.
	// This is necessary to ensure that does not affect this calculation.
	// Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
	temperature = max(temperature, 2.7)
	var/thermal_protection_flags = get_cold_protection_flags(temperature)
	var/thermal_protection = cold_protection

	// Apply clothing items protection
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & CHEST)
			thermal_protection += THERMAL_PROTECTION_CHEST
		if(thermal_protection_flags & GROIN)
			thermal_protection += THERMAL_PROTECTION_GROIN
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT

	return min(1, round(thermal_protection, 0.001))

/mob/living/carbon/human/has_smoke_protection()
	if(isclothing(wear_mask))
		if(wear_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	if(isclothing(glasses))
		if(glasses.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	if(isclothing(head))
		var/obj/item/clothing/CH = head
		if(CH.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	return ..()

/mob/living/carbon/human/proc/handle_heart(seconds_per_tick, times_fired)
	var/we_breath = !HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT)

	if(!undergoing_cardiac_arrest())
		return

	if(we_breath)
		adjustOxyLoss(4 * seconds_per_tick)
		Unconscious(80)
	// Tissues die without blood circulation
	adjustBruteLoss(1 * seconds_per_tick)

/mob/living/carbon/human/proc/handle_radiation(seconds_per_tick, times_fired)
	if(HAS_TRAIT(src, TRAIT_RADIMMUNE))
		return
	if(radiation > 0)
		throw_alert(ALERT_IRRADIATED, /atom/movable/screen/alert/irradiated) // So many alerts... So messy...
		clear_alert(ALERT_IRRADIATED_LESS)
	else if(radiation_damage > 0)
		throw_alert(ALERT_IRRADIATED_LESS, /atom/movable/screen/alert/irradiated/less)
		clear_alert(ALERT_IRRADIATED)
	else
		clear_alert(ALERT_IRRADIATED)
		clear_alert(ALERT_IRRADIATED_LESS)
		REMOVE_TRAIT(src, TRAIT_IRRADIATED, RADIATION_TRAIT)
	if(!(radiation == 0 && radiation_damage == 0))
		ADD_TRAIT(src, TRAIT_IRRADIATED, RADIATION_TRAIT)

	var/effective_radiation = radiation // Used for halting radiation effects and adding functionality for radiation resistant humans
	var/effective_rad_damage = radiation_damage

	if(HAS_TRAIT(src, TRAIT_HALT_RADIATION_EFFECTS))
		effective_rad_damage = 0
		effective_radiation = 0
	else if (has_reagent(/datum/reagent/inverse/pen_acid, needs_metabolizing = TRUE))
		effective_radiation *= 1.5
		effective_rad_damage *= 1.5

	if(effective_radiation > 0) // Effective rads of 0 pauses rad decay. It's called HALT_RADIATION_EFFECTS, not HALT_RADIATION_SYMPTOMS_BUT_LET_THE_EFFECTS_WEAR_OFF
		radiation_stage(seconds_per_tick) // Note: This function is unaffected by effective rads
	else if(effective_rad_damage > 0)
		radiation_damage = max(radiation_damage - seconds_per_tick * 0.5, 0)

	if(effective_rad_damage >= RAD_STAGE_THRESHOLDS[1] && effective_rad_damage < RAD_STAGE_THRESHOLDS[2]) // Stage 1: Mild dizziness, tox damage, and fatigue
		adjustToxLoss(0.1)
		if(SPT_PROB(3, seconds_per_tick))
			if(prob(30)) // To avoid chat spam since there are going to be a lot of symptoms at high stages
				to_chat(src, span_warning("You feel dizzy."))
			adjust_dizzy_up_to(10 SECONDS, 20 SECONDS)
		if(SPT_PROB(2, seconds_per_tick))
			if(prob(30))
				to_chat(src, span_warning("You feel weak."))
			adjustStaminaLoss(25)
	if(effective_rad_damage >= RAD_STAGE_THRESHOLDS[2]) // Stage 2: It's like stage 1 but worse. From here on we keep the effects of all stages below ours
		adjustToxLoss(min(0.1 + (effective_rad_damage-15)/1000, 0.5))
		if(SPT_PROB(2, seconds_per_tick))
			if(prob(30))
				to_chat(src, span_warning("You feel nauseated."))
			adjust_disgust(35)
		if(SPT_PROB(2, seconds_per_tick))
			if(prob(30))
				to_chat(src, span_warning("You feel [(effective_rad_damage >= 300) ? "very" : ""] weak."))
			adjustStaminaLoss(min(20+effective_rad_damage/10, 60))
	if(effective_rad_damage >= RAD_STAGE_THRESHOLDS[3]) // Stage 3: Glow that lasts until we are no longer irradiated + headaches and immunodeficiency
		ADD_TRAIT(src, TRAIT_IMMUNODEFICIENCY, RADIATION_TRAIT)
		var/filter = get_filter("rad_glow")
		if (!filter)
			add_filter("rad_glow", 2, list("type" = "outline", "color" = "#39ff1430", "size" = 2))
			addtimer(CALLBACK(src, PROC_REF(start_glow_loop), src), rand(0.1 SECONDS, 1.9 SECONDS)) // Things should look uneven
		if(SPT_PROB(1.5, seconds_per_tick))
			to_chat(src, span_warning("[pick("Your head hurts.", "Your head pounds.")]"))
			adjust_dizzy_up_to(15 SECONDS, 30 SECONDS)
			adjust_drowsiness_up_to(15 SECONDS, 30 SECONDS)
			adjustStaminaLoss(min(10+effective_rad_damage/10, 50))
		if(effective_radiation > RAD_MOB_HAIRLOSS && SPT_PROB(0.5, seconds_per_tick)) // Hair loss and mutations are thematic but not necessarily fun, so they shouldn't happen unless we are thoroughly fucked up
			var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
			if(!(hairstyle == "Bald") && (head?.head_flags & (HEAD_HAIR|HEAD_FACIAL_HAIR)))
				to_chat(src, span_danger("Your hair starts to fall out in clumps..."))
				addtimer(CALLBACK(src, PROC_REF(go_bald), src), 5 SECONDS)
	else
		remove_filter("rad_glow")
		REMOVE_TRAIT(src, TRAIT_IMMUNODEFICIENCY, RADIATION_TRAIT)
	if(effective_rad_damage >= RAD_STAGE_THRESHOLDS[4]) // Stage 4: Our organs start to fail and the headaches get a lot worse.
		for(var/slot in organs_slot)
			var/damage = min(effective_radiation/25, 0.5) * (rand(75, 125)/100) // Arr en gee
			var/max_damage = effective_radiation*10
			for(var/radiation_resistant_organ in list(ORGAN_SLOT_BRAIN, ORGAN_SLOT_EARS, ORGAN_SLOT_EYES)) // Radiation quickly causing brain traumas, blindness, and deafness would be a little unfair
				if(slot == radiation_resistant_organ)
					damage /= 2
					max_damage /=2
			adjustOrganLoss(slot, damage, max_damage, ORGAN_ORGANIC) // Robotics are immune to radiation
		if(SPT_PROB(1, seconds_per_tick))
			visible_message(span_danger("[src] starts having a seizure!"), span_userdanger("You have a seizure!"))
			Unconscious(12 SECONDS)
			adjust_disgust(10)
		if(SPT_PROB(1.5, seconds_per_tick))
			if(!is_blind(src))
				to_chat(src, span_warning("Your vision swims.")) // It should start to get really bad around here
			adjust_confusion_up_to(10 SECONDS, 20 SECONDS)
			adjust_disgust(30)
			adjust_staggered_up_to(15 SECONDS, 30 SECONDS)
			adjustStaminaLoss(40)
			Knockdown(4 SECONDS, 3 SECONDS)
		if(effective_radiation > RAD_MOB_MUTATE && SPT_PROB(0.75, seconds_per_tick))
			to_chat(src, span_danger("You mutate!"))
			easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
			INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "gasp")
			domutcheck()
	if(effective_rad_damage >= RAD_STAGE_THRESHOLDS[5]) // Stage 5: Our skin starts peeling off and we start vomiting blood.
		var/possible_organic_parts = get_damageable_bodyparts(BODYTYPE_ORGANIC)
		if(possible_organic_parts) // We don't want to tell someone their skin is peeling off if it actually isn't
			adjustBruteLoss(0.25 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)
			if(SPT_PROB(1.5, seconds_per_tick))
				to_chat(src, span_danger("Your skin is peeling off of your body!"))
				adjustBruteLoss(6, required_bodytype = BODYTYPE_ORGANIC)
		if(SPT_PROB(0.5, seconds_per_tick))
			vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 10)

	if(effective_radiation > RAD_MOB_MICROWAVE)
		if(!has_status_effect(/datum/status_effect/washing_regen))
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(src, span_danger("Your body feels unnaturally hot."))
			adjust_coretemperature(min(effective_radiation*2-2, 30), seconds_per_tick, max_temp = effective_radiation * 100)
			adjust_bodytemperature(min(effective_radiation*2-2, 30), seconds_per_tick, max_temp = effective_radiation * 100)

/mob/living/carbon/human/proc/go_bald()
	set_facial_hairstyle("Shaved", update = FALSE)
	set_hairstyle("Bald")

/mob/living/carbon/human/proc/start_glow_loop()
	var/filter = get_filter("rad_glow")
	if (!filter)
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)

/mob/living/carbon/human/proc/radiation_stage(seconds_per_tick)
	var/stage_cap = 1
	var/shower = has_status_effect(/datum/status_effect/washing_regen)

	for(var/i in 1 to 4) // If our radiation is over a requirement, we get to increase our radiation damage beyond a stage threshold
		if(radiation >= RAD_STAGE_REQUIREMENTS[i])
			stage_cap = i+1

	if(radiation_damage < RAD_STAGE_THRESHOLDS[stage_cap])
		radiation_damage = min(radiation_damage + radiation * seconds_per_tick * (shower ? 0.3 : 1), RAD_STAGE_THRESHOLDS[stage_cap])
		if(radiation > 2)
			return // We don't heal rads if we're still accumulating damage, unless our radiation level is really low.
	radiation = max(radiation - RAD_MOB_DECAY_RATE * (shower ? 3 : 1), 0)
	return

#undef THERMAL_PROTECTION_HEAD
#undef THERMAL_PROTECTION_CHEST
#undef THERMAL_PROTECTION_GROIN
#undef THERMAL_PROTECTION_LEG_LEFT
#undef THERMAL_PROTECTION_LEG_RIGHT
#undef THERMAL_PROTECTION_FOOT_LEFT
#undef THERMAL_PROTECTION_FOOT_RIGHT
#undef THERMAL_PROTECTION_ARM_LEFT
#undef THERMAL_PROTECTION_ARM_RIGHT
#undef THERMAL_PROTECTION_HAND_LEFT
#undef THERMAL_PROTECTION_HAND_RIGHT
