/// SSAccessories setup
/datum/controller/subsystem/accessories
	var/list/ears_list_lizard
	var/list/ears_list_dog
	var/list/ears_list_fox
	var/list/ears_list_bunny
	var/list/ears_list_mouse
	var/list/ears_list_bird
	var/list/ears_list_monkey
	var/list/ears_list_deer
	var/list/ears_list_fish
	var/list/ears_list_bug
	var/list/ears_list_humanoid
	var/list/ears_list_synthetic
	var/list/ears_list_alien

/datum/controller/subsystem/accessories/setup_lists()
	. = ..()
	ears_list_lizard = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/lizard)["default_sprites"] // FLAKY DEFINE: this should be using DEFAULT_SPRITE_LIST
	ears_list_dog = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/dog)["default_sprites"]
	ears_list_fox = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/fox)["default_sprites"]
	ears_list_bunny = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/bunny)["default_sprites"]
	ears_list_mouse = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/mouse)["default_sprites"]
	ears_list_bird = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/bird)["default_sprites"]
	ears_list_monkey = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/monkey)["default_sprites"]
	ears_list_deer = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/deer)["default_sprites"]
	ears_list_fish = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/fish)["default_sprites"]
	ears_list_bug = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/bug)["default_sprites"]
	ears_list_humanoid = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/humanoid)["default_sprites"]
	ears_list_synthetic = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/cybernetic)["default_sprites"]
	ears_list_alien = init_sprite_accessory_subtypes(/datum/sprite_accessory/ears_more/alien)["default_sprites"]

/datum/dna
	///	This variable is read by the regenerate_organs() proc to know what organ subtype to give
	var/ear_type = NO_VARIATION

/datum/species/regenerate_organs(mob/living/carbon/target, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	. = ..()
	if(target.dna.features["ears"] && !(type in GLOB.species_blacklist_no_mutant))
		if(target.dna.ear_type == NO_VARIATION)
			return .
		else if(target.dna.features["ears"] != /datum/sprite_accessory/ears/none::name && target.dna.features["ears"] != /datum/sprite_accessory/blank::name)
			var/obj/item/organ/organ_path = text2path("/obj/item/organ/ears/[target.dna.ear_type]")
			var/obj/item/organ/replacement = SSwardrobe.provide_type(organ_path)
			replacement.Insert(target, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			return .

/// Dropdown to select which ears you'll be rocking
/datum/preference/choiced/ear_variation
	savefile_key = "ear_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/choiced/ear_variation/create_default_value()
	return NO_VARIATION

/datum/preference/choiced/ear_variation/init_possible_values()
	return list(NO_VARIATION) + (GLOB.mutant_variations)

/datum/preference/choiced/ear_variation/apply_to_human(mob/living/carbon/human/target, chosen_variation)
	target.dna.ear_type = chosen_variation
	if(chosen_variation == NO_VARIATION)
		target.dna.features["ears"] = /datum/sprite_accessory/ears/none::name

/datum/preference/choiced/ear_variation/is_accessible(datum/preferences/preferences)
	. = ..()
	var/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species in GLOB.species_blacklist_no_mutant)
		return FALSE
	return TRUE

///	All current ear types to choose from
//	Cat
/datum/preference/choiced/felinid_ears
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/felinid_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == CAT)
		return TRUE
	return FALSE

/datum/preference/choiced/felinid_ears/create_default_value()
	return /datum/sprite_accessory/ears/none::name

/datum/preference/choiced/felinid_ears/apply_to_human(mob/living/carbon/human/target, value)
	..()
	if(target.dna.ear_type == CAT)
		target.dna.features["ears"] = value

/datum/preference/choiced/felinid_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list[value]
	return generate_ears_icon(chosen_ears)

//	Lizard
/datum/preference/choiced/lizard_ears
	savefile_key = "feature_lizard_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/lizard_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_lizard)

/datum/preference/choiced/lizard_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == LIZARD)
		return TRUE
	return FALSE

/datum/preference/choiced/lizard_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/lizard/none::name

/datum/preference/choiced/lizard_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == LIZARD)
		target.dna.features["ears"] = value

/datum/preference/choiced/lizard_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_lizard[value]
	return generate_ears_icon(chosen_ears)

//	Fox
/datum/preference/choiced/fox_ears
	savefile_key = "feature_fox_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/fox_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_fox)

/datum/preference/choiced/fox_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == FOX)
		return TRUE
	return FALSE

/datum/preference/choiced/fox_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/fox/none::name

/datum/preference/choiced/fox_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == FOX)
		target.dna.features["ears"] = value

/datum/preference/choiced/fox_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_fox[value]
	return generate_ears_icon(chosen_ears)

//	Dog
/datum/preference/choiced/dog_ears
	savefile_key = "feature_dog_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/dog_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_dog)

/datum/preference/choiced/dog_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == DOG)
		return TRUE
	return FALSE

/datum/preference/choiced/dog_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/dog/none::name

/datum/preference/choiced/dog_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == DOG)
		target.dna.features["ears"] = value

/datum/preference/choiced/dog_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_dog[value]
	return generate_ears_icon(chosen_ears)

//	Bunny
/datum/preference/choiced/bunny_ears
	savefile_key = "feature_bunny_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/bunny_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_bunny)

/datum/preference/choiced/bunny_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == BUNNY)
		return TRUE
	return FALSE

/datum/preference/choiced/bunny_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/bunny/none::name

/datum/preference/choiced/bunny_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == BUNNY)
		target.dna.features["ears"] = value

/datum/preference/choiced/bunny_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_bunny[value]
	return generate_ears_icon(chosen_ears)

//	Bird
/datum/preference/choiced/bird_ears
	savefile_key = "feature_bird_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/bird_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_bird)

/datum/preference/choiced/bird_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == BIRD)
		return TRUE
	return FALSE

/datum/preference/choiced/bird_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/bird/none::name

/datum/preference/choiced/bird_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == BIRD)
		target.dna.features["ears"] = value

/datum/preference/choiced/bird_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_bird[value]
	return generate_ears_icon(chosen_ears)

//	Mouse
/datum/preference/choiced/mouse_ears
	savefile_key = "feature_mouse_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/mouse_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_mouse)

/datum/preference/choiced/mouse_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == MOUSE)
		return TRUE
	return FALSE

/datum/preference/choiced/mouse_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/mouse/none::name

/datum/preference/choiced/mouse_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == MOUSE)
		target.dna.features["ears"] = value

/datum/preference/choiced/mouse_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_mouse[value]
	return generate_ears_icon(chosen_ears)

//	Monkey
/datum/preference/choiced/monkey_ears
	savefile_key = "feature_monkey_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/monkey_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_monkey)

/datum/preference/choiced/monkey_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == MONKEY)
		return TRUE
	return FALSE

/datum/preference/choiced/monkey_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/monkey/none::name

/datum/preference/choiced/monkey_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == MONKEY)
		target.dna.features["ears"] = value

/datum/preference/choiced/monkey_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_monkey[value]
	return generate_ears_icon(chosen_ears)

//	Deer
/datum/preference/choiced/deer_ears
	savefile_key = "feature_deer_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/deer_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_deer)

/datum/preference/choiced/deer_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == DEER)
		return TRUE
	return FALSE

/datum/preference/choiced/deer_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/deer/none::name

/datum/preference/choiced/deer_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == DEER)
		target.dna.features["ears"] = value

/datum/preference/choiced/deer_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_deer[value]
	return generate_ears_icon(chosen_ears)

//	Fish
/datum/preference/choiced/fish_ears
	savefile_key = "feature_fish_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/fish_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_fish)

/datum/preference/choiced/fish_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == FISH)
		return TRUE
	return FALSE

/datum/preference/choiced/fish_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/fish/none::name

/datum/preference/choiced/fish_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == FISH)
		target.dna.features["ears"] = value

/datum/preference/choiced/fish_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_fish[value]
	return generate_ears_icon(chosen_ears)

//	Bug
/datum/preference/choiced/bug_ears
	savefile_key = "feature_bug_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/bug_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_bug)

/datum/preference/choiced/bug_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == BUG)
		return TRUE
	return FALSE

/datum/preference/choiced/bug_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/bug/none::name

/datum/preference/choiced/bug_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == BUG)
		target.dna.features["ears"] = value

/datum/preference/choiced/bug_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_bug[value]
	return generate_ears_icon(chosen_ears)

//	Humanoid
/datum/preference/choiced/humanoid_ears
	savefile_key = "feature_humanoid_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/humanoid_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_humanoid)

/datum/preference/choiced/humanoid_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == HUMANOID)
		return TRUE
	return FALSE

/datum/preference/choiced/humanoid_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/humanoid/none::name

/datum/preference/choiced/humanoid_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == HUMANOID)
		target.dna.features["ears"] = value

/datum/preference/choiced/humanoid_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_humanoid[value]
	return generate_ears_icon(chosen_ears)

//	Cybernetic
/datum/preference/choiced/synthetic_ears
	savefile_key = "feature_synth_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/synthetic_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_synthetic)

/datum/preference/choiced/synthetic_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == CYBERNETIC)
		return TRUE
	return FALSE

/datum/preference/choiced/synthetic_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/cybernetic/none::name

/datum/preference/choiced/synthetic_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == CYBERNETIC)
		target.dna.features["ears"] = value

/datum/preference/choiced/synthetic_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_synthetic[value]
	return generate_ears_icon(chosen_ears)

//	Alien
/datum/preference/choiced/alien_ears
	savefile_key = "feature_alien_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	relevant_external_organ = null
	should_generate_icons = TRUE
	main_feature_name = "Ears"

/datum/preference/choiced/alien_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_alien)

/datum/preference/choiced/alien_ears/is_accessible(datum/preferences/preferences)
	. = ..()
	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	if(species.type in GLOB.species_blacklist_no_mutant)
		return FALSE
	var/chosen_variation = preferences.read_preference(/datum/preference/choiced/ear_variation)
	if(chosen_variation == ALIEN)
		return TRUE
	return FALSE

/datum/preference/choiced/alien_ears/create_default_value()
	return /datum/sprite_accessory/ears_more/alien/none::name

/datum/preference/choiced/alien_ears/apply_to_human(mob/living/carbon/human/target, value)
	if(target.dna.ear_type == ALIEN)
		target.dna.features["ears"] = value

/datum/preference/choiced/alien_ears/icon_for(value)
	var/datum/sprite_accessory/chosen_ears = SSaccessories.ears_list_alien[value]
	return generate_ears_icon(chosen_ears)


/// Proc to gen that icon
//	We don't wanna copy paste this
/datum/preference/choiced/proc/generate_ears_icon(datum/sprite_accessory/sprite_accessory)
	return uni_icon('icons/effects/crayondecal.dmi', "x")
/*
	var/static/datum/universal_icon/final_icon
	final_icon = uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_head_m", SOUTH)
	var/datum/universal_icon/eyes = uni_icon('icons/mob/human/human_face.dmi', "eyes", SOUTH)
	eyes.blend_color(COLOR_GRAY, ICON_MULTIPLY)
	final_icon.blend_icon(eyes, ICON_OVERLAY)

	if (sprite_accessory.icon_state != "none")
		var/datum/universal_icon/markings_icon_1 = uni_icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_BEHIND", SOUTH)
		markings_icon_1.blend_color(COLOR_RED, ICON_MULTIPLY)
		var/datum/universal_icon/markings_icon_2 = uni_icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_BEHIND_2", SOUTH)
		markings_icon_2.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		var/datum/universal_icon/markings_icon_3 = uni_icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_BEHIND_3", SOUTH)
		markings_icon_3.blend_color(COLOR_BLUE, ICON_MULTIPLY)
		final_icon.blend_icon(markings_icon_1, ICON_OVERLAY)
		final_icon.blend_icon(markings_icon_2, ICON_OVERLAY)
		final_icon.blend_icon(markings_icon_3, ICON_OVERLAY)
		// adj breaker
		var/datum/universal_icon/markings_icon_1_a = uni_icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_ADJ", SOUTH)
		markings_icon_1_a.blend_color(COLOR_RED, ICON_MULTIPLY)
		var/datum/universal_icon/markings_icon_2_a = uni_icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_ADJ_2", SOUTH)
		markings_icon_2_a.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		var/datum/universal_icon/markings_icon_3_a = uni_icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_ADJ_3", SOUTH)
		markings_icon_3_a.blend_color(COLOR_BLUE, ICON_MULTIPLY)
		final_icon.blend_icon(markings_icon_1_a, ICON_OVERLAY)
		final_icon.blend_icon(markings_icon_2_a, ICON_OVERLAY)
		final_icon.blend_icon(markings_icon_3_a, ICON_OVERLAY)
		// front breaker
		var/datum/universal_icon/markings_icon_1_f = uni_icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_FRONT", SOUTH)
		markings_icon_1_f.blend_color(COLOR_RED, ICON_MULTIPLY)
		var/datum/universal_icon/markings_icon_2_f = uni_icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_FRONT_2", SOUTH)
		markings_icon_2_f.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		var/datum/universal_icon/markings_icon_3_f = uni_icon(sprite_accessory.icon, "m_ears_[sprite_accessory.icon_state]_FRONT_3", SOUTH)
		markings_icon_3_f.blend_color(COLOR_BLUE, ICON_MULTIPLY)
		final_icon.blend_icon(markings_icon_1_f, ICON_OVERLAY)
		final_icon.blend_icon(markings_icon_2_f, ICON_OVERLAY)
		final_icon.blend_icon(markings_icon_3_f, ICON_OVERLAY)

	final_icon.crop(11, 20, 23, 32)
	final_icon.scale(32, 32)

	return final_icon */

/// Overwrite lives here
//	This is for the triple color channel
/datum/bodypart_overlay/mutant/ears
	layers = EXTERNAL_FRONT | EXTERNAL_FRONT_2 | EXTERNAL_FRONT_3 | EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3 | EXTERNAL_BEHIND | EXTERNAL_BEHIND_2 | EXTERNAL_BEHIND_3
	feature_key = "ears"
	feature_key_sprite = "ears"

/datum/bodypart_overlay/mutant/ears/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(limb == null)
		return ..()
	if(limb.owner == null)
		return ..()
	if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT))
		overlay.color = limb.owner.dna.features["ears_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT))
		overlay.color = limb.owner.dna.features["ears_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND))
		overlay.color = limb.owner.dna.features["ears_color_1"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_2))
		overlay.color = limb.owner.dna.features["ears_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_2))
		overlay.color = limb.owner.dna.features["ears_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_2))
		overlay.color = limb.owner.dna.features["ears_color_2"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_FRONT_3))
		overlay.color = limb.owner.dna.features["ears_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_ADJACENT_3))
		overlay.color = limb.owner.dna.features["ears_color_3"]
		return overlay
	else if(draw_layer == bitflag_to_layer(EXTERNAL_BEHIND_3))
		overlay.color = limb.owner.dna.features["ears_color_3"]
		return overlay
	return ..()
