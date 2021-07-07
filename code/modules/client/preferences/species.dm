/// Species preference
/datum/preference/choiced/species
	savefile_key = "species"

// MOTHBLOCKS TODO: What is keyed_list/roundstart_no_hard_check?
/datum/preference/choiced/species/deserialize(input)
	return GLOB.species_list[sanitize_inlist(input, get_choices_serialized(), "human")]

/datum/preference/choiced/species/serialize(input)
	var/datum/species/species = input
	return initial(species.id)

/datum/preference/choiced/species/create_default_value()
	return /datum/species/human

/datum/preference/choiced/species/init_possible_values()
	var/list/values = list()

	for (var/species_id in get_selectable_species())
		values += GLOB.species_list[species_id]

	return values

/datum/preference/choiced/species/apply(mob/living/carbon/human/target, value)
	target.set_species(value, icon_update = FALSE, pref_load = TRUE)
