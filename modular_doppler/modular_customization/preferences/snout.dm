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
