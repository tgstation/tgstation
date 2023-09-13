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

/// Tests unarmed clicking a cyborg doesn't cause damage
/datum/unit_test/silicon_punch

/datum/unit_test/silicon_punch/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/silicon/robot/borgo = allocate(/mob/living/silicon/robot)
	borgo.forceMove(locate(attacker.x + 1, attacker.y, attacker.z))
	attacker.set_combat_mode(TRUE)
	click_wrapper(attacker, borgo)
	TEST_ASSERT_EQUAL(borgo.getBruteLoss(), 0, "Cyborg took damage from an unarmed punched - \
		their unarmed damage threshold should be too high for this to happen.")

/// Tests flashing silicons causing blind and stun
/datum/unit_test/silicon_stun

/datum/unit_test/silicon_stun/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/silicon/robot/borgo = allocate(/mob/living/silicon/robot)
	var/obj/item/assembly/flash/handheld/flash = allocate(/obj/item/assembly/flash/handheld)
	attacker.put_in_active_hand(flash, forced = TRUE)

	click_wrapper(attacker, borgo)
	TEST_ASSERT(borgo.is_blind(), "Robot was not blinded when flashed.")
	TEST_ASSERT(!borgo.IsStun(), "Robot was stunned when flashed, which it shouldn't have happened on first flash.")
	click_wrapper(attacker, borgo)
	TEST_ASSERT(borgo.IsStun(), "Robot was not stunned when flashed, which should have happened on second flash.")
