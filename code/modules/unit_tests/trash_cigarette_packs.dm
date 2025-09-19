/// Checks to make sure all cigarette packs trash is included in /obj/effect/spawner/random/trash/cigpack
/datum/unit_test/trash_cigarette_packs

/datum/unit_test/trash_cigarette_packs/Run()
	var/list/cigpack_trash = /obj/effect/spawner/random/trash/cigpack::loot

	for(var/obj/item/storage/fancy/cigarettes/cigpack in subtypesof(/obj/item/storage/fancy/cigarettes))
		TEST_ASSERT(cigpack in cigpack_trash, "[cigpack.type] must include its empty subtype for loot table /obj/effect/spawner/random/trash/cigpack")

	for(var/obj/item/storage/fancy/cigarettes/cigars/cigar_box in subtypesof(/obj/item/storage/fancy/cigarettes/cigars))
		TEST_ASSERT(cigar_box in cigpack_trash, "[cigar_box.type] must include its empty subtype for loot table /obj/effect/spawner/random/trash/cigpack")

/*
		for(var/current_path in pathlist)
			for(var/subtype in subtypesof(current_path))
				.[subtype] = TRUE
*/
