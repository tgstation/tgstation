/datum/species/get_features()
	var/list/features = ..()

	features += /datum/preference/choiced/breasts

	GLOB.features_by_species[type] = features

	return features

/// SSAccessories setup
/datum/controller/subsystem/accessories
	var/list/breasts_list

/datum/controller/subsystem/accessories/setup_lists()
	. = ..()
	breasts_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/breasts)["default_sprites"] // FLAKY DEFINE: this should be using DEFAULT_SPRITE_LIST


/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["breasts"])
		if(target.dna.features["breasts"] != "Bare")
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/breasts)
			//replacement.build_from_dna(target.dna, "breasts") //TODO: do we need to add this
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_BREASTS)
	if(old_part)
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()


/// Main breast prefs
//core toggle
/datum/preference/toggle/breasts
	savefile_key = "has_breasts"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/breasts/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		//to_chat(world, "Begone, boobs.")
		target.dna.features["breasts"] = "Bare"

/datum/preference/toggle/breasts/create_default_value()
	return FALSE

//sprite selection
/datum/preference/choiced/breasts
	savefile_key = "feature_breasts"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	main_feature_name = "Breasts"
	should_generate_icons = TRUE
	priority = PREFERENCE_PRIORITY_DEFAULT
	can_randomize = FALSE

/datum/preference/choiced/breasts/init_possible_values()
	return assoc_to_keys_features(SSaccessories.breasts_list)

/datum/preference/choiced/breasts/icon_for(value)
	return generate_breasts_shot(SSaccessories.breasts_list[value], "breasts")

/datum/preference/choiced/breasts/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["breasts"] = value

/datum/preference/choiced/breasts/create_default_value()
	return /datum/sprite_accessory/breasts/bare::name

/datum/preference/choiced/breasts/is_accessible(datum/preferences/preferences)
	. = ..()
	var/has_breasts = preferences.read_preference(/datum/preference/toggle/breasts)
	if(has_breasts == TRUE)
		return TRUE
	return FALSE


/proc/generate_breasts_shot(datum/sprite_accessory/sprite_accessory, key)
	var/icon/final_icon = icon('icons/mob/human/bodyparts_greyscale.dmi', "human_chest_f", SOUTH)

	if (!isnull(sprite_accessory))
		var/icon/accessory_icon = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", SOUTH)
		var/icon/accessory_icon_2 = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ_2", SOUTH)
		accessory_icon_2.Blend(COLOR_RED, ICON_MULTIPLY)
		var/icon/accessory_icon_3 = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ_3", SOUTH)
		accessory_icon_3.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		final_icon.Blend(accessory_icon, ICON_OVERLAY)
		final_icon.Blend(accessory_icon_2, ICON_OVERLAY)
		final_icon.Blend(accessory_icon_3, ICON_OVERLAY)

	final_icon.Crop(10, 8, 22, 23)
	final_icon.Scale(26, 32)
	final_icon.Crop(-2, 1, 29, 32)

	return final_icon
