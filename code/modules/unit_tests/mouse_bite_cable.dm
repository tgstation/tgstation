/// Unit Test to ensure that a mouse bites a cable, gets shocked, and dies.
/datum/unit_test/mouse_bite_cable

/datum/unit_test/mouse_bite_cable/Run()
	var/mob/living/simple_animal/mouse/biter = allocate(/mob/living/simple_animal/mouse/cable_lover) // use special subtype that will bypass the probability check to bite on a cable
	var/obj/structure/cable/wire = allocate(/obj/structure/cable)
	biter.chew_probability = 100 // Make sure the mouse bites the cable!
	wire.powernet = new /datum/powernet() // Make sure the cable has a powernet.
	wire.powernet.avail = 100000 // Make sure the powernet has a good amount of power! handle_automated_action checks to see if there is ANY power in the powernet and passes fine, but better safe than sorry in this instance.

	var/turf/open/floor/stage = get_turf(wire)
	stage.underfloor_accessibility = UNDERFLOOR_INTERACTABLE // the unit tests room has normal flooring so let's just make it be interactable for the sake of this test

	biter.forceMove(stage)
	biter.handle_automated_action() // it's not so automated since we're forcing it and doing everything we can to ensure that mice fucking bites that wire but potato potato

	TEST_ASSERT(QDELETED(biter), "Mouse did not die after biting a powered cable.") // we qdel the mouse mob on death
	TEST_ASSERT(QDELETED(wire), "Cable was not deleted after being bitten by a mouse.")

	stage.underfloor_accessibility = initial(stage.underfloor_accessibility) // reset the floor to its original state, to be nice to other tests in case that matters
