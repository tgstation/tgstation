/datum/reagent/toxin/lipolytic
	name = "Lipolytic"
	description = "Более безопасная альтернатива «Липолициду». Помогает сбалансировать уровень жиров в организме и избавиться от чувства тяжести в животе. <small>Побочный эффект: в отдельных случаях возможно появление тошноты или рвоты.</small>"
	silent_toxin = TRUE
	color = "#FAFFFA"
	metabolization_rate = REAGENTS_METABOLISM * 0.25
	toxpwr = 0
	ph = 3
	inverse_chem = /datum/reagent/impurity/ipecacide
	chemical_flags = REAGENT_NO_RANDOM_RECIPE

/datum/reagent/toxin/lipolytic/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired, metabolization_ratio)
	. = ..()
	if(affected_mob.nutrition >= NUTRITION_LEVEL_WELL_FED)
		affected_mob.adjust_nutrition(-1.5 * metabolization_ratio * normalise_creation_purity() * seconds_per_tick)

		if(affected_mob.overeatduration > 0)
			affected_mob.overeatduration = max(affected_mob.overeatduration - (4 SECONDS * seconds_per_tick), 0)

	if(prob(0.1))
		affected_mob.vomit(vomit_flags = VOMIT_CATEGORY_BLOOD, lost_nutrition = 25)
