/datum/unit_test/blood_volume_procs

/datum/unit_test/blood_volume_procs/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	// Test initial blood status.
	TEST_ASSERT(dummy.can_have_blood())
	TEST_ASSERT(CAN_HAVE_BLOOD(dummy))

	// Test initial blood volume.
	TEST_ASSERT_EQUAL(dummy.default_blood_volume, BLOOD_VOLUME_NORMAL)
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), dummy.default_blood_volume)
	TEST_ASSERT_EQUAL(dummy.get_modified_blood_volume(), dummy.get_blood_volume())

	var/adjustment_amount = 100
	var/expected_final_volume = dummy.get_blood_volume() + adjustment_amount

	// Test increasing blood volume.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount), adjustment_amount)
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume)

	adjustment_amount = -100
	expected_final_volume = dummy.get_blood_volume() + adjustment_amount

	// Test decreasing blood volume.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount), adjustment_amount)
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume)

	adjustment_amount = 100
	var/expected_adjustment = 50
	expected_final_volume = dummy.get_blood_volume() + expected_adjustment

	// Test increasing blood volume, clamped to a maximum.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount, maximum = expected_final_volume), expected_adjustment)
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume)

	adjustment_amount = -100
	expected_adjustment = -50
	expected_final_volume = dummy.get_blood_volume() + expected_adjustment

	// Test decreasing blood volume, clamped to a minimum.
	TEST_ASSERT_EQUAL(dummy.adjust_blood_volume(adjustment_amount, minimum = expected_final_volume), expected_adjustment)
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), expected_final_volume)

	dummy.reagents.add_reagent(saline_path, 10)
	var/datum/reagent/medicine/salglu_solution/saline = dummy.reagents.has_reagent(/datum/reagent/medicine/salglu_solution)
	dummy.set_blood_volume(saline.dilution_cap)

	// Test if saline dilutes blood volume beyond the dilution cap.
	TEST_ASSERT_EQUAL(dummy.get_modified_blood_volume(), saline_path.dilution_cap)

	dummy.set_blood_volume(BLOOD_VOLUME_BAD)
	var/expected_dilution = saline.volume * saline.dilution_per_unit
	expected_final_volume = dummy.get_blood_volume() + expected_dilution

	// Test if saline dilutes low blood volume properly.
	TEST_ASSERT_EQUAL(dummy.get_modified_blood_volume(), expected_final_volume)

	ADD_TRAIT(dummy, TRAIT_NOBLOOD)

	// Test if adding TRAIT_NOBLOOD works properly.
	TEST_ASSERT(!dummy.can_have_blood())
	TEST_ASSERT(!CAN_HAVE_BLOOD(dummy))
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), 0)

	REMOVE_TRAIT(dummy, TRAIT_NOBLOOD)

	// Test if removing TRAIT_NOBLOOD works properly.
	TEST_ASSERT(dummy.can_have_blood())
	TEST_ASSERT(CAN_HAVE_BLOOD(dummy))
	TEST_ASSERT_EQUAL(dummy.get_blood_volume(), dummy.default_blood_volume)
