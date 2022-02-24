/// Species preference
/datum/preference/choiced/species
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "species"
	priority = PREFERENCE_PRIORITY_SPECIES
	randomize_by_default = FALSE

/datum/preference/choiced/species/deserialize(input, datum/preferences/preferences)
	return GLOB.species_list[sanitize_inlist(input, get_choices_serialized(), "human")]

/datum/preference/choiced/species/serialize(input)
	var/datum/species/species = input
	return initial(species.id)

/datum/preference/choiced/species/create_default_value()
	return /datum/species/human

/datum/preference/choiced/species/create_random_value(datum/preferences/preferences)
	return pick(get_choices())

/datum/preference/choiced/species/init_possible_values()
	var/list/values = list()

	for (var/species_id in get_selectable_species())
		values += GLOB.species_list[species_id]

	return values

/datum/preference/choiced/species/apply_to_human(mob/living/carbon/human/target, value)
	target.set_species(value, icon_update = FALSE, pref_load = TRUE)

/datum/preference/choiced/species/compile_constant_data()
	var/list/data = list()

	for (var/species_id in get_selectable_species())
		var/species_type = GLOB.species_list[species_id]
		var/datum/species/species = new species_type()

		var/list/diet = species.get_species_diet()
		var/list/perk_cards = species.get_species_perks()

		data[species_id] = list(
			"name" = species.name,
			"desc" = species.get_species_description(),
			"lore" = species.get_species_lore(),
			"icon" = sanitize_css_class_name(species.name),
			"use_skintones" = species.use_skintones,
			"sexes" = species.sexes,
			// "Features" includes things like wings, tails, frills.
			"enabled_features" = species.get_features(),
			// Species perks here - small cards that explain goods and bads about the species
			"positives" = perk_cards[SPECIES_POSITIVE_PERK],
			"neutrals" = perk_cards[SPECIES_NEUTRAL_PERK],
			"negatives" = perk_cards[SPECIES_NEGATIVE_PERK],
		) += diet

	return data
