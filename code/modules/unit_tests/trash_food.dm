/// Checks to make sure all food trash is included in /obj/effect/spawner/random/trash/food_packaging
/datum/unit_test/trash_food

/datum/unit_test/trash_food/Run()
	var/list/food_trash = /obj/effect/spawner/random/trash/food_packaging::loot
	// list of pieces of trash we never want to include because they are special or rare (usually mutated botany plants)
	var/list/food_trash_blacklist = list(
		// already added to botanical_waste spawner or too exotic
		/obj/item/grown/bananapeel,
		/obj/item/grown/bananapeel/bombanana,
		/obj/item/grown/bananapeel/mimanapeel,
		/obj/item/grown/bananapeel/bluespace,
		/obj/item/food/grown/bungopit,
		/obj/item/food/egg,
		/obj/item/gun/ballistic/revolver/peashooter,
		/obj/item/grown/corncob,
		/obj/item/grown/corncob/pepper,
		// misc waste products that don't belong in trash spawner
		/obj/item/reagent_containers/cup/bowl,
		/obj/item/plate,
		/obj/item/stack/rods, // kebab
		/obj/item/paper/paperslip/fortune, // fortune cookie
		/obj/item/dice/fudge, // /obj/item/food/fudgedice
	)

	for(var/path in subtypesof(/obj/item/food))
		var/obj/item/food/food = path
		var/trash = food::trash_type
		if(!trash)
			continue
		if(trash in food_trash_blacklist)
			continue

		TEST_ASSERT(food_trash[trash], "[food] must include its trash_type for loot table /obj/effect/spawner/random/trash/food_packaging or be added to this unit tests food_trash_blacklist")
