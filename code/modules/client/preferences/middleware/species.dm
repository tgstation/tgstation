/// Middleware to handle species
/datum/preference_middleware/species

/datum/preference_middleware/species/get_constant_data()
	var/list/data = list()

	var/list/food_flags = FOOD_FLAGS

	for (var/species_id in get_selectable_species())
		var/species_type = GLOB.species_list[species_id]
		var/datum/species/species = new species_type

		var/list/diet = list()

		if (!(TRAIT_NOHUNGER in species.inherent_traits))
			diet = list(
				"liked_food" = bitfield2list(species.liked_food, food_flags),
				"disliked_food" = bitfield2list(species.disliked_food, food_flags),
				"toxic_food" = bitfield2list(species.toxic_food, food_flags),
			)

		data[species_id] = list(
			"name" = species.name,

			"use_skintones" = species.use_skintones,
			"sexes" = species.sexes,

			"enabled_features" = species.get_features(),
		) + diet

	return data

