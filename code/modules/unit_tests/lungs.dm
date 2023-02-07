/// Tests the standard lungs organ to ensure they process gas correctly.
/datum/unit_test/lungs_sanity/Run()
	// Nothing.
	var/datum/gas_mixture/empty_test_mix = allocate(/datum/gas_mixture)
	// 50 Litres of O2/N2 gas mix, ideal for life.
	var/datum/gas_mixture/test_mix = create_standard_mix()
	// Seperated lab rats to isolate side-effects.
	var/mob/living/carbon/human/suffocate_lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/suffocate_null_lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	// Seperated lungs to isolate side-effects.
	var/obj/item/organ/internal/lungs/suffocate_test_lungs = allocate(/obj/item/organ/internal/lungs)
	var/obj/item/organ/internal/lungs/suffocate_null_test_lungs = allocate(/obj/item/organ/internal/lungs)
	var/obj/item/organ/internal/lungs/test_lungs = allocate(/obj/item/organ/internal/lungs)

	// Tests suffocation with empty gas mix.
	var/breath_ok = suffocate_test_lungs.check_breath(empty_test_mix, suffocate_lab_rat)
	if(breath_ok)
		TEST_FAIL("Lungs check_breath() returned status code 1 when 0 was expected.")
	if(!suffocate_lab_rat.failed_last_breath)
		TEST_FAIL("Lungs check_breath() didn't suffocate on an empty gas_mix when expected.")
	// Ensure gas alerts are accurate.
	check_gas_alerts(suffocate_lab_rat, suffocate_test_lungs, empty_test_mix)

	// Tests suffocation with null. This does indeed happen normally.
	breath_ok = suffocate_null_test_lungs.check_breath(null, suffocate_null_lab_rat)
	if(breath_ok)
		TEST_FAIL("Lungs check_breath() returned status code 1 when 0 was expected.")
	if(!suffocate_null_lab_rat.failed_last_breath)
		TEST_FAIL("Lungs check_breath() didn't suffocate on null when expected.")
	// Ensure gas alerts are accurate.
	check_gas_alerts(suffocate_null_lab_rat, suffocate_null_test_lungs, empty_test_mix)

	// Test one breath of O2/N2 mix
	breath_ok = test_lungs.check_breath(test_mix, lab_rat)
	// Return status code 0 indicates failure to respirate.
	if(!breath_ok)
		TEST_FAIL("Lungs check_breath() returned status code 0 when 1 was expected.")
	if(lab_rat.failed_last_breath)
		TEST_FAIL("Lungs check_breath() can't get a full breath from standard air.")
	// Ensure gas alerts are accurate.
	check_gas_alerts(lab_rat, test_lungs, test_mix)

/// Tests the Plasmaman lungs organs to ensure they process gas correctly.
/datum/unit_test/lungs_sanity/lungs_sanity_plasmaman/Run()
	// 50 Litres of pure Plasma.
	var/datum/gas_mixture/plasma_test_mix = create_plasma_mix()
	var/mob/living/carbon/human/plasma_lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/internal/lungs/plasmaman/plasma_test_lungs = allocate(/obj/item/organ/internal/lungs/plasmaman)
	// Test one breath of Plasma on Plasmaman lungs.
	var/breath_ok = plasma_test_lungs.check_breath(plasma_test_mix, plasma_lab_rat)
	// Return status code 0 indicates failure to respirate.
	if(!breath_ok)
		TEST_FAIL("Plasmaman Lungs check_breath() returned status code 0 when 1 was expected.")
	if(plasma_lab_rat.failed_last_breath)
		TEST_FAIL("Plasmaman Lungs check_breath() can't get a full breath from pure Plasma air.")
	// Ensure gas alerts are accurate.
	check_gas_alerts(plasma_lab_rat, plasma_test_lungs, plasma_test_mix)

/// Tests the Ashwalker lungs organs to ensure they process gas correctly.
/datum/unit_test/lungs_sanity/lungs_sanity_ashwalker/Run()
	// Gas mix resembling one cell of lavaland's atmosphere.
	var/datum/gas_mixture/lavaland_test_mix = create_lavaland_mix()
	var/obj/item/organ/internal/lungs/lavaland/lavaland_test_lungs = allocate(/obj/item/organ/internal/lungs/lavaland)
	var/mob/living/carbon/human/lavaland_lab_rat = allocate(/mob/living/carbon/human/consistent)
	// Test one breath of Lavaland gas mix on Ashwalker lungs.
	var/breath_ok = lavaland_test_lungs.check_breath(lavaland_test_mix, lavaland_lab_rat)
	// Return status code 0 indicates failure to respirate.
	if(!breath_ok)
		TEST_FAIL("Lavaland Lungs check_breath() returned status code 0 when 1 was expected.")
	if(lavaland_lab_rat.failed_last_breath)
		TEST_FAIL("Lavaland Lungs check_breath() can't get a full breath from pure Lavaland air.")
	// Ensure gas alerts are accurate.
	check_gas_alerts(lavaland_lab_rat, lavaland_test_lungs, lavaland_test_mix)

// Set up an O2/N2 gas mix which is "ideal" for organic life.
/datum/unit_test/lungs_sanity/proc/create_standard_mix()
	var/datum/gas_mixture/test_mix = allocate(/datum/gas_mixture, 50)
	test_mix.temperature = T20C
	test_mix.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	test_mix.gases[/datum/gas/oxygen][MOLES] = (ONE_ATMOSPHERE*50)/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
	test_mix.gases[/datum/gas/nitrogen][MOLES] = (ONE_ATMOSPHERE*50)/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
	return test_mix

// Set up an O2/N2 gas mix which is "ideal" for plasmamen.
/datum/unit_test/lungs_sanity/proc/create_plasma_mix()
	var/datum/gas_mixture/test_mix = allocate(/datum/gas_mixture, 50)
	test_mix.temperature = T20C
	test_mix.assert_gases(/datum/gas/plasma)
	test_mix.gases[/datum/gas/plasma][MOLES] = (ONE_ATMOSPHERE*50)/(R_IDEAL_GAS_EQUATION*T20C) * 100
	return test_mix

// Set up an O2/N2 gas mix which is "ideal" for organic life.
/datum/unit_test/lungs_sanity/proc/create_lavaland_mix()
	var/datum/gas_mixture/immutable/planetary/lavaland_mix = SSair.planetary[LAVALAND_DEFAULT_ATMOS]
	var/datum/gas_mixture/test_mix = allocate(/datum/gas_mixture, 50)
	test_mix.gases = lavaland_mix.gases.Copy()
	test_mix.temperature = T20C
	return test_mix

/// Ensures the correct gas alerts are displayed after Lungs take a breath.
/datum/unit_test/lungs_sanity/proc/check_gas_alerts(mob/living/carbon/human/lab_rat, obj/item/organ/internal/lungs/test_lungs, datum/gas_mixture/test_mix)
	// Check "not enough" gas alerts.
	if(lab_rat.has_alert(ALERT_NOT_ENOUGH_OXYGEN) && (!test_lungs.safe_oxygen_min || test_mix.has_gas(/datum/gas/oxygen)))
		TEST_FAIL("Lungs check_breath() threw ALERT_NOT_ENOUGH_OXYGEN when it wasn't expeced.")
	if(lab_rat.has_alert(ALERT_NOT_ENOUGH_NITRO) && (!test_lungs.safe_nitro_min || test_mix.has_gas(/datum/gas/nitrogen)))
		TEST_FAIL("Lungs check_breath() threw ALERT_NOT_ENOUGH_NITROGEN when it wasn't expeced.")
	if(lab_rat.has_alert(ALERT_NOT_ENOUGH_CO2) && (!test_lungs.safe_co2_min || test_mix.has_gas(/datum/gas/carbon_dioxide)))
		TEST_FAIL("Lungs check_breath() threw ALERT_NOT_ENOUGH_CO2 when it wasn't expeced.")
	if(lab_rat.has_alert(ALERT_NOT_ENOUGH_PLASMA) && (!test_lungs.safe_plasma_min || test_mix.has_gas(/datum/gas/plasma)))
		TEST_FAIL("Lungs check_breath() threw ALERT_NOT_ENOUGH_PLASMA when it wasn't expeced.")
	// Check "too much" gas alerts.
	if(lab_rat.has_alert(ALERT_TOO_MUCH_OXYGEN) && (!test_lungs.safe_oxygen_max || !test_mix.has_gas(/datum/gas/oxygen)))
		TEST_FAIL("Lungs check_breath() threw ALERT_TOO MUCH_OXYGEN when it wasn't expeced.")
	if(lab_rat.has_alert(ALERT_TOO_MUCH_NITRO) && (!test_lungs.safe_nitro_max || !test_mix.has_gas(/datum/gas/nitrogen)))
		TEST_FAIL("Lungs check_breath() threw ALERT_TOO_MUCH_NITROGEN when it wasn't expeced.")
	if(lab_rat.has_alert(ALERT_TOO_MUCH_CO2) && (!test_lungs.safe_co2_max || !test_mix.has_gas(/datum/gas/carbon_dioxide)))
		TEST_FAIL("Lungs check_breath() threw ALERT_TOO_MUCH_CO2 when it wasn't expeced.")
	if(lab_rat.has_alert(ALERT_TOO_MUCH_PLASMA) && (!test_lungs.safe_plasma_max || !test_mix.has_gas(/datum/gas/plasma)))
		TEST_FAIL("Lungs check_breath() threw ALERT_TOO_MUCH_PLASMA when it wasn't expeced.")
