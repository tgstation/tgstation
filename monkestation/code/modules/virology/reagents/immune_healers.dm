/datum/reagent/medicine/immune_healer
	name = "Aluxive"
	description = "A powerful immune enhancing drug, often used in small doses to counteract immunodeficiency."
	color = "#667056"
	ph = 7.4
	metabolization_rate = REAGENTS_METABOLISM
	data = list(
		"level" = 0.05,
		"threshold" = 1,
		) //level is in precentage

/datum/reagent/medicine/immune_healer/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	affected_mob.immune_system.ImmuneRepair(data["level"] ,data["threshold"])
	return ..()

/datum/reagent/medicine/immune_healer/immune_suppressant
	name = "Radiohydrate"
	description = "A potent immunosuppressant, can be used to prevent so-called benifical viruses from being naturally cured."
	color = "#7ba813"
	ph = 10.8
	metabolization_rate = REAGENTS_METABOLISM
	data = list(
		"level" = -0.05,
		"threshold" = 1,
		) //level is in precentage
	overdose_threshold = 20 //about double the amount needed to bring your immune strength to 0

/datum/reagent/medicine/immune_healer/immune_suppressant/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(affected_mob.immune_system.antibodies && affected_mob.immune_system.strength == 0)
		var/list/possible_antibodies = list()
		//only reduce antibodies that arent 1
		for(var/antibody as anything in affected_mob.immune_system.antibodies)
			if(affected_mob.immune_system.antibodies[antibody] > 1)
				possible_antibodies += antibody
		//checks if there are any antibodies to remove
		if(length(possible_antibodies) > 0)
			var/affected_antibody = pick(possible_antibodies)
			affected_mob.immune_system.antibodies[affected_antibody] = max(affected_mob.immune_system.antibodies[affected_antibody] - 1, 1)
	..()

/datum/reagent/medicine/immune_healer/immune_booster
	name = "Aetericilide"
	description = "An immune system enhancement drug, able to increase the power of a person's immune system up to 5 times its starting level."
	color = "#16eedc"
	ph = 6.3
	metabolization_rate = REAGENTS_METABOLISM
	data = list(
		"level" = 0.04, //a little slower than Aluxive
		"threshold" = 3,
		) //level is in precentage

/datum/chemical_reaction/immune_healer
	results = list(/datum/reagent/medicine/immune_healer = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/medicine/c2/seiver = 1, /datum/reagent/cryptobiolin = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/immune_suppressant
	results = list(/datum/reagent/medicine/immune_healer/immune_suppressant = 4)
	required_reagents = list(/datum/reagent/uranium/radium = 1, /datum/reagent/medicine/mine_salve = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/immune_booster
	results = list(/datum/reagent/medicine/immune_healer/immune_booster = 2)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/stable_plasma = 1, /datum/reagent/diethylamine = 1, /datum/reagent/copper = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER
