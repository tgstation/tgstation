/mob/living/carbon/can_speak(allow_mimes = FALSE)
	// If we're not a nobreath species, and we don't have lungs, we can't talk
	if(dna?.species && !HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT) && !getorganslot(ORGAN_SLOT_LUNGS))
		// How do species that don't breathe, talk? Magic, that's what.
		return FALSE

	return ..()

/mob/living/carbon/could_speak_language(datum/language/language)
	var/obj/item/organ/internal/tongue/T = getorganslot(ORGAN_SLOT_TONGUE)
	if(T)
		// the tower of babel needs to bypass the tongue language restrictions without giving omnitongue
		return HAS_TRAIT(src, TRAIT_TOWER_OF_BABEL) || T.could_speak_language(language)
	else
		return initial(language.flags) & TONGUELESS_SPEECH
