/datum/unit_test/embedding

/datum/unit_test/embedding/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/firer = allocate(/mob/living/carbon/human/consistent)
	var/obj/projectile/bullet/c38/bullet = new(get_turf(firer))
	bullet.set_embed(bullet.get_embed().generate_with_values(embed_chance = 100))
	TEST_ASSERT_EQUAL(bullet.get_embed().embed_chance, 100, "embed_chance failed to modify")
	bullet.preparePixelProjectile(victim, firer)
	bullet.fire(get_angle(firer, victim), victim)
	var/list/components = victim.GetComponents(/datum/component/embedded)
	TEST_ASSERT_EQUAL(components.len, 1, "Projectile with 100% embed chance didn't embed, or embedded multiple times")
	var/datum/component/embedded/comp = components[1]
	TEST_ASSERT_EQUAL(comp.weapon.get_embed().embed_chance, 100, "embed_chance modification did not transfer to shrapnel")
