
/datum/preference/color/anime_color
	savefile_key = "feature_animecolor"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/anime_color/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color/anime_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["animecolor"] = value

/datum/preference/color/anime_color/is_valid(value)
	if (!..(value))
		return FALSE
	return TRUE

/datum/preference/color/anime_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/preference_middleware/quirks/located = locate(/datum/preference_middleware/quirks) in preferences.middleware
	if(!located)
		return FALSE
	var/list/quirks = located.get_selected_quirks()
	for(var/item in quirks)
		if(item == "Anime")
			return TRUE
	return FALSE

/datum/preference/choiced/anime_top
	category = PREFERENCE_CATEGORY_CLOTHING
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Anime Top"
	savefile_key = "feature_anime_top"
	should_generate_icons = TRUE

/datum/preference/choiced/anime_top/init_possible_values()
	var/list/values = list()

	var/icon/head_icon = icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_head_m")
	head_icon.Blend(skintone2hex("caucasian1"), ICON_MULTIPLY)

	for (var/name in GLOB.anime_top_list)
		var/datum/sprite_accessory/accessory = GLOB.anime_top_list[name]
		if (accessory == null || accessory.icon_state == null)
			continue

		var/icon/final_icon = new(head_icon)

		var/icon/icon = icon(accessory.icon, "m_anime_top_[accessory.icon_state]_FRONT")
		final_icon.Blend(icon, ICON_OVERLAY)

		final_icon.Crop(10, 19, 22, 31)
		final_icon.Scale(32, 32)

		values[name] = final_icon

	return values

/datum/preference/choiced/anime_top/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["anime_top"] = value

/datum/preference/choiced/anime_top/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/preference_middleware/quirks/located = locate(/datum/preference_middleware/quirks) in preferences.middleware
	if(!located)
		return FALSE
	var/list/quirks = located.get_selected_quirks()
	for(var/item in quirks)
		if(item == "Anime")
			return TRUE
	return FALSE
/datum/preference/choiced/anime_middle
	category = PREFERENCE_CATEGORY_CLOTHING
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Anime Middle"
	savefile_key = "feature_anime_middle"
	should_generate_icons = TRUE

/datum/preference/choiced/anime_middle/init_possible_values()
	var/list/values = list()

	var/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)

	var/icon/body_icon = icon('icons/effects/effects.dmi', "nothing")
	for (var/body_part in body_parts)
		var/gender = body_part == BODY_ZONE_CHEST || body_part == BODY_ZONE_HEAD ? "_m" : ""
		body_icon.Blend(icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_[body_part][gender]", dir = NORTH), ICON_OVERLAY)
	body_icon.Blend(skintone2hex("caucasian1"), ICON_MULTIPLY)
	var/icon/jumpsuit_icon = icon('icons/mob/clothing/under/civilian.dmi', "barman", dir = NORTH)
	body_icon.Blend(jumpsuit_icon, ICON_OVERLAY)

	for (var/name in GLOB.anime_middle_list)
		var/datum/sprite_accessory/accessory = GLOB.anime_middle_list[name]

		var/icon/icon = icon(accessory.icon, "m_anime_middle_[accessory.icon_state]_FRONT", NORTH)
		var/icon/final_icon = new(body_icon)
		final_icon.Blend(icon, ICON_OVERLAY)

		values[accessory.name] = final_icon

	return values

/datum/preference/choiced/anime_middle/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["anime_middle"] = value

/datum/preference/choiced/anime_middle/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/preference_middleware/quirks/located = locate(/datum/preference_middleware/quirks) in preferences.middleware
	if(!located)
		return FALSE
	var/list/quirks = located.get_selected_quirks()
	for(var/item in quirks)
		if(item == "Anime")
			return TRUE
	return FALSE

/datum/preference/choiced/anime_bottom
	category = PREFERENCE_CATEGORY_CLOTHING
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Anime Bottom"
	savefile_key = "feature_anime_bottom"
	should_generate_icons = TRUE

/datum/preference/choiced/anime_bottom/init_possible_values()
	var/list/values = list()

	var/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)
	var/icon/body_icon = icon('icons/effects/effects.dmi', "nothing")
	for (var/body_part in body_parts)
		var/gender = body_part == BODY_ZONE_CHEST || body_part == BODY_ZONE_HEAD ? "_m" : ""
		body_icon.Blend(icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_[body_part][gender]", dir = NORTH), ICON_OVERLAY)
	body_icon.Blend(skintone2hex("caucasian1"), ICON_MULTIPLY)
	var/icon/jumpsuit_icon = icon('icons/mob/clothing/under/civilian.dmi', "barman", dir = NORTH)
	jumpsuit_icon.Blend("#b3b3b3", ICON_MULTIPLY)
	body_icon.Blend(jumpsuit_icon, ICON_OVERLAY)

	for (var/name in GLOB.anime_bottom_list)
		var/datum/sprite_accessory/accessory = GLOB.anime_bottom_list[name]
		if (accessory == null)
			if(accessory.icon_state == null || accessory.icon_state == "none")
				values[name] = icon('icons/mob/landmarks.dmi', "x")
			continue

		var/icon/final_icon = new(body_icon)
		final_icon.Blend(icon(accessory.icon, "m_anime_bottom_[accessory.icon_state]_FRONT", NORTH), ICON_OVERLAY)

		values[accessory.name] = final_icon

	return values

/datum/preference/choiced/anime_bottom/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["anime_bottom"] = value

/datum/preference/choiced/anime_bottom/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/preference_middleware/quirks/located = locate(/datum/preference_middleware/quirks) in preferences.middleware
	if(!located)
		return FALSE
	var/list/quirks = located.get_selected_quirks()
	for(var/item in quirks)
		if(item == "Anime")
			return TRUE
	return FALSE
