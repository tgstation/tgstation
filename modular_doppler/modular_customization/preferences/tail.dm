
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
