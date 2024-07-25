/datum/symptom/narcolepsy
	name = "Aurora Snorealis"
	desc = "The virus causes a hormone imbalance, making the host sleepy and narcoleptic."
	stage = 2
	restricted = TRUE
	badness = EFFECT_DANGER_ANNOYING
	max_multiplier = 5
	var/yawning = FALSE


/datum/symptom/narcolepsy/activate(mob/living/carbon/M)
	switch(round(multiplier, 1))
		if(1)
			if(prob(50))
				to_chat(M, span_warning("You feel tired."))
		if(2)
			if(prob(50))
				to_chat(M, span_warning("You feel very tired."))
		if(3)
			if(prob(50))
				to_chat(M, span_warning("You try to focus on staying awake."))

			M.adjust_drowsiness_up_to(2.5 SECONDS, 20 SECONDS)

		if(4)
			if(prob(50))
				if(yawning)
					to_chat(M, span_warning("You try and fail to suppress a yawn."))
				else
					to_chat(M, span_warning("You nod off for a moment.")) //you can't really yawn while nodding off, can you?

			M.adjust_drowsiness_up_to(5 SECONDS, 20 SECONDS)

			if(yawning)
				M.emote("yawn")
				if(M.check_airborne_sterility())
					return
				var/strength = 0
				for (var/datum/disease/advanced/V  as anything in M.diseases)
					strength += V.infectionchance
				strength = round(strength/M.diseases.len)

				var/i = 1
				while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
					new /obj/effect/pathogen_cloud/core(get_turf(src), M, virus_copylist(M.diseases))
					strength -= 30
					i++

		if(5)
			if(prob(50))
				to_chat(M, span_warning("[pick("So tired...","You feel very sleepy.","You have a hard time keeping your eyes open.","You try to stay awake.")]"))

			M.adjust_drowsiness_up_to(10 SECONDS, 20 SECONDS)

			if(yawning)
				M.emote("yawn")
				if(M.check_airborne_sterility())
					return
				var/strength = 0
				for (var/datum/disease/advanced/V  as anything in M.diseases)
					strength += V.infectionchance
				strength = round(strength/M.diseases.len)

				var/i = 1
				while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
					new /obj/effect/pathogen_cloud/core(get_turf(src), M, virus_copylist(M.diseases))
					strength -= 30
					i++


#define STARLIGHT_CAN_HEAL 2
#define STARLIGHT_CAN_HEAL_WITH_PENALTY 1
#define STARLIGHT_CANNOT_HEAL 0
#define STARLIGHT_MAX_RANGE 2

/datum/symptom/starlight
	name = "Starlight Condensation"
	desc = "The virus reacts to direct starlight, producing regenerative chemicals. Works best against toxin-based damage."
	max_multiplier = 5
	stage = 2
	restricted = TRUE
	badness = EFFECT_DANGER_HELPFUL

	var/list/passive_message = span_notice("You miss the feeling of starlight on your skin.")
	var/nearspace_penalty = 0.3

/datum/symptom/starlight/activate(mob/living/carbon/mob)

	var/mob/living/M = mob
	switch(round(multiplier))
		if(4, 5)
			var/effectiveness = CanHeal(mob)
			if(!effectiveness)
				if(passive_message && prob(2) && passive_message_condition(M))
					to_chat(M, passive_message)
				return
			else
				Heal(M, effectiveness)
	return

/datum/symptom/starlight/proc/CanTileHealDirectional(turf/turf_to_check, direction)
	if(direction == UP)
		turf_to_check = GET_TURF_ABOVE(turf_to_check)
		if(!turf_to_check)
			return STARLIGHT_CANNOT_HEAL
	var/area/area_to_check = get_area(turf_to_check)
	var/levels_of_glass = 0 // Since starlight condensation only works 2 tiles to the side anyways, it shouldn't work with like 100 z-levels of glass
	while(levels_of_glass <= STARLIGHT_MAX_RANGE)
		// Outdoors covers lavaland and unroofed areas but with tiles under,
		// while space covers normal space and those caused by explosions,
		// if there is a floor tile when checking above, that means
		// a roof exists so the outdoors should only work downwards
		if(isspaceturf(turf_to_check) || (area_to_check.outdoors && direction == DOWN))
			if (levels_of_glass)
				return STARLIGHT_CAN_HEAL_WITH_PENALTY // Glass gives a penalty.
			return STARLIGHT_CAN_HEAL // No glass = can heal fully.

		// Our turf is transparent, but it's NOT openspace - it's something like glass which reduces power
		if(istransparentturf(turf_to_check) && !(istype(turf_to_check, /turf/open/openspace)))
			levels_of_glass += 1

		// Our turf is transparent OR openspace - we can check higher or lower z-levels
		if(istransparentturf(turf_to_check) || istype(turf_to_check, /turf/open/openspace))
			// Check above or below us
			if(direction == UP)
				turf_to_check = GET_TURF_ABOVE(turf_to_check)
			else
				turf_to_check = GET_TURF_BELOW(turf_to_check)

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
				if(direction == DOWN || (direction == UP && area_to_check.outdoors))
					if (levels_of_glass)
						return STARLIGHT_CAN_HEAL_WITH_PENALTY
					return STARLIGHT_CAN_HEAL

		return STARLIGHT_CANNOT_HEAL // Hit a non-space, Non-transparent turf - no healsies

/datum/symptom/starlight/proc/CanTileHeal(turf/original_turf, satisfied_with_penalty)
	var/current_heal_level = CanTileHealDirectional(original_turf, DOWN)
	if(current_heal_level == STARLIGHT_CAN_HEAL)
		return current_heal_level
	if(current_heal_level && satisfied_with_penalty) // do not care if there is a healing penalty or no
		return current_heal_level
	var/heal_level_from_above = CanTileHealDirectional(original_turf, UP)
	if(heal_level_from_above > current_heal_level)
		return heal_level_from_above
	else
		return current_heal_level

/datum/symptom/starlight/proc/CanHeal(mob/living/carbon/mob)
	var/mob/living/affected_mob = mob
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

/datum/symptom/starlight/proc/Heal(mob/living/carbon/M, actual_power)
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

/datum/symptom/starlight/proc/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss() || M.getToxLoss())
		return TRUE
	return FALSE

/datum/symptom/toxolysis
	name = "Toxolysis"
	desc = "The virus rapidly breaks down any foreign chemicals in the bloodstream."
	max_multiplier = 10
	stage = 2
	var/food_conversion = FALSE

/datum/symptom/toxolysis/activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	. = ..()
	var/mob/living/M = mob
	switch(round(multiplier))
		if(9, 10)
			food_conversion = TRUE
			Heal(M, multiplier)
		if(4, 5, 6, 7, 8)
			Heal(M, multiplier)
		else
			multiplier = min(multiplier + 0.1, max_multiplier)
	return

/datum/symptom/toxolysis/proc/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.type, actual_power)
		if(food_conversion)
			M.adjust_nutrition(0.3)
		if(prob(2))
			to_chat(M, span_notice("You feel a mild warmth as your blood purifies itself."))
	return TRUE
