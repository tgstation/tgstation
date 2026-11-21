/**
 * Makes sure that the input and output of food processor recipes, excluding where one is not a food item,
 * have either matching food types or that, by adding foodtypes in the 'added_foodtypes' var of the recipe
 * and removing foodtypes in the 'removed_foodtypes' var of the recipe, the foodtypes of the input would match the output
 * TL;DR consistency.
 */
/datum/unit_test/food_processor

/datum/unit_test/food_processor/Run()
	var/list/food_processes = subtypesof(/datum/food_processor_process)

	for(var/datum/food_processor_process/recipe as anything in food_processes)
		if(!ispath(recipe::input, /obj/item/food) || !ispath(recipe::output, /obj/item/food))
			continue
		var/obj/item/food/input = recipe::input
		var/obj/item/food/output = recipe::output

		var/input_foodtypes = input::foodtypes
		var/output_foodtypes = output::foodtypes

		input_foodtypes |= recipe::added_foodtypes
		input_foodtypes &= ~recipe::removed_foodtypes

		if(input_foodtypes != output_foodtypes)
			var/text_in_flags = jointext(bitfield_to_list(input_foodtypes, FOOD_FLAGS),"|")
			var/text_out_flags = jointext(bitfield_to_list(output_foodtypes, FOOD_FLAGS),"|")
			TEST_FAIL("foodtypes of input ([text_in_flags]) vs output ([text_out_flags]) of [recipe] don't match! Check the datum again and fix it")
