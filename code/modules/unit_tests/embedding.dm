/datum/unit_test/embedding

/datum/unit_test/embedding/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/firer = allocate(/mob/living/carbon/human/consistent)
	var/obj/projectile/bullet/c38/bullet = new(get_turf(firer))
	bullet.get_embed().embed_chance = 100
	TEST_ASSERT_EQUAL(bullet.get_embed().embed_chance, 100, "embed_chance failed to modify")
	bullet.aim_projectile(victim, firer)
	bullet.fire(get_angle(firer, victim), victim)
	var/obj/item/shrapnel/shrapnel = locate() in victim
	TEST_ASSERT(!isnull(shrapnel), "Projectile with 100% embed chance didn't embed")
	TEST_ASSERT_EQUAL(shrapnel.get_embed().embed_chance, 100, "embed_chance modification did not transfer to shrapnel")
