/// Verifies that all glands for an egg are valid
/datum/unit_test/mob_spawn

/datum/unit_test/mob_spawn/Run()
	//if you make a prototype mob spawn, add it here.
	var/list/prototypes = list(
		/obj/effect/mob_spawn/human/fugitive, //prototype of fugitive hunters
	)

	for(var/mob_spawn_path in subtypesof(/obj/effect/mob_spawn) - prototypes)
		var/obj/effect/mob_spawn/mob_spawn = allocate(mob_spawn_path)

		if(mob_spawn.ghost_usable)
			if(!mob_spawn.mob_name)
				Fail("[mob_spawn.type] has no \"mob_name\" var, which is required for ghost usable mob spawns.")
			//there is specifically one case in which this isn't a dumb inheritance mistake, and that's for some kind of changeling or lich mob spawn that starts dead.
			//you can remove this assert when you add that, until then don't make ghost roles that die instantly
			if(mob_spawn.death)
				Fail("[mob_spawn.type] has death set to TRUE, which is nonsensical for ghost usable mob spawns.")
			if(mob_spawn.roundstart)
				Fail("[mob_spawn.type] has roundstart set to TRUE, which is contradictory for ghost usable mob spawns.")
			if(mob_spawn.instant)
				Fail("[mob_spawn.type] has instant set to TRUE, which is contradictory for ghost usable mob spawns.")

		qdel(mob_spawn)
