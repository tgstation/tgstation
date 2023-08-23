/// Tests the ability to unlock and crowbar open a silicon
/datum/unit_test/silicon_interacting

/datum/unit_test/silicon_interacting/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/silicon/robot/borgo = allocate(/mob/living/silicon/robot)
	var/obj/item/card/id/advanced/gold/captains_spare/id = allocate(/obj/item/card/id/advanced/gold/captains_spare)
	var/obj/item/crowbar/crowbar = allocate(/obj/item/crowbar)
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
