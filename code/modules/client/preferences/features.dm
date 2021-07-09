// These will be shown in the sidebar, but at the bottom.
#define PREFERENCE_CATEGORY_FEATURES "features"

/datum/preference/choiced/moth_antennae
	savefile_key = "feature_moth_antennae"
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE

/datum/preference/choiced/moth_antennae/init_possible_values()
	var/list/icon/values = possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.moth_antennae_list,
		"moth_antennae",
		list("FRONT"),
	)

	// MOTHBLOCKS TODO: Zoom in, because they're small

	// Moth wings are in a stupid dimension
	for (var/name in values)
		values[name].Crop(1, 1, 32, 32)

	return values

/datum/preference/choiced/moth_antennae/apply(mob/living/carbon/human/target, value)
	target.dna.features["moth_antennae"] = value

/datum/preference/choiced/moth_markings
	savefile_key = "feature_moth_markings"
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE

/datum/preference/choiced/moth_markings/init_possible_values()
	var/list/values = list()

	var/icon/moth_body = icon('icons/blanks/32x32.dmi', "nothing")

	moth_body.Blend(icon('icons/mob/moth_wings.dmi', "m_moth_wings_plain_BEHIND"), ICON_OVERLAY)

	var/list/body_parts_with_markings = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)

	var/list/body_parts = body_parts_with_markings + list(
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
	)

	for (var/body_part in body_parts)
		var/gender = (body_part == "chest" || body_part == "head") ? "_m" : ""
		moth_body.Blend(icon('icons/mob/human_parts.dmi', "moth_[body_part][gender]"), ICON_OVERLAY)

	moth_body.Blend(icon('icons/mob/human_face.dmi', "motheyes"), ICON_OVERLAY)

	for (var/markings_name in GLOB.moth_markings_list)
		var/datum/sprite_accessory/markings = GLOB.moth_markings_list[markings_name]
		var/icon/icon_with_markings = new(moth_body)

		if (markings_name != "None")
			for (var/body_part in body_parts_with_markings)
				var/icon/body_part_icon = icon(markings.icon, "[markings.icon_state]_[body_part]")
				body_part_icon.Crop(1, 1, 32, 32)
				icon_with_markings.Blend(body_part_icon, ICON_OVERLAY)

		icon_with_markings.Blend(icon('icons/mob/moth_wings.dmi', "m_moth_wings_plain_FRONT"), ICON_OVERLAY)
		icon_with_markings.Blend(icon('icons/mob/moth_antennae.dmi', "m_moth_antennae_plain_FRONT"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.Scale(64, 64)
		icon_with_markings.Crop(15, 64, 15 + 31, 64 - 31)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/moth_markings/apply(mob/living/carbon/human/target, value)
	target.dna.features["moth_markings"] = value

/datum/preference/choiced/moth_wings
	savefile_key = "feature_moth_wings"
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE

/datum/preference/choiced/moth_wings/init_possible_values()
	var/list/icon/values = possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.moth_wings_list,
		"moth_wings",
		list("BEHIND", "FRONT"),
	)

	// Moth wings are in a stupid dimension
	for (var/name in values)
		values[name].Crop(1, 1, 32, 32)

	return values

/datum/preference/choiced/moth_wings/apply(mob/living/carbon/human/target, value)
	target.dna.features["moth_wings"] = value

#undef PREFERENCE_CATEGORY_FEATURES
