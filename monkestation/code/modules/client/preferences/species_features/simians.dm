/datum/preference/color/fur_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "fur"
	relevant_species_trait = SPECIES_FUR

/datum/preference/color/fur_color/apply_to_human(mob/living/carbon/human/target, value)
	var/mob/user = usr
	var/datum/species/species_type = user?.client.prefs.read_preference(/datum/preference/choiced/species)
	if(initial(species_type.uses_fur))
		target.dna.features["mcolor"] = value

/datum/preference/choiced/simian_tail
	savefile_key = "feature_tail_monkey"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Simian Tail"
	should_generate_icons = TRUE

/datum/preference/choiced/simian_tail/init_possible_values()
	var/list/values = list()

	var/icon/simian_chest = icon('monkestation/icons/mob/species/simian/bodyparts.dmi', "simian_chest")

	for (var/tail_name in GLOB.tails_list_monkey)
		var/datum/sprite_accessory/tail = GLOB.tails_list_monkey[tail_name]
		if(tail.locked)
			continue

		var/icon/final_icon = new(simian_chest)
		final_icon.Blend(icon(tail.icon, "m_tail_[tail.icon_state]_FRONT"), ICON_OVERLAY)
		final_icon.Crop(10, 8, 22, 23)
		final_icon.Scale(26, 32)
		final_icon.Crop(-2, 1, 29, 32)

		values[tail.name] = final_icon

	return values

/datum/preference/choiced/simian_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_monkey"] = value
