/datum/preference/choiced/moth_antennae
	savefile_key = "feature_moth_antennae"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Antennae"
	should_generate_icons = TRUE

/datum/preference/choiced/moth_antennae/init_possible_values()
	var/list/values = list()

	var/icon/moth_head = icon('icons/mob/human/species/moth/bodyparts.dmi', "moth_head")
	moth_head.Blend(icon('icons/mob/human/human_face.dmi', "motheyes"), ICON_OVERLAY)

	for (var/antennae_name in GLOB.moth_antennae_list)
		var/datum/sprite_accessory/antennae = GLOB.moth_antennae_list[antennae_name]
		if(antennae.locked)
			continue

		var/icon/icon_with_antennae = new(moth_head)
		icon_with_antennae.Blend(icon(antennae.icon, "m_moth_antennae_[antennae.icon_state]_FRONT"), ICON_OVERLAY)
		icon_with_antennae.Scale(64, 64)
		icon_with_antennae.Crop(15, 64, 15 + 31, 64 - 31)

		values[antennae.name] = icon_with_antennae

	return values

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
	var/list/values = list()

	var/icon/moth_body = icon('icons/blanks/32x32.dmi', "nothing")

	moth_body.Blend(icon('icons/mob/human/species/moth/moth_wings.dmi', "m_moth_wings_plain_BEHIND"), ICON_OVERLAY)

	var/list/body_parts = list(
		/obj/item/bodypart/head/moth,
		/obj/item/bodypart/chest/moth,
		/obj/item/bodypart/arm/left/moth,
		/obj/item/bodypart/arm/right/moth,
	)

	for (var/obj/item/bodypart/body_part in body_parts)
		var/gender = (initial(body_part.is_dimorphic)) ? "_m" : ""
		moth_body.Blend(icon('icons/mob/human/species/moth/bodyparts.dmi', "moth_[body_part][gender]"), ICON_OVERLAY)

	moth_body.Blend(icon('icons/mob/human/human_face.dmi', "motheyes"), ICON_OVERLAY)

	for (var/markings_name in GLOB.moth_markings_list)
		var/datum/sprite_accessory/markings = GLOB.moth_markings_list[markings_name]
		if(markings.locked)
			continue
		var/icon/icon_with_markings = new(moth_body)

		if (markings_name != "None")
			for (var/body_part in body_parts)
				var/icon/body_part_icon = icon(markings.icon, "[markings.icon_state]_[body_part]")
				body_part_icon.Crop(1, 1, 32, 32)
				icon_with_markings.Blend(body_part_icon, ICON_OVERLAY)

		icon_with_markings.Blend(icon('icons/mob/human/species/moth/moth_wings.dmi', "m_moth_wings_plain_FRONT"), ICON_OVERLAY)
		icon_with_markings.Blend(icon('icons/mob/human/species/moth/moth_antennae.dmi', "m_moth_antennae_plain_FRONT"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.Scale(64, 64)
		icon_with_markings.Crop(15, 64, 15 + 31, 64 - 31)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/moth_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_markings"] = value

/datum/preference/choiced/moth_wings
	savefile_key = "feature_moth_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Moth wings"
	should_generate_icons = TRUE

/datum/preference/choiced/moth_wings/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.moth_wings_list,
		"moth_wings",
		list("BEHIND", "FRONT"),
	)

/datum/preference/choiced/moth_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_wings"] = value
