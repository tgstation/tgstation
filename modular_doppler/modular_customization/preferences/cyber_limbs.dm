// What will be supplied to proc/init_possible_values and proc/apply_to_human
GLOBAL_LIST_INIT(frame_types, list(
	"none",
	"bare",
	"synth_lizard",
	"human_like",
	"bs_one",
	"bs_two",
	"classic",
	"e_three_n",
	"hi_one",
	"hi_two",
	"mariinsky",
	"mc",
	"sgm",
	"wtm",
	"xmg_one",
	"xmg_two",
	"zhp",
	"zhenkov",
	"zhenkovdark",
	"shard_alpha",
	"polytronic",
	))

// What will be showed in the drop-down
GLOBAL_LIST_INIT(frame_type_names, list(
	"none" = "Species Default",
	"bare" = "Bare",
	"synth_lizard" = "Synthetic Lizard",
	"human_like" = "Human-Like",
	"bs_one" = "Bishop Cyberkinetics",
	"bs_two" = "Bishop Cyberkinetics 2.0",
	"classic" = "Android",
	"e_three_n" = "E3N",
	"hi_one" = "Hephaestus Industries",
	"hi_two" = "Hephaestus Industries 2.0",
	"mariinsky" = "Mariinsky Ballet Company",
	"mc" = "Morpheus Cyberkinetics",
	"sgm" = "Shellguard Munitions S-Series",
	"wtm" = "Ward Takahashi Manufacturing",
	"xmg_one" = "Xion Manufacturing Group",
	"xmg_two" = "Xion Manufacturing Group 2.0",
	"zhp" = "Zeng-Hu Pharmaceuticals",
	"zhenkov" = "Zhenkov & Co. Foundries",
	"zhenkovdark" = "Zhenkov & Co. Foundries - At Night",
	"shard_alpha" = "Shard Alpha Raptoral",
	"polytronic" = "Polytronic Modular Doll",
	))

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["frame_list"] && !(type in GLOB.species_blacklist_no_humanoid))
		//head
		if(target.dna.features["frame_list"][BODY_ZONE_HEAD] && type == /datum/species/android)
			var/obj/item/bodypart/head/old_limb = target.get_bodypart(BODY_ZONE_HEAD)
			old_limb.drop_limb(TRUE, FALSE, FALSE)
			old_limb.moveToNullspace()
			var/obj/item/bodypart/head/replacement = SSwardrobe.provide_type(target.dna.features["frame_list"][BODY_ZONE_HEAD])
			replacement.try_attach_limb(target, TRUE)
		//chest
		if(target.dna.features["frame_list"][BODY_ZONE_CHEST])
			var/obj/item/bodypart/chest/old_limb = target.get_bodypart(BODY_ZONE_CHEST)
			old_limb.drop_limb(TRUE, FALSE, FALSE)
			old_limb.moveToNullspace()
			var/obj/item/bodypart/chest/replacement = SSwardrobe.provide_type(target.dna.features["frame_list"][BODY_ZONE_CHEST])
			replacement.try_attach_limb(target, TRUE)
		//right arm
		if(target.dna.features["frame_list"][BODY_ZONE_R_ARM])
			var/obj/item/bodypart/arm/right/old_limb = target.get_bodypart(BODY_ZONE_R_ARM)
			old_limb.drop_limb(TRUE, FALSE, FALSE)
			old_limb.moveToNullspace()
			var/obj/item/bodypart/arm/right/replacement = SSwardrobe.provide_type(target.dna.features["frame_list"][BODY_ZONE_R_ARM])
			replacement.try_attach_limb(target, TRUE)
		//left arm
		if(target.dna.features["frame_list"][BODY_ZONE_L_ARM])
			var/obj/item/bodypart/arm/left/old_limb = target.get_bodypart(BODY_ZONE_L_ARM)
			old_limb.drop_limb(TRUE, FALSE, FALSE)
			old_limb.moveToNullspace()
			var/obj/item/bodypart/arm/left/replacement = SSwardrobe.provide_type(target.dna.features["frame_list"][BODY_ZONE_L_ARM])
			replacement.try_attach_limb(target, TRUE)
		//right leg
		if(target.dna.features["frame_list"][BODY_ZONE_R_LEG])
			var/obj/item/bodypart/leg/right/old_limb = target.get_bodypart(BODY_ZONE_R_LEG)
			old_limb.drop_limb(TRUE, FALSE, FALSE)
			old_limb.moveToNullspace()
			var/obj/item/bodypart/leg/right/replacement = SSwardrobe.provide_type(target.dna.features["frame_list"][BODY_ZONE_R_LEG])
			replacement.try_attach_limb(target, TRUE)
		//left leg
		if(target.dna.features["frame_list"][BODY_ZONE_L_LEG])
			var/obj/item/bodypart/leg/left/old_limb = target.get_bodypart(BODY_ZONE_L_LEG)
			old_limb.drop_limb(TRUE, FALSE, FALSE)
			old_limb.moveToNullspace()
			var/obj/item/bodypart/leg/left/replacement = SSwardrobe.provide_type(target.dna.features["frame_list"][BODY_ZONE_L_LEG])
			replacement.try_attach_limb(target, TRUE)
		return .

// Head
/datum/preference/choiced/head_type
	main_feature_name = "Add Limb: Head"
	savefile_key = "head_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

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
	if(species == /datum/species/android) // lifting this restriction would require code for the head's internal organs to become cybernetic too
		return TRUE
	return FALSE

// Chest
/datum/preference/choiced/chest_type
	main_feature_name = "Add Limb: Chest"
	savefile_key = "chest_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/choiced/chest_type/compile_constant_data()
	var/list/data = ..()
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.frame_type_names
	return data

/datum/preference/choiced/chest_type/init_possible_values()
	return GLOB.frame_types

/datum/preference/choiced/chest_type/apply_to_human(mob/living/carbon/human/target, value)
	if(value == "none")
		return
	LAZYADDASSOC(target.dna.features["frame_list"], BODY_ZONE_CHEST, text2path("/obj/item/bodypart/chest/robot/android/[value]"))

/datum/preference/choiced/chest_type/create_default_value()
	return "none"

/datum/preference/choiced/chest_type/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_humanoid)
		return FALSE
	return TRUE

// Right arm
/datum/preference/choiced/arm_r_type
	main_feature_name = "Add Limb: R-Arm"
	savefile_key = "arm_r_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

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

// Left arm
/datum/preference/choiced/arm_l_type
	main_feature_name = "Add Limb: L-Arm"
	savefile_key = "arm_l_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/choiced/arm_l_type/compile_constant_data()
	var/list/data = ..()
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.frame_type_names
	return data

/datum/preference/choiced/arm_l_type/init_possible_values()
	return GLOB.frame_types

/datum/preference/choiced/arm_l_type/apply_to_human(mob/living/carbon/human/target, value)
	if(value == "none")
		return
	LAZYADDASSOC(target.dna.features["frame_list"], BODY_ZONE_L_ARM, text2path("/obj/item/bodypart/arm/left/robot/android/[value]"))

/datum/preference/choiced/arm_l_type/create_default_value()
	return "none"

/datum/preference/choiced/arm_l_type/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_humanoid)
		return FALSE
	return TRUE

// Right leg
/datum/preference/choiced/leg_r_type
	main_feature_name = "Add Limb: R-Leg"
	savefile_key = "leg_r_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/choiced/leg_r_type/compile_constant_data()
	var/list/data = ..()
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.frame_type_names
	return data

/datum/preference/choiced/leg_r_type/init_possible_values()
	return GLOB.frame_types

/datum/preference/choiced/leg_r_type/apply_to_human(mob/living/carbon/human/target, value)
	if(value == "none")
		return
	LAZYADDASSOC(target.dna.features["frame_list"], BODY_ZONE_R_LEG, text2path("/obj/item/bodypart/leg/right/robot/android/[value]"))

/datum/preference/choiced/leg_r_type/create_default_value()
	return "none"

/datum/preference/choiced/leg_r_type/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_humanoid)
		return FALSE
	return TRUE

// Left leg
/datum/preference/choiced/leg_l_type
	main_feature_name = "Add Limb: L-Leg"
	savefile_key = "leg_l_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/choiced/leg_l_type/compile_constant_data()
	var/list/data = ..()
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.frame_type_names
	return data

/datum/preference/choiced/leg_l_type/init_possible_values()
	return GLOB.frame_types

/datum/preference/choiced/leg_l_type/apply_to_human(mob/living/carbon/human/target, value)
	if(value == "none")
		for(var/obj/item/bodypart/whatever as anything in target.bodyparts)
			whatever.change_exempt_flags &= ~BP_BLOCK_CHANGE_SPECIES
		target.dna?.species?.replace_body(target)
		return
	LAZYADDASSOC(target.dna.features["frame_list"], BODY_ZONE_L_LEG, text2path("/obj/item/bodypart/leg/left/robot/android/[value]"))

/datum/preference/choiced/leg_l_type/create_default_value()
	return "none"

/datum/preference/choiced/leg_l_type/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_humanoid)
		return FALSE
	return TRUE
