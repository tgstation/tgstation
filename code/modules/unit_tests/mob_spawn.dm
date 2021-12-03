/// Verifies that all glands for an egg are valid
/datum/unit_test/mob_spawn

/datum/unit_test/mob_spawn/Run()
	for(var/mob_spawn_path in subtypesof(/obj/effect/mob_spawn))
		var/obj/effect/mob_spawn/mob_spawn = allocate(mob_spawn_path)

		if(mob_spawn.ghost_usable)
			TEST_ASSERT(mob_spawn.mob_name, "[mob_spawn.type] has no \"mob_name\" var, which is required for ghost usable mob spawns.")
			//there is specifically one case in which this isn't a dumb inheritance mistake, and that's for some kind of changeling or lich mob spawn that starts dead.
			//you can remove this assert when you add that, until then don't make ghost roles that die instantly
			TEST_ASSERT(!mob_spawn.death, "[mob_spawn.type] has death set to TRUE, which is nonsensical for ghost usable mob spawns.")
			TEST_ASSERT(!mob_spawn.roundstart, "[mob_spawn.type] has roundstart set to TRUE, which is contradictory for ghost usable mob spawns.")
			TEST_ASSERT(!mob_spawn.instant, "[mob_spawn.type] has instant set to TRUE, which is contradictory for ghost usable mob spawns.")

		qdel(mob_spawn)
