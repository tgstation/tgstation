/**
 * Confirm that it is possible to bake a cake, get the food buff from a hand-made food and confirm that the reagents are consistent throughout the process
 */
/datum/unit_test/bake_a_cake/Run()
	var/turf/table_loc = run_loc_floor_bottom_left
	var/turf/oven_loc = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/human_loc = get_step(run_loc_floor_bottom_left, NORTHEAST)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, human_loc)
	var/obj/machinery/oven/the_oven = allocate(/obj/machinery/oven, oven_loc)
	var/obj/structure/table/the_table = allocate(/obj/structure/table, table_loc)
	var/obj/item/knife/kitchen/a_knife = allocate(/obj/item/knife/kitchen, table_loc)
	var/obj/item/reagent_containers/cup/beaker/beaker = allocate(/obj/item/reagent_containers/cup/beaker, table_loc)
	var/obj/item/reagent_containers/condiment/flour/flour_bag = allocate(/obj/item/reagent_containers/condiment/flour, table_loc)
	var/obj/item/reagent_containers/condiment/sugar/sugar_bag = allocate(/obj/item/reagent_containers/condiment/sugar, table_loc)
	var/obj/item/storage/fancy/egg_box/egg_box = allocate(/obj/item/storage/fancy/egg_box, table_loc)
	var/obj/item/food/egg/sample_egg = egg_box.contents[1]

	var/datum/chemical_reaction/recipe = GLOB.chemical_reactions_list[/datum/chemical_reaction/food/cakebatter]
	var/sugar_required = recipe.required_reagents[/datum/reagent/consumable/sugar]
	var/flour_required = recipe.required_reagents[/datum/reagent/consumable/flour]
	var/eggyolk_required = recipe.required_reagents[/datum/reagent/consumable/eggyolk]
	var/eggwhite_required = recipe.required_reagents[/datum/reagent/consumable/eggwhite]
	var/total_volume = sugar_required + flour_required + eggyolk_required + eggwhite_required

	var/sugar_purity = sugar_bag.reagents.get_average_purity()
	TEST_ASSERT_EQUAL(sugar_purity, 1, "Incorrect sugar purity!")
	var/flour_purity = flour_bag.reagents.get_average_purity()
	TEST_ASSERT_EQUAL(flour_purity, CONSUMABLE_STANDARD_PURITY, "Incorrect flour purity!")
	var/egg_purity = sample_egg.reagents.get_average_purity()
	TEST_ASSERT_EQUAL(egg_purity, CONSUMABLE_STANDARD_PURITY, "Incorrect egg reagents purity!")

	human.mind = new /datum/mind(null) // Add brain for the food buff

	// It's a piece of cake to bake a pretty cake
	while(beaker.reagents.get_reagent_amount(/datum/reagent/consumable/sugar) < sugar_required && beaker.reagents.total_volume < total_volume)
		sugar_bag.melee_attack_chain(human, beaker)
	while(beaker.reagents.get_reagent_amount(/datum/reagent/consumable/flour) < flour_required && beaker.reagents.total_volume < total_volume)
		flour_bag.melee_attack_chain(human, beaker)
	while((beaker.reagents.get_reagent_amount(/datum/reagent/consumable/eggyolk) < eggyolk_required \
	|| beaker.reagents.get_reagent_amount(/datum/reagent/consumable/eggwhite) < eggwhite_required) \
	&& beaker.reagents.total_volume < total_volume \
	&& beaker.reagents.total_volume >= (sugar_required + flour_required)) // Make sure that we won't miss the reaction
		var/obj/item/egg = egg_box.contents[1]
		egg.melee_attack_chain(human, beaker, list(RIGHT_CLICK = TRUE))
	var/obj/item/food/cake_batter = locate(/obj/item/food/cakebatter) in table_loc
	TEST_ASSERT_NOTNULL(cake_batter, "Failed making cake batter!")
	TEST_ASSERT_EQUAL(beaker.reagents.total_volume, 0, "Cake batter did not consume all beaker reagents!")

	var/batter_purity = cake_batter.reagents.get_average_purity()
	var/batter_purity_expected = (sugar_required * sugar_purity + flour_required * flour_purity + (eggyolk_required + eggwhite_required) * egg_purity) / total_volume
	TEST_ASSERT_EQUAL(batter_purity, batter_purity_expected, "Incorrect average purity of the cake batter reagents!")

	the_oven.add_tray_to_oven(new /obj/item/plate/oven_tray(the_oven)) // Doesn't have one unless maploaded
	the_oven.attack_hand(human)
	var/obj/item/plate/oven_tray/oven_tray = locate(/obj/item/plate/oven_tray) in the_oven.contents
	TEST_ASSERT_NOTNULL(oven_tray, "The oven doesn't have a tray!")
	cake_batter.melee_attack_chain(human, oven_tray, list(ICON_X = "0", ICON_Y = "0"))
	the_oven.attack_hand(human)
	the_oven.process(90 SECONDS) // Bake it
	the_oven.attack_hand(human)
	var/obj/item/food/cake/plain/cake = locate(/obj/item/food/cake/plain) in oven_tray.contents
	TEST_ASSERT_NOTNULL(cake, "Didn't manage to bake a cake!")

	cake.melee_attack_chain(human, the_table, list(ICON_X = "0", ICON_Y = "0"))
	a_knife.melee_attack_chain(human, cake)
	var/obj/item/food/cakeslice/plain/cake_slice = locate(/obj/item/food/cakeslice/plain) in table_loc
	TEST_ASSERT_NOTNULL(cake_slice, "Didn't manage to cut the cake!")

	var/cake_slice_purity = cake_slice.reagents.get_average_purity()
	TEST_ASSERT_EQUAL(cake_slice_purity, batter_purity_expected, "Incorrect average purity of the cake slice reagents!")

	cake_slice.attack_hand(human) // Pick it up
	var/datum/component/edible/edible_comp = cake_slice.GetComponent(/datum/component/edible)
	edible_comp.eat_time = 0
	cake_slice.attack(human, human) // Eat it
	var/datum/status_effect/food/effect = locate(/datum/status_effect/food) in human.status_effects
	TEST_ASSERT_NOTNULL(effect, "Eating the cake had no effect!")
