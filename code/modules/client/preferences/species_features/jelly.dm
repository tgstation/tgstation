GLOBAL_LIST_INIT(jelly_style_limb_ids, list(
	"Slimeperson" = SPECIES_SLIMEPERSON,
	"Luminescent" = SPECIES_LUMINESCENT,
	"Stargazer" = SPECIES_STARGAZER,
))

GLOBAL_LIST_INIT(jelly_eye_choices, list(
	"Three eyes" = /obj/item/organ/eyes/jelly,
	"Normal" = /obj/item/organ/eyes,
))

/// Shared base for jelly bodypart style prefs
/datum/preference/choiced/jelly_bodypart
	abstract_type = /datum/preference/choiced/jelly_bodypart
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	var/body_zone
	var/dna_feature

/datum/preference/choiced/jelly_bodypart/head
	savefile_key = "feature_jelly_head"
	body_zone = BODY_ZONE_HEAD
	dna_feature = FEATURE_JELLY_HEAD

/datum/preference/choiced/jelly_bodypart/chest
	savefile_key = "feature_jelly_chest"
	body_zone = BODY_ZONE_CHEST
	dna_feature = FEATURE_JELLY_CHEST

/datum/preference/choiced/jelly_eyes
	savefile_key = "feature_jelly_eyes"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	priority = PREFERENCE_PRIORITY_BODY_TYPE

/datum/preference/choiced/jelly_bodypart/init_possible_values()
	return list("Slimeperson", "Luminescent", "Stargazer")

/datum/preference/choiced/jelly_bodypart/create_default_value()
	return "Stargazer"

/datum/preference/choiced/jelly_bodypart/is_accessible(datum/preferences/preferences)
	if(!..())
		return FALSE
	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	return ispath(species_type, /datum/species/jelly)

/datum/preference/choiced/jelly_bodypart/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features[dna_feature] = value
	apply_jelly_style(target.get_bodypart(body_zone), value)

/datum/preference/choiced/jelly_eyes/init_possible_values()
	return list("Normal", "Three eyes")

/datum/preference/choiced/jelly_eyes/create_default_value()
	return "Three eyes"

/datum/preference/choiced/jelly_eyes/is_accessible(datum/preferences/preferences)
	if(!..())
		return FALSE
	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	return ispath(species_type, /datum/species/jelly)

/datum/preference/choiced/jelly_eyes/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	if(!istype(target.dna?.species, /datum/species/jelly))
		return

	var/eye_type = GLOB.jelly_eye_choices[value]
	if(isnull(eye_type))
		return

	var/obj/item/organ/eyes/current_eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	if(current_eyes?.type == eye_type)
		return

	var/obj/item/organ/eyes/new_eyes = new eye_type()
	new_eyes.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
	target.update_body()

