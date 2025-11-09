/datum/unit_test/blood_volume_procs

/datum/unit_test/blood_volume_procs/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	// Test initial blood status.
	TEST_ASSERT(dummy.can_have_blood(), "Initialization of blood volume status is screwed up.")
	TEST_ASSERT(CAN_HAVE_BLOOD(dummy), "Caching of blood volume status is screwed up.")

	// Test initial blood volume.
	TEST_ASSERT_EQUAL(dummy.default_blood_volume, BLOOD_VOLUME_NORMAL, "Default blood volume is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), dummy.default_blood_volume, "Blood volume isn't initialized properly.")
	TEST_ASSERT_EQUAL(dummy.get_modified_blood_volume(), dummy.get_blood_volume(), "Blood volume is modified on initialization.")

	var/adjustment_amount = 100
	var/expected_final_volume = dummy.get_blood_volume() + adjustment_amount

	// Test increasing blood volume.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount), adjustment_amount, "Adjustment proc return value is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "Final blood volume is different from what was expected.")

	adjustment_amount = -100
	expected_final_volume = dummy.get_blood_volume() + adjustment_amount

	// Test decreasing blood volume.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount), adjustment_amount, "Adjustment proc return value is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "Final blood volume is different from what was expected.")

	adjustment_amount = 100
	var/expected_adjustment = 50
	expected_final_volume = dummy.get_blood_volume() + expected_adjustment

	// Test increasing blood volume, clamped to a maximum.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount, maximum = expected_final_volume), expected_adjustment, "Clamped adjustment proc return value is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "Clamped final blood volume is different from what was expected.")

	adjustment_amount = -100
	expected_adjustment = -50
	expected_final_volume = dummy.get_blood_volume() + expected_adjustment

	// Test decreasing blood volume, clamped to a minimum.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount, minimum = expected_final_volume), expected_adjustment, "Clamped adjustment proc return value is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "Clamped final blood volume is different from what was expected.")

	dummy.reagents.add_reagent(/datum/reagent/medicine/salglu_solution, 10)
	var/datum/reagent/medicine/salglu_solution/saline = dummy.reagents.has_reagent(/datum/reagent/medicine/salglu_solution)
	dummy.set_blood_volume(saline.dilution_cap)

	// Test if saline dilutes blood volume beyond the dilution cap.
	TEST_ASSERT_EQUAL(dummy.get_modified_blood_volume(), saline.dilution_cap, "Saline goes above or below its dilution cap.")

	dummy.set_blood_volume(BLOOD_VOLUME_BAD)
	var/expected_dilution = saline.volume * saline.dilution_per_unit
	expected_final_volume = dummy.get_blood_volume() + expected_dilution

	// Test if saline dilutes low blood volume properly.
	TEST_ASSERT_EQUAL(dummy.get_modified_blood_volume(), expected_final_volume, "Saline didn't dilute low blood by the expected amount.")

	ADD_TRAIT(dummy, TRAIT_NOBLOOD, TRAIT_GENERIC)

	// Test if adding TRAIT_NOBLOOD works properly.
	TEST_ASSERT(!dummy.can_have_blood(), "Adding TRAIT_NOBLOOD didn't make the mob have no blood.")
	TEST_ASSERT(!CAN_HAVE_BLOOD(dummy), "Caching of blood volume status is screwed up after the addition of TRAIT_NOBLOOD.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), 0, "Blood volume wasn't emptied after the addition of TRAIT_NOBLOOD.")

	REMOVE_TRAIT(dummy, TRAIT_NOBLOOD, TRAIT_GENERIC)

	// Test if removing TRAIT_NOBLOOD works properly.
	TEST_ASSERT(dummy.can_have_blood(), "Removing TRAIT_NOBLOOD didn't make the mob have blood again.")
	TEST_ASSERT(CAN_HAVE_BLOOD(dummy), "Caching of blood volume status is screwed up after the removal of TRAIT_NOBLOOD.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), dummy.default_blood_volume, "Blood volume wasn't fixed after the removal of TRAIT_NOBLOOD.")
