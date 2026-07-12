/**
 * This unit test crates a boulder, spawns it, and then moves it through boulder processing to confirm that boulders can be processed without issue.
 */

/datum/unit_test/boulder_processing

/datum/unit_test/boulder_processing/Run()
	var/turf/refinery_loc = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/smelter_loc = get_step(refinery_loc, EAST)
	var/turf/opposite_loc = get_step(smelter_loc, EAST)
	var/obj/item/boulder/shabby/test_boulder = EASY_ALLOCATE() //Called because we know it has both iron and glass for each machine.
	var/obj/machinery/bouldertech/refinery/test_refine = allocate(/obj/machinery/bouldertech/refinery, refinery_loc)
	var/obj/machinery/bouldertech/refinery/smelter/test_smelter = allocate(/obj/machinery/bouldertech/refinery/smelter, smelter_loc)
	test_refine.dir = WEST
	test_smelter.dir = WEST
	//Test to confirm that the boulder is as we expect it to be:
	TEST_ASSERT(test_boulder.durability > 0,  "Boulder was spawned such that it's durability is less than 1!")
	test_boulder.durability = 2
	test_boulder.Move(get_turf(refinery_loc), EAST)
	TEST_ASSERT_EQUAL(test_boulder.loc, test_refine, "The boulder was not moved into the refinery's contents!")
	for(var/i in 1 to 2)
		test_refine.process()
	TEST_ASSERT_NOTEQUAL(test_boulder.loc, test_refine, "The boulder was not moved out of the refinery's contents!")
	TEST_ASSERT(!test_boulder.has_material_type(/datum/material/glass), "After the boulder was successfully processed by the refinery, no-ferrous materials still remain inside!")
	TEST_ASSERT(test_boulder.durability > 0,  "Boulder was processed successfully, but exited with durability under 1!")
	test_boulder.durability = 2
	test_boulder.Move(get_turf(smelter_loc), EAST)
	TEST_ASSERT_EQUAL(test_boulder.loc, test_smelter, "The boulder was not moved into the smelter's contents! We are at: [test_boulder.x], [test_boulder.y], and machine is at [test_smelter.x], [test_smelter.y] which is [test_smelter.loc]")
	for(var/i in 1 to 2)
		test_smelter.process()
	TEST_ASSERT(QDELETED(test_boulder),"After being processed by both a refinery and smelter, the boulder was not qdeleted!")
	/// Now we run it in reverse, using the opposite_loc to start with the smelter!
	// Manually reset cooldowns for accepting new boulders.
	COOLDOWN_RESET(test_refine, accept_cooldown)
	COOLDOWN_RESET(test_smelter, accept_cooldown)
		//Test to confirm that the boulder is as we expect it to be:
	var/obj/item/boulder/shabby/second_boulder = allocate(/obj/item/boulder/shabby, opposite_loc) //Called because we know it has both iron and glass for each machine.
	TEST_ASSERT(second_boulder.durability > 0,  "Boulder was spawned such that it's durability is less than 1!")
	second_boulder.durability = 2
	second_boulder.Move(get_turf(smelter_loc), WEST)
	TEST_ASSERT_EQUAL(second_boulder.loc, test_smelter, "The boulder was not moved into the smelter's contents! We are at: [second_boulder.x], [second_boulder.y], and machine is at [test_smelter.x], [test_smelter.y] which is [test_smelter.loc]")
	for(var/i in 1 to 2)
		test_smelter.process()
	TEST_ASSERT_NOTEQUAL(second_boulder.loc, test_smelter, "The boulder was not moved out of the smelter's contents!")
	TEST_ASSERT(!second_boulder.has_material_type(/datum/material/iron), "After the boulder was successfully processed by the smelter, ferrous materials still remain inside!")
	TEST_ASSERT(second_boulder.durability > 0, "Boulder was processed successfully, but exited with durability under 1!")
	second_boulder.durability = 2
	second_boulder.Move(get_turf(refinery_loc), WEST)
	TEST_ASSERT_EQUAL(second_boulder.loc, test_refine, "The boulder was not moved into the refinery's contents!")
	for(var/i in 1 to 2)
		test_refine.process()
	TEST_ASSERT(QDELETED(second_boulder), "After being processed by both a refinery and smelter, the boulder was not qdeleted!")
