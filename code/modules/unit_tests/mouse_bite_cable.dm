/// Unit Test to ensure that a mouse bites a cable, gets shocked, and dies.
/datum/unit_test/mouse_bite_cable

/datum/unit_test/mouse_bite_cable/Run()
	// use dummy subtype that will bypass the probability check to bite on a cable
	var/mob/living/basic/mouse/biter = allocate(/mob/living/basic/mouse/cable_lover)
	var/obj/structure/cable/wire = allocate(/obj/structure/cable)
	// Make sure the cable has a powernet.
	wire.powernet = new()
	// Make sure the powernet has a good amount of power!
	// mice bites check if there is ANY power in the powernet  and passes fine, but better safe than sorry
	wire.powernet.avail = 100000

	var/turf/open/floor/stage = get_turf(wire)
	// the unit tests room has normal flooring so let's just make it be interactable for the sake of this test
	stage.underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	// relocate the rat
	biter.forceMove(stage)

	// Ai controlling processes expect a seconds_per_tick, supply a real-fake dt
	var/fake_dt = SSai_controllers.wait * 0.1
	// Force this fker to be on
	biter.ai_controller.ai_traits |= CANNOT_GO_IDLE | CAN_RUN_WITHOUT_CLIENTS
	biter.ai_controller.set_ai_status(AI_STATUS_ON)

	// Mouse eating is chance-based, so we set the hunting target directly, yes, this messed with the test from what it was before, but I'm not sure how to do it better :(
	biter.ai_controller.set_blackboard_key(BB_LOW_PRIORITY_HUNTING_TARGET, wire)

	// Tick the tree until the hunt branch moves onto and bites the cable. Can we do this better in unit tests?? idk..
	for(var/i in 1 to 5)
		if(QDELETED(biter))
			break
		biter.ai_controller.SelectBehaviors(fake_dt)
		biter.ai_controller.process(fake_dt)

	// Now check that the bite went through - remember we qdel mice on death
	TEST_ASSERT(QDELETED(biter), "Mouse, did not die after biting a powered cable.")
	TEST_ASSERT(QDELETED(wire), "Cable, was not deleted after being bitten by a mouse.")

	// reset the floor to its original state, to be nice to other tests in case that matters
	stage.underfloor_accessibility = initial(stage.underfloor_accessibility)


/// Dummy mouse that is guaranteed to die when biting shocked cables.
/mob/living/basic/mouse/cable_lover
	cable_zap_prob = 100
