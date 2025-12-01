/datum/unit_test/movement_order_sanity/Run()
	var/obj/movement_tester/test_obj = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)
	var/list/movement_cache = test_obj.movement_order

	var/obj/movement_interceptor/interceptor = allocate(__IMPLIED_TYPE__)
	interceptor.forceMove(locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	var/did_move = step(test_obj, EAST)

	TEST_ASSERT(did_move, "Object did not move at all.")
	TEST_ASSERT(QDELETED(test_obj), "Object was not qdeleted.")
	TEST_ASSERT(length(movement_cache) == 4, "Movement order length was not the expected value of 4, got: [length(movement_cache)].\nMovement Log\n[jointext(movement_cache, "\n")]")

	// Due to when the logging takes place, it will always be Move Move > Moved Moved instead of the reality of
	// Move > Moved > Move > Moved
	TEST_ASSERT(findtext(movement_cache[1], "Moving from"),"Movement step 1 was not a Move attempt.\nMovement Log\n[jointext(movement_cache, "\n")]")
	TEST_ASSERT(findtext(movement_cache[2], "Moving from"),"Movement step 2 was not a Move attempt.\nMovement Log\n[jointext(movement_cache, "\n")]")
	TEST_ASSERT(findtext(movement_cache[3], "Moved from"),"Movement step 3 was not a Moved() call.\nMovement Log\n[jointext(movement_cache, "\n")]")
	TEST_ASSERT(findtext(movement_cache[4], "Moved from"),"Movement step 4 was not a Moved() call.\nMovement Log\n[jointext(movement_cache, "\n")]")

/obj/movement_tester
	name = "movement debugger"
	var/list/movement_order = list()

/obj/movement_tester/Move(atom/newloc, direct, glide_size_override, z_movement_flags)
	movement_order += "Moving from ([loc.x], [loc.y]) to [newloc ? "([newloc.x], [newloc.y])" : "NULL"]"
	return ..()

/obj/movement_tester/doMove(atom/destination)
	movement_order += "Abstractly Moving from ([loc.x], [loc.y]) to [destination ? "([destination.x], [destination.y])" : "NULL"]"
	return ..()

/obj/movement_tester/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	movement_order += "Moved from ([old_loc.x], [old_loc.y]) to [loc ? "([loc.x], [loc.y])" : "NULL"]"
	return ..()

/obj/movement_interceptor
	name = "movement interceptor"

/obj/movement_interceptor/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/connect_loc, list(COMSIG_ATOM_ENTERED = PROC_REF(on_crossed)))

/obj/movement_interceptor/proc/on_crossed(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(src == arrived)
		return

	qdel(arrived)
