/datum/preference/choiced/vampire_status
	savefile_key = "feature_vampire_status"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Vampire status"
	should_generate_icons = TRUE
	relevant_species_trait = BLOOD_CLANS

/datum/preference/choiced/vampire_status/create_default_value()
	return "Inoculated" //eh, have em try out the mechanic first

/datum/preference/choiced/vampire_status/init_possible_values()
	var/list/values = list()

	values["Inoculated"] = icon('icons/obj/drinks.dmi', "bloodglass")
	values["Outcast"] = icon('icons/obj/bloodpack.dmi', "generic_bloodpack")

	return values

/datum/preference/choiced/vampire_status/apply_to_human(mob/living/carbon/human/target, value)
	return //checked on species spawn!
