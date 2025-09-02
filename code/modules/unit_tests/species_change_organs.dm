/**
 * Unit test to ensure that, when a mob changes species,
 * certain aspects are carried over between their old and new set of organs
 * (brain traumas, cybernetics, and organ damage, limb-loss)
 */
/datum/unit_test/species_change_organs

/datum/unit_test/species_change_organs/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	// Give a trauma
	dummy.gain_trauma(/datum/brain_trauma/severe/blindness)
	// Give a cyber heart
	var/obj/item/organ/heart/cybernetic/cyber_heart = allocate(/obj/item/organ/heart/cybernetic)
	cyber_heart.Insert(dummy, special = TRUE, movement_flags = DELETE_IF_REPLACED)
	// Give one of their organs a bit of damage
	var/obj/item/organ/appendix/existing_appendix = dummy.get_organ_slot(ORGAN_SLOT_APPENDIX)
	existing_appendix.set_organ_damage(25)
	// Dismember a leg and an arm (sorry pal)
	var/obj/item/bodypart/arm/right_arm = dummy.get_bodypart(BODY_ZONE_R_ARM)
	var/obj/item/bodypart/leg/left_leg = dummy.get_bodypart(BODY_ZONE_L_LEG)
	right_arm.dismember()
	left_leg.dismember()

	// Changing species should
	// - Persist brain traumas
	// - Persist cybernetic implants
	// - Persist organ damage to identical types
	// - Persist loss of limbs

	// Set up a species to pass over
	var/datum/species/lizard/changed_species = new()
	// But make sure the lizard's mutant organs are "normal"
	changed_species.mutantheart = dummy.dna.species.mutantheart
	changed_species.mutantappendix = dummy.dna.species.mutantappendix
	// and make sure they're not a TRAIT_NOBLOOD species so they need a heart
	changed_species.inherent_traits -= TRAIT_NOBLOOD

	// Now make them a lizard
	dummy.set_species(changed_species)
	TEST_ASSERT(istype(dummy.dna.species, /datum/species/lizard), "Dummy didn't transform into a lizard when testing species organ changes.")

	// Grab the lizard's appendix for comparison later
	// They should've been given a new one, but our damage should also have transferred over
	var/obj/item/organ/appendix/lizard_appendix = dummy.get_organ_slot(ORGAN_SLOT_APPENDIX)

	// They should have the trauma still
	TEST_ASSERT(dummy.has_trauma_type(/datum/brain_trauma/severe/blindness), "Dummy, upon changing species, did not carry over their brain trauma!")
	// They should have their cybernetic heart still
	TEST_ASSERT_EQUAL(dummy.get_organ_slot(ORGAN_SLOT_HEART), cyber_heart, "Dummy, upon changing species, did not carry over their cybernetic organs!")
	// They should have appendix damage still
	TEST_ASSERT_EQUAL(lizard_appendix.damage, 25, "Dummy, upon changing species, did not carry over appendix damage!")

	// They should be missing both the right arm and left leg still
	var/list/missing_limbs = dummy.get_missing_limbs()
	TEST_ASSERT(!(/obj/item/bodypart/arm/right in missing_limbs), "Dummy, upon changing species, regenerated their lost arm!")
	TEST_ASSERT(!(/obj/item/bodypart/leg/left in missing_limbs), "Dummy, upon changing species, regenerated their lost leg!")
