/datum/preference/choiced/apid_wings
	savefile_key = "feature_apid_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Apid wings"
	should_generate_icons = TRUE

/datum/preference/choiced/apid_wings/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.apid_wings_list,
		"apid_wings",
		list("BEHIND", "FRONT"),
	)

/datum/preference/choiced/apid_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["apid_wings"] = value

/datum/preference/choiced/apid_antenna
	savefile_key = "feature_apid_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Apid Antennae"
	should_generate_icons = TRUE

/datum/preference/choiced/apid_antenna/init_possible_values()
	var/list/values = list()

	var/icon/moth_head = icon('icons/mob/species/moth/bodyparts.dmi', "moth_head")
	moth_head.Blend(icon('icons/mob/species/human/human_face.dmi', "motheyes"), ICON_OVERLAY)

	for (var/antennae_name in GLOB.apid_antenna_list)
		var/datum/sprite_accessory/antennae = GLOB.apid_antenna_list[antennae_name]
		if(antennae.locked)
			continue

		var/icon/icon_with_antennae = new(moth_head)
		icon_with_antennae.Blend(icon(antennae.icon, "m_apid_antenna_[antennae.icon_state]_ADJ"), ICON_OVERLAY)
		icon_with_antennae.Scale(64, 64)
		icon_with_antennae.Crop(15, 64, 15 + 31, 64 - 31)

		values[antennae.name] = icon_with_antennae

	return values

/datum/preference/choiced/apid_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["apid_antenna"] = value
