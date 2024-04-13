/// Tests that no runtimes are thrown when a mob is on fire
/datum/unit_test/burning

/datum/unit_test/burning/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/initial_temp = dummy.bodytemperature
	// Light this baby up
	dummy.set_fire_stacks(20)
	dummy.ignite_mob()
	TEST_ASSERT(dummy.on_fire, "Dummy is not on fire despite having 20 fire stacks and being ignited.")
	// Manually tick it a few times
	var/datum/status_effect/fire_handler/fire_stacks/handler = locate() in dummy.status_effects
	for(var/i in 1 to 5)
		handler.tick_interval = world.time - 1
		handler.process()
	TEST_ASSERT(dummy.fire_stacks < 20, "Dummy should have decayed firestacks, but did not. (Dummy stacks: [dummy.fire_stacks]).")
	TEST_ASSERT(dummy.bodytemperature > initial_temp, "Dummy did not heat up despite being on fire. (Dummy temp: [dummy.bodytemperature], initial temp: [initial_temp])")
