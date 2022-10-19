/// Unit tests that the novaflower's unique genes function.
/datum/unit_test/novaflower_burn

/datum/unit_test/novaflower_burn/Run()
	var/mob/living/carbon/human/botanist = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/grown/novaflower/weapon = allocate(/obj/item/grown/novaflower)

	TEST_ASSERT(weapon.force > 0, "[weapon] spawned with zero force.")

	// Keep this around for comparison later.
	var/initial_force = weapon.force
	// Start by having the novaflower equipped to an attacker's hands
	// They are not wearing botany gloves (have plant protection), so they should take damage = the flower's force.
	weapon.attack_hand(botanist)
	TEST_ASSERT_EQUAL(botanist.get_active_held_item(), weapon, "The botanist failed to pick up [weapon].")
	TEST_ASSERT_EQUAL(botanist.getFireLoss(), weapon.force, "The botanist picked up [weapon] with their bare hands, and took an incorrect amount of fire damage.")

	// Heal our attacker for easy comparison later
	botanist.adjustFireLoss(-100)
	// And give them the plant safe trait so we don't have to worry about attacks being cancelled
	ADD_TRAIT(botanist, TRAIT_PLANT_SAFE, "unit_test")

	// Now, let's get a smack with the novaflower and see what happens.
	weapon.melee_attack_chain(botanist, victim)

	TEST_ASSERT(botanist.getFireLoss() <= 0, "The botanist took fire damage from [weapon], even though they were plant safe.")
	TEST_ASSERT_EQUAL(victim.getFireLoss(), initial_force, "The target took an incorrect amount of fire damage after being hit with [weapon].")
	TEST_ASSERT(weapon.force < initial_force, "[weapon] didn't lose any force after an attack.")
	TEST_ASSERT(victim.fire_stacks > 0, "[weapon] didn't apply any firestacks to the target after an attack.")
	TEST_ASSERT(victim.on_fire, "[weapon] didn't set the target on fire after an attack.")

	// Lastly we should check that degredation to zero works.
	weapon.force = 0
	weapon.melee_attack_chain(botanist, victim)

	TEST_ASSERT(QDELETED(weapon), "[weapon] wasn't deleted after hitting someone with zero force.")
