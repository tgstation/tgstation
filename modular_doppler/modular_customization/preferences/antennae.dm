/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["moth_antennae"])
		if(target.dna.features["moth_antennae"] != /datum/sprite_accessory/moth_antennae/none::name && target.dna.features["moth_antennae"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(/obj/item/organ/external/antennae)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .
	var/obj/item/organ/old_part = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_ANTENNAE)
	if(old_part)
		old_part.Remove(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		old_part.moveToNullspace()

//core toggle
/datum/preference/toggle/antennae
	savefile_key = "has_antennae"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/toggle/antennae/apply_to_human(mob/living/carbon/human/target, value)
	if(value == FALSE)
		target.dna.features["moth_antennae"] = /datum/sprite_accessory/moth_antennae/none::name

/datum/preference/toggle/antennae/create_default_value()
	return FALSE

//sprite selection
/datum/preference/choiced/moth_antennae
	category = PREFERENCE_CATEGORY_CLOTHING

/datum/preference/choiced/moth_antennae/is_accessible(datum/preferences/preferences)
	. = ..()
	var/has_antennae = preferences.read_preference(/datum/preference/toggle/antennae)
	if(has_antennae == TRUE)
		return TRUE
	return FALSE

/datum/preference/choiced/moth_antennae/create_default_value()
	return /datum/sprite_accessory/moth_antennae/none::name
