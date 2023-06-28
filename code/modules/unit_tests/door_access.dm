/// Tests to make sure door access works correctly.
/datum/unit_test/door_access_check

/datum/unit_test/door_access_check/Run()
	var/mob/living/carbon/human/subject = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/obj/machinery/door/airlock/instant/door = allocate(/obj/machinery/door/airlock/instant, run_loc_floor_bottom_left, EAST) //special subtype that just flips the density var on open() and close(), akin to a real airlock.

	// First, test that someone without any access can open a door that doesn't have any access requirements. Let's test it via using the bumpopen() proc, called when someone bumps into the door.
	door.bumpopen(subject)
	TEST_ASSERT_EQUAL(door.density, FALSE, "Subject failed to open access-free airlock!")
	door.close() // close it here as well

	// Alright, now let's test that someone with access can open a door that requires access when only req_access is set.
	subject.equipOutfit(/datum/outfit/job/assistant/consistent) // set up the outfit here to ensure the last check is pure.
	var/obj/item/card/id/advanced/keycard = subject.wear_id

	// Test two accesses at once just to make sure the script hasn't changed on us.
	keycard.access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)
	door.req_access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)
	door.bumpopen(subject)
	TEST_ASSERT_EQUAL(door.density, FALSE, "Subject with valid access failed to open airlock access-locked behind req_access!")
	door.close()

	// Okay, now let's edit the req_access on the door to make sure the subject can't open it with the requirements of req_access (must have all accesses required on keycard to open door).
	door.req_access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS, ACCESS_CARGO)
	door.bumpopen(subject)
	TEST_ASSERT_EQUAL(door.density, TRUE, "Subject with invalid access succeeded in opening airlock access-locked behind req_access!")
	door.close() // included for completeness, will early return if the door is already closed.

	// Alright, now to test req_one_access. The two systems should be mutually exclusive, so we'll reset the access on the keycard and the door before we continue..
	door.req_access = null
	door.req_one_access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)
	keycard.access = list(ACCESS_MAINT_TUNNELS)
	door.bumpopen(subject)
	TEST_ASSERT_EQUAL(door.density, FALSE, "Subject with valid access failed to open airlock access-locked behind req_one_access!")
	door.close()

	// Now, let's test req_one_access with an invalid access. The keycard is still on ACCESS_MAINT_TUNNELS from last step.
	door.req_one_access = list(ACCESS_ENGINEERING, ACCESS_CARGO)
	door.bumpopen(subject)
	TEST_ASSERT_EQUAL(door.density, TRUE, "Subject with invalid access succeeded in opening airlock access-locked behind req_one_access!")
	door.close()
