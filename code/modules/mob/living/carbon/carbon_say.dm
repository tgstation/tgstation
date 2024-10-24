/mob/living/carbon/can_speak(allow_mimes = FALSE)
	// If we're not a nobreath species, and we don't have lungs, we can't talk
	if(dna?.species && !HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT) && !get_organ_slot(ORGAN_SLOT_LUNGS))
		// How do species that don't breathe, talk? Magic, that's what.
		return FALSE

	return ..()

/mob/living/carbon/could_speak_language(datum/language/language_path)
	var/obj/item/organ/tongue/spoken_with = get_organ_slot(ORGAN_SLOT_TONGUE)
	if(spoken_with)
		// the tower of babel needs to bypass the tongue language restrictions without giving omnitongue
		return HAS_MIND_TRAIT(src, TRAIT_TOWER_OF_BABEL) || spoken_with.could_speak_language(language_path)

	return initial(language_path.flags) & TONGUELESS_SPEECH
