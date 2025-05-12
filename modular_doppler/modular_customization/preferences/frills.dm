/// Frills fixing
/obj/item/organ/frills
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

/datum/preference/toggle/frills/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_mutant)
		return FALSE
	return TRUE

/datum/preference/choiced/lizard_frills/icon_for(value)
	var/datum/sprite_accessory/sprite_accessory = SSaccessories.frills_list[value]
	var/static/datum/universal_icon/body
	if (isnull(body))
		body = uni_icon('icons/mob/human/species/lizard/bodyparts.dmi', "lizard_head")
	var/datum/universal_icon/final_icon = body.copy()

	if(sprite_accessory.icon_state != "none")
		if(icon_exists(sprite_accessory.icon, "m_frills_[sprite_accessory.icon_state]_ADJ"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "m_frills_[sprite_accessory.icon_state]_ADJ")
			accessory_icon.shift(NORTH, 0, ICON_SIZE_X, ICON_SIZE_Y)
			accessory_icon.blend_color(COLOR_WEBSAFE_DARK_GRAY, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "m_frills_[sprite_accessory.icon_state]_FRONT"))
			var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "m_frills_[sprite_accessory.icon_state]_FRONT")
			accessory_icon.shift(NORTH, 0, ICON_SIZE_X, ICON_SIZE_Y)
			accessory_icon.blend_color(COLOR_WEBSAFE_DARK_GRAY, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon, ICON_OVERLAY)

	final_icon.crop(11, 20, 23, 32)
	final_icon.scale(32, 32)

	return final_icon

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["frills"] && !(type in GLOB.species_blacklist_no_mutant))
		if(target.dna.features["frills"] != /datum/sprite_accessory/frills/none::name && target.dna.features["frills"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/frills)
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
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/has_frills = preferences.read_preference(/datum/preference/toggle/frills)
	if(has_frills == TRUE)
		return TRUE
	return FALSE

/datum/preference/choiced/lizard_frills/create_default_value()
	return /datum/sprite_accessory/frills/none::name
