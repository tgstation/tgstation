///Tests whether the mech generator is loadable while empty, loadable while loaded, installable, runs successfully, shuts off successfully, and successfully charges the mech
/datum/unit_test/mech_generator

/datum/unit_test/mech_generator/Run()
	var/mob/living/carbon/human/consistent/robotocist = EASY_ALLOCATE()
	var/obj/vehicle/sealed/mecha/ripley/our_mech = EASY_ALLOCATE()
	var/obj/item/mecha_parts/mecha_equipment/generator/prefilled_generator = EASY_ALLOCATE()
	var/obj/item/mecha_parts/mecha_equipment/generator/printed/active_generator = EASY_ALLOCATE()
	var/obj/item/stack/sheet/mineral/plasma/fuel = EASY_ALLOCATE(1)

	prefilled_generator.max_fuel = 10 * SHEET_MATERIAL_AMOUNT
	active_generator.fuelrate_active = 2 * SHEET_MATERIAL_AMOUNT
	our_mech.cell.charge /= 2 // We're not being precise here, it doesn't matter
	var/starting_charge = our_mech.cell.charge

	robotocist.put_in_active_hand(fuel)
	click_wrapper(robotocist, prefilled_generator)
	TEST_ASSERT(!QDELETED(fuel), "Mech generator was filled while already at its maximum capacity")

	click_wrapper(robotocist, active_generator)
	TEST_ASSERT(QDELETED(fuel), "Mech generator was not able to be filled while empty")

	fuel = EASY_ALLOCATE(1)
	robotocist.put_in_active_hand(fuel)
	click_wrapper(robotocist, active_generator)
	TEST_ASSERT(QDELETED(fuel), "Mech generator was not able to be filled while partially full")

	robotocist.put_in_active_hand(active_generator)
	click_wrapper(robotocist, our_mech)
	TEST_ASSERT_EQUAL(active_generator.loc, our_mech, "Failed to place mech generator within mech")

	active_generator.active = TRUE
	active_generator.process(1)
	TEST_ASSERT(active_generator.active, "Mech generator shut down prematurely")
	TEST_ASSERT(our_mech.cell.charge > starting_charge, "Mech generator did not produce any power for its mech")
	TEST_ASSERT(!active_generator.fuel.amount, "Mech generator did not consume its fuel when activated")

	active_generator.process(1)
	TEST_ASSERT(!active_generator.active, "Mech generator did not shut down despite being out of fuel")
