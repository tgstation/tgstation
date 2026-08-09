/// Tests that replacing tiling using a crowbar or screwdriver in the offhand works properly
/datum/unit_test/tile_replacement
	var/old_turf_type
	var/turf/target_turf

/datum/unit_test/tile_replacement/Run()
	var/mob/living/carbon/human/consistent/interior_designer = EASY_ALLOCATE()
	var/obj/item/crowbar/ripper = EASY_ALLOCATE()
	var/obj/item/screwdriver/screwer = EASY_ALLOCATE()
	var/obj/item/stack/tile/iron/first_tile = EASY_ALLOCATE(1)
	var/obj/item/stack/tile/wood/wooden_replacement = EASY_ALLOCATE(1)

	target_turf = get_step(run_loc_floor_bottom_left, EAST)
	old_turf_type = target_turf.type
	target_turf.ChangeTurf(/turf/open/floor/plating)

	interior_designer.put_in_inactive_hand(ripper)
	interior_designer.put_in_active_hand(first_tile)

	click_wrapper(interior_designer, target_turf)
	TEST_ASSERT(istype(target_turf, /turf/open/floor/iron), "Clicking a plating with a floor tile did not place plating")
	TEST_ASSERT(QDELETED(first_tile), "Placing floor tiling did not consume the tile")

	interior_designer.put_in_active_hand(wooden_replacement)
	click_wrapper(interior_designer, target_turf)
	TEST_ASSERT(istype(target_turf, /turf/open/floor/wood), "Clicking floor tiling with a wood tile and a crowbar in the off-hand did not replace the tile")
	TEST_ASSERT(QDELETED(wooden_replacement), "Replacing floor tiling with wooden tiling did not consume the tile")

	interior_designer.drop_all_held_items()
	interior_designer.put_in_inactive_hand(screwer)
	first_tile = locate(/obj/item/stack/tile/iron) in target_turf
	TEST_ASSERT_NOTNULL(first_tile, "Replacing a floor tile with a wooden one did not drop the normal tile")

	interior_designer.put_in_active_hand(first_tile)
	click_wrapper(interior_designer, target_turf)
	TEST_ASSERT(istype(target_turf, /turf/open/floor/iron), "Failed to replace wooden floor tiling using a screwdriver")
	TEST_ASSERT_NOTNULL(locate(/obj/item/stack/tile/wood) in target_turf, "Replacing wooden floor tiling using a screwdriver did not drop the tile")

/datum/unit_test/tile_replacement/Destroy()
	target_turf.ChangeTurf(old_turf_type)
	return ..()
