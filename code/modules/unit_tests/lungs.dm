#define LUNGS_TEST_RETURN(breath_ok, test_lungs) if(!breath_ok)\
	TEST_FAIL("[test_lungs.type]/check_breath() returned falsy / status code 0 (failure) when it wasn't expected.")\

#define LUNGS_TEST_RETURN_FAIL(breath_ok, test_lungs) if(breath_ok)\
	TEST_FAIL("[test_lungs.type]/check_breath() returned truthy / status code 1 (success) when it wasn't expected.")\

#define LUNGS_TEST_BREATHE(test_lungs, lab_rat, needed_gases) if(lab_rat.failed_last_breath)\
	TEST_FAIL("[test_lungs.type]/check_breath() can't get a full breath from [needed_gases].")\

#define LUNGS_TEST_SUFFOCATE(test_lungs, lab_rat, suffocant) if(!lab_rat.failed_last_breath)\
	TEST_FAIL("[test_lungs.type]/check_breath() didn't suffocate from [suffocant] when expected.")\

/// Tests the standard lungs organ to ensure breathing and suffocation behave as expected.
/// Performs a check on each gas to ensure side-effects are properly applied to Humans.
/datum/unit_test/lungs_sanity

/// Ensures the correct gas alerts are displayed after Lungs take a breath.
/datum/unit_test/proc/check_gas_alerts(mob/living/carbon/human/lab_rat, obj/item/organ/internal/lungs/test_lungs, datum/gas_mixture/test_mix)
	TEST_ASSERT(lab_rat.has_alert(ALERT_NOT_ENOUGH_OXYGEN) && (!test_lungs.safe_oxygen_min || test_mix.has_gas(/datum/gas/oxygen)), "Lungs check_breath() threw ALERT_NOT_ENOUGH_OXYGEN when it wasn't expeced.")
	TEST_ASSERT(lab_rat.has_alert(ALERT_NOT_ENOUGH_NITRO) && (!test_lungs.safe_nitro_min || test_mix.has_gas(/datum/gas/nitrogen)), "Lungs check_breath() threw ALERT_NOT_ENOUGH_NITROGEN when it wasn't expeced.")
	TEST_ASSERT(lab_rat.has_alert(ALERT_NOT_ENOUGH_CO2) && (!test_lungs.safe_co2_min || test_mix.has_gas(/datum/gas/carbon_dioxide)), "Lungs check_breath() threw ALERT_NOT_ENOUGH_CO2 when it wasn't expeced.")
	TEST_ASSERT(lab_rat.has_alert(ALERT_NOT_ENOUGH_PLASMA) && (!test_lungs.safe_plasma_min || test_mix.has_gas(/datum/gas/plasma)), "Lungs check_breath() threw ALERT_NOT_ENOUGH_PLASMA when it wasn't expeced.")
	TEST_ASSERT(lab_rat.has_alert(ALERT_TOO_MUCH_OXYGEN) && (!test_lungs.safe_oxygen_max || !test_mix.has_gas(/datum/gas/oxygen)), "Lungs check_breath() threw ALERT_TOO MUCH_OXYGEN when it wasn't expeced.")
	TEST_ASSERT(lab_rat.has_alert(ALERT_TOO_MUCH_NITRO) && (!test_lungs.safe_nitro_max || !test_mix.has_gas(/datum/gas/nitrogen)), "Lungs check_breath() threw ALERT_TOO_MUCH_NITROGEN when it wasn't expeced.")
	TEST_ASSERT(lab_rat.has_alert(ALERT_TOO_MUCH_CO2) && (!test_lungs.safe_co2_max || !test_mix.has_gas(/datum/gas/carbon_dioxide)), "Lungs check_breath() threw ALERT_TOO_MUCH_CO2 when it wasn't expeced.")
	TEST_ASSERT(lab_rat.has_alert(ALERT_TOO_MUCH_PLASMA) && (!test_lungs.safe_plasma_max || !test_mix.has_gas(/datum/gas/plasma)), "Lungs check_breath() threw ALERT_TOO_MUCH_PLASMA when it wasn't expeced.")

/datum/unit_test/lungs_sanity/Run()
	// Tests the "standard" form of breathing.
	// 50 Litres of O2/N2 gas mix, ideal for life.
	var/datum/gas_mixture/test_mix = create_standard_mix()
	var/obj/item/organ/internal/lungs/test_lungs = allocate(/obj/item/organ/internal/lungs)
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	// Test one breath of O2/N2 mix.
	var/breath_ok = test_lungs.check_breath(test_mix, lab_rat)
	// Return status code 0 indicates failure to respirate.
	LUNGS_TEST_RETURN(breath_ok, test_lungs)
	LUNGS_TEST_BREATHE(test_lungs, lab_rat, "standard gas mixture")
	// Ensure gas alerts are accurate.
	check_gas_alerts(lab_rat, test_lungs, test_mix)

	// Test suffocation with an empty gas mix.
	var/datum/gas_mixture/empty_test_mix = allocate(/datum/gas_mixture)
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs)
	// Test one breath of nothing. Suffocate due to the breath being empty.
	breath_ok = test_lungs.check_breath(empty_test_mix, lab_rat)
	LUNGS_TEST_RETURN_FAIL(breath_ok, test_lungs)
	LUNGS_TEST_SUFFOCATE(test_lungs, lab_rat, "empty gas mixture")
	// Ensure gas alerts are accurate.
	check_gas_alerts(lab_rat, test_lungs, empty_test_mix)

	// Tests suffocation with null. This does indeed happen normally.
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs)
	// Test one breath of nothing. Suffocate due to the breath being null.
	breath_ok = test_lungs.check_breath(null, lab_rat)
	LUNGS_TEST_RETURN_FAIL(breath_ok, test_lungs)
	LUNGS_TEST_SUFFOCATE(test_lungs, lab_rat, "null")
	// Ensure gas alerts are accurate.
	check_gas_alerts(lab_rat, test_lungs, empty_test_mix)

	// Tests suffocation with Nitrogen.
	var/datum/gas_mixture/nitro_test_mix = create_nitrogen_mix()
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs)
	// Test one breath of Nitrogen. Suffocate due to the breath being 100% N2.
	breath_ok = test_lungs.check_breath(nitro_test_mix, lab_rat)
	LUNGS_TEST_RETURN_FAIL(breath_ok, test_lungs)
	LUNGS_TEST_SUFFOCATE(test_lungs, lab_rat, "pure nitrogen")
	// Ensure gas alerts are accurate.
	check_gas_alerts(lab_rat, test_lungs, nitro_test_mix)

/// Tests the standard lungs organ to ensure breathing and suffocation behave as expected.
/// Performs a check on each gas to ensure side-effects are properly applied to Humans.
/datum/unit_test/lungs_sanity_plasmaman

/datum/unit_test/lungs_sanity_plasmaman/Run()
	// 50 Litres of pure Plasma.
	var/datum/gas_mixture/plasma_test_mix = create_plasma_mix()
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/internal/lungs/plasmaman/test_lungs = allocate(/obj/item/organ/internal/lungs/plasmaman)
	// Test one breath of Plasma on Plasmaman lungs.
	var/breath_ok = test_lungs.check_breath(plasma_test_mix, lab_rat)
	LUNGS_TEST_RETURN(breath_ok, test_lungs)
	LUNGS_TEST_BREATHE(test_lungs, lab_rat, "pure plasma")
	// Ensure gas alerts are accurate.
	check_gas_alerts(lab_rat, test_lungs, plasma_test_mix)

	// Tests suffocation with Nitrogen.
	var/datum/gas_mixture/nitro_test_mix = create_nitrogen_mix()
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs/plasmaman)
	// Test one breath of Nitrogen on Plasmaman lungs.
	breath_ok = test_lungs.check_breath(nitro_test_mix, lab_rat)
	LUNGS_TEST_RETURN_FAIL(breath_ok, test_lungs)
	LUNGS_TEST_SUFFOCATE(test_lungs, lab_rat, "pure nitrogen")
	// Ensure gas alerts are accurate.
	check_gas_alerts(lab_rat, test_lungs, nitro_test_mix)

/// Tests the Ashwalker lungs organs to ensure it behaves the way we expect.
/datum/unit_test/lungs_sanity/lungs_sanity_ashwalker

/datum/unit_test/lungs_sanity/lungs_sanity_ashwalker/Run()
	// Gas mix resembling one cell of lavaland's atmosphere.
	var/datum/gas_mixture/lavaland_test_mix = create_lavaland_mix()
	var/obj/item/organ/internal/lungs/lavaland/test_lungs = allocate(/obj/item/organ/internal/lungs/lavaland)
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	// Test one breath of Lavaland gas mix on Ashwalker lungs.
	var/breath_ok = test_lungs.check_breath(lavaland_test_mix, lab_rat)
	LUNGS_TEST_RETURN(breath_ok, test_lungs)
	LUNGS_TEST_BREATHE(test_lungs, lab_rat, "Lavaland air mixture")
	// Ensure gas alerts are accurate.
	check_gas_alerts(lab_rat, test_lungs, lavaland_test_mix)

// Set up a 50-Litre gas mixture with the given gases and percentages.
/datum/unit_test/proc/create_gas_mix(list/gases_to_percentages)
	var/datum/gas_mixture/test_mix = allocate(/datum/gas_mixture, 50)
	test_mix.temperature = T20C
	for(var/datum/gas/gas_type as anything in gases_to_percentages)
		test_mix.assert_gas(gas_type)
		test_mix.gases[gas_type][MOLES] = (ONE_ATMOSPHERE * 50) / (R_IDEAL_GAS_EQUATION * T20C) * gases_to_percentages[gas_type]
	return test_mix

// Set up an O2/N2 gas mix which is "ideal" for organic life.
/datum/unit_test/proc/create_standard_mix()
	return create_gas_mix(list(/datum/gas/oxygen = O2STANDARD, /datum/gas/nitrogen = N2STANDARD))

// Set up a pure Nitrogen gas mix.
/datum/unit_test/proc/create_nitrogen_mix()
	return create_gas_mix(list(/datum/gas/nitrogen = 1))

// Set up an O2/N2 gas mix which is "ideal" for plasmamen.
/datum/unit_test/proc/create_plasma_mix()
	return create_gas_mix(list(/datum/gas/plasma = 1))

// Set up an O2/N2 gas mix which is "ideal" for organic life.
/datum/unit_test/proc/create_lavaland_mix()
	var/datum/gas_mixture/immutable/planetary/lavaland_mix = SSair.planetary[LAVALAND_DEFAULT_ATMOS]
	var/datum/gas_mixture/test_mix = allocate(/datum/gas_mixture, 50)
	test_mix.temperature = T20C
	test_mix.gases = lavaland_mix.gases.Copy()
	return test_mix

#undef LUNGS_TEST_RETURN
#undef LUNGS_TEST_RETURN_FAIL
#undef LUNGS_TEST_BREATHE
#undef LUNGS_TEST_SUFFOCATE
