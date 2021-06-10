/// Species preference
/datum/preference/species
	savefile_key = "species"

// MOTHBLOCKS TODO: What is keyed_list/roundstart_no_hard_check?
/datum/preference/species/deserialize(input)
	return GLOB.species_list[sanitize_inlist(input, get_choices_serialized(), "human")]

/datum/preference/species/serialize(input)
	var/datum/species/species = input
	return initial(species.id)

/datum/preference/species/create_default_value()
	return /datum/species/human

/datum/preference/species/init_possible_values()
	var/list/values = list()

	for (var/species_id in GLOB.roundstart_races)
		values += GLOB.species_list[species_id]

	return values

/datum/preference/species/apply(mob/living/carbon/human/target, value)
	target.set_species(value, icon_update = FALSE, pref_load = TRUE)
