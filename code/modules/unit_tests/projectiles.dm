/datum/unit_test/projectile_movetypes/Run()
	for(var/path in typesof(/obj/projectile))
		var/obj/projectile/P = path
		if(initial(P.movement_type) & PHASING)
			Fail("[path] has default movement type PHASING. Piercing projectiles should be done using the projectile piercing system, not movement_types!")
