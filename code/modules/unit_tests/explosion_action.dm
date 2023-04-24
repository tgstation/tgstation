/// Tests the EX_ACT macro on several different types of atoms to ensure that it still works as expected.
/datum/unit_test/explosion_action
	/// rolling var for how much brute damage the alien has taken.
	var/alien_brute_loss = 0
	/// rolling var for how much burn damage the alien has taken.
	var/alien_burn_loss = 0
	/// aliens get a bit of damage done to their ears when exploded, so check that too.
	var/alien_ear_damage = 0

/datum/unit_test/explosion_action/Run()
	// Throughout this test, we use the "abstract" type of a `/mob/living` to ensure that the raw framework will still work and remain hardy against any `ex_act()` overrides
	// that may be done on the subtype-to-subtype basis. Any time we use an explicit subtype is to test that framework, so if you update that for some reason, you should also update this test.
	// Like, if you balance aliens to take more ear damage and this test fails, just update the test to reflect that. That's it.

	// You may delete this entire section of the test when the entire `simple_animal` framework needs to be scrapped.
	var/mob/living/simple_animal/test_simple_animal = allocate(/mob/living/simple_animal)
	test_simple_animal.maxHealth = MAX_LIVING_HEALTH
	test_simple_animal.health = MAX_LIVING_HEALTH

	EX_ACT(test_simple_animal, EXPLODE_NONE) // should do nothing.
	TEST_ASSERT_EQUAL(test_simple_animal.health, MAX_LIVING_HEALTH, "EX_ACT() with EXPLODE_NONE severity should not affect the health of a simple animal! Something has gone terribly wrong!")

	EX_ACT(test_simple_animal, EXPLODE_LIGHT) // should do 30 damage.
	TEST_ASSERT_EQUAL(test_simple_animal.health, MAX_LIVING_HEALTH - 30, "EX_ACT() with EXPLODE_LIGHT severity should have done 30 damage to a simple animal!")
	test_simple_animal.revive(ADMIN_HEAL_ALL)

	EX_ACT(test_simple_animal, EXPLODE_HEAVY) // should do 60 damage.
	TEST_ASSERT_EQUAL(test_simple_animal.health, MAX_LIVING_HEALTH - 60, "EX_ACT() with EXPLODE_HEAVY severity should have done 60 damage to a simple animal!")
	test_simple_animal.revive(ADMIN_HEAL_ALL)

	EX_ACT(test_simple_animal, EXPLODE_DEVASTATE) // this should gib.
	TEST_ASSERT(QDELETED(test_simple_animal), "EX_ACT() with EXPLODE_DEVASTATE severity should have gibbed a simple animal!")

	// Now let's be safe and check basic mobs (they're the future, man)
	var/mob/living/basic/test_basic_animal = allocate(/mob/living/basic)
	test_basic_animal.maxHealth = MAX_LIVING_HEALTH
	test_basic_animal.health = MAX_LIVING_HEALTH

	EX_ACT(test_basic_animal, EXPLODE_NONE) // should do nothing.
	TEST_ASSERT_EQUAL(test_basic_animal.health, MAX_LIVING_HEALTH, "EX_ACT() with EXPLODE_NONE severity should not affect the health of a basic animal! Something has gone terribly wrong!")

	EX_ACT(test_basic_animal, EXPLODE_LIGHT) // should do 30 damage.
	TEST_ASSERT_EQUAL(test_basic_animal.health, MAX_LIVING_HEALTH - 30, "EX_ACT() with EXPLODE_LIGHT severity should have done 30 damage to a basic animal!")
	test_basic_animal.revive(ADMIN_HEAL_ALL) // reset the health to keep things consistent

	EX_ACT(test_basic_animal, EXPLODE_HEAVY) // should do 60 damage.
	TEST_ASSERT_EQUAL(test_basic_animal.health, MAX_LIVING_HEALTH - 60, "EX_ACT() with EXPLODE_HEAVY severity should have done 60 damage to a basic animal!")
	test_basic_animal.revive(ADMIN_HEAL_ALL)

	EX_ACT(test_basic_animal, EXPLODE_DEVASTATE) // this should gib.
	TEST_ASSERT(QDELETED(test_basic_animal), "EX_ACT() with EXPLODE_DEVASTATE severity should have gibbed a basic animal!")

	// Aliens have their own implementation too.
	var/mob/living/carbon/alien/test_alien = allocate(/mob/living/carbon/alien)
	test_alien.maxHealth = MAX_LIVING_HEALTH
	test_alien.health = MAX_LIVING_HEALTH

	EX_ACT(test_alien, EXPLODE_NONE) // should do nothing.
	get_alien_damages(test_alien)
	TEST_ASSERT_EQUAL(alien_brute_loss, 0, "EX_ACT() with EXPLODE_NONE severity should not affect the brute loss of an alien! Something has gone terribly wrong!")
	TEST_ASSERT_EQUAL(alien_burn_loss, 0, "EX_ACT() with EXPLODE_NONE severity should not affect the burn loss of an alien! Something has gone terribly wrong!")
	TEST_ASSERT_EQUAL(alien_ear_damage, 0, "EX_ACT() with EXPLODE_NONE severity should not affect the ear damage of an alien! Something has gone terribly wrong!")

	EX_ACT(test_alien, EXPLODE_LIGHT) // should do 30 brute overall and 15 organ damage to the ears.
	get_alien_damages(test_alien)
	TEST_ASSERT_EQUAL(alien_brute_loss, 30, "EX_ACT() with EXPLODE_LIGHT severity should have done 30 brute damage to an alien!")
	TEST_ASSERT_EQUAL(alien_burn_loss, 0, "EX_ACT() with EXPLODE_LIGHT severity should not affect the burn loss of an alien!")
	TEST_ASSERT_EQUAL(alien_ear_damage, 15, "EX_ACT() with EXPLODE_LIGHT severity should have done 15 ear damage to an alien!")
	test_alien.revive(ADMIN_HEAL_ALL)

	EX_ACT(test_alien, EXPLODE_HEAVY) // should do 60 brute, 60 burn, and 30 organ damage to the ears.
	get_alien_damages(test_alien)
	TEST_ASSERT_EQUAL(alien_brute_loss, 60, "EX_ACT() with EXPLODE_HEAVY severity should have done 60 brute damage to an alien!")
	TEST_ASSERT_EQUAL(alien_burn_loss, 60, "EX_ACT() with EXPLODE_HEAVY severity should have done 60 burn damage to an alien!")
	TEST_ASSERT_EQUAL(alien_ear_damage, 30, "EX_ACT() with EXPLODE_HEAVY severity should have done 30 ear damage to an alien!")

	// Let's check to make sure the armor system works as expected. Corgi dogs are the only one that have this implemented on the basic level, so let's use that.
	var/mob/living/basic/pet/dog/corgi/test_dog = set_up_test_dog()

	// those two items should give us a 100% armor rating, so let's test that to make sure it works (all ex_act checks should now be prob(100)), no room for error.
	EX_ACT(test_dog, EXPLODE_LIGHT) // should do 20 damage (basic animals do a prob() check based on the armor rating, and divide the expected brute loss by 1.5).
	TEST_ASSERT_EQUAL(test_dog.health, MAX_LIVING_HEALTH - 20, "EX_ACT() with EXPLODE_LIGHT severity should have done 20 damage to a corgi with an immune helmet and vest!")
	test_dog.revive(ADMIN_HEAL_ALL)

	EX_ACT(test_dog, EXPLODE_HEAVY) // should do 40 damage.
	TEST_ASSERT_EQUAL(test_dog.health, MAX_LIVING_HEALTH - 40, "EX_ACT() with EXPLODE_HEAVY severity should have done 40 damage to a corgi with an immune helmet and vest!")
	test_dog.revive(ADMIN_HEAL_ALL)

	EX_ACT(test_dog, EXPLODE_DEVASTATE) // this should NOT gib, but should do 500 damage. 500 is a lot but we don't really need to test that exact number here to be honest
	TEST_ASSERT(!QDELETED(test_dog), "EX_ACT() with EXPLODE_DEVASTATE severity should NOT have gibbed a corgi with an immune helmet and vest!")
	TEST_ASSERT_EQUAL(test_dog.stat, DEAD, "EX_ACT() with EXPLODE_DEVASTATE severity should have killed a corgi with an immune helmet and vest!")

	// Humans have a lot of prob() checks and stuff (e.g. delimbing) and it's really complicated, so let's just test the basic stuff here. if you want to test this further should really go into its own unit test.
	var/mob/living/carbon/human/test_human = allocate(/mob/living/carbon/human/consistent)

	ADD_TRAIT(test_human, TRAIT_BOMBIMMUNE, REF(src))
	EX_ACT(test_human, EXPLODE_DEVASTATE) // we're bomb immune, so we shouldn't gib.
	TEST_ASSERT(!QDELETED(test_human), "EX_ACT() with EXPLODE_DEVASTATE severity should NOT have gibbed a human with the bomb immune trait!")
	REMOVE_TRAIT(test_human, TRAIT_BOMBIMMUNE, REF(src))

	EX_ACT(test_human, EXPLODE_DEVASTATE) // we should gib now.
	TEST_ASSERT(QDELETED(test_human), "EX_ACT() with EXPLODE_DEVASTATE severity should have gibbed a human!")

/// Sets up a fully armored corgi for testing purposes. Split out into its own proc as to not clutter up the main test.
/datum/unit_test/explosion_action/proc/set_up_test_dog()
	var/mob/living/basic/pet/dog/corgi/returnable_dog = allocate(/mob/living/basic/pet/dog/corgi)
	returnable_dog.maxHealth = MAX_LIVING_HEALTH
	returnable_dog.health = MAX_LIVING_HEALTH

	var/obj/item/clothing/head/helmet/invincible_hat = allocate(/obj/item/clothing/head/helmet)
	invincible_hat.set_armor(/datum/armor/immune)
	returnable_dog.inventory_head = invincible_hat

	var/obj/item/clothing/suit/armor/vest/invincible_vest = allocate(/obj/item/clothing/suit/armor/vest)
	invincible_vest.set_armor(/datum/armor/immune)
	returnable_dog.inventory_back = invincible_vest

	return returnable_dog

/// Proc to lessen the amount of copypasta we do for the alien tests, simply sets the rolling vars we have.
/datum/unit_test/explosion_action/proc/get_alien_damages(mob/living/carbon/alien/subject)
	alien_brute_loss = subject.getBruteLoss()
	alien_burn_loss = subject.getFireLoss()
	alien_ear_damage = subject.get_organ_loss(ORGAN_SLOT_EARS)
