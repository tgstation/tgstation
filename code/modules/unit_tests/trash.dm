/// Checks to make sure all food trash is included into the /obj/effect/spawner/random/trash/food_packaging
/datum/unit_test/food_trash

/datum/unit_test/food_trash/Run()
	var/list/food_trash = /obj/effect/spawner/random/trash/food_packaging::loot
	// list of pieces of trash we never want to include because they are special or rare (usually mutated botany plants)
	var/list/food_trash_blacklist = list(
		/obj/item/grown/bananapeel/bombanana,
		/obj/item/grown/bananapeel/mimanapeel,
		/obj/item/grown/bananapeel/bluespace,
		/obj/item/food/egg,
		/obj/item/gun/ballistic/revolver/peashooter,
		/obj/item/grown/corncob/pepper,
	)

	for(var/obj/item/food/throwaway in subtypesof(/obj/item/food))
		var/trash = throwaway.trash_type
		if(!trash)
			continue
		if(trash in food_trash_blacklist)
			continue

		TEST_ASSERT(food_trash[trash], "[throwaway.type] must include its trash_type for loot table /obj/effect/spawner/random/trash/food_packaging or be added to this unit tests food_trash_blacklist")
