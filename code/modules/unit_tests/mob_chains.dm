/// Checks if mobs who are linked together with the mob chain component react as expected
/datum/unit_test/mob_chains

/datum/unit_test/mob_chains/Run()
	var/mob/living/centipede_head = allocate(/mob/living/basic/pet/dog)
	var/list/segments = list(centipede_head)
	centipede_head.AddComponent(/datum/component/mob_chain)
	var/mob/living/centipede_tail = centipede_head
	for (var/i in 1 to 2)
		var/mob/living/new_segment = allocate(/mob/living/basic/pet/dog)
		new_segment.AddComponent(/datum/component/mob_chain, front = centipede_tail)
		segments += new_segment
		centipede_tail = new_segment

	var/test_damage = 15
	centipede_head.apply_damage(test_damage, BRUTE)
	TEST_ASSERT_EQUAL(centipede_head.bruteloss, 0, "Centipede head took damage which should have been passed to its tail.")
	TEST_ASSERT_EQUAL(centipede_tail.bruteloss, test_damage, "Centipede tail did not take damage which should have originated from its head.")

	var/expected_damage = 5
	for (var/mob/living/segment as anything in segments)
		segment.combat_mode = TRUE
		segment.melee_damage_lower = expected_damage
		segment.melee_damage_upper = expected_damage

	var/mob/living/victim = allocate(/mob/living/basic/pet/dog)
	centipede_head.ClickOn(victim)
	TEST_ASSERT_EQUAL(victim.bruteloss, expected_damage * 3, "Centipede failed to do damage with all of its segments.")

	centipede_head.death()
	TEST_ASSERT_EQUAL(centipede_tail.stat, DEAD, "Centipede tail failed to die with head.")
