/// Generic description for the corrupted organs that don't have one.
#define GENERIC_CORRUPTED_ORGAN_DESC "This shares the shape of a normal organ, but it's been covered and filled with some sort of midnight-black pulsing tissue, engorged with some sort of infectious mass."

/// The rate at which blood metabolizes in a Hemophage's stomach subtype.
#define BLOOD_METABOLIZATION_RATE (0.1 * REAGENTS_METABOLISM)
/// Defines the time for making a corrupted organ start off corrupted.
#define ORGAN_CORRUPTION_INSTANT 0


/obj/item/organ/liver/hemophage
	name = "liver" // Name change is handled by /datum/component/organ_corruption/corrupt_organ()
	desc = GENERIC_CORRUPTED_ORGAN_DESC
	icon = 'modular_doppler/modular_species/species_types/hemophage/icons/hemophage_organs.dmi'
	organ_flags = ORGAN_EDIBLE | ORGAN_TUMOR_CORRUPTED


/obj/item/organ/liver/hemophage/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/organ_corruption/liver, time_to_corrupt = ORGAN_CORRUPTION_INSTANT)

/obj/item/organ/liver/hemophage/handle_chemical(mob/living/carbon/affected_mob, datum/reagent/chem, seconds_per_tick, times_fired)
	. = ..()

	// parent returned COMSIG_MOB_STOP_REAGENT_CHECK or we are failing
	if((. & COMSIG_MOB_STOP_REAGENT_CHECK) || (organ_flags & ORGAN_FAILING))
		return

	// hemophages drink blood so blood must be pretty good for them
	if(!istype(chem, /datum/reagent/blood))
		return

	var/feedback_delivered = FALSE
	for(var/datum/wound/iter_wound as anything in affected_mob.all_wounds)
		if(!SPT_PROB(5, seconds_per_tick))
			continue

		var/helped = iter_wound.blood_life_process()
		if(feedback_delivered || !helped)
			continue

		to_chat(affected_mob, span_notice("A euphoric feeling hits you as blood's warmth washes through your insides. Your body feels more alive, your wounds healthier."))
		feedback_delivered = TRUE


// Different handling, different name.
// Returns FALSE by default so broken bones and 'loss' wounds don't give a false message
/datum/wound/proc/blood_life_process()
	return FALSE

// Slowly increase (gauzed) clot rate, better than tea.
/datum/wound/pierce/bleed/blood_life_process()
	gauzed_clot_rate += 0.1
	return TRUE

// Slowly increase clot rate, better than tea.
/datum/wound/slash/flesh/blood_life_process()
	clot_rate += 0.2
	return TRUE

// Brought over from tea as well.
/datum/wound/burn/flesh/blood_life_process()
	// Sanitizes and heals, but with a limit
	if(flesh_healing <= 0.1)
		flesh_healing += 0.02
	infestation_rate = max(infestation_rate - 0.005, 0)
	return TRUE


/obj/item/organ/stomach/hemophage
	name = "stomach" // Name change is handled by /datum/component/organ_corruption/corrupt_organ()
	desc = GENERIC_CORRUPTED_ORGAN_DESC
	icon = 'modular_doppler/modular_species/species_types/hemophage/icons/hemophage_organs.dmi'
	organ_flags = ORGAN_EDIBLE | ORGAN_TUMOR_CORRUPTED


/obj/item/organ/stomach/hemophage/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/organ_corruption/stomach, time_to_corrupt = ORGAN_CORRUPTION_INSTANT)


// I didn't feel like moving this behavior onto the component, it was just too annoying to do.
/obj/item/organ/stomach/hemophage/on_life(seconds_per_tick, times_fired)
	var/datum/reagent/blood/blood = reagents.has_reagent(/datum/reagent/blood)
	if(blood)
		blood.metabolization_rate = BLOOD_METABOLIZATION_RATE
		var/blood_DNA = blood.data["blood_DNA"]
		if(!blood_DNA) //does the blood we're digesting have any DNA? if it doesn't, it's artificial, and that's gross..
			src.owner.adjust_disgust(DISGUST_LEVEL_GROSS / 16, DISGUST_LEVEL_VERYGROSS)
			src.owner.add_mood_event("gross_food", /datum/mood_event/disgust/hemophage_feed_synthesized_blood)

	return ..()


/obj/item/organ/tongue/hemophage
	name = "tongue" // Name change is handled by /datum/component/organ_corruption/corrupt_organ()
	desc = GENERIC_CORRUPTED_ORGAN_DESC
	icon = 'modular_doppler/modular_species/species_types/hemophage/icons/hemophage_organs.dmi'
	organ_flags = ORGAN_EDIBLE | ORGAN_TUMOR_CORRUPTED
	liked_foodtypes = BLOODY
	disliked_foodtypes = NONE


/obj/item/organ/tongue/hemophage/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/organ_corruption/tongue, time_to_corrupt = ORGAN_CORRUPTION_INSTANT)


#undef GENERIC_CORRUPTED_ORGAN_DESC
#undef BLOOD_METABOLIZATION_RATE
#undef ORGAN_CORRUPTION_INSTANT
