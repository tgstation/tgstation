/datum/reagent/medicine/antipathogenic
	name = "Placebo"
	description = "Highly ineffective, don't bet on those to keep you healthy."
	color = "#006600" //rgb: 000, 102, 000
	data = list(
		"threshold" = 0,
		)


/datum/reagent/medicine/antipathogenic/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	if(..())
		return TRUE
	M.immune_system.ApplyAntipathogenics(data["threshold"])

/datum/reagent/medicine/antipathogenic/spaceacillin
	data = list(
		"threshold" = 50,
		)

/datum/reagent/consumable/nutriment/soup/chicken_noodle_soup
	data = list(
		"threshold" = 20
	)

/datum/reagent/consumable/nutriment/soup/chicken_noodle_soup/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	if(..())
		return TRUE
	M.immune_system.ApplyAntipathogenics(data["threshold"])

/datum/reagent/medicine/antipathogenic/changeling
	name = "Changeling Immunoglobulin"
	description = "Antibodies from a changeling's immune system. They seem to shift and change to respond to threats"

/datum/reagent/medicine/antipathogenic/changeling/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	if(..())
		return TRUE
	M.immune_system.AntibodyCure()
