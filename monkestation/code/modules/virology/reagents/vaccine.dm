/datum/reagent/vaccine
	name = "Vaccine"
	description = "A subunit vaccine. Introduces antigens without pathogenic particles to the body, allowing the immune system to produce enough antibodies to prevent any current or future infection."
	reagent_state = LIQUID
	color = "#A6A6A6" //rgb: 166, 166, 166
	data = list(
		"antigen" = list(),
		)

/datum/reagent/vaccine/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(..())
		return 1
	drinker.immune_system.ApplyVaccine(data["antigen"])
