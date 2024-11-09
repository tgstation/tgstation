/datum/controller/subsystem/accessories
	var/list/fluff_list

/datum/controller/subsystem/accessories/setup_lists()
	. = ..()
	fluff_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/fluff)["default_sprites"] // FLAKY DEFINE: this should be using DEFAULT_SPRITE_LIST

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["fluff"] && !(type in GLOB.species_blacklist_no_mutant))
		if(target.dna.features["fluff"] != /datum/sprite_accessory/fluff/none::name && target.dna.features["fluff"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/fluff)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_FLUFF)
	if(old_part)
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()

//core toggle
/datum/preference/toggle/fluff
	savefile_key = "has_fluff"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/fluff/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		target.dna.features["fluff"] = /datum/sprite_accessory/fluff/none::name

/datum/preference/toggle/fluff/create_default_value()
	return FALSE

/datum/preference/toggle/fluff/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_mutant)
		return FALSE
	return TRUE

/datum/preference/choiced/fluff
	savefile_key = "fluff"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Fluff"

/datum/preference/choiced/fluff/init_possible_values()
	return assoc_to_keys_features(SSaccessories.fluff_list)

/datum/preference/choiced/fluff/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/has_fluff = preferences.read_preference(/datum/preference/toggle/fluff)
	if(has_fluff)
		return TRUE
	return FALSE

/datum/preference/choiced/fluff/create_default_value()
	return /datum/sprite_accessory/fluff/none::name

/datum/preference/choiced/fluff/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["fluff"] = value

/datum/preference/choiced/fluff/icon_for(value)
	var/datum/sprite_accessory/fluff = SSaccessories.fluff_list[value]
	var/icon/final_icon = icon(fluff.icon, "m_fluff_[fluff.icon_state]_ADJ")
	final_icon.Blend(icon(fluff.icon, "m_fluff_[fluff.icon_state]_ADJ"), ICON_OVERLAY)
	return final_icon

/// Overwrite lives here
//	This is for the triple color channel
/datum/bodypart_overlay/mutant/fluff
	layers = EXTERNAL_FRONT | EXTERNAL_FRONT_2 | EXTERNAL_FRONT_3 | EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3
	feature_key_sprite = "fluff"

/datum/bodypart_overlay/mutant/fluff/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT))
		overlay.color = limb.owner.dna.features["fluff_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["fluff_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_2))
		overlay.color = limb.owner.dna.features["fluff_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["fluff_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_3))
		overlay.color = limb.owner.dna.features["fluff_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["fluff_color_3"]
		return overlay
	return ..()
