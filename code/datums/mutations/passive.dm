/datum/mutation/biotechcompat
	name = "Biotech Compatibility"
	desc = "Subject is more compatibile with biotechnology such as skillchips."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MINI

/datum/mutation/biotechcompat/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.adjust_skillchip_complexity_modifier(1)

/datum/mutation/biotechcompat/on_losing(mob/living/carbon/human/owner)
	owner.adjust_skillchip_complexity_modifier(-1)
	return ..()

/datum/mutation/clever
	name = "Clever"
	desc = "Causes the subject to feel just a little bit smarter. Most effective in specimens with low levels of intelligence."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MODERATE // literally makes you on par with station equipment
	text_gain_indication = span_danger("You feel a little bit smarter.")
	text_lose_indication = span_danger("Your mind feels a little bit foggy.")

/datum/mutation/clever/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE), GENETIC_MUTATION)

/datum/mutation/clever/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE), GENETIC_MUTATION)
