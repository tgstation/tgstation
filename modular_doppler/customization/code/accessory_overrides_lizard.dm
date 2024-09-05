/datum/species/get_features()
	var/list/features = ..()

	features += /datum/preference/choiced/lizard_snout
	features += /datum/preference/choiced/lizard_frills
	features += /datum/preference/choiced/lizard_horns
	features += /datum/preference/choiced/lizard_tail
	features += /datum/preference/choiced/lizard_body_markings

	GLOB.features_by_species[type] = features

	return features





/// Snout fixing
/obj/item/organ/external/snout
	name = "snout"

/datum/bodypart_overlay/mutant/snout
	layers = EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3

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

//core toggle
/datum/preference/toggle/snout
	savefile_key = "has_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/snout/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		target.dna.features["snout"] = /datum/sprite_accessory/snouts/none::name

/datum/preference/toggle/snout/create_default_value()
	return FALSE

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["snout"])
		if(target.dna.features["snout"] != /datum/sprite_accessory/snouts/none::name && target.dna.features["snout"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/external/snout)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT)
	if(old_part)
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()

//sprite selection
/datum/preference/choiced/lizard_snout
	category = PREFERENCE_CATEGORY_CLOTHING

/datum/preference/choiced/lizard_snout/is_accessible(datum/preferences/preferences)
	. = ..()
	var/has_snout = preferences.read_preference(/datum/preference/toggle/snout)
	if(has_snout == TRUE)
		return TRUE
	return FALSE

/datum/preference/choiced/lizard_snout/create_default_value()
	return /datum/sprite_accessory/snouts/none::name





/// Horns fixing
/obj/item/organ/external/horns
	name = "horns"

/datum/bodypart_overlay/mutant/horns
	layers = EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3

/datum/bodypart_overlay/mutant/horns/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["horns_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["horns_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["horns_color_3"]
		return overlay
	return ..()

//core toggle
/datum/preference/toggle/horns
	savefile_key = "has_horns"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/horns/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		target.dna.features["horns"] = /datum/sprite_accessory/horns/none::name

/datum/preference/toggle/horns/create_default_value()
	return FALSE

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["horns"])
		if(target.dna.features["horns"] != /datum/sprite_accessory/horns/none::name && target.dna.features["horns"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/external/horns)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_HORNS)
	if(old_part)
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()

//sprite selection
/datum/preference/choiced/lizard_horns
	category = PREFERENCE_CATEGORY_CLOTHING

/datum/preference/choiced/lizard_horns/is_accessible(datum/preferences/preferences)
	. = ..()
	var/has_horns = preferences.read_preference(/datum/preference/toggle/horns)
	if(has_horns == TRUE)
		return TRUE
	return FALSE

/datum/preference/choiced/lizard_horns/create_default_value()
	return /datum/sprite_accessory/horns/none::name





/// Frills fixing
/obj/item/organ/external/frills
	name = "frills"

/datum/bodypart_overlay/mutant/frills
	layers = EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3

/datum/bodypart_overlay/mutant/frills/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["frills_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["frills_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["frills_color_3"]
		return overlay
	return ..()

//core toggle
/datum/preference/toggle/frills
	savefile_key = "has_frills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/frills/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		target.dna.features["frills"] = /datum/sprite_accessory/frills/none::name

/datum/preference/toggle/frills/create_default_value()
	return FALSE

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["frills"])
		if(target.dna.features["frills"] != /datum/sprite_accessory/frills/none::name && target.dna.features["frills"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/external/frills)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_FRILLS)
	if(old_part)
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()

//sprite selection
/datum/preference/choiced/lizard_frills
	category = PREFERENCE_CATEGORY_CLOTHING

/datum/preference/choiced/lizard_frills/is_accessible(datum/preferences/preferences)
	. = ..()
	var/has_frills = preferences.read_preference(/datum/preference/toggle/frills)
	if(has_frills == TRUE)
		return TRUE
	return FALSE

/datum/preference/choiced/lizard_frills/create_default_value()
	return /datum/sprite_accessory/frills/none::name





/// Tails fixing
/obj/item/organ/external/tail/lizard
	name = "tail"

/datum/bodypart_overlay/mutant/tail/lizard
	layers = EXTERNAL_FRONT | EXTERNAL_FRONT_2 | EXTERNAL_FRONT_3 | EXTERNAL_BEHIND | EXTERNAL_BEHIND_2 | EXTERNAL_BEHIND_3
	feature_key_sprite = "tail"

/datum/bodypart_overlay/mutant/tail/lizard/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
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

//core toggle
/datum/preference/toggle/tail
	savefile_key = "has_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/tail/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		target.dna.features["tail_lizard"] = /datum/sprite_accessory/tails/lizard/none::name

/datum/preference/toggle/tail/create_default_value()
	return FALSE

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target == null)
		return
	if(target.dna.features["tail_lizard"])
		if(target.dna.features["tail_lizard"] != /datum/sprite_accessory/tails/lizard/none::name && target.dna.features["tail_lizard"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/external/tail/lizard)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/external/tail/lizard/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(istype(old_part))
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()

//sprite selection
/datum/preference/choiced/lizard_tail
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Tail"

/datum/preference/choiced/lizard_tail/is_accessible(datum/preferences/preferences)
	. = ..()
	var/has_tail = preferences.read_preference(/datum/preference/toggle/tail)
	if(has_tail == TRUE)
		return TRUE
	return FALSE

/datum/preference/choiced/lizard_tail/create_default_value()
	return /datum/sprite_accessory/tails/lizard/none::name

/datum/preference/choiced/lizard_tail/icon_for(value)
	var/datum/sprite_accessory/sprite_accessory = SSaccessories.tails_list_lizard[value]

	var/icon/final_icon = icon('icons/mob/human/species/lizard/bodyparts.dmi', "lizard_chest_m", NORTH)

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





/// Standard bodymark fixing
/datum/bodypart_overlay/simple/body_marking/lizard
	layers = EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3

/datum/bodypart_overlay/simple/body_marking/lizard/get_image(layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	var/gender_string = (use_gender && limb.is_dimorphic) ? (limb.gender == MALE ? MALE : FEMALE + "_") : "" //we only got male and female sprites
	if(layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		return image(icon, gender_string + icon_state + "_" + limb.body_zone + "_2", layer = layer)
	if(layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		return image(icon, gender_string + icon_state + "_" + limb.body_zone + "_3", layer = layer)
	return image(icon, gender_string + icon_state + "_" + limb.body_zone, layer = layer)

/datum/bodypart_overlay/simple/body_marking/lizard/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["body_markings_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["body_markings_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["body_markings_color_3"]
		return overlay
	return ..()

/datum/preference/choiced/lizard_body_markings/create_default_value()
	return /datum/sprite_accessory/lizard_markings/none::name

//toggle prefs
/datum/preference/toggle/markings
	savefile_key = "has_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/markings/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		target.dna.features["lizard_markings"] = /datum/sprite_accessory/lizard_markings/none::name

/datum/preference/toggle/markings/create_default_value()
	return FALSE

//toggle pref integration
/datum/preference/choiced/lizard_body_markings
	category = PREFERENCE_CATEGORY_CLOTHING

/datum/preference/choiced/lizard_body_markings/is_accessible(datum/preferences/preferences)
	. = ..()
	var/has_markings = preferences.read_preference(/datum/preference/toggle/markings)
	if(has_markings == TRUE)
		return TRUE
	return FALSE

//manually adding them now
/datum/species/add_body_markings(mob/living/carbon/human/hooman)
	. = ..()
	if(hooman.dna.features["lizard_markings"] && hooman.dna.features["lizard_markings"] != /datum/sprite_accessory/lizard_markings/none::name && hooman.dna.features["snout"] != /datum/sprite_accessory/blank::name) //loop through possible species markings
		var/datum/bodypart_overlay/simple/body_marking/markings = new /datum/bodypart_overlay/simple/body_marking/lizard() // made to die... mostly because we cant use initial on lists but its convenient and organized
		var/accessory_name = hooman.dna.features[markings.dna_feature_key] //get the accessory name from dna
		var/datum/sprite_accessory/moth_markings/accessory = markings.get_accessory(accessory_name) //get the actual datum

		if(isnull(accessory))
			CRASH("Value: [accessory_name] did not have a corresponding sprite accessory!")

		for(var/obj/item/bodypart/part as anything in markings.applies_to) //check through our limbs
			var/obj/item/bodypart/people_part = hooman.get_bodypart(initial(part.body_zone)) // and see if we have a compatible marking for that limb

			if(!people_part)
				continue

			var/datum/bodypart_overlay/simple/body_marking/overlay = new /datum/bodypart_overlay/simple/body_marking/lizard()

			// Tell the overlay what it should look like
			overlay.icon = accessory.icon
			overlay.icon_state = accessory.icon_state
			overlay.use_gender = accessory.gender_specific
			overlay.draw_color = accessory.color_src ? hooman.dna.features["mcolor"] : null

			people_part.add_bodypart_overlay(overlay)
