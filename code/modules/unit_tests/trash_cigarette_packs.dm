/// Checks to make sure all cigarette packs trash is included in /obj/effect/spawner/random/trash/cigpack
/datum/unit_test/trash_cigarette_packs

/datum/unit_test/trash_cigarette_packs/Run()
	var/list/cigpack_trash = /obj/effect/spawner/random/trash/cigpack::loot

	for(var/cigpack in subtypesof(/obj/item/storage/fancy/cigarettes))
		TEST_ASSERT(is_path_in_list(cigpack, cigpack_trash), "[cigpack] must include its empty subtype for loot table /obj/effect/spawner/random/trash/cigpack")

	for(var/cigars in subtypesof(/obj/item/storage/fancy/cigarettes/cigars))
		TEST_ASSERT(is_path_in_list(cigars, cigpack_trash), "[cigars] must include its empty subtype for loot table /obj/effect/spawner/random/trash/cigpack")


