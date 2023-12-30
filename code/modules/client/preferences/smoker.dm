/datum/preference/choiced/smoker
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "smoker"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/smoker/init_possible_values()
	return list("Random") + GLOB.favorite_brand

/datum/preference/choiced/glasses/icon_for(value)
	switch(value)
		if ("Random")
			return icon('icons/effects/random_spawners.dmi', "questionmark")
		if ("Space Cigarettes")
			return icon('icons/obj/cigarettes.dmi', "cig")
		if ("Midori Tabako")
			return icon('icons/obj/cigarettes.dmi', "midori")
		if ("Carp Classic")
			return icon('icons/obj/cigarettes.dmi', "carp")
		if ("Robust Cigarettes")
			return icon('icons/obj/cigarettes.dmi', "robust")
		if ("Robust Gold Cigarettes")
			return icon('icons/obj/cigarettes.dmi', "robustg")
		if ("Syndicate Cigarettes")
			return icon('icons/obj/cigarettes.dmi', "syndie")
		if ("Premium Cigars")
			return icon('icons/obj/cigarettes.dmi', "cigarcase")
		if ("Cohiba Cigars")
			return icon('icons/obj/cigarettes.dmi', "cohibacase")
		if ("Havanian Cigars")
			return icon('icons/obj/cigarettes.dmi', "cohibacase") //Why doesn't this has its own icon? smh

/datum/preference/choiced/smoker/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Smoker" in preferences.all_quirks

/datum/preference/choiced/smoker/apply_to_human(mob/living/carbon/human/target, value)
	return
