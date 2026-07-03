/datum/preference/choiced/species_feature/moth_antennae
	savefile_key = "feature_moth_antennae"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Антенна"
	should_generate_icons = TRUE
	relevant_organ = /obj/item/organ/antennae

/datum/preference/choiced/species_feature/moth_antennae/icon_for(value)
	var/static/datum/universal_icon/moth_head

	if (isnull(moth_head))
		moth_head = uni_icon('icons/mob/human/species/moth/bodyparts.dmi', "moth_head")
		moth_head.blend_icon(uni_icon(/obj/item/organ/eyes/moth::eye_icon, "[/obj/item/organ/eyes/moth::eye_icon_state]_l"), ICON_OVERLAY)
		moth_head.blend_icon(uni_icon(/obj/item/organ/eyes/moth::eye_icon, "[/obj/item/organ/eyes/moth::eye_icon_state]_r"), ICON_OVERLAY)

	var/datum/sprite_accessory/antennae = get_accessory_for_value(value)

	var/datum/universal_icon/icon_with_antennae = moth_head.copy()
	icon_with_antennae.blend_icon(uni_icon(antennae.icon, "m_moth_antennae_[antennae.icon_state]_FRONT"), ICON_OVERLAY)
	icon_with_antennae.scale(64, 64)
	icon_with_antennae.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_antennae

/datum/preference/choiced/species_feature/moth_markings
	savefile_key = "feature_moth_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Метки на теле"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/moth

/datum/preference/choiced/species_feature/moth_markings/icon_for(value)
	var/static/list/body_parts = list(
		/obj/item/bodypart/head/moth,
		/obj/item/bodypart/chest/moth,
		/obj/item/bodypart/arm/left/moth,
		/obj/item/bodypart/arm/right/moth,
	)

	var/static/datum/universal_icon/moth_body
	if (isnull(moth_body))
		moth_body = uni_icon('icons/blanks/32x32.dmi', "nothing")

		for (var/obj/item/bodypart/body_part as anything in body_parts)
			moth_body.blend_icon(uni_icon('icons/mob/human/species/moth/bodyparts.dmi', initial(body_part.icon_state)), ICON_OVERLAY)

		moth_body.blend_icon(uni_icon(/obj/item/organ/eyes/moth::eye_icon, "[/obj/item/organ/eyes/moth::eye_icon_state]_l"), ICON_OVERLAY)
		moth_body.blend_icon(uni_icon(/obj/item/organ/eyes/moth::eye_icon, "[/obj/item/organ/eyes/moth::eye_icon_state]_r"), ICON_OVERLAY)

	var/datum/sprite_accessory/markings = get_accessory_for_value(value)
	var/datum/universal_icon/icon_with_markings = moth_body.copy()

	if (value != SPRITE_ACCESSORY_NONE)
		for (var/obj/item/bodypart/body_part as anything in body_parts)
			var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "[markings.icon_state]_[initial(body_part.body_zone)]")
			body_part_icon.crop(1, 1, 32, 32)
			icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

	icon_with_markings.blend_icon(uni_icon('icons/mob/human/species/moth/moth_wings.dmi', "m_moth_wings_plain_FRONT"), ICON_OVERLAY)
	icon_with_markings.blend_icon(uni_icon('icons/mob/human/species/moth/moth_antennae.dmi', "m_moth_antennae_plain_FRONT"), ICON_OVERLAY)

	// Zoom in on the top of the head and the chest
	icon_with_markings.scale(64, 64)
	icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_markings

/datum/preference/choiced/species_feature/moth_wings
	savefile_key = "feature_moth_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Крылья моли"
	should_generate_icons = TRUE
	relevant_organ = /obj/item/organ/wings/moth

/datum/preference/choiced/species_feature/moth_wings/icon_for(value)
	var/datum/sprite_accessory/moth_wings = get_accessory_for_value(value)
	return uni_icon(moth_wings.icon, "m_moth_wings_[moth_wings.icon_state]_BEHIND")
