/datum/preference/choiced/fur_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "fur"

/datum/preference/choiced/fur_color/init_possible_values()
	return GLOB.fur_tones

/datum/preference/choiced/fur_color/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.fur_tone_names

	var/list/to_hex = list()
	for (var/choice in get_choices())
		var/list/hsl = rgb2num("#[choice]", COLORSPACE_HSL)

		to_hex[choice] = list(
			"lightness" = hsl[3],
			"value" = "#[choice]",
		)

	data["to_hex"] = to_hex

	return data

/datum/preference/choiced/fur_color/apply_to_human(mob/living/carbon/human/target, value)
	target.skin_tone = value

/datum/preference/choiced/fur_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	return initial(species_type.use_fur)

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
