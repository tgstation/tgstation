/// Tests to ensure that the the ability for a human to pick up and hold their pet works as intended. It's a complex process with a lot of moving parts and checks, but we just wanna test the known case to prevent regression.
/// We start at the mousedrop phase instead of calling the working procs directly as that step is likely to have the most aberrant failure conditions due to how many things start listening at the mousedrop phase.
/datum/unit_test/pick_up_and_hold_pet

/datum/unit_test/pick_up_and_hold_pet/Run()
	var/mob/living/carbon/human/consistent/dummy = EASY_ALLOCATE()
	var/mob/living/basic/pet/dog/corgi/ian/instant_pickup/pet = EASY_ALLOCATE()

	pet.ai_controller.set_ai_status(AI_STATUS_OFF) // quick lobotomy to prevent the pet from scampering and ruining adjacency checks

	dummy.start_pulling(pet)
	dummy.setGrabState(GRAB_AGGRESSIVE)

	pet.MouseDrop(dummy)

	var/pet_loc = pet.loc
	TEST_ASSERT_EQUAL(pet_loc, dummy, "Pet was not picked up into the human after mousedrop! (pet's loc is [pet_loc] instead of [dummy])")


/// Subtype of Ian deliberately used in order to get instant pickup to avoid the sleep timer and slow down the whole unit test run
/mob/living/basic/pet/dog/corgi/ian/instant_pickup

/mob/living/basic/pet/dog/corgi/ian/instant_pickup/mob_try_pickup(mob/living/user, instant)
	return ..(user, TRUE)


