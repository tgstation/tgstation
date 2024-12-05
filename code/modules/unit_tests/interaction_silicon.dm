/// Tests the ability to unlock and crowbar open a silicon
/datum/unit_test/silicon_interacting

/datum/unit_test/silicon_interacting/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/mob/living/silicon/robot/borgo = EASY_ALLOCATE()
	var/obj/item/card/id/advanced/gold/captains_spare/id = EASY_ALLOCATE()
	var/obj/item/crowbar/crowbar = EASY_ALLOCATE()
	// unlock
	attacker.put_in_active_hand(id, forced = TRUE)
	click_wrapper(attacker, borgo)
	TEST_ASSERT(!borgo.locked, "Robot was not unlocked when swiped with ID")
	// open
	id.forceMove(attacker.drop_location())
	attacker.put_in_active_hand(crowbar, forced = TRUE)
	click_wrapper(attacker, borgo)
	TEST_ASSERT(borgo.opened, "Robot was not opened when crowbarred")
	// close
	attacker.put_in_active_hand(crowbar, forced = TRUE)
	click_wrapper(attacker, borgo)
	TEST_ASSERT(!borgo.opened, "Robot was not closed when crowbarred")
	// lock
	crowbar.forceMove(attacker.drop_location())
	attacker.put_in_active_hand(id, forced = TRUE)
	click_wrapper(attacker, borgo)
	TEST_ASSERT(borgo.locked, "Robot was not re-locked when swiped with ID")

/// Tests unarmed clicking a cyborg doesn't cause damage
/datum/unit_test/silicon_punch

/datum/unit_test/silicon_punch/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/mob/living/silicon/robot/borgo = EASY_ALLOCATE()
	borgo.forceMove(locate(attacker.x + 1, attacker.y, attacker.z))
	attacker.set_combat_mode(TRUE)
	click_wrapper(attacker, borgo)
	TEST_ASSERT_EQUAL(borgo.getBruteLoss(), 0, "Cyborg took damage from an unarmed punched - \
		their unarmed damage threshold should be too high for this to happen.")
