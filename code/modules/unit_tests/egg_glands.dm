/// Verifies that all glands for an egg are valid
/datum/unit_test/egg_glands

/datum/unit_test/egg_glands/Run()
	var/obj/item/food/egg/egg = allocate(/obj/item/food/egg)

	for (var/datum/reagent/reagent_type as anything in subtypesof(/datum/reagent))
		if (!(initial(reagent_type.chemical_flags) & REAGENT_CAN_BE_SYNTHESIZED))
			continue

		try
			mix_color_from_reagents(egg.reagents.reagent_list + list(new reagent_type))
		catch (var/exception/exception)
			TEST_FAIL("[reagent_type] fails mixing\n[exception]")
