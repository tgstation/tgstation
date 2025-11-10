/datum/unit_test/blood_volume_procs

/datum/unit_test/blood_volume_procs/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	// Test initial blood status.
	TEST_ASSERT(dummy.can_have_blood(), "Initialization of blood volume status is screwed up.")
	TEST_ASSERT(CAN_HAVE_BLOOD(dummy), "Caching of blood volume status is screwed up.")

	// Test initial blood volume.
	TEST_ASSERT_EQUAL(dummy.default_blood_volume, BLOOD_VOLUME_NORMAL, "Default blood volume is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), dummy.default_blood_volume, "Blood volume isn't initialized properly.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(apply_modifiers = TRUE), dummy.get_blood_volume(), "Blood volume is modified on initialization.")

	var/set_amount = 400

	// Test setting blood volume.
	TEST_ASSERT_EQUAL(dummy.set_blood_volume(set_amount), set_amount, "Set proc return value is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), set_amount, "Final blood volume is different from what was expected.")

	dummy.set_blood_volume(BLOOD_VOLUME_NORMAL)
	var/adjustment_amount = 100
	var/expected_final_volume = dummy.get_blood_volume() + adjustment_amount

	// Test increasing blood volume.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount), adjustment_amount, "Adjustment proc return value is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "Final blood volume is different from what was expected.")

	dummy.set_blood_volume(BLOOD_VOLUME_NORMAL)
	adjustment_amount = -100
	expected_final_volume = dummy.get_blood_volume() + adjustment_amount

	// Test decreasing blood volume.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount), adjustment_amount, "Adjustment proc return value is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "Final blood volume is different from what was expected.")

	dummy.set_blood_volume(BLOOD_VOLUME_NORMAL)
	adjustment_amount = 100
	var/expected_adjustment = 50
	expected_final_volume = dummy.get_blood_volume() + expected_adjustment

	// Test increasing blood volume, clamped to a maximum.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount, maximum = expected_final_volume), expected_adjustment, "Clamped adjustment proc return value is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "Clamped final blood volume is different from what was expected.")

	dummy.set_blood_volume(BLOOD_VOLUME_NORMAL)
	adjustment_amount = -100
	expected_adjustment = -50
	expected_final_volume = dummy.get_blood_volume() + expected_adjustment

	// Test decreasing blood volume, clamped to a minimum.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount, minimum = expected_final_volume), expected_adjustment, "Clamped adjustment proc return value is incorrect.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "Clamped final blood volume is different from what was expected.")

	dummy.set_blood_volume(BLOOD_VOLUME_NORMAL)
	adjustment_amount = 100
	expected_final_volume = dummy.get_blood_volume() + adjustment_amount
	var/minimum = BLOOD_VOLUME_NORMAL + 200

	// Test if increasing an existing volume that is below the minimum causes it to jump to the minimum.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount, minimum = minimum), adjustment_amount, "When existing volume is below the minimum, adjustment the proc return value after trying to increase it is unexpected. (likely jumped to minimum)")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "When existing volume is below the minimum, the final volume after trying to increase it is unexpected. (likely jumped to minimum)")

	dummy.set_blood_volume(BLOOD_VOLUME_NORMAL)
	adjustment_amount = -100
	expected_final_volume = dummy.get_blood_volume() + adjustment_amount
	var/maximum = BLOOD_VOLUME_NORMAL - 200

	// Test if decreasing an existing volume that is above the maximum causes it to jump to the maximum.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount, maximum = maximum), adjustment_amount, "When existing volume is above the maximum, the adjustment proc return value after trying to decrease it is unexpected. (likely jumped to maximum)")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "When existing volume is above the maximum, the final volume after trying to decrease it is unexpected. (likely jumped to maximum)")

	dummy.set_blood_volume(BLOOD_VOLUME_NORMAL)
	adjustment_amount = BLOOD_VOLUME_MAXIMUM * 10
	expected_final_volume = dummy.get_blood_volume() + adjustment_amount

	// Test increasing blood volume beyond BLOOD_VOLUME_MAXIMUM by setting the maximum to INFINITY. This is allowed. (e.g. setting it to BLOOD_VOLUME_MAX_LETHAL)
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount, maximum = INFINITY), adjustment_amount, "Setting adjustment proc maximum to INFINITY results in an unexpected adjustment proc return value.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "Setting adjustment proc maximum to INFINITY results in an unexpected final volume.")

	dummy.set_blood_volume(BLOOD_VOLUME_NORMAL)
	adjustment_amount = BLOOD_VOLUME_MAXIMUM * -10
	expected_final_volume = dummy.get_blood_volume() + adjustment_amount

	// Test decreasing blood volume below 0 by setting the minimum to -INFINITY. Shouldn't be used, but I want to verify that bypassing the default minimum works as expected.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount, minimum = -INFINITY), adjustment_amount, "Setting adjustment proc minimum to -INFINITY results in an unexpected adjustment proc return value.")
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume, "Setting adjustment proc minimum to -INFINITY results in an unexpected final volume.")

	dummy.reagents.add_reagent(/datum/reagent/medicine/salglu_solution, 10)
	var/datum/reagent/medicine/salglu_solution/saline = dummy.reagents.has_reagent(/datum/reagent/medicine/salglu_solution)
	dummy.set_blood_volume(saline.dilution_cap)

	// Test if saline dilutes blood volume beyond the dilution cap.
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(apply_modifiers = TRUE), saline.dilution_cap, "Saline goes above or below its dilution cap.")

	dummy.set_blood_volume(BLOOD_VOLUME_BAD)
	var/expected_dilution = saline.volume * saline.dilution_per_unit
	expected_final_volume = dummy.get_blood_volume() + expected_dilution

	// Test if saline dilutes low blood volume properly.
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(apply_modifiers = TRUE), expected_final_volume, "Saline didn't dilute low blood by the expected amount.")

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
