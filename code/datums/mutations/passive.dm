/datum/mutation/human/biotechcompat
	name = "Biotech Compatibility"
	desc = "Subject is more compatibile with biotechnology such as skillchips."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MINI

/datum/mutation/human/biotechcompat/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	owner.adjust_skillchip_complexity_modifier(1)

/datum/mutation/human/biotechcompat/on_losing(mob/living/carbon/human/owner)
	owner.adjust_skillchip_complexity_modifier(-1)
	return ..()

/datum/mutation/human/clever
	name = "Clever"
	desc = "Causes the subject to feel just a little bit smarter. Most effective in specimens with low levels of intelligence."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MODERATE // literally makes you on par with station equipment
	text_gain_indication = "<span class='danger'>You feel a little bit smarter.</span>"
	text_lose_indication = "<span class='danger'>Your mind feels a little bit foggy.</span>"

/datum/mutation/human/clever/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE), GENETIC_MUTATION)

/datum/mutation/human/clever/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE), GENETIC_MUTATION)
