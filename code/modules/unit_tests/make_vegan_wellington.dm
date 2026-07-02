/**
 * Confirm that it is possible to make a beef wellington exclusively with podpeople "meat" that won't have the MEAT food type.
 */
/datum/unit_test/make_vegan_wellington/Run()
	var/turf/table_loc = run_loc_floor_bottom_left
	var/turf/griddle_loc = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/human_loc = get_step(run_loc_floor_bottom_left, NORTHEAST)

	///allocate a table. We don't need it for anything other than cutting a meat slab into cutlets.
	allocate(/obj/structure/table, table_loc)

	var/obj/machinery/griddle/griddle = allocate(__IMPLIED_TYPE__, griddle_loc)
	var/obj/item/knife/kitchen/a_knife = allocate(__IMPLIED_TYPE__, table_loc)
	var/obj/machinery/processor/processor = allocate(__IMPLIED_TYPE__, table_loc)

	var/obj/item/reagent_containers/cup/beaker/beaker = allocate(__IMPLIED_TYPE__, table_loc)

	var/datum/crafting_recipe/food/beef_wellington/recipe = locate() in GLOB.cooking_recipes

	// bake_a_cake should already check that batters and doughes can be made, so let's not waste time making the dough from scratch
	for(var/ingredient in recipe.reqs)
		var/amount = recipe.reqs[ingredient]
		if(ispath(ingredient, /datum/reagent))
			beaker.reagents.add_reagent(ingredient, amount)
		else if(ispath(ingredient, /obj/item/food/meat)) //we will use vegetable variants for this
			continue
		for(var/i in 1 to amount)
			allocate(ingredient, table_loc)

	// Important ingredients made from 100% organic walking vegetables
	var/obj/item/food/meat/slab/human/mutant/plant/raw_steak = allocate(__IMPLIED_TYPE__, griddle_loc)
	var/obj/item/food/meat/slab/human/mutant/plant/uncut_cutlet = allocate(__IMPLIED_TYPE__, table_loc)

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, human_loc)

	//cut the plant slab into raw cutlet(s)
	a_knife.melee_attack_chain(human, uncut_cutlet)
	var/obj/item/food/meat/rawcutlet/cutlet
	for(var/obj/item/food/meat/rawcutlet/made in table_loc)
		allocated += made
		cutlet = made
	TEST_ASSERT_NOTNULL(cutlet, "Failed making cutlet out of plant meat!")
	TEST_ASSERT(meat_check(cutlet), "Cutlet made from plant meat has MEAT foodtype!")

	//process the raw cutlet into raw bacon
	cutlet.melee_attack_chain(human, processor)
	processor.interact(human)
	var/obj/item/food/meat/rawbacon/raw_bacon = locate() in table_loc
	TEST_ASSERT_NOTNULL(raw_bacon, "Failed making bacon out of plant cutlet!")
	allocated += raw_bacon
	TEST_ASSERT(meat_check(raw_bacon), "Bacon made from plant meat has MEAT foodtype!")

	//turn the griddle on and cook steak and bacon on it
	griddle.attack_hand(human)
	raw_steak.melee_attack_chain(human, griddle, list(ICON_X = "0", ICON_Y = "0"))
	raw_bacon.melee_attack_chain(human, griddle, list(ICON_X = "0", ICON_Y = "0"))
	griddle.process(90 SECONDS) //should be done.

	var/obj/item/food/meat/steak/steak = locate() in griddle
	TEST_ASSERT_NOTNULL(steak, "Failed cooking steak!")
	allocated += steak
	steak.forceMove(griddle_loc) //move it out of the griddle so that it can be used in recipes.
	TEST_ASSERT(meat_check(steak), "Cooked plant \"steak\" has MEAT foodtype!")

	var/obj/item/food/meat/bacon/bacon = locate() in griddle
	TEST_ASSERT_NOTNULL(bacon, "Failed cooking bacon!")
	allocated += bacon
	bacon.forceMove(griddle_loc) //move it out of the griddle
	TEST_ASSERT(meat_check(bacon), "Cooked plant \"bacon\" has MEAT foodtype!")

	//final step, make the recipe and check that it doesn't have
	var/datum/component/personal_crafting/crafting = human.GetComponent(__IMPLIED_TYPE__)
	var/obj/item/food/beef_wellington/wellington = crafting.construct_item(human, recipe)
	allocated += wellington
	TEST_ASSERT_NOTNULL(wellington, "Failed making beef wellington!")
	TEST_ASSERT(meat_check(wellington), "Beef wellington made from plant \"meat\" still has MEAT foodtype!")

/datum/unit_test/make_vegan_wellington/proc/meat_check(obj/item/food/target)
	var/datum/component/edible/edible = target.GetComponent(__IMPLIED_TYPE__)
	return !(edible.foodtypes & MEAT) // return FALSE if it has the MEAT foodtype
