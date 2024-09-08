
/// SSAccessories setup
/datum/controller/subsystem/accessories
	var/list/tails_list_canine

/datum/controller/subsystem/accessories/setup_lists()
	. = ..()
	tails_list_canine = init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/dog)["default_sprites"] // FLAKY DEFINE: this should be using DEFAULT_SPRITE_LIST

/datum/dna
	///	This variable is read by the regenerate_organs() proc to know what organ subtype to give
	var/tail_type = NO_VARIATION

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target == null)
		return
	if(!ishuman(target))
		return

	if(target.dna.features["tail_lizard"] != /datum/sprite_accessory/tails/lizard/none::name && target.dna.features["tail_lizard"] != /datum/sprite_accessory/blank::name)
		var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/external/tail/lizard)
		replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		return .
	else if(target.dna.features["tail_cat"] != /datum/sprite_accessory/tails/human/cat/none::name && target.dna.features["tail_cat"] != /datum/sprite_accessory/blank::name)
		var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/external/tail/cat)
		replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		return .
	else if(target.dna.features["tail_monkey"] != /datum/sprite_accessory/tails/monkey/none::name && target.dna.features["tail_monkey"] != /datum/sprite_accessory/blank::name)
		var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/external/tail/monkey)
		replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		return .
	else if((target.dna.features["tail_other"] != "No tail" && target.dna.features["tail_other"] != /datum/sprite_accessory/blank::name) && (target.dna.tail_type != NO_VARIATION))
		var/obj/item/organ/organ_path = text2path("/obj/item/organ/external/tail/[target.dna.tail_type]")
		var/obj/item/organ/replacement = SSwardrobe.provide_type(organ_path)
		replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		return .

	var/obj/item/organ/external/tail/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(istype(old_part))
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()


/// Dropdown to select which tail you'll be rocking
//	This is my third attempt at writing this, which means it has to be good
/datum/preference/choiced/tail_variation
	savefile_key = "tail_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/choiced/tail_variation/create_default_value()
	return NO_VARIATION

/datum/preference/choiced/tail_variation/init_possible_values()
	return list(NO_VARIATION) + (GLOB.mutant_variations)

/datum/preference/choiced/tail_variation/apply_to_human(mob/living/carbon/human/target, chosen_variation)
//	Read by the regenerate_organs() proc to know what organ subtype to grant
	target.dna.tail_type = chosen_variation
//	Make a beautiful switch list to support the choices
//	Luckily for all of us, this list wont get any bigger
	switch(chosen_variation)
		if(NO_VARIATION)
			target.dna.features["tail_lizard"] = /datum/sprite_accessory/tails/lizard/none::name
			target.dna.features["tail_cat"] = /datum/sprite_accessory/tails/human/cat/none::name
			target.dna.features["tail_monkey"] = /datum/sprite_accessory/tails/monkey/none::name
			target.dna.features["tail_other"] = /datum/sprite_accessory/tails/none::name
		if(REPTILE)
			target.dna.features["tail_cat"] = /datum/sprite_accessory/tails/human/cat/none::name
			target.dna.features["tail_monkey"] = /datum/sprite_accessory/tails/monkey/none::name
			target.dna.features["tail_other"] = /datum/sprite_accessory/tails/none::name
		if(FELINE)
			target.dna.features["tail_lizard"] = /datum/sprite_accessory/tails/lizard/none::name
			target.dna.features["tail_monkey"] = /datum/sprite_accessory/tails/monkey/none::name
			target.dna.features["tail_other"] = /datum/sprite_accessory/tails/none::name
		if(SIMIAN)
			target.dna.features["tail_cat"] = /datum/sprite_accessory/tails/human/cat/none::name
			target.dna.features["tail_lizard"] = /datum/sprite_accessory/tails/lizard/none::name
			target.dna.features["tail_other"] = /datum/sprite_accessory/tails/none::name
		else
			target.dna.features["tail_lizard"] = /datum/sprite_accessory/tails/lizard/none::name
			target.dna.features["tail_cat"] = /datum/sprite_accessory/tails/human/cat/none::name
			target.dna.features["tail_monkey"] = /datum/sprite_accessory/tails/monkey/none::name

///	All current tail types to choose from
//	Lizard
/datum/preference/choiced/lizard_tail // this is an overwrite, so its missing some variables
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Tail"

/datum/preference/choiced/lizard_tail/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/tail_variation)
	if(chosen_variation == REPTILE)
		return TRUE
	return FALSE

/datum/preference/choiced/lizard_tail/create_default_value()
	return /datum/sprite_accessory/tails/lizard/none::name

/datum/preference/choiced/lizard_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_lizard"] = value

/datum/preference/choiced/lizard_tail/icon_for(value)
	var/datum/sprite_accessory/chosen_tail = SSaccessories.tails_list_lizard[value]
	return generate_tail_icon(chosen_tail)

//	Cat
/datum/preference/choiced/tail_human // its a lie
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Tail"

/datum/preference/choiced/tail_human/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/tail_variation)
	if(chosen_variation == FELINE)
		return TRUE
	return FALSE

/datum/preference/choiced/tail_human/create_default_value()
	return /datum/sprite_accessory/tails/human/cat/none::name

/datum/preference/choiced/tail_human/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_cat"] = value

/datum/preference/choiced/tail_human/icon_for(value)
	var/datum/sprite_accessory/chosen_tail = SSaccessories.tails_list_human[value] // its a lie
	return generate_tail_icon(chosen_tail)

//	Monkey
/datum/preference/choiced/monkey_tail
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Tail"

/datum/preference/choiced/monkey_tail/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/tail_variation)
	if(chosen_variation == SIMIAN)
		return TRUE
	return FALSE

/datum/preference/choiced/monkey_tail/create_default_value()
	return /datum/sprite_accessory/tails/monkey/none::name

/datum/preference/choiced/monkey_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_monkey"] = value

/datum/preference/choiced/monkey_tail/icon_for(value)
	var/datum/sprite_accessory/chosen_tail = SSaccessories.tails_list_monkey[value]
	return generate_tail_icon(chosen_tail)

//	Dog
/datum/preference/choiced/dog_tail
	savefile_key = "feature_dog_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Tail"

/datum/preference/choiced/dog_tail/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tails_list_canine)

/datum/preference/choiced/dog_tail/is_accessible(datum/preferences/preferences)
	. = ..()
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/tail_variation)
	if(chosen_variation == CANINE)
		return TRUE
	return FALSE

/datum/preference/choiced/dog_tail/create_default_value()
	return /datum/sprite_accessory/tails/dog/none::name

/datum/preference/choiced/dog_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_other"] = value

/datum/preference/choiced/dog_tail/icon_for(value)
	var/datum/sprite_accessory/chosen_tail = SSaccessories.tails_list_canine[value]
	return generate_tail_icon(chosen_tail)


/// Proc to gen that icon
//	We don't wanna copy paste this
/datum/preference/choiced/proc/generate_tail_icon(chosen_tail)
	var/datum/sprite_accessory/sprite_accessory = chosen_tail
	var/icon/final_icon = icon('icons/mob/human/bodyparts_greyscale.dmi', "human_chest_m", NORTH)

	if (sprite_accessory.icon_state != "none")
		var/icon/markings_icon_1 = icon(sprite_accessory.icon, "m_tail_[sprite_accessory.icon_state]_BEHIND", NORTH)
		markings_icon_1.Blend(COLOR_RED, ICON_MULTIPLY)
		var/icon/markings_icon_2 = icon(sprite_accessory.icon, "m_tail_[sprite_accessory.icon_state]_BEHIND_2", NORTH)
		markings_icon_2.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		var/icon/markings_icon_3 = icon(sprite_accessory.icon, "m_tail_[sprite_accessory.icon_state]_BEHIND_3", NORTH)
		markings_icon_3.Blend(COLOR_BLUE, ICON_MULTIPLY)
		final_icon.Blend(markings_icon_1, ICON_OVERLAY)
		final_icon.Blend(markings_icon_2, ICON_OVERLAY)
		final_icon.Blend(markings_icon_3, ICON_OVERLAY)
		// front breaker
		var/icon/markings_icon_1_f = icon(sprite_accessory.icon, "m_tail_[sprite_accessory.icon_state]_FRONT", NORTH)
		markings_icon_1_f.Blend(COLOR_RED, ICON_MULTIPLY)
		var/icon/markings_icon_2_f = icon(sprite_accessory.icon, "m_tail_[sprite_accessory.icon_state]_FRONT_2", NORTH)
		markings_icon_2_f.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		var/icon/markings_icon_3_f = icon(sprite_accessory.icon, "m_tail_[sprite_accessory.icon_state]_FRONT_3", NORTH)
		markings_icon_3_f.Blend(COLOR_BLUE, ICON_MULTIPLY)
		final_icon.Blend(markings_icon_1_f, ICON_OVERLAY)
		final_icon.Blend(markings_icon_2_f, ICON_OVERLAY)
		final_icon.Blend(markings_icon_3_f, ICON_OVERLAY)

	//final_icon.Crop(4, 12, 28, 32)
	//final_icon.Scale(32, 26)
	//final_icon.Crop(-2, 1, 29, 32)

	return final_icon

/// Overwrite lives here
//	This is for the triple color channel
/obj/item/organ/external/tail
	name = "tail"

/datum/bodypart_overlay/mutant/tail
	layers = EXTERNAL_FRONT | EXTERNAL_FRONT_2 | EXTERNAL_FRONT_3 | EXTERNAL_BEHIND | EXTERNAL_BEHIND_2 | EXTERNAL_BEHIND_3
	feature_key_sprite = "tail"

/datum/bodypart_overlay/mutant/tail/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT))
		overlay.color = limb.owner.dna.features["tail_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND))
		overlay.color = limb.owner.dna.features["tail_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_2))
		overlay.color = limb.owner.dna.features["tail_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_2))
		overlay.color = limb.owner.dna.features["tail_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_3))
		overlay.color = limb.owner.dna.features["tail_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_3))
		overlay.color = limb.owner.dna.features["tail_color_3"]
		return overlay
	return ..()
