// What will be supplied to proc/init_possible_values and proc/apply_to_human
GLOBAL_LIST_INIT(frame_types, list(
	"none",
	"classic",
	"mariinsky",
	"e_three_n",
	"bare",
	))

// What will be showed in the drop-down
GLOBAL_LIST_INIT(frame_type_names, list(
	"none" = "Default",
	"classic" = "Android",
	"mariinsky" = "Mariinsky Ballet Company",
	"e_three_n" = "E3N",
	"bare" = "Bare",
	))

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["frame_list"])
		//head
		if(target.dna.features["frame_list"][BODY_ZONE_HEAD])
			var/obj/item/bodypart/head/old_limb = target.get_bodypart(BODY_ZONE_HEAD)
			old_limb.drop_limb(TRUE, FALSE, FALSE)
			old_limb.moveToNullspace()
			var/obj/item/bodypart/head/replacement = SSwardrobe.provide_type(target.dna.features["frame_list"][BODY_ZONE_HEAD])
			replacement.try_attach_limb(target, TRUE)
			return .
		//right arm
		if(target.dna.features["frame_list"][BODY_ZONE_R_ARM])
			var/obj/item/bodypart/arm/right/old_limb = target.get_bodypart(BODY_ZONE_R_ARM)
			old_limb.drop_limb(TRUE, FALSE, FALSE)
			old_limb.moveToNullspace()
			var/obj/item/bodypart/arm/right/replacement = SSwardrobe.provide_type(target.dna.features["frame_list"][BODY_ZONE_R_ARM])
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

/datum/preference/choiced/head_type/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_humanoid)
		return FALSE
	return TRUE

// Right arm
/datum/preference/choiced/arm_r_type
	main_feature_name = "Arm Right Type"
	savefile_key = "arm_r_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	should_generate_icons = FALSE

/datum/preference/choiced/arm_r_type/compile_constant_data()
	var/list/data = ..()
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.frame_type_names
	return data

/datum/preference/choiced/arm_r_type/init_possible_values()
	return GLOB.frame_types

/datum/preference/choiced/arm_r_type/apply_to_human(mob/living/carbon/human/target, value)
	if(value == "none")
		return
	LAZYADDASSOC(target.dna.features["frame_list"], BODY_ZONE_R_ARM, text2path("/obj/item/bodypart/arm/right/robot/android/[value]"))

/datum/preference/choiced/arm_r_type/create_default_value()
	return "none"

/datum/preference/choiced/arm_r_type/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_humanoid)
		return FALSE
	return TRUE

