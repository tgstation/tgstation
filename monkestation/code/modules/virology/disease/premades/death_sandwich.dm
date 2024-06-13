/datum/disease/advanced/premade/death_sandwich_poisoning
	name = "Death Sandwich Poisoning"
	form = "Condition"
	origin = "Death Sandwich"
	category = DISEASE_SANDWICH

	symptoms = list(
		new /datum/symptom/death_sandwich
	)
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	robustness = 100
	strength = 100

	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0

/datum/disease/advanced/premade/death_sandwich_poisoning/after_add()
	. = ..()
	antigen = null
	stage = 3

/datum/disease/advanced/premade/death_sandwich_poisoning/activate(mob/living/mob, starved, seconds_per_tick)
	. = ..()
	if(mob.has_reagent(/datum/reagent/toxin/anacea, 1)) //anacea is still the cure, i dunno
		cure()
