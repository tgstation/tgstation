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

/datum/reagent/iron
	chemical_flags_nova = REAGENT_BLOOD_REGENERATING

/datum/reagent/blood
	chemical_flags_nova = REAGENT_BLOOD_REGENERATING // For Hemophages to be able to drink it without any issue.

/datum/reagent/blood/on_new(list/data)
	. = ..()

	if(!src.data["blood_type"])
		src.data["blood_type"] = random_blood_type() // This is so we don't get blood without a blood type spawned from something that doesn't explicitly set the blood type.



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

/*
#define DERMAGEN_SCAR_FIX_AMOUNT 10

/datum/reagent/medicine/dermagen
	name = "Dermagen"
	description = "Heals scars formed by past physical trauma when applied. Minimum 10u needed, only works when applied topically."
	reagent_state = LIQUID
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
*/
