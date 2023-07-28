/// Tests that guns (bayonetted or otherwise) are able to be used as melee weapons in close range
/datum/unit_test/pistol_whip

/datum/unit_test/pistol_whip/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)

	victim.forceMove(locate(attacker.x + 1, attacker.y, attacker.z))

	// These assertions are just here because I don't understand gun code
	TEST_ASSERT(gun.chambered, "Gun spawned without a chambered round.")
	TEST_ASSERT_EQUAL(gun.magazine.ammo_count(), gun.magazine.max_ammo, "Gun spawned without a full magazine, \
		when it should spawn with mag size + 1 (chambered) rounds.")

	// Combat mode in melee range -> pistol whip
	attacker.set_combat_mode(TRUE)
	click_wrapper(attacker, victim)
	TEST_ASSERT_EQUAL(gun.magazine.ammo_count(), gun.magazine.max_ammo, "The gun fired a shot when it was used for a pistol whip.")
	TEST_ASSERT_NOTEQUAL(victim.getBruteLoss(), 0, "Victim did not take brute damage from being pistol-whipped.")
	attacker.fully_heal()

	// No combat mode -> point blank shot
	attacker.set_combat_mode(FALSE)
	click_wrapper(attacker, victim)
	TEST_ASSERT_EQUAL(gun.magazine.ammo_count(), gun.magazine.max_ammo - 1, "The gun did not fire a shot when it was used for a point-blank shot.")
	TEST_ASSERT_NOTEQUAL(victim.getBruteLoss(), 0, "Victim did not take brute damage from being fired upon point-blank.")
