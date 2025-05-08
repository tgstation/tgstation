/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["snout"] && !(type in GLOB.species_blacklist_no_mutant))
		if(target.dna.features["snout"] != /datum/sprite_accessory/snouts/none::name && target.dna.features["snout"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/snout)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT)
	if(old_part)
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()

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

/datum/preference/toggle/snout/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_mutant)
		return FALSE
	return TRUE

/datum/preference/choiced/lizard_snout
	category = PREFERENCE_CATEGORY_CLOTHING

/datum/preference/choiced/lizard_snout/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/has_snout = preferences.read_preference(/datum/preference/toggle/snout)
	if(has_snout == TRUE)
		return TRUE
	return FALSE

/datum/preference/choiced/lizard_snout/create_default_value()
	return /datum/sprite_accessory/snouts/none::name


/datum/preference/choiced/lizard_snout/icon_for(value)
	return generate_snout_icon(SSaccessories.snouts_list[value])

/datum/preference/choiced/proc/generate_snout_icon(datum/sprite_accessory/sprite_accessory)
	var/static/datum/universal_icon/body
	if (isnull(body))
		body = uni_icon('modular_doppler/modular_species/species_types/anthromorph/icons/bodyparts.dmi', "anthromorph_head", EAST)
	var/datum/universal_icon/final_icon = body.copy()

	if (sprite_accessory.icon_state != "No Snout")
		if(icon_exists(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_ADJ"))
			var/datum/universal_icon/accessory_icon_adj = uni_icon(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_ADJ", EAST)
			accessory_icon_adj.blend_color(COLOR_RED, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon_adj, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_ADJ_2"))
			var/datum/universal_icon/accessory_icon_adj_2 = uni_icon(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_ADJ_2", EAST)
			accessory_icon_adj_2.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon_adj_2, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_ADJ_3"))
			var/datum/universal_icon/accessory_icon_adj_3 = uni_icon(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_ADJ_2", EAST)
			accessory_icon_adj_3.blend_color(COLOR_BLUE, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon_adj_3, ICON_OVERLAY)
		///front breaker
		if(icon_exists(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_FRONT"))
			var/datum/universal_icon/accessory_icon_front = uni_icon(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_FRONT", EAST)
			accessory_icon_front.blend_color(COLOR_RED, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon_front, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_FRONT_2"))
			var/datum/universal_icon/accessory_icon_front_2 = uni_icon(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_FRONT_2", EAST)
			accessory_icon_front_2.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon_front_2, ICON_OVERLAY)
		if(icon_exists(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_FRONT_3"))
			var/datum/universal_icon/accessory_icon_front_3 = uni_icon(sprite_accessory.icon, "m_snout_[sprite_accessory.icon_state]_FRONT_3", EAST)
			accessory_icon_front_3.blend_color(COLOR_BLUE, ICON_MULTIPLY)
			final_icon.blend_icon(accessory_icon_front_3, ICON_OVERLAY)

	final_icon.crop(11, 20, 23, 32)
	final_icon.scale(32, 32)

	return final_icon


/// Overwrite lives here
//	This is for the triple color channel
/datum/bodypart_overlay/mutant/snout
	layers = EXTERNAL_FRONT | EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3
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
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT))
		overlay.color = limb.owner.dna.features["snout_color_1"]
		return overlay
	return ..()
