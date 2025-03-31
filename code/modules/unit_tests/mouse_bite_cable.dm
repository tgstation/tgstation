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
	// Set AI - AIs by default are off in z-levels with no client, we have to force it on.
	biter.ai_controller.set_ai_status(AI_STATUS_ON)
	biter.ai_controller.can_idle = FALSE
	// Select behavior - this will queue finding the cable
	biter.ai_controller.SelectBehaviors(fake_dt)
	// Process behavior - this will execute the "locate the cable" behavior
	biter.ai_controller.process(fake_dt)
	// Check that the cable was found
	TEST_ASSERT(biter.ai_controller.blackboard[BB_LOW_PRIORITY_HUNTING_TARGET] == wire, "Mouse, after executing find, did not set the cable as a target.")
	// Select behavior - this will queue hunting
	biter.ai_controller.SelectBehaviors(fake_dt)
	// Process behavior - this will execute the hunt for the cable and cause a bite (as we're in the min range)
	biter.ai_controller.process(fake_dt)
	// Check that the cable was removed, as it was hunted correctly
	TEST_ASSERT_NULL(biter.ai_controller.blackboard[BB_LOW_PRIORITY_HUNTING_TARGET], "Mouse, after executing hunt, did not clear their target blackboard.")

	// Now check that the bite went through - remember we qdel mice on death
	TEST_ASSERT(QDELETED(biter), "Mouse, did not die after biting a powered cable.")
	TEST_ASSERT(QDELETED(wire), "Cable, was not deleted after being bitten by a mouse.")

	// reset the floor to its original state, to be nice to other tests in case that matters
	stage.underfloor_accessibility = initial(stage.underfloor_accessibility)


/// Dummy mouse that is guaranteed to die when biting shocked cables.
/mob/living/basic/mouse/cable_lover
	cable_zap_prob = 100
	ai_controller = /datum/ai_controller/basic_controller/mouse/guaranteed_to_bite

/// Dummy mouse's ai controller that is guaranteed to find and bite a cable beneath it
/datum/ai_controller/basic_controller/mouse/guaranteed_to_bite
	planning_subtrees = list(/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables/guaranteed)

/// Cable hunting subtree that's guarantee to hunt its target.
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables/guaranteed
	hunt_chance = 100
