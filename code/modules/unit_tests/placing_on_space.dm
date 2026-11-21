/// Tests that lattices, catwalks, cabling, tiling, and RCD tiling can be successfully placed on space tiles
/datum/unit_test/placing_on_space
	var/old_turf_type
	var/turf/target_turf

/datum/unit_test/placing_on_space/Run()
	var/mob/living/carbon/human/consistent/engineer = EASY_ALLOCATE()
	var/obj/item/stack/rods/two/lattice_material = EASY_ALLOCATE()
	var/obj/item/stack/cable_coil/single_cable = EASY_ALLOCATE(1)
	var/obj/item/stack/tile/iron/single_tile = EASY_ALLOCATE(1)
	var/obj/item/construction/rcd/loaded/plating_placer = EASY_ALLOCATE()

	target_turf = get_step(run_loc_floor_bottom_left, EAST)
	old_turf_type = target_turf.type
	target_turf.ChangeTurf(/turf/open/space)

	engineer.put_in_active_hand(lattice_material)
	click_wrapper(engineer, target_turf)
	var/obj/structure/lattice/constructed_lattice = locate() in target_turf
	TEST_ASSERT_NOTNULL(constructed_lattice, "Failed to construct a lattice on a space tile using iron rods")

	click_wrapper(engineer, constructed_lattice)
	var/obj/structure/lattice/catwalk/constructed_catwalk = locate() in target_turf
	TEST_ASSERT_NOTNULL(constructed_catwalk, "Failed to construct a catwalk on a lattice on a space tile using iron rods")
	TEST_ASSERT(QDELETED(constructed_lattice), "Constructing a catwalk on a lattice did not delete the lattice")
	TEST_ASSERT(QDELETED(lattice_material), "Using two iron rods to construct a catwalk did not consume them both")

	engineer.put_in_active_hand(single_cable)
	click_wrapper(engineer, constructed_catwalk)
	TEST_ASSERT(locate(/obj/structure/cable) in target_turf, "Failed to place a cable on a catwalk in space")
	TEST_ASSERT(QDELETED(single_cable), "Using a piece of cable to place a cable did not consume it")

	engineer.put_in_active_hand(single_tile)
	click_wrapper(engineer, constructed_catwalk)
	TEST_ASSERT(istype(target_turf, /turf/open/floor/plating), "Failed to place plating on a catwalk in space via an iron tile")
	TEST_ASSERT(QDELETED(single_tile), "Placing plating on a catwalk in space did not delete the used floor tile")
	TEST_ASSERT(QDELETED(constructed_catwalk), "Placing plating on a catwalk in space did not delete the involved catwalk")

	engineer.put_in_active_hand(plating_placer)
	target_turf.ChangeTurf(/turf/open/space)
	click_wrapper(engineer, target_turf)
	TEST_ASSERT(istype(target_turf, /turf/open/floor/plating), "Failed to use an RCD to place plating on space")

/datum/unit_test/placing_on_space/Destroy()
	target_turf.ChangeTurf(old_turf_type)
	return ..()
