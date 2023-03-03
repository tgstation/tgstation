#define TEST_ALERT_THROW_MESSAGE(lungs_organ, alert_name) "[lungs_organ.type]/check_breath() failed to throw alert [alert_name] when expected."
#define TEST_ALERT_INHIBIT_MESSAGE(lungs_organ, alert_name) "[lungs_organ.type]/check_breath() threw alert [alert_name] when it wasn't expected."

/// Tests the standard lungs organ to ensure breathing and suffocation behave as expected.
/// Performs a check on each main (can be life-sustaining) gas, and ensures gas alerts are only thrown when expected.
/// TODO: Add a gas exchange test.
/datum/unit_test/lungs_sanity

/datum/unit_test/lungs_sanity/Run()
	// "Standard" form of breathing.
	// 2500 Litres of O2/N2 gas mix, ideal for life.
	var/datum/gas_mixture/test_mix = create_standard_mix()
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/internal/lungs/test_lungs = allocate(/obj/item/organ/internal/lungs)
	// Test one breath of O2/N2 mix.
	lungs_test_check_breath("standard gas mixture", lab_rat, test_lungs, test_mix)

	// Suffocation with an empty gas mix.
	var/datum/gas_mixture/empty_test_mix = allocate(/datum/gas_mixture)
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs)
	// Test one breath of nothing. Suffocate due to the breath being empty.
	lungs_test_check_breath("empty gas mixture", lab_rat, test_lungs, empty_test_mix, expect_failure = TRUE)

	// Suffocation with null. This does indeed happen normally.
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs)
	// Test one breath of nothing. Suffocate due to the breath being null.
	lungs_test_check_breath("null", lab_rat, test_lungs, null, expect_failure = TRUE)

	// Suffocation with Nitrogen.
	var/datum/gas_mixture/nitro_test_mix = create_nitrogen_mix()
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs)
	// Test one breath of Nitrogen. Suffocate due to the breath being 100% N2.
	lungs_test_check_breath("pure Nitrogen", lab_rat, test_lungs, nitro_test_mix, expect_failure = TRUE)

/// Tests the Plasmaman lungs organ to ensure Plasma breathing and suffocation behave as expected.
/datum/unit_test/lungs_sanity_plasmaman

/datum/unit_test/lungs_sanity_plasmaman/Run()
	// 2500 Litres of pure Plasma.
	var/datum/gas_mixture/plasma_test_mix = create_plasma_mix()
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/internal/lungs/plasmaman/test_lungs = allocate(/obj/item/organ/internal/lungs/plasmaman)
	// Test one breath of Plasma on Plasmaman lungs.
	lungs_test_check_breath("pure Plasma", lab_rat, test_lungs, plasma_test_mix)

	// Tests suffocation with Nitrogen.
	var/datum/gas_mixture/nitro_test_mix = create_nitrogen_mix()
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	test_lungs = allocate(/obj/item/organ/internal/lungs/plasmaman)
	// Test one breath of Nitrogen on Plasmaman lungs.
	lungs_test_check_breath("pure Nitrogen", lab_rat, test_lungs, nitro_test_mix, expect_failure = TRUE)

/// Tests the lavaland/Ashwalker lungs organ.
/// Ensures they can breathe from the lavaland air mixture properly, and suffocate on inadequate mixture.
/datum/unit_test/lungs_sanity_ashwalker

/datum/unit_test/lungs_sanity_ashwalker/Run()
	// Gas mix resembling one cell of lavaland's atmosphere.
	var/datum/gas_mixture/lavaland_test_mix = create_lavaland_mix()
	var/obj/item/organ/internal/lungs/lavaland/test_lungs = allocate(/obj/item/organ/internal/lungs/lavaland)
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	// Test one breath of Lavaland gas mix on Ashwalker lungs.
	lungs_test_check_breath("Lavaland air mixture", lab_rat, test_lungs, lavaland_test_mix)

/// Comprehensive unit test for [/obj/item/organ/internal/lungs/proc/check_breath()]
/// If "expect_failure" is set to TRUE, the test ensures the given Human suffocated.
/// A "test_name" string is required to contextualize test logs. Describe the gas you're testing.
/datum/unit_test/proc/lungs_test_check_breath(test_name, mob/living/carbon/human/lab_rat, obj/item/organ/internal/lungs/test_lungs, datum/gas_mixture/test_mix, expect_failure = FALSE)
	// Setup a small volume of gas which represents one "breath" from test_mix.
	var/datum/gas_mixture/test_breath

	if(!isnull(test_mix))
		var/total_moles = test_mix.total_moles()
		if(total_moles > 0)
			test_breath = test_mix.remove(total_moles * BREATH_PERCENTAGE)

	if(isnull(test_breath))
		test_breath = allocate(/datum/gas_mixture, BREATH_VOLUME)

	// Setup gas lists even if empty, for convenience.
	test_breath.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)

	// Backup of the breath mixture, to compare against after testing check_breath().
	var/datum/gas_mixture/test_breath_backup = test_breath.copy()

	// Get partial pressures for each "main" gas.
	var/oxygen_pp = 0
	var/nitro_pp = 0
	var/plasma_pp = 0
	var/co2_pp = 0
	if(test_breath.total_moles() > 0)
		oxygen_pp = test_breath.get_breath_partial_pressure(test_breath.gases[/datum/gas/oxygen][MOLES])
		nitro_pp = test_breath.get_breath_partial_pressure(test_breath.gases[/datum/gas/nitrogen][MOLES])
		plasma_pp = test_breath.get_breath_partial_pressure(test_breath.gases[/datum/gas/plasma][MOLES])
		co2_pp = test_breath.get_breath_partial_pressure(test_breath.gases[/datum/gas/carbon_dioxide][MOLES])

	// Test a single "breath" of air.
	var/status_code = test_lungs.check_breath(test_breath, lab_rat)

	// We need to assert_gases() again because check_breath() calls garbage_collect() before returning, deleting lists we need.
	test_breath.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)

	// Ensures failed_last_breath is set as we expect, and that check_breath returns a corollary status code.
	if(expect_failure)
		TEST_ASSERT(!status_code, "[test_lungs.type]/check_breath() returned truthy / status code 1 (success) when it wasn't expected.")
		TEST_ASSERT(lab_rat.failed_last_breath, "[test_lungs.type]/check_breath() should suffocate from [test_name].")
	else
		TEST_ASSERT(status_code, "[test_lungs.type]/check_breath() returned falsy / status code 0 (failure) when it wasn't expected.")
		TEST_ASSERT(!lab_rat.failed_last_breath, "[test_lungs.type]/check_breath() can't get a full breath from [test_name].")

	var/min_oxygen = test_lungs.safe_oxygen_min
	var/min_nitro = test_lungs.safe_nitro_min
	var/min_co2 = test_lungs.safe_co2_min
	var/min_plasma = test_lungs.safe_plasma_min
	var/max_oxygen = test_lungs.safe_oxygen_max
	var/max_nitro = test_lungs.safe_nitro_max
	var/max_co2 = test_lungs.safe_co2_max
	var/max_plasma = test_lungs.safe_plasma_max

	// Checks each "main" gas to ensure gas alerts are thrown/inhibited when expected.
	lungs_test_alert_min(lab_rat, test_lungs, ALERT_NOT_ENOUGH_OXYGEN, min_oxygen, oxygen_pp)
	lungs_test_alert_max(lab_rat, test_lungs, ALERT_TOO_MUCH_OXYGEN, max_oxygen, oxygen_pp)

	lungs_test_alert_min(lab_rat, test_lungs, ALERT_NOT_ENOUGH_NITRO, min_nitro, nitro_pp)
	lungs_test_alert_max(lab_rat, test_lungs, ALERT_TOO_MUCH_NITRO, max_nitro, nitro_pp)

	lungs_test_alert_min(lab_rat, test_lungs, ALERT_NOT_ENOUGH_CO2, min_co2, co2_pp)
	lungs_test_alert_max(lab_rat, test_lungs, ALERT_TOO_MUCH_CO2, max_co2, co2_pp)

	lungs_test_alert_min(lab_rat, test_lungs, ALERT_NOT_ENOUGH_PLASMA, min_plasma, plasma_pp)
	lungs_test_alert_max(lab_rat, test_lungs, ALERT_TOO_MUCH_PLASMA, max_plasma, plasma_pp)

	// Tests for main gas exchange.
	var/list/old_breath_gases = test_breath_backup.gases
	// Track the volumes of O2 and CO2 which are expected to be exhaled.
	var/expected_oxygen = old_breath_gases[/datum/gas/oxygen][MOLES]
	var/expected_co2 = old_breath_gases[/datum/gas/carbon_dioxide][MOLES]
	if(min_oxygen)
		expected_co2 += expected_oxygen
		expected_oxygen -= expected_oxygen
	if(min_nitro)
		expected_co2 += old_breath_gases[/datum/gas/nitrogen][MOLES]
	if(min_co2)
		expected_oxygen += old_breath_gases[/datum/gas/carbon_dioxide][MOLES]
		expected_co2 -= old_breath_gases[/datum/gas/carbon_dioxide][MOLES]
	if(min_plasma)
		expected_co2 += old_breath_gases[/datum/gas/plasma][MOLES]

	// Validate conversion of inhaled gas to exhaled gas.
	var/list/breath_gases = test_breath.gases
	if(min_oxygen)
		TEST_ASSERT_EQUAL(breath_gases[/datum/gas/carbon_dioxide][MOLES], expected_co2, "[test_lungs.type]/check_breath() should convert Oxygen into an equivalent volume of CO2.")
	if(min_nitro)
		TEST_ASSERT_EQUAL(breath_gases[/datum/gas/carbon_dioxide][MOLES], expected_co2, "[test_lungs.type]/check_breath() should convert Nitrogen into an equivalent volume of CO2.")
	if(min_co2)
		TEST_ASSERT_EQUAL(breath_gases[/datum/gas/oxygen][MOLES], expected_oxygen, "[test_lungs.type]/check_breath() should convert CO2 into an equivalent volume of Oxygen.")
	if(min_plasma)
		TEST_ASSERT_EQUAL(breath_gases[/datum/gas/carbon_dioxide][MOLES], expected_co2, "[test_lungs.type]/check_breath() should convert Plasma into an equivalent volume of CO2.")

/// Tests minimum gas alerts by comparing gas pressure.
/datum/unit_test/proc/lungs_test_alert_min(mob/living/carbon/human/lab_rat, obj/item/organ/internal/lungs/test_lungs, alert_name, min_pressure, pressure)
	var/alert_thrown = lab_rat.has_alert(alert_name)
	var/pressure_safe = (pressure >= min_pressure) || (min_pressure == 0)
	TEST_ASSERT(!pressure_safe && alert_thrown || pressure_safe, TEST_ALERT_THROW_MESSAGE(test_lungs, alert_name))
	TEST_ASSERT(pressure_safe && !alert_thrown || !pressure_safe, TEST_ALERT_INHIBIT_MESSAGE(test_lungs, alert_name))

/// Tests maximum gas alerts by comparing gas pressure.
/datum/unit_test/proc/lungs_test_alert_max(mob/living/carbon/human/lab_rat, obj/item/organ/internal/lungs/test_lungs, alert_name, max_pressure, pressure)
	var/alert_thrown = lab_rat.has_alert(alert_name)
	var/pressure_safe = (pressure <= max_pressure) || (max_pressure == 0)
	TEST_ASSERT(!pressure_safe && alert_thrown || pressure_safe, TEST_ALERT_THROW_MESSAGE(test_lungs, alert_name))
	TEST_ASSERT(pressure_safe && !alert_thrown || !pressure_safe, TEST_ALERT_INHIBIT_MESSAGE(test_lungs, alert_name))

/// Set up a 2500-Litre gas mixture with the given gases and percentages.
/datum/unit_test/proc/create_gas_mix(list/gas_to_percent)
	var/datum/gas_mixture/test_mix = allocate(/datum/gas_mixture, 2500)
	test_mix.temperature = T20C
	for(var/datum/gas/gas_type as anything in gas_to_percent)
		test_mix.add_gas(gas_type)
		test_mix.gases[gas_type][MOLES] = (ONE_ATMOSPHERE * 2500 / (R_IDEAL_GAS_EQUATION * T20C) * gas_to_percent[gas_type])
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

/// Set up an Lavaland gas mix which is "ideal" for Ashwalker life.
/datum/unit_test/proc/create_lavaland_mix()
	var/datum/gas_mixture/immutable/planetary/lavaland_mix = SSair.planetary[LAVALAND_DEFAULT_ATMOS]
	var/datum/gas_mixture/test_mix = allocate(/datum/gas_mixture, 2500)
	test_mix.copy_from(lavaland_mix)
	return test_mix

#undef TEST_ALERT_THROW_MESSAGE
#undef TEST_ALERT_INHIBIT_MESSAGE
