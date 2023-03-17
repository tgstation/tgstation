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
	savefile_key = "feature_monkey_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Simian Tail"
	should_generate_icons = TRUE

/datum/preference/choiced/simian_tail/init_possible_values()
	var/list/values = list()

	var/icon/ipc_head = icon('monkestation/icons/mob/species/simian/bodyparts.dmi', "simian_chest")

	for (var/antennae_name in GLOB.tails_list_monkey)
		var/datum/sprite_accessory/antennae = GLOB.tails_list_monkey[antennae_name]
		if(antennae.locked)
			continue

		var/icon/icon_with_antennae = new(ipc_head)
		icon_with_antennae.Blend(icon(antennae.icon, "m_tail_[antennae.icon_state]_FRONT"), ICON_OVERLAY)
		icon_with_antennae.Scale(64, 64)
		icon_with_antennae.Crop(15, 64, 15 + 31, 64 - 31)

		values[antennae.name] = icon_with_antennae

	return values

/datum/preference/choiced/simian_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["monkey_tail"] = value
