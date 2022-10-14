/datum/unit_test/species_change_organs

/datum/unit_test/species_change_organs/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)

	// Give a trauma
	dummy.gain_trauma_type(/datum/brain_trauma/severe/blindness)
	// Give a cyber heart
	var/obj/item/organ/internal/heart/cybernetic/cyber_heart = new()
	cyber_heart.Insert(dummy, TRUE, FALSE)
	// Give one of their organs a bit of damage
	var/obj/item/organ/internal/appendix/existing_appendix = dummy.getorganslot(ORGAN_SLOT_APPENDIX)
	existing_appendix.setOrganDamage(25)

	// Changing species should
	// - Persist brain traumas
	// - Persist cybernetic implants
	// - Persist organ damage to identical types

	// Set up a species to pass over
	var/datum/species/lizard/changed_species = new()
	// But make sure the lizard's mutantheart is a normal heart
	changed_species.mutantheart = /obj/item/organ/internal/heart
	changed_species.mutantappendix = /obj/item/organ/internal/appendix

	// Now make them a lizard
	dummy.set_species(changed_species)
	// Grab the lizard's appendix
	var/obj/item/organ/internal/appendix/lizard_appendix = dummy.getorganslot(ORGAN_SLOT_APPENDIX)

	TEST_ASSERT(dummy.has_trauma_type(/datum/brain_trauma/severe/blindness), "Dummy, upon changing species, did not carry over their brain trauma!")
	TEST_ASSERT_EQUAL(dummy.getorganslot(ORGAN_SLOT_HEART), cyber_heart, "Dummy, upon changing species, did not carry over their cybernetic organs!")
	TEST_ASSERT_EQUAL(lizard_appendix.damage, 25, "Dummy, upon changing species, did not carry over appendix damage!")
