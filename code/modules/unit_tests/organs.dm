/datum/unit_test/organ_sanity/Run()
	// Fetch the globally instantiated DNA Infuser entries.
	for(var/obj/item/organ/test_organ as anything in subtypesof(/obj/item/organ))
		if(test_organ == /obj/item/organ/internal)
			continue
		if(test_organ == /obj/item/organ/external)
			continue
		if(test_organ == /obj/item/organ/external/wings)
			continue
		// Human which will receive organ.
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
		test_organ = new test_organ()
		var/implant_ok = test_organ.Insert(lab_rat, special = TRUE, drop_if_replaced = FALSE)
		if(!implant_ok)
			TEST_FAIL("The organ \"[test_organ.type]\" was not inserted in the mob when expected.")
			continue
		// Now yank it back out.
		test_organ.Remove(lab_rat, special = TRUE)
		if(test_organ.owner != null)
			TEST_FAIL("The organ \"[test_organ.type]\" was not removed from the mob when expected.")
