/// Tests to make sure door access works correctly.
/datum/unit_test/door_access_check

/datum/unit_test/door_access_check/Run()
	var/mob/living/carbon/human/subject = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/obj/machinery/door/airlock/instant/door = allocate(/obj/machinery/door/airlock/instant, run_loc_floor_bottom_left, EAST) //special subtype that just flips the density var on open() and close(), akin to a real airlock.
	door.interaction_flags_machine |= INTERACT_MACHINE_OFFLINE

	// First, test that someone without any access can open a door that doesn't have any access requirements. Let's test it via using the bumpopen() proc, called when someone bumps into the door.
	subject.Bump(door)
	TEST_ASSERT_EQUAL(door.density, FALSE, "Subject failed to open access-free airlock!")
	door.close() // close it here as well
	subject.last_bumped = 0

	// Alright, now let's test that someone with access can open a door that requires access when only req_access is set.
	subject.equipOutfit(/datum/outfit/job/assistant/consistent) // set up the outfit here to ensure the last check is pure.
	var/obj/item/card/id/advanced/keycard = subject.wear_id

	// Test two accesses at once just to make sure the script hasn't changed on us.
	keycard.access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)
	door.req_access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)
	subject.Bump(door)
	TEST_ASSERT_EQUAL(door.density, FALSE, "Subject with valid access failed to open airlock access-locked behind req_access!")
	door.close()
	subject.last_bumped = 0

	// Okay, now let's edit the req_access on the door to make sure the subject can't open it with the requirements of req_access (must have all accesses required on keycard to open door).
	door.req_access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS, ACCESS_CARGO)
	subject.Bump(door)
	TEST_ASSERT_EQUAL(door.density, TRUE, "Subject with invalid access succeeded in opening airlock access-locked behind req_access!")
	door.close() // included for completeness, will early return if the door is already closed.
	subject.last_bumped = 0

	// Alright, now to test req_one_access. The two systems should be mutually exclusive, so we'll reset the access on the keycard and the door before we continue..
	door.req_access = null
	door.req_one_access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)
	keycard.access = list(ACCESS_MAINT_TUNNELS)
	subject.Bump(door)
	TEST_ASSERT_EQUAL(door.density, FALSE, "Subject with valid access failed to open airlock access-locked behind req_one_access!")
	door.close()
	subject.last_bumped = 0

	// Now, let's test req_one_access with an invalid access. The keycard is still on ACCESS_MAINT_TUNNELS from last step.
	door.req_one_access = list(ACCESS_ENGINEERING, ACCESS_CARGO)
	subject.Bump(door)
	TEST_ASSERT_EQUAL(door.density, TRUE, "Subject with invalid access succeeded in opening airlock access-locked behind req_one_access!")

/// Tests that the AI can open doors
/datum/unit_test/door_access_ai

/datum/unit_test/door_access_ai/Run()
	var/mob/dead/observer/fake_ghost = allocate(__IMPLIED_TYPE__) // ai must be passed a mob in /new, cringe
	var/mob/living/silicon/ai/subject = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right, null, fake_ghost)
	var/obj/machinery/door/airlock/instant/door = allocate(__IMPLIED_TYPE__)
	door.interaction_flags_machine |= INTERACT_MACHINE_OFFLINE

	door.AIShiftClick(subject)
	TEST_ASSERT_EQUAL(door.density, FALSE, "AI failed to open access-free airlock!")

/// Tests that the AI can open windoors
/datum/unit_test/windoor_access_ai

/datum/unit_test/windoor_access_ai/Run()
	var/mob/dead/observer/fake_ghost = allocate(__IMPLIED_TYPE__) // ai must be passed a mob in /new, cringe
	var/mob/living/silicon/ai/subject = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right, null, fake_ghost)
	var/obj/machinery/door/window/instant/door = allocate(__IMPLIED_TYPE__)
	door.interaction_flags_machine |= INTERACT_MACHINE_OFFLINE

	door.attack_ai(subject)
	TEST_ASSERT_EQUAL(door.density, FALSE, "AI failed to open access-free window door!")

/// Tests that telekinesis can open airlocks without access set (and cannot open airlocks that have an access set)
/datum/unit_test/door_access_telekinesis

/datum/unit_test/door_access_telekinesis/Run()
	var/mob/living/carbon/human/consistent/subject = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	var/obj/machinery/door/airlock/instant/door = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)
	door.interaction_flags_machine |= INTERACT_MACHINE_OFFLINE
	subject.dna.add_mutation(/datum/mutation/telekinesis, list(INNATE_TRAIT))
	subject.equipOutfit(/datum/outfit/job/assistant/consistent)

	var/obj/item/card/id/advanced/keycard = subject.wear_id
	keycard.access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)

	// Test TK on an access-free airlock
	door.attack_tk(subject)
	TEST_ASSERT_EQUAL(door.density, FALSE, "Subject with telekinesis failed to open access-free airlock at range!")
	door.close()

	// Test TK on an access-locked airlock while having valid access - this should fail
	door.req_access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)
	door.attack_tk(subject)
	TEST_ASSERT_EQUAL(door.density, TRUE, "Subject with telekinesis managed to open access-locked airlock at range (with access)!")

	// Test TK on an access-locked airlock without having valid access - this should also fail
	keycard.access = list()
	door.attack_tk(subject)
	TEST_ASSERT_EQUAL(door.density, TRUE, "Subject with telekinesis managed to open access-locked airlock at range (with no access)!")

/// Tests that mechas can bump open airlocks
/datum/unit_test/door_access_mecha

/datum/unit_test/door_access_mecha/Run()
	var/obj/vehicle/sealed/mecha/ripley/subject_mech = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/subject_pilot = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	var/obj/machinery/door/airlock/instant/door = allocate(__IMPLIED_TYPE__)
	door.interaction_flags_machine |= INTERACT_MACHINE_OFFLINE
	subject_pilot.equipOutfit(/datum/outfit/job/assistant/consistent)
	subject_mech.accesses = list()
	subject_mech.mob_enter(subject_pilot)

	var/obj/item/card/id/advanced/keycard = subject_pilot.wear_id
	keycard.access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)

	// Test bumping an access-free airlock - this should open
	subject_mech.Bump(door)
	TEST_ASSERT_EQUAL(door.density, FALSE, "Mecha failed to open access-free airlock!")
	door.close()

	// Setting an access on the door, this should open
	door.req_access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)
	subject_mech.Bump(door)
	TEST_ASSERT_EQUAL(door.density, FALSE, "Mecha failed to open access-locked airlock with valid access!")
	door.close()

	// Now setting a different access on the door, this should not open
	door.req_access = list(ACCESS_CARGO)
	subject_mech.Bump(door)
	TEST_ASSERT_EQUAL(door.density, TRUE, "Mecha opened access-locked airlock with invalid access!")

/// Checks that hands_blocked mobs cannot open doors unless it's an access-free door.
/datum/unit_test/door_access_handcuffs

/datum/unit_test/door_access_handcuffs/Run()
	var/mob/living/carbon/human/subject = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)
	var/obj/machinery/door/airlock/instant/door = allocate(__IMPLIED_TYPE__)
	door.interaction_flags_machine |= INTERACT_MACHINE_OFFLINE
	subject.equipOutfit(/datum/outfit/job/assistant/consistent)
	ADD_TRAIT(subject, TRAIT_HANDS_BLOCKED, INNATE_TRAIT)

	var/obj/item/card/id/advanced/keycard = subject.wear_id
	keycard.access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)

	// Test that you can bump open an access-free airlock with hands blocked.
	subject.Bump(door)
	TEST_ASSERT_EQUAL(door.density, FALSE, "Subject failed to bump open access-free airlock while hands blocked!")
	door.close()
	subject.last_bumped = 0

	// Attack handing should fail though - because unarmed attack fails while hands are blocked.
	subject.UnarmedAttack(door)
	TEST_ASSERT_EQUAL(door.density, TRUE, "Subject opened attack-handed open access-free airlock while hands blocked!")
	door.close()

	// Now adding an access, this should not open even though we have access.
	door.req_access = list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS)
	subject.Bump(door)
	TEST_ASSERT_EQUAL(door.density, TRUE, "Subject opened access-locked airlock while hands blocked!")
