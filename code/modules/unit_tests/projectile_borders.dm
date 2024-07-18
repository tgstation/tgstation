/datum/unit_test/projectile_borders

/datum/unit_test/projectile_borders/Run()
	var/mob/living/carbon/human/firer = allocate(/mob/living/carbon/human/consistent)
	var/turf/firer_turf = get_turf(firer)
	var/turf/glass_turf = get_step(firer_turf, NORTH)
	var/obj/projectile/bullet/a50ae/bullet = new(firer_turf)
	var/obj/structure/window/window1 = new(firer_turf)
	var/obj/structure/window/window2 = new(glass_turf)
	window1.setDir(NORTH)
	window2.setDir(SOUTH)
	bullet.projectile_piercing = ALL
	bullet.damage = 120
	bullet.preparePixelProjectile(glass_turf, firer)
	bullet.fire(0, glass_turf)
	TEST_ASSERT(QDELETED(window1), "Directional window on piercing projectile firer's turf was not destroyed")
	TEST_ASSERT(QDELETED(window2), "Directional window on piercing projectile target turf was not destroyed")
