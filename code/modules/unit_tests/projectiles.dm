/datum/unit_test/projectile_movetypes/Run()
	for(var/path in typesof(/obj/projectile))
		var/obj/projectile/projectile = path
		if(initial(projectile.movement_type) & PHASING)
			TEST_FAIL("[path] has default movement type PHASING. Piercing projectiles should be done using the projectile piercing system, not movement_types!")

/datum/unit_test/gun_go_bang/Run()
	// test is for a ballistic gun that starts loaded + chambered
	var/obj/item/gun/test_gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/gunner = allocate(/mob/living/carbon/human/consistent)
	ADD_TRAIT(victim, TRAIT_PIERCEIMMUNE, INNATE_TRAIT) // So the human isn't randomly affected by shrapnel

	var/obj/item/ammo_casing/loaded_casing = test_gun.chambered
	TEST_ASSERT(loaded_casing, "Gun started without round chambered, should be loaded")
	var/obj/projectile/loaded_bullet = loaded_casing.loaded_projectile
	TEST_ASSERT(loaded_bullet, "Ammo casing has no loaded bullet")

	gunner.put_in_hands(test_gun, forced=TRUE)
	gunner.set_combat_mode(FALSE) // just to make sure we know we're not trying to pistol-whip them
	var/expected_damage = loaded_bullet.damage
	loaded_bullet.def_zone = BODY_ZONE_CHEST
	var/did_we_shoot = test_gun.afterattack(victim, gunner)
	TEST_ASSERT(did_we_shoot, "Gun does not appeared to have successfully fired.")
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), expected_damage, "Victim took incorrect amount of damage, expected [expected_damage], got [victim.getBruteLoss()].")

	var/obj/item/bodypart/expected_part = victim.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(expected_part.brute_dam, expected_damage, "Intended bodypart took incorrect amount of damage, either it hit another bodypart or armor was incorrectly applied. Expected [expected_damage], got [expected_part.brute_dam].")
