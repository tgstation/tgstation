/**
 * # species datum
 *
 * Datum that handles different species in the game.
 *
 * This datum handles species in the game, such as lizardpeople, mothmen, zombies, skeletons, etc.
 * It is used in [carbon humans][mob/living/carbon/human] to determine various things about them, like their food preferences, if they have biological genders, their damage resistances, and more.
 *
 */
/datum/species
	/// Adding a language type to this in the form of /datum/language will allow the language to be displayed in preferences for that species, even if it is a secret language.
	/// Currently used for Ættmál in hearthkin.
	var/list/language_prefs_whitelist
	///If a species can always be picked in prefs for the purposes of customizing it for ghost roles or events
	var/always_customizable = FALSE
	///How are we treated regarding processing reagents, by default we process them as if we're organic
	var/reagent_flags = PROCESS_ORGANIC
	///This is the outfit which will be used by the species its preview portrait
	var/datum/outfit/preview_outfit = /datum/outfit/job/assistant/consistent


/// Cybernetic limbs logic here!
//	Used for most races
/datum/species/on_species_gain(mob/living/carbon/human/target, datum/species/old_species, pref_load)
	var/list/frame_bodyparts = target.dna.features["frame_list"]
	if(type in GLOB.species_blacklist_no_humanoid)
		return ..()
	if(type == /datum/species/android && frame_bodyparts && frame_bodyparts[BODY_ZONE_HEAD])
		bodypart_overrides[BODY_ZONE_HEAD] = frame_bodyparts[BODY_ZONE_HEAD]
	if(frame_bodyparts && frame_bodyparts[BODY_ZONE_CHEST])
		bodypart_overrides[BODY_ZONE_CHEST] = frame_bodyparts[BODY_ZONE_CHEST]
	if(frame_bodyparts && frame_bodyparts[BODY_ZONE_R_ARM])
		bodypart_overrides[BODY_ZONE_R_ARM] = frame_bodyparts[BODY_ZONE_R_ARM]
	if(frame_bodyparts && frame_bodyparts[BODY_ZONE_L_ARM])
		bodypart_overrides[BODY_ZONE_L_ARM] = frame_bodyparts[BODY_ZONE_L_ARM]
	if(frame_bodyparts && frame_bodyparts[BODY_ZONE_R_LEG])
		bodypart_overrides[BODY_ZONE_R_LEG] = frame_bodyparts[BODY_ZONE_R_LEG]
	if(frame_bodyparts && frame_bodyparts[BODY_ZONE_L_LEG])
		bodypart_overrides[BODY_ZONE_L_LEG] = frame_bodyparts[BODY_ZONE_L_LEG]
	return ..()


/// Animal trait logic goes here!
//	Used for the genemod and anthro species

/// Find or build a user's preferred animal trait
/datum/species/proc/find_animal_trait(mob/living/carbon/human/target)
	/// Trait which is given to the target, none by default
	var/animal_trait = NO_VARIATION
	// Lets find the chosen trait, exciting!
	for(var/trait as anything in GLOB.genemod_variations)
		if(HAS_TRAIT(target, trait))
			animal_trait = trait
			break
	return animal_trait

/// Apply the chosen trait, updating the species data according to the desired organ's data
//	The proc runs before the mutant organs are read and loaded onto the target
/datum/species/proc/apply_animal_trait(mob/living/carbon/human/target, animal_trait)
	if(!ishuman(target) || animal_trait == NO_VARIATION || !animal_trait)
		return

	//// Add the organs!
	// tongue
	var/obj/item/organ/tongue = text2path("/obj/item/organ/internal/tongue/[animal_trait]")
	if(tongue) // text2path nulls if it can't find a matching subtype, so don't worry adding an organ for every single trait value
		mutanttongue = tongue.type

	// lungs
	var/obj/item/organ/lungs = text2path("/obj/item/organ/internal/lungs/[animal_trait]")
	if(lungs)
		mutantlungs = lungs.type
	else // If you have an organ that is more specific, you can add it in this switch() list
		switch(animal_trait)
			if(FROG)
				mutantlungs = /obj/item/organ/internal/lungs/fish/amphibious

	// liver
	var/obj/item/organ/liver = text2path("/obj/item/organ/internal/liver/[animal_trait]")
	if(liver)
		mutantliver = liver.type
	else
		switch(animal_trait)
			if(BUG)
				mutantliver = /obj/item/organ/internal/liver/roach

	// stomach
	var/obj/item/organ/stomach = text2path("/obj/item/organ/internal/stomach/[animal_trait]")
	if(stomach)
		mutantstomach = stomach.type
	else
		switch(animal_trait)
			if(BUG)
				mutantstomach = /obj/item/organ/internal/stomach/roach

	// appendix
	var/obj/item/organ/appendix = text2path("/obj/item/organ/internal/appendix/[animal_trait]")
	if(appendix)
		mutantappendix = appendix.type
	else
		switch(animal_trait)
			if(BUG)
				mutantappendix = /obj/item/organ/internal/appendix/roach

	////
	//	Adding remaining traits, elements, components, and more from here on
	switch(animal_trait)
		if(BIRD)
			target.AddComponent(/datum/component/pinata, candy = list(/obj/item/feather))
		if(BUG)
			inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
			ADD_TRAIT(target, TRAIT_WEB_WEAVER, SPECIES_TRAIT)
			ADD_TRAIT(target, TRAIT_WEB_SURFER, SPECIES_TRAIT)
		if(CAT)
			ADD_TRAIT(target, TRAIT_CATLIKE_GRACE, SPECIES_TRAIT)
			ADD_TRAIT(target, TRAIT_HATED_BY_DOGS, SPECIES_TRAIT)
			ADD_TRAIT(target, TRAIT_WATER_HATER, SPECIES_TRAIT)
		if(DEER)
			target.AddElement(/datum/element/cliff_walking)
		if(FISH)
			ADD_TRAIT(target, TRAIT_WATER_ADAPTATION, SPECIES_TRAIT)
			target.add_quirk(/datum/quirk/item_quirk/breather/water_breather) // this trait necessitates you get this 'item_quirk'
		if(FROG)
			ADD_TRAIT(target, TRAIT_WATER_ADAPTATION, SPECIES_TRAIT)

/// spec_revival logic
/datum/species/proc/spec_revival(mob/living/carbon/human/target)
	return

/mob/living/carbon/human/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(.)
		if(dna && dna.species)
			dna.species.spec_revival(src)
