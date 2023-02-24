/// Tests the standard lungs organ to ensure breathing and suffocation behave as expected.
/// Performs a check on each main (can be life-sustaining) gas, and ensures gas alerts are only thrown when expected.
/datum/unit_test/lungs_sanity

/datum/unit_test/lungs_sanity/Run()
	// "Standard" form of breathing.
	// 50 Litres of O2/N2 gas mix, ideal for life.
	var/datum/gas_mixture/test_mix = create_standard_mix()
	var/obj/item/organ/internal/lungs/test_lungs = allocate(/obj/item/organ/internal/lungs)
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/breath_ok = FALSE

	// Test one breath of O2/N2 mix.
	breath_ok = test_lungs.check_breath(test_mix, lab_rat)
	lungs_test_return(breath_ok, test_lungs)
	lungs_test_breathe(lab_rat, test_lungs, "standard gas mixture")
	lungs_test_alerts(lab_rat, test_lungs, test_mix)

	// Suffocation with an empty gas mix.
	var/datum/gas_mixture/empty_test_mix = allocate(/datum/gas_mixture)
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs)
	// Test one breath of nothing. Suffocate due to the breath being empty.
	breath_ok = test_lungs.check_breath(empty_test_mix, lab_rat)
	lungs_test_return_fail(breath_ok, test_lungs)
	lungs_test_suffocate(lab_rat, test_lungs, "empty gas mixture")
	lungs_test_alerts(lab_rat, test_lungs, test_mix)

	// Suffocation with null. This does indeed happen normally.
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs)
	// Test one breath of nothing. Suffocate due to the breath being null.
	breath_ok = test_lungs.check_breath(null, lab_rat)
	lungs_test_return_fail(breath_ok, test_lungs)
	lungs_test_suffocate(lab_rat, test_lungs, "null")
	lungs_test_alerts(lab_rat, test_lungs, test_mix)

	// Suffocation with Nitrogen.
	var/datum/gas_mixture/nitro_test_mix = create_nitrogen_mix()
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs)
	// Test one breath of Nitrogen. Suffocate due to the breath being 100% N2.
	breath_ok = test_lungs.check_breath(nitro_test_mix, lab_rat)
	lungs_test_return_fail(breath_ok, test_lungs)
	lungs_test_suffocate(lab_rat, test_lungs, "pure nitrogen")
	lungs_test_alerts(lab_rat, test_lungs, nitro_test_mix)

/// Tests the Plasmaman lungs organ to ensure Plasma breathing and suffocation behave as expected.
/datum/unit_test/lungs_sanity_plasmaman

/datum/unit_test/lungs_sanity_plasmaman/Run()
	// 50 Litres of pure Plasma.
	var/datum/gas_mixture/plasma_test_mix = create_plasma_mix()
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/internal/lungs/plasmaman/test_lungs = allocate(/obj/item/organ/internal/lungs/plasmaman)
	// Test one breath of Plasma on Plasmaman lungs.
	var/breath_ok = test_lungs.check_breath(plasma_test_mix, lab_rat)
	lungs_test_return(breath_ok, test_lungs)
	lungs_test_breathe(lab_rat, test_lungs, "pure plasma")
	lungs_test_alerts(lab_rat, test_lungs, plasma_test_mix)

	// Tests suffocation with Nitrogen.
	var/datum/gas_mixture/nitro_test_mix = create_nitrogen_mix()
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs/plasmaman)
	// Test one breath of Nitrogen on Plasmaman lungs.
	breath_ok = test_lungs.check_breath(nitro_test_mix, lab_rat)
	lungs_test_return_fail(breath_ok, test_lungs)
	lungs_test_suffocate(lab_rat, test_lungs, "pure nitrogen")
	lungs_test_alerts(lab_rat, test_lungs, nitro_test_mix)

/// Tests the lavaland/Ashwalker lungs organ.
/// Ensures they can breathe from the lavaland air mixture properly, and suffocate on inadequate mixture.
/datum/unit_test/lungs_sanity_ashwalker

/datum/unit_test/lungs_sanity_ashwalker/Run()
	// Gas mix resembling one cell of lavaland's atmosphere.
	var/datum/gas_mixture/lavaland_test_mix = create_lavaland_mix()
	var/obj/item/organ/internal/lungs/lavaland/test_lungs = allocate(/obj/item/organ/internal/lungs/lavaland)
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	// Test one breath of Lavaland gas mix on Ashwalker lungs.
	var/breath_ok = test_lungs.check_breath(lavaland_test_mix, lab_rat)
	lungs_test_return(breath_ok, test_lungs)
	lungs_test_breathe(lab_rat, test_lungs, "Lavaland air mixture")
	lungs_test_alerts(lab_rat, test_lungs, lavaland_test_mix)

/// Checks the given status code to ensure success / truthy.
/datum/unit_test/proc/lungs_test_return(breath_ok, obj/item/organ/internal/lungs/test_lungs)
	TEST_ASSERT(breath_ok, "[test_lungs.type]/check_breath() returned falsy / status code 0 (failure) when it wasn't expected.")

/// Checks the given status code to ensure failure / falsy.
/datum/unit_test/proc/lungs_test_return_fail(breath_ok, obj/item/organ/internal/lungs/test_lungs)
	TEST_ASSERT(!breath_ok, "[test_lungs.type]/check_breath() returned truthy / status code 1 (success) when it wasn't expected.")

/// Checks the given Human to ensure they successfully breathed.
/datum/unit_test/proc/lungs_test_breathe(mob/living/carbon/human/lab_rat, obj/item/organ/internal/lungs/test_lungs, needed_gases)
	TEST_ASSERT(!lab_rat.failed_last_breath, "[test_lungs.type]/check_breath() can't get a full breath from [needed_gases].")

// Checks the given Human to ensure they suffocated / failed to breathe
/datum/unit_test/proc/lungs_test_suffocate(mob/living/carbon/human/lab_rat, obj/item/organ/internal/lungs/test_lungs, suffocant)
	TEST_ASSERT(lab_rat.failed_last_breath, "[test_lungs.type]/check_breath() didn't suffocate from [suffocant] when expected.")

/// Silver-bullet test for gas alerts which are thrown/displayed after Lungs take a breath.
/// For each alerting gas in the game, this test ensures the Lungs' minimums and maximums are respected.
/datum/unit_test/proc/lungs_test_alerts(mob/living/carbon/human/lab_rat, obj/item/organ/internal/lungs/test_lungs, datum/gas_mixture/test_mix)
	// Get partial pressures for each main gas in the mix. Identical to Lungs implementation of partial pressure.
	var/oxygen_pp = test_mix.get_breath_partial_pressure(test_mix[/datum/gas/oxygen][MOLES])
	var/nitro_pp = test_mix.get_breath_partial_pressure(test_mix[/datum/gas/nitrogen][MOLES])
	var/co2_pp = test_mix.get_breath_partial_pressure(test_mix[/datum/gas/carbon_dioxide][MOLES])
	var/plasma_pp = test_mix.get_breath_partial_pressure(test_mix[/datum/gas/plasma][MOLES])

	// Minimum partial pressures.
	TEST_ASSERT((oxygen_pp < test_lungs.safe_oxygen_min) && lab_rat.has_alert(ALERT_NOT_ENOUGH_OXYGEN), "Lungs check_breath() failed to throw ALERT_NOT_ENOUGH_OXYGEN when expected.")
	TEST_ASSERT((oxygen_pp >= test_lungs.safe_oxygen_min) && !lab_rat.has_alert(ALERT_NOT_ENOUGH_OXYGEN), "Lungs check_breath() threw ALERT_NOT_ENOUGH_OXYGEN when it wasn't expected.")

	TEST_ASSERT((nitro_pp < test_lungs.safe_nitro_min) && lab_rat.has_alert(ALERT_NOT_ENOUGH_NITRO), "Lungs check_breath() failed to throw ALERT_NOT_ENOUGH_NITRO when expected.")
	TEST_ASSERT((nitro_pp >= test_lungs.safe_nitro_min) && !lab_rat.has_alert(ALERT_NOT_ENOUGH_NITRO), "Lungs check_breath() threw ALERT_NOT_ENOUGH_NITRO when it wasn't expected.")

	TEST_ASSERT((co2_pp < test_lungs.safe_co2_min) && lab_rat.has_alert(ALERT_NOT_ENOUGH_CO2), "Lungs check_breath() failed to throw ALERT_NOT_ENOUGH_CO2 when expected.")
	TEST_ASSERT((co2_pp >= test_lungs.safe_co2_min) && !lab_rat.has_alert(ALERT_NOT_ENOUGH_CO2), "Lungs check_breath() threw ALERT_NOT_ENOUGH_CO2 when it wasn't expected.")

	TEST_ASSERT((plasma_pp < test_lungs.safe_plasma_min) && lab_rat.has_alert(ALERT_NOT_ENOUGH_PLASMA), "Lungs check_breath() failed to throw ALERT_NOT_ENOUGH_PLASMA when expected.")
	TEST_ASSERT((plasma_pp >= test_lungs.safe_plasma_min) && !lab_rat.has_alert(ALERT_NOT_ENOUGH_PLASMA), "Lungs check_breath() threw ALERT_NOT_ENOUGH_PLASMA when it wasn't expected.")

	// Maximum partial pressures.
	TEST_ASSERT((oxygen_pp <= test_lungs.safe_oxygen_max) && !lab_rat.has_alert(ALERT_TOO_MUCH_OXYGEN), "Lungs check_breath() threw ALERT_TOO MUCH_OXYGEN when it wasn't expected.")
	TEST_ASSERT((oxygen_pp > test_lungs.safe_oxygen_max) && lab_rat.has_alert(ALERT_TOO_MUCH_OXYGEN), "Lungs check_breath() failed to throw ALERT_TOO MUCH_OXYGEN when expected.")

	TEST_ASSERT((nitro_pp <= test_lungs.safe_nitro_max) && !lab_rat.has_alert(ALERT_TOO_MUCH_NITRO), "Lungs check_breath() threw ALERT_TOO MUCH_NITRO when it wasn't expected.")
	TEST_ASSERT((nitro_pp > test_lungs.safe_nitro_max) && lab_rat.has_alert(ALERT_TOO_MUCH_NITRO), "Lungs check_breath() failed to throw ALERT_TOO MUCH_NITRO when expected.")

	TEST_ASSERT((co2_pp <= test_lungs.safe_co2_max) && !lab_rat.has_alert(ALERT_TOO_MUCH_CO2), "Lungs check_breath() threw ALERT_TOO MUCH_CO2 when it wasn't expected.")
	TEST_ASSERT((co2_pp > test_lungs.safe_co2_max) && lab_rat.has_alert(ALERT_TOO_MUCH_CO2), "Lungs check_breath() failed to throw ALERT_TOO MUCH_CO2 when expected.")

	TEST_ASSERT((plasma_pp <= test_lungs.safe_plasma_max) && !lab_rat.has_alert(ALERT_TOO_MUCH_PLASMA), "Lungs check_breath() threw ALERT_TOO MUCH_PLASMA when it wasn't expected.")
	TEST_ASSERT((plasma_pp > test_lungs.safe_plasma_max) && lab_rat.has_alert(ALERT_TOO_MUCH_PLASMA), "Lungs check_breath() failed to throw ALERT_TOO MUCH_PLASMA when expected.")

/// Set up a 50-Litre gas mixture with the given gases and percentages.
/datum/unit_test/proc/create_gas_mix(list/gases_to_percentages)
	var/datum/gas_mixture/test_mix = allocate(/datum/gas_mixture, 50)
	test_mix.temperature = T20C
	for(var/datum/gas/gas_type as anything in gases_to_percentages)
		test_mix.assert_gas(gas_type)
		test_mix.gases[gas_type][MOLES] = (ONE_ATMOSPHERE * 50) / (R_IDEAL_GAS_EQUATION * T20C) * gases_to_percentages[gas_type]
	return test_mix

/// Set up an O2/N2 gas mix which is "ideal" for organic life.
/datum/unit_test/proc/create_standard_mix()
	return create_gas_mix(list(/datum/gas/oxygen = O2STANDARD, /datum/gas/nitrogen = N2STANDARD))

/// Set up a pure Nitrogen gas mix.
/datum/unit_test/proc/create_nitrogen_mix()
	return create_gas_mix(list(/datum/gas/nitrogen = 1))

/// Set up an O2/N2 gas mix which is "ideal" for plasmamen.
/datum/unit_test/proc/create_plasma_mix()
	return create_gas_mix(list(/datum/gas/plasma = 1))

/// Set up an O2/N2 gas mix which is "ideal" for organic life.
/datum/unit_test/proc/create_lavaland_mix()
	var/datum/gas_mixture/immutable/planetary/lavaland_mix = SSair.planetary[LAVALAND_DEFAULT_ATMOS]
	var/datum/gas_mixture/test_mix = allocate(/datum/gas_mixture, 50)
	test_mix.temperature = T20C
	test_mix.gases = lavaland_mix.gases.Copy()
	return test_mix
