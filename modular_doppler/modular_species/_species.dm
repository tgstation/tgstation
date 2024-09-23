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
	// Organs (or just tongues)
	/// Find and set our new informed tongue!
	var/obj/item/organ/tongue = text2path("/obj/item/organ/internal/tongue/[animal_trait]")
	if(tongue) // text2path nulls if it can't find a matching subtype, so don't worry adding an organ for every single trait value
		mutanttongue = tongue.type
	//	Adding traits from here on
	switch(animal_trait)
		if(CAT)
			ADD_TRAIT(target, TRAIT_CATLIKE_GRACE, SPECIES_TRAIT)
			ADD_TRAIT(target, TRAIT_HATED_BY_DOGS, SPECIES_TRAIT)

