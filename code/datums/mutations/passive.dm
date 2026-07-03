/datum/mutation/biotechcompat
	name = "Biotech Compatibility"
	desc = "Субъект становится более совместимым с биотехнологиями, такими как скилл-чипы."
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
	desc = "Заставляет субъекта чувствовать себя немного умнее. Наиболее эффективен с особями, обладающими низким уровнем интеллекта."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MODERATE // literally makes you on par with station equipment
	text_gain_indication = span_danger("Ты чувствуешь себя немного умнее.")
	text_lose_indication = span_danger("Твоё сознание немного затуманивается.")

/datum/mutation/clever/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE), GENETIC_MUTATION)

/datum/mutation/clever/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE), GENETIC_MUTATION)
