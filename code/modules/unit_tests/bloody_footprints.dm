///Tests to make sure bloody footprits work as expected
///So no stacking, they actually apply, and shoe staining thrown in for free
/datum/unit_test/bloody_footprints

/datum/unit_test/bloody_footprints/Run()
	var/mob/living/carbon/human/blood_master = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/shoes/holds_blood = allocate(/obj/item/clothing/shoes)

	blood_master.equip_to_slot_if_possible(holds_blood, ITEM_SLOT_FEET)

	var/turf/open/move_to = get_step(blood_master, get_dir(blood_master, run_loc_floor_top_right))
	//We need to not be "on" the same tile as the pool
	blood_master.forceMove(move_to)

	var/obj/effect/decal/cleanable/blood/pool = allocate(/obj/effect/decal/cleanable/blood)

	//Max out the pools blood, so each step will make things stained enough to matter
	pool.bloodiness = BLOOD_POOL_MAX

	pool.forceMove(run_loc_floor_bottom_left)
	blood_master.forceMove(run_loc_floor_bottom_left)

	var/datum/component/bloodysoles/soles = holds_blood.GetComponent(/datum/component/bloodysoles)
	var/blood_type = pool.blood_state

	TEST_ASSERT(soles.bloody_shoes[blood_type], "Shoes didn't become stained after stepping in a pool of [blood_type]")

	//We need to do this so the component will even attempt to apply a footprint overlay, please kill me slowly
	soles.last_pickup -= 1

	//Move off the bloody tile, time to do some testing
	blood_master.forceMove(move_to)

	soles.last_pickup -= 1
	blood_master.forceMove(run_loc_floor_bottom_left)

	var/footprint_total = 0
	for(var/obj/effect/decal/cleanable/blood/footprints/print_set in move_to)
		if(print_set.blood_state == blood_type)
			footprint_total += 1

	TEST_ASSERT(footprint_total, "The floor didn't get covered in [blood_type] after being walked over")

	soles.last_pickup -= 1

	//Another set of movements to try and make some doubled up prints
	blood_master.forceMove(move_to)

	soles.last_pickup -= 1
	blood_master.forceMove(run_loc_floor_bottom_left)

	footprint_total = 0
	for(var/obj/effect/decal/cleanable/blood/footprints/print_set in move_to)
		if(print_set.blood_state == blood_type)
			footprint_total += 1

	TEST_ASSERT(footprint_total, "The floor somehow lost its footprints after being walked over")
	TEST_ASSERT(footprint_total == 1, "The floor had more then one set of footprints in it ([footprint_total]), something is fucked")
