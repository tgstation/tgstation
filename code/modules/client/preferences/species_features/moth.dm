/datum/preference/choiced/moth_antennae
	savefile_key = "feature_moth_antennae"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Antennae"
	should_generate_icons = TRUE

/datum/preference/choiced/moth_antennae/init_possible_values()
	return assoc_to_keys_features(SSaccessories.moth_antennae_list)

/datum/preference/choiced/moth_antennae/icon_for(value)
	var/static/icon/moth_head

	if (isnull(moth_head))
		moth_head = icon('icons/mob/human/species/moth/bodyparts.dmi', "moth_head")
		moth_head.Blend(icon('icons/mob/human/human_face.dmi', "motheyes_l"), ICON_OVERLAY)
		moth_head.Blend(icon('icons/mob/human/human_face.dmi', "motheyes_r"), ICON_OVERLAY)

	var/datum/sprite_accessory/antennae = SSaccessories.moth_antennae_list[value]

	var/icon/icon_with_antennae = new(moth_head)
	icon_with_antennae.Blend(icon(antennae.icon, "m_moth_antennae_[antennae.icon_state]_FRONT"), ICON_OVERLAY)
	icon_with_antennae.Scale(64, 64)
	icon_with_antennae.Crop(15, 64, 15 + 31, 64 - 31)

	return icon_with_antennae

/datum/preference/choiced/moth_antennae/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_antennae"] = value

/datum/preference/choiced/moth_markings
	savefile_key = "feature_moth_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body markings"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "moth_markings"

/datum/preference/choiced/moth_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.moth_markings_list)

/datum/preference/choiced/moth_markings/icon_for(value)
	var/static/list/body_parts = list(
		/obj/item/bodypart/head/moth,
		/obj/item/bodypart/chest/moth,
		/obj/item/bodypart/arm/left/moth,
		/obj/item/bodypart/arm/right/moth,
	)

	var/static/icon/moth_body
	if (isnull(moth_body))
		moth_body = icon('icons/blanks/32x32.dmi', "nothing")

		moth_body.Blend(icon('icons/mob/human/species/moth/moth_wings.dmi', "m_moth_wings_plain_BEHIND"), ICON_OVERLAY)

		for (var/obj/item/bodypart/body_part as anything in body_parts)
			moth_body.Blend(icon('icons/mob/human/species/moth/bodyparts.dmi', initial(body_part.icon_state)), ICON_OVERLAY)

		moth_body.Blend(icon('icons/mob/human/human_face.dmi', "motheyes_l"), ICON_OVERLAY)
		moth_body.Blend(icon('icons/mob/human/human_face.dmi', "motheyes_r"), ICON_OVERLAY)

	var/datum/sprite_accessory/markings = SSaccessories.moth_markings_list[value]
	var/icon/icon_with_markings = new(moth_body)

	if (value != "None")
		for (var/obj/item/bodypart/body_part as anything in body_parts)
			var/icon/body_part_icon = icon(markings.icon, "[markings.icon_state]_[initial(body_part.body_zone)]")
			body_part_icon.Crop(1, 1, 32, 32)
			icon_with_markings.Blend(body_part_icon, ICON_OVERLAY)

	icon_with_markings.Blend(icon('icons/mob/human/species/moth/moth_wings.dmi', "m_moth_wings_plain_FRONT"), ICON_OVERLAY)
	icon_with_markings.Blend(icon('icons/mob/human/species/moth/moth_antennae.dmi', "m_moth_antennae_plain_FRONT"), ICON_OVERLAY)

	// Zoom in on the top of the head and the chest
	icon_with_markings.Scale(64, 64)
	icon_with_markings.Crop(15, 64, 15 + 31, 64 - 31)

	return icon_with_markings

/datum/preference/choiced/moth_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_markings"] = value

/datum/preference/choiced/moth_wings
	savefile_key = "feature_moth_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Moth wings"
	should_generate_icons = TRUE

/datum/preference/choiced/moth_wings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.moth_wings_list)

/datum/preference/choiced/moth_wings/icon_for(value)
	var/datum/sprite_accessory/moth_wings = SSaccessories.moth_wings_list[value]
	var/icon/final_icon = icon(moth_wings.icon, "m_moth_wings_[moth_wings.icon_state]_BEHIND")
	final_icon.Blend(icon(moth_wings.icon, "m_moth_wings_[moth_wings.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/moth_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_wings"] = value
