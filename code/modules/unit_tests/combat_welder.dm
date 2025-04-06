/datum/unit_test/welder_combat

/datum/unit_test/welder_combat/Run()
	var/mob/living/carbon/human/consistent/tider = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/victim = EASY_ALLOCATE()
	var/obj/item/weldingtool/weapon = EASY_ALLOCATE()

	tider.put_in_active_hand(weapon, forced = TRUE)
	tider.set_combat_mode(TRUE)
	weapon.attack_self(tider)
	weapon.melee_attack_chain(tider, victim)

	TEST_ASSERT_NOTEQUAL(victim.getFireLoss(), 0, "Victim did not get burned by welder.")
	TEST_ASSERT_EQUAL(weapon.get_fuel(), weapon.max_fuel - 1, "Welder did not consume fuel on attacking a mob")

	var/obj/structure/blob/blobby = EASY_ALLOCATE()
	weapon.melee_attack_chain(tider, blobby)

	TEST_ASSERT_NOTEQUAL(blobby.get_integrity(), blobby.max_integrity, "Blob did not get burned by welder.")
	TEST_ASSERT_EQUAL(weapon.get_fuel(), weapon.max_fuel - 2, "Welder did not consume fuel on attacking a blob")

	weapon.force = 999
	weapon.melee_attack_chain(tider, blobby)

	TEST_ASSERT(QDELETED(blobby), "Blob was not destroyed by welder.")
	TEST_ASSERT_EQUAL(weapon.get_fuel(), weapon.max_fuel - 3, "Welder did not consume fuel on deleting a blob")
