/proc/generate_anteater_side_shot(datum/sprite_accessory/sprite_accessory, key, include_snout = TRUE)
	var/static/datum/universal_icon/anteater
	var/static/datum/universal_icon/anteater_with_snout

	if (isnull(anteater))
		anteater = uni_icon('troutstation/icons/mob/human/species/anteater/bodyparts.dmi', "anteater_head", EAST)
		var/datum/universal_icon/eyes = uni_icon('icons/mob/human/human_face.dmi', "eyes_l", EAST)
		eyes.blend_color(COLOR_GRAY, ICON_MULTIPLY)
		anteater.blend_icon(eyes, ICON_OVERLAY)

		anteater_with_snout = anteater.copy()
		anteater_with_snout.blend_icon(uni_icon('troutstation/icons/mob/human/species/anteater/anteater_snouts.dmi', "m_anteater_snout_big_ADJ", EAST), ICON_OVERLAY)

	var/datum/universal_icon/final_icon = include_snout ? anteater_with_snout.copy() : anteater.copy()

	if (!isnull(sprite_accessory) && sprite_accessory.icon_state != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", EAST)
		final_icon.blend_icon(accessory_icon, ICON_OVERLAY)

	final_icon.crop(11, 20, 23, 32)
	final_icon.scale(32, 32)
	final_icon.blend_color(COLOR_LIGHT_BROWN, ICON_MULTIPLY)

	return final_icon

/datum/preference/choiced/anteater_body_markings
	savefile_key = "feature_anteater_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body markings"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/anteater

/datum/preference/choiced/anteater_body_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.anteater_markings_list)

/datum/preference/choiced/anteater_body_markings/icon_for(value)
	var/datum/sprite_accessory/sprite_accessory = SSaccessories.anteater_markings_list[value]

	var/datum/universal_icon/final_icon = uni_icon('troutstation/icons/mob/human/species/anteater/bodyparts.dmi', "anteater_chest_m")

	if (sprite_accessory.icon_state != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/body_markings_icon = uni_icon(
			sprite_accessory.icon,
			"male_[sprite_accessory.icon_state]_chest",
		)

		final_icon.blend_icon(body_markings_icon, ICON_OVERLAY)

	final_icon.blend_color(COLOR_LIGHT_BROWN, ICON_MULTIPLY)
	final_icon.crop(10, 8, 22, 23)
	final_icon.scale(26, 32)
	final_icon.crop(-2, 1, 29, 32)

	return final_icon

/datum/preference/choiced/anteater_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_ANTEATER_MARKINGS] = value

/datum/preference/choiced/anteater_snout
	savefile_key = "feature_anteater_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Snout"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/anteater_snout

/datum/preference/choiced/anteater_snout/init_possible_values()
	return assoc_to_keys_features(SSaccessories.anteater_snouts_list)

/datum/preference/choiced/anteater_snout/icon_for(value)
	return generate_anteater_side_shot(SSaccessories.anteater_snouts_list[value], FEATURE_ANTEATER_SNOUT, include_snout = FALSE)

/datum/preference/choiced/anteater_snout/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_ANTEATER_SNOUT] = value

/datum/preference/choiced/anteater_tail
	savefile_key = "feature_anteater_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/anteater

/datum/preference/choiced/anteater_tail/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tails_list_anteater)

/datum/preference/choiced/anteater_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_ANTEATER_TAIL] = value

/datum/preference/choiced/anteater_tail/create_default_value()
	return /datum/sprite_accessory/tails/anteater/giant::name
