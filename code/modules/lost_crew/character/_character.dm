/// Datum for controlling the base character, such as species, scarring, styles, augments etc
/datum/corpse_character
	/// Species type to spawn with
	var/datum/species/species_type = /datum/species/human

/datum/corpse_character/proc/apply_character(mob/living/carbon/human/fashionable_corpse, list/saved_objects, list/recovered_items, list/datum/callback/on_revive_and_player_occupancy)
	fashionable_corpse.set_species(species_type)
	fashionable_corpse.fully_replace_character_name(fashionable_corpse.real_name, fashionable_corpse.generate_random_mob_name())

/// Not really all roundstart species, but plasmaman is a bit too flamboyant and felinids aren't interesting
/datum/corpse_character/mostly_roundstart
	var/list/possible_species = list(
		/datum/species/human = 10,
		/datum/species/lizard = 2,
		/datum/species/ethereal = 1,
		/datum/species/moth = 1,
		)

/datum/corpse_character/mostly_roundstart/apply_character(mob/living/carbon/human/fashionable_corpse, list/saved_objects, list/recovered_items, list/datum/callback/on_revive_and_player_occupancy)
	species_type = pick_weight(possible_species)
	..()

/datum/corpse_character/human
	species_type = /datum/species/human

/// used by the morgue trays to spawn bodies (obeying three different configs???????????????????? yes please daddy give me more config for benign features)
/datum/corpse_character/morgue

/datum/corpse_character/morgue/apply_character(mob/living/carbon/human/fashionable_corpse, list/saved_objects, list/recovered_items, list/datum/callback/on_revive_and_player_occupancy)
	var/use_species = !(CONFIG_GET(flag/morgue_cadaver_disable_nonhumans))
	var/species_probability = CONFIG_GET(number/morgue_cadaver_other_species_probability) * use_species
	var/override_species = CONFIG_GET(string/morgue_cadaver_override_species)

	if(override_species)
		species_type = GLOB.species_list[override_species]

	else if(prob(species_probability))
		species_type = GLOB.species_list[pick(get_selectable_species())]

		if(!species_type)
			stack_trace("failed to spawn cadaver with species ID [species_type]") //if it's invalid they'll just be a human, so no need to worry too much aside from yelling at the server owner lol.
			species_type = initial(species_type)

	return ..()

/datum/corpse_character/pod
	species_type = /datum/species/pod

/datum/corpse_character/pod/apply_character(mob/living/carbon/human/fashionable_corpse, list/saved_objects, list/recovered_items, list/datum/callback/on_revive_and_player_occupancy)
	. = ..()

	recovered_items += new /obj/item/plant_analyzer () //needed to properly healthscan them
