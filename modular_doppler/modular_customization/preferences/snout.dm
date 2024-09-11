/// SSAccessories setup
/datum/controller/subsystem/accessories
	var/list/snouts_list_bunny
	var/list/snouts_list_mouse
	var/list/snouts_list_cat
	var/list/snouts_list_bird

/datum/controller/subsystem/accessories/setup_lists()
	. = ..()
	snouts_list_bunny = init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts_more/bunny)["default_sprites"] // FLAKY DEFINE: this should be using DEFAULT_SPRITE_LIST
	snouts_list_mouse = init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts_more/mouse)["default_sprites"]
	snouts_list_cat = init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts_more/cat)["default_sprites"]
	snouts_list_bird = init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts_more/bird)["default_sprites"]


/datum/dna
	///	This variable is read by the regenerate_organs() proc to know what organ subtype to give
	var/snout_type = NO_VARIATION

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["snout"])
		if(target.dna.snout_type == NO_VARIATION)
			return .
		if(target.dna.features["snout"] != /datum/sprite_accessory/snouts/none::name && target.dna.features["snout"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/organ_path = text2path("/obj/item/organ/external/snout/[target.dna.snout_type]")
			var/obj/item/organ/replacement = SSwardrobe.provide_type(organ_path)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT)
	if(old_part)
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()

/// Dropdown to select which snout you'll be rocking
/datum/preference/choiced/snout_variation
	savefile_key = "snout_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/choiced/snout_variation/create_default_value()
	return NO_VARIATION

/datum/preference/choiced/snout_variation/init_possible_values()
	return list(NO_VARIATION) + (GLOB.mutant_variations)

/datum/preference/choiced/snout_variation/apply_to_human(mob/living/carbon/human/target, chosen_variation)
	target.dna.snout_type = chosen_variation
	if(chosen_variation == NO_VARIATION)
		target.dna.features["snout"] = /datum/sprite_accessory/snouts/none::name

///	All current snout types to choose from
//	Lizard
/datum/preference/choiced/lizard_snout
	category = PREFERENCE_CATEGORY_CLOTHING

/datum/preference/choiced/lizard_snout/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/snout_variation)
	if(chosen_variation == LIZARD)
		return TRUE
	return FALSE

/datum/preference/choiced/lizard_snout/apply_to_human(mob/living/carbon/human/target, value)
	..()
	if(target.dna.snout_type == LIZARD)
		target.dna.features["snout"] = value

/datum/preference/choiced/lizard_snout/create_default_value()
	return /datum/sprite_accessory/snouts/none::name

//	Bunny
/datum/preference/choiced/bunny_snout
	savefile_key = "feature_bunny_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	main_feature_name = "Snout"

/datum/preference/choiced/bunny_snout/init_possible_values()
	return assoc_to_keys_features(SSaccessories.snouts_list_bunny)

/datum/preference/choiced/bunny_snout/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/snout_variation)
	if(chosen_variation == BUNNY)
		return TRUE
	return FALSE

/datum/preference/choiced/bunny_snout/create_default_value()
	return /datum/sprite_accessory/snouts_more/bunny/none::name

/datum/preference/choiced/bunny_snout/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.snout_type == BUNNY)
		target.dna.features["snout"] = value

/datum/preference/choiced/bunny_snout/icon_for(value)
	var/datum/sprite_accessory/chosen_snout = SSaccessories.snouts_list_bunny[value]
	return generate_snout_icon(chosen_snout)

//	Mouse
/datum/preference/choiced/mouse_snout
	savefile_key = "feature_mouse_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	main_feature_name = "Snout"

/datum/preference/choiced/mouse_snout/init_possible_values()
	return assoc_to_keys_features(SSaccessories.snouts_list_mouse)

/datum/preference/choiced/mouse_snout/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/snout_variation)
	if(chosen_variation == MOUSE)
		return TRUE
	return FALSE

/datum/preference/choiced/mouse_snout/create_default_value()
	return /datum/sprite_accessory/snouts_more/mouse/none::name

/datum/preference/choiced/mouse_snout/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.snout_type == MOUSE)
		target.dna.features["snout"] = value

/datum/preference/choiced/mouse_snout/icon_for(value)
	var/datum/sprite_accessory/chosen_snout = SSaccessories.snouts_list_mouse[value]
	return generate_snout_icon(chosen_snout)

//	Cat
/datum/preference/choiced/cat_snout
	savefile_key = "feature_cat_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	main_feature_name = "Snout"

/datum/preference/choiced/cat_snout/init_possible_values()
	return assoc_to_keys_features(SSaccessories.snouts_list_cat)

/datum/preference/choiced/cat_snout/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/snout_variation)
	if(chosen_variation == CAT)
		return TRUE
	return FALSE

/datum/preference/choiced/cat_snout/create_default_value()
	return /datum/sprite_accessory/snouts_more/cat/none::name

/datum/preference/choiced/cat_snout/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.snout_type == CAT)
		target.dna.features["snout"] = value

/datum/preference/choiced/cat_snout/icon_for(value)
	var/datum/sprite_accessory/chosen_snout = SSaccessories.snouts_list_cat[value]
	return generate_snout_icon(chosen_snout)

//	Bird
/datum/preference/choiced/bird_snout
	savefile_key = "feature_bird_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	main_feature_name = "Snout"

/datum/preference/choiced/bird_snout/init_possible_values()
	return assoc_to_keys_features(SSaccessories.snouts_list_bird)

/datum/preference/choiced/bird_snout/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/snout_variation)
	if(chosen_variation == BIRD)
		return TRUE
	return FALSE

/datum/preference/choiced/bird_snout/create_default_value()
	return /datum/sprite_accessory/snouts_more/bird/none::name

/datum/preference/choiced/bird_snout/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.snout_type == BIRD)
		target.dna.features["snout"] = value

/datum/preference/choiced/bird_snout/icon_for(value)
	var/datum/sprite_accessory/chosen_snout = SSaccessories.snouts_list_bird[value]
	return generate_snout_icon(chosen_snout)


/// Proc to gen that icon
//	We don't wanna copy paste this
/datum/preference/choiced/proc/generate_snout_icon(chosen_snout)
	var/datum/sprite_accessory/sprite_accessory = chosen_snout
	var/static/icon/final_icon
	final_icon = icon('icons/mob/human/bodyparts_greyscale.dmi', "human_head_m", EAST)
	var/icon/eyes = icon('icons/mob/human/human_face.dmi', "eyes", EAST)
	eyes.Blend(COLOR_GRAY, ICON_MULTIPLY)
	final_icon.Blend(eyes, ICON_OVERLAY)

	if (sprite_accessory.icon_state != "none")
		var/icon/markings_icon_1 = icon(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_ADJ", EAST)
		markings_icon_1.Blend(COLOR_RED, ICON_MULTIPLY)
		var/icon/markings_icon_2 = icon(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_ADJ_2", EAST)
		markings_icon_2.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		var/icon/markings_icon_3 = icon(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_ADJ_3", EAST)
		markings_icon_3.Blend(COLOR_BLUE, ICON_MULTIPLY)
		final_icon.Blend(markings_icon_1, ICON_OVERLAY)
		final_icon.Blend(markings_icon_2, ICON_OVERLAY)
		final_icon.Blend(markings_icon_3, ICON_OVERLAY)

	final_icon.Crop(11, 20, 23, 32)
	final_icon.Scale(32, 32)

	return final_icon

/// Overwrite lives here
//	This is for the triple color channel
/datum/bodypart_overlay/mutant/snout
	layers = EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3
	feature_key_sprite = "snout"

/datum/bodypart_overlay/mutant/snout/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["snout_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["snout_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["snout_color_3"]
		return overlay
	return ..()
