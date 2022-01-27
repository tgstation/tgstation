/// Unit test to ensure plants can't self-mutate into themselves.
/datum/unit_test/hydroponics_self_mutation

/datum/unit_test/hydroponics_self_mutation/Run()
	var/list/all_seeds = subtypesof(/obj/item/seeds)

	for(var/seed in all_seeds)
		var/obj/item/seeds/instantiated_seed = new seed()
		for(var/path in instantiated_seed.mutatelist)
			TEST_ASSERT(!istype(instantiated_seed, path), "[instantiated_seed] - [instantiated_seed.type] is able to mutate into itself! Its mutatelist is not set correctly.")
		qdel(instantiated_seed)
