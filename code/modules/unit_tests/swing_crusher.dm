/// Tests that the Kinetic Crusher fires a projectile on RMB rather than swinging
/datum/unit_test/crusher_projectile

/datum/unit_test/crusher_projectile/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/kinetic_crusher/crusher = allocate(/obj/item/kinetic_crusher)

	attacker.put_in_active_hand(crusher, forced = TRUE)
	crusher.attack_self(attacker)

	click_wrapper(attacker, run_loc_floor_top_right, list2params(list(RIGHT_CLICK = TRUE, BUTTON = RIGHT_CLICK)))

	TEST_ASSERT(!crusher.charged, "Attacker failed to fire the kinetic crusher on right clicking a distant target")
