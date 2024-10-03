// What will be supplied to proc/init_possible_values and proc/apply_to_human
GLOBAL_LIST_INIT(frame_types, list(
	"none",
	"classic",
	"mariinsky",
	))

// What will be showed in the drop-down
GLOBAL_LIST_INIT(frame_type_names, list(
	"none" = "Default",
	"classic" = "Android",
	"mariinsky" = "Mariinsky Ballet Company",
	))

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["frame_list"])

		if(target.dna.features["frame_list"][BODY_ZONE_HEAD])
			var/obj/item/bodypart/head/old_limb = target.get_bodypart(BODY_ZONE_HEAD)
			old_limb.drop_limb(TRUE, FALSE, FALSE)
			old_limb.moveToNullspace()
			var/obj/item/bodypart/head/replacement = SSwardrobe.provide_type(target.dna.features["frame_list"][BODY_ZONE_HEAD])
			replacement.try_attach_limb(target, TRUE)
			return .


// Head
/datum/preference/choiced/head_type
	main_feature_name = "Head Type"
	savefile_key = "head_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	should_generate_icons = FALSE

/datum/preference/choiced/head_type/compile_constant_data()
	var/list/data = ..()
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.frame_type_names
	return data

/datum/preference/choiced/head_type/init_possible_values()
	return GLOB.frame_types

/datum/preference/choiced/head_type/apply_to_human(mob/living/carbon/human/target, value)
	if(value == "none")
		return
	LAZYADDASSOC(target.dna.features["frame_list"], BODY_ZONE_HEAD, text2path("/obj/item/bodypart/head/robot/android/[value]"))

/datum/preference/choiced/head_type/create_default_value()
	return "none"

/*
/datum/preference/choiced/head_type/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species == /datum/species/android)
		return TRUE
	return FALSE
*/
