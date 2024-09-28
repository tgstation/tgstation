/datum/corpse_character
	var/datum/species/species_type = /datum/mutation/human

/datum/corpse_character/proc/apply_character(mob/living/carbon/human/fashionable_corpse, list/saved_objects)
	fashionable_corpse.set_species(species_type)
	fashionable_corpse.fully_replace_character_name(generate_random_name_species_based(fashionable_corpse.gender, species_type = species_type))

/datum/corpse_character/roundstart
	var/list/possible_species = list(
		/datum/species/human = 10,
		/datum/species/lizard = 2,
		/datum/species/ethereal = 1,
		/datum/species/moth = 1,
		)

/datum/corpse_character/roundstart/apply_character(mob/living/carbon/human/fashionable_corpse, list/saved_objects)
	species_type = pick_weight(possible_species)
	..()
