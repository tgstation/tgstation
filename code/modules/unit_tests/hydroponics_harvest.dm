/**
 * A test to make sure harvesting plants in hydroponics results in the correct number of plants with the correct chemicals inside of it.
 *
 * We plant a seed into a tray and harvest it with a human.
 * This seed is set to have the maximum potency and yield with no instability to prevent mutations.
 * Then we check how many products we got from the harvest. For most plants, this should be 10 products, as we have a yield of 10.
 * Alternatively, if the plant has a trait that halves the products on harvest, it should result in 5 products.
 *
 * After we harvest our seed, we check for the plant's nutriments and vitamins.
 * Most plants have nutriments, so most plants should result in a number of nutriments.
 * Some plants have vitamins and some don't, so we then check the number of vitamins.
 * Additionally, the plant may have traits that double the amount of chemicals it can hold. We check the max volume in that case and adjust accordingly.
 * Plants may have additional chemicals genes that we don't check.
 * Plants may have traits that effect the final product's contents that we don't check.
 * Chemicals may react inside of the plant on harvest, which we don't check.
 *
 * After we check the harvest and the chemicals in the harvest, we go ahead and clean up the harvested products and remove the seed if it has perennial growth.
 *
 * This test checks both /obj/item/food/grown items and /obj/item/grown items since, despite both being used in hydroponics,
 * they aren't the same type so everything that works with one isn't guaranteed to work with the other.
 */
/datum/unit_test/hydroponics_harvest/Run()
	var/obj/machinery/hydroponics/soil/testing_soil = allocate(/obj/machinery/hydroponics/soil)
	var/obj/item/seeds/planted_food_seed = allocate(/obj/item/seeds/apple) //grown food
	var/obj/item/seeds/planted_not_food_seed = allocate(/obj/item/seeds/sunflower) //grown inedible
	var/obj/item/seeds/planted_densified_seed = allocate(/obj/item/seeds/redbeet) //grown + densified chemicals

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)

	testing_soil.forceMove(run_loc_floor_bottom_left)

	var/nearby_loc = locate((run_loc_floor_bottom_left.x + 1), run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	human.forceMove(nearby_loc)

	var/seeds_loc = locate((run_loc_floor_bottom_left.x + 1), (run_loc_floor_bottom_left.y + 1), run_loc_floor_bottom_left.z)
	planted_food_seed.forceMove(seeds_loc)
	planted_not_food_seed.forceMove(seeds_loc)
	planted_densified_seed.forceMove(seeds_loc)

	// Apples should harvest 10 apples with 10u nutrients and 4u vitamins.
	test_seed(testing_soil, planted_food_seed, human)
	// Sunflowers should harvest 10 sunflowers with 4u nutriment and 0u vitamins. It should also have 8u oil.
	test_seed(testing_soil, planted_not_food_seed, human)
	// Redbeets should harvest 5 beets (10 / 2) with 10u nutriments (5 x 2) and 10u vitamins (5 x 2) thanks to densified chemicals.
	test_seed(testing_soil, planted_densified_seed, human)

/datum/unit_test/hydroponics_harvest/proc/plant_and_update_seed(obj/machinery/hydroponics/tray, obj/item/seeds/seed)
	seed.set_yield(10) // Sets the seed yield to 10. This gets clamped to 5 if the plant has traits to half the yield.
	seed.set_potency(100) // Sets the seed potency to 100.
	seed.set_instability(0) // Sets the seed instability to 0, to prevent mutations.

	tray.set_seed(seed)
	seed.forceMove(tray)
	tray.name = tray.myseed ? "[initial(tray.name)] ([tray.myseed.plantname])" : initial(tray.name)

	tray.set_plant_health(seed.endurance)
	tray.age = 20
	tray.set_plant_status(HYDROTRAY_PLANT_HARVESTABLE)

/datum/unit_test/hydroponics_harvest/proc/test_seed(obj/machinery/hydroponics/tray, obj/item/seeds/seed, mob/living/carbon/user)
	tray.reagents.add_reagent(/datum/reagent/plantnutriment/eznutriment, 20)
	plant_and_update_seed(tray, seed)
	var/saved_name = tray.name // Name gets cleared when some plants are harvested.

	if(!tray.myseed)
		TEST_FAIL("Hydroponics harvest from [saved_name] had no seed set properly to test.")

	if(tray.myseed != seed)
		TEST_FAIL("Hydroponics harvest from [saved_name] had [tray.myseed] planted when it was testing [seed].")

	var/double_chemicals = seed.get_gene(/datum/plant_gene/trait/maxchem)
	var/expected_yield = seed.getYield()
	var/max_volume = 100 //For 99% of plants, max volume is 100.

	if(double_chemicals)
		max_volume *= 2

	tray.attack_hand(user)
	var/list/obj/item/all_harvested_items = list()
	for(var/obj/item/harvested_food in user.drop_location())
		all_harvested_items += harvested_food

	if(!all_harvested_items.len)
		TEST_FAIL("Hydroponics harvest from [saved_name] resulted in 0 harvest.")

	TEST_ASSERT_EQUAL(all_harvested_items.len, expected_yield, "Hydroponics harvest from [saved_name] only harvested [all_harvested_items.len] items instead of [expected_yield] items.")
	TEST_ASSERT(all_harvested_items[1].reagents, "Hydroponics harvest from [saved_name] had no reagent container.")
	TEST_ASSERT_EQUAL(all_harvested_items[1].reagents.maximum_volume, max_volume, "Hydroponics harvest from [saved_name] [double_chemicals ? "did not have its reagent capacity doubled to [max_volume] properly." : "did not have its reagents capped at [max_volume] properly."]")

	var/expected_nutriments = seed.reagents_add[/datum/reagent/consumable/nutriment]
	var/expected_vitamins = seed.reagents_add[/datum/reagent/consumable/nutriment/vitamin]

	var/found_nutriments = all_harvested_items[1].reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	var/found_vitamins = all_harvested_items[1].reagents.get_reagent_amount(/datum/reagent/consumable/nutriment/vitamin)

	QDEL_LIST(all_harvested_items) //We got everything we needed from our harvest, we can clean it up.

	TEST_ASSERT_EQUAL(found_nutriments, expected_nutriments * max_volume, "Hydroponics harvest from [saved_name] has a [expected_nutriments] nutriment gene (expecting [expected_nutriments * max_volume]) but only had [found_nutriments] units of nutriment inside.")
	TEST_ASSERT_EQUAL(found_vitamins, expected_vitamins * max_volume, "Hydroponics harvest from [saved_name] has a [expected_vitamins] vitamin gene (expecting [expected_vitamins * max_volume]) but only had [found_vitamins] units of vitamins inside.")

	if(tray.myseed)
		tray.age = 0
		tray.set_plant_health(0)

		tray.set_seed(null)
		tray.name = tray.myseed ? "[initial(tray.name)] ([tray.myseed.plantname])" : initial(tray.name)
