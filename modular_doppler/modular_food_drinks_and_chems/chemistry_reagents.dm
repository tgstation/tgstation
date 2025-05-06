/*
/datum/reagent/fuel
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/fuel/oil
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/stable_plasma
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/pax
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/water
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/hellwater
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/carbondioxide
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/stable_plasma/on_mob_life(mob/living/carbon/C)
	if(C.mob_biotypes & MOB_ROBOTIC)
		C.nutrition = min(C.nutrition + 5, NUTRITION_LEVEL_FULL-1)
	..()

/datum/reagent/fuel/on_mob_life(mob/living/carbon/C)
	if(C.mob_biotypes & MOB_ROBOTIC)
		C.nutrition = min(C.nutrition + 5, NUTRITION_LEVEL_FULL-1)
	..()

/datum/reagent/fuel/oil/on_mob_life(mob/living/carbon/C)
	if(C.mob_biotypes & MOB_ROBOTIC && C.blood_volume < BLOOD_VOLUME_NORMAL)
		C.blood_volume += 0.5
	..()

/datum/reagent/carbondioxide/on_mob_life(mob/living/carbon/C)
	if(C.mob_biotypes & MOB_ROBOTIC)
		C.nutrition = min(C.nutrition + 5, NUTRITION_LEVEL_FULL-1)
	..()
*/

/datum/reagent/iron
	chemical_flags_doppler = REAGENT_BLOOD_REGENERATING

/datum/reagent/blood
	chemical_flags_doppler = REAGENT_BLOOD_REGENERATING // For Hemophages to be able to drink it without any issue.

/datum/reagent/blood/on_new(list/data)
	. = ..()

	if(!src.data["blood_type"])
		src.data["blood_type"] = random_human_blood_type() // This is so we don't get blood without a blood type spawned from something that doesn't explicitly set the blood type.

// Catnip
/datum/reagent/pax/catnip
	name = "Catnip"
	taste_description = "grass"
	description = "A colourless liquid that makes people more peaceful and felines happier."
	metabolization_rate = 1.75 * REAGENTS_METABOLISM

/datum/reagent/pax/catnip/on_mob_life(mob/living/carbon/M)
	if(isfelinid(M))
		if(prob(20))
			M.emote("nya")
		if(prob(20))
			to_chat(M, span_notice("[pick("Headpats feel nice.", "Backrubs would be nice.", "Mew")]"))
	else
		to_chat(M, span_notice("[pick("I feel oddly calm.", "I feel relaxed.", "Mew?")]"))
	..()


#define DERMAGEN_SCAR_FIX_AMOUNT 10

/datum/chemical_reaction/medicine/dermagen
	results = list(/datum/reagent/medicine/dermagen = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol = 4, /datum/reagent/medicine/c2/synthflesh = 3, /datum/reagent/medicine/mine_salve = 3)
	mix_message = "The slurry congeals into a thick cream."

/datum/reagent/medicine/dermagen
	name = "Dermagen"
	description = "Heals scars formed by past physical trauma when applied. Minimum 10u needed, only works when applied topically."
	color = "#FFEBEB"
	ph = 6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/dermagen/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	. = ..()
	if(!iscarbon(exposed_mob))
		return
	if(!(methods & (PATCH|TOUCH|VAPOR)))
		return
	var/mob/living/carbon/scarred = exposed_mob
	if(scarred.stat == DEAD)
		show_message = FALSE
	if(show_message)
		to_chat(scarred, span_danger("The scars on your body start to fade and disappear."))
	if(reac_volume >= DERMAGEN_SCAR_FIX_AMOUNT)
		for(var/i in scarred.all_scars)
			qdel(i)

#undef DERMAGEN_SCAR_FIX_AMOUNT


/**
 * Check if this holder contains a reagent with a `chemical_flags_doppler` containing this flag.
 *
 * Arguments:
 * * chemical_flag - The bitflag to search for.
 * * min_volume - Checks for having a specific amount of reagents matching that `chemical_flag`
 */
/datum/reagents/proc/has_chemical_flag_doppler(chemical_flag, min_volume = 0)
	var/found_amount = 0
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/holder_reagent as anything in cached_reagents)
		if (holder_reagent.chemical_flags_doppler & chemical_flag)
			found_amount += holder_reagent.volume
			if(found_amount >= min_volume)
				return TRUE

	return FALSE

/datum/reagent
	/// Modular version of `chemical_flags`, so we don't have to worry about
	/// it causing conflicts in the future.
	var/chemical_flags_doppler = NONE
