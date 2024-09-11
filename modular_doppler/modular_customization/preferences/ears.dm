/// SSAccessories setup
/datum/controller/subsystem/accessories
	var/list/ears_list_dog
	var/list/ears_list_fox
	var/list/ears_list_bunny
	var/list/ears_list_mouse

/datum/controller/subsystem/accessories/setup_lists()
	. = ..()
	ears_list_dog = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/dog)["default_sprites"] // FLAKY DEFINE: this should be using DEFAULT_SPRITE_LIST
	ears_list_fox = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/fox)["default_sprites"]
	ears_list_bunny = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/bunny)["default_sprites"]
	ears_list_mouse = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/mouse)["default_sprites"]

/datum/dna
	///	This variable is read by the regenerate_organs() proc to know what organ subtype to give
	var/ear_type = NO_VARIATION

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["ears"])
		if(target.dna.ear_type == NO_VARIATION)
			return .
		else if(target.dna.features["ears"] != /datum/sprite_accessory/ears/none::name && target.dna.features["ears"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/organ_path = text2path("/obj/item/organ/internal/ears/[target.dna.ear_type]")
			var/obj/item/organ/replacement = SSwardrobe.provide_type(organ_path)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/internal/ears/old_part = target.get_organ_slot(ORGAN_SLOT_EARS)
	if(istype(old_part))
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()


/// Dropdown to select which ears you'll be rocking
/datum/preference/choiced/ear_variation
	savefile_key = "ear_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/choiced/ear_variation/create_default_value()
	return NO_VARIATION

/datum/preference/choiced/ear_variation/init_possible_values()
	return list(NO_VARIATION) + (GLOB.mutant_variations)

/datum/preference/choiced/ear_variation/apply_to_human(mob/living/carbon/human/target, chosen_variation)
	target.dna.ear_type = chosen_variation
	if(chosen_variation == NO_VARIATION)
		target.dna.features["ears"] = /datum/sprite_accessory/ears/none::name


///	All current ear types to choose from
//	Cat
/datum/preference/choiced/ears
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == CAT)
		return TRUE
	return FALSE

/datum/preference/choiced/ears/create_default_value()
	return /datum/sprite_accessory/ears/none::name

/datum/preference/choiced/ears/apply_to_human(mob/living/carbon/human/target, value)
	..()
	if(target.dna.ear_type == CAT)
		target.dna.features["ears"] = value

/datum/preference/choiced/ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list[value]
	return generate_ears_icon(chosen_ears)

//	Fox
/datum/preference/choiced/fox_ears
	savefile_key = "feature_fox_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/fox_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_fox)

/datum/preference/choiced/fox_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == FOX)
		return TRUE
	return FALSE

/datum/preference/choiced/fox_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/fox/none::name

/datum/preference/choiced/fox_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == FOX)
		target.dna.features["ears"] = value

/datum/preference/choiced/fox_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_fox[value]
	return generate_ears_icon(chosen_ears)

//	Dog
/datum/preference/choiced/dog_ears
	savefile_key = "feature_dog_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/dog_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_dog)

/datum/preference/choiced/dog_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == DOG)
		return TRUE
	return FALSE

/datum/preference/choiced/dog_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/dog/none::name

/datum/preference/choiced/dog_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == DOG)
		target.dna.features["ears"] = value

/datum/preference/choiced/dog_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_dog[value]
	return generate_ears_icon(chosen_ears)

//	Bunny
/datum/preference/choiced/bunny_ears
	savefile_key = "feature_bunny_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/bunny_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_bunny)

/datum/preference/choiced/bunny_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == BUNNY)
		return TRUE
	return FALSE

/datum/preference/choiced/bunny_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/bunny/none::name

/datum/preference/choiced/bunny_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == BUNNY)
		target.dna.features["ears"] = value

/datum/preference/choiced/bunny_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_bunny[value]
	return generate_ears_icon(chosen_ears)

//	Mouse
/datum/preference/choiced/mouse_ears
	savefile_key = "feature_mouse_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/mouse_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_mouse)

/datum/preference/choiced/mouse_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == MOUSE)
		return TRUE
	return FALSE

/datum/preference/choiced/mouse_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/mouse/none::name

/datum/preference/choiced/mouse_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == MOUSE)
		target.dna.features["ears"] = value

/datum/preference/choiced/mouse_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_mouse[value]
	return generate_ears_icon(chosen_ears)


/// Proc to gen that icon
//	We don't wanna copy paste this
/datum/preference/choiced/proc/generate_ears_icon(chosen_ears)
	var/datum/sprite_accessory/sprite_accessory = chosen_ears
	var/static/icon/final_icon
	final_icon = icon('icons/mob/human/bodyparts_greyscale.dmi', "human_head_m", SOUTH)
	var/icon/eyes = icon('icons/mob/human/human_face.dmi', "eyes", SOUTH)
	eyes.Blend(COLOR_GRAY, ICON_MULTIPLY)
	final_icon.Blend(eyes, ICON_OVERLAY)

	if (sprite_accessory.icon_state != "none")
		var/icon/markings_icon_1 = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_BEHIND", SOUTH)
		markings_icon_1.Blend(COLOR_RED, ICON_MULTIPLY)
		var/icon/markings_icon_2 = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_BEHIND_2", SOUTH)
		markings_icon_2.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		var/icon/markings_icon_3 = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_BEHIND_3", SOUTH)
		markings_icon_3.Blend(COLOR_BLUE, ICON_MULTIPLY)
		final_icon.Blend(markings_icon_1, ICON_OVERLAY)
		final_icon.Blend(markings_icon_2, ICON_OVERLAY)
		final_icon.Blend(markings_icon_3, ICON_OVERLAY)
		// adj breaker
		var/icon/markings_icon_1_a = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_ADJ", SOUTH)
		markings_icon_1_a.Blend(COLOR_RED, ICON_MULTIPLY)
		var/icon/markings_icon_2_a = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_ADJ_2", SOUTH)
		markings_icon_2_a.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		var/icon/markings_icon_3_a = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_ADJ_3", SOUTH)
		markings_icon_3_a.Blend(COLOR_BLUE, ICON_MULTIPLY)
		final_icon.Blend(markings_icon_1_a, ICON_OVERLAY)
		final_icon.Blend(markings_icon_2_a, ICON_OVERLAY)
		final_icon.Blend(markings_icon_3_a, ICON_OVERLAY)
		// front breaker
		var/icon/markings_icon_1_f = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_FRONT", SOUTH)
		markings_icon_1_f.Blend(COLOR_RED, ICON_MULTIPLY)
		var/icon/markings_icon_2_f = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_FRONT_2", SOUTH)
		markings_icon_2_f.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		var/icon/markings_icon_3_f = icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_FRONT_3", SOUTH)
		markings_icon_3_f.Blend(COLOR_BLUE, ICON_MULTIPLY)
		final_icon.Blend(markings_icon_1_f, ICON_OVERLAY)
		final_icon.Blend(markings_icon_2_f, ICON_OVERLAY)
		final_icon.Blend(markings_icon_3_f, ICON_OVERLAY)

	final_icon.Crop(11, 20, 23, 32)
	final_icon.Scale(32, 32)

	return final_icon

/// Overwrite lives here
//	This is for the triple color channel
/datum/bodypart_overlay/mutant/ears
	layers = EXTERNAL_FRONT | EXTERNAL_FRONT_2 | EXTERNAL_FRONT_3 | EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3 | EXTERNAL_BEHIND | EXTERNAL_BEHIND_2 | EXTERNAL_BEHIND_3
	feature_key = "ears"
	feature_key_sprite = "ears"

/datum/bodypart_overlay/mutant/ears/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT))
		overlay.color = limb.owner.dna.features["ears_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["ears_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND))
		overlay.color = limb.owner.dna.features["ears_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_2))
		overlay.color = limb.owner.dna.features["ears_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["ears_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_2))
		overlay.color = limb.owner.dna.features["ears_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_3))
		overlay.color = limb.owner.dna.features["ears_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["ears_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_3))
		overlay.color = limb.owner.dna.features["ears_color_3"]
		return overlay
	return ..()

