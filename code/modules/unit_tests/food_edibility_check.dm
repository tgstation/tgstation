/// Makes sure that spawned food has reagents and the edible component (or else it can't be eaten).
/datum/unit_test/food_edibility_check

/datum/unit_test/food_edibility_check/Run()
	var/list/not_food = list(
		/obj/item/food/grown,
		/obj/item/food/grown/mushroom,
		/obj/item/food/clothing,
		/obj/item/food/meat/slab/human/mutant,
		/obj/item/food/grown/shell)

	var/list/food_paths = subtypesof(/obj/item/food) - not_food

	for(var/food_path in food_paths)
		var/obj/item/food/spawned_food = allocate(food_path)

		if(!spawned_food.reagents)
			TEST_FAIL("[food_path] does not have any reagents, making it inedible!")

		if(!IS_EDIBLE(spawned_food))
			TEST_FAIL("[food_path] does not have the edible component, making it inedible!")

		qdel(spawned_food)
