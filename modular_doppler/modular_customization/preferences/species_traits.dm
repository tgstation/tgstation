///	Pref logic for animalistic species traits
//	defines in `code/__DEFINES/~doppler_defines/mutant_variations.dm`
/datum/preference/choiced/animalistic_trait
	main_feature_name = "Animalistic trait"
	savefile_key = "feature_animalistic"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	relevant_inherent_trait = TRAIT_ANIMALISTIC
	should_generate_icons = TRUE

/datum/preference/choiced/animalistic_trait/init_possible_values()
	return GLOB.genemod_variations

/datum/preference/choiced/animalistic_trait/icon_for(value)
	switch(value)
		if(BIRD)
			return icon('icons/mob/simple/animal.dmi', "chicken_brown", EAST)
		if(BUNNY)
			return icon('icons/mob/simple/rabbit.dmi', "rabbit_white", WEST)
		if(BUG)
			return icon('icons/mob/simple/animal.dmi', "cockroach", EAST)
		if(CAT)
			return icon('icons/mob/simple/pets.dmi', "cat2", WEST)
		if(DEER)
			return icon('icons/mob/simple/animal.dmi', "deer-doe", EAST)
		if(DOG)
			return icon('icons/mob/simple/pets.dmi', "corgi", WEST)
		if(FISH)
			return icon('icons/mob/simple/carp.dmi', "carp", EAST)
		if(FOX)
			return icon('icons/mob/simple/pets.dmi', "fox", WEST)
		if(FROG)
			return icon('icons/mob/simple/animal.dmi', "frog", EAST)
		if(LIZARD)
			return icon('icons/mob/simple/animal.dmi', "lizard", WEST)
		if(MONKEY)
			return icon('icons/mob/human/human.dmi', "monkey", EAST)
		if(MOUSE)
			return icon('icons/mob/simple/animal.dmi', "mouse_white", WEST)
		else
			return icon('icons/effects/crayondecal.dmi', "x")


/datum/preference/choiced/animalistic_trait/apply_to_human(mob/living/carbon/human/target, value)
	if(value == NO_VARIATION)
		return
	ADD_TRAIT(target, value, SPECIES_TRAIT)

/datum/preference/choiced/animalistic_trait/create_default_value()
	return NO_VARIATION
