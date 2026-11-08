/// Checks that GLOB.periodic_table holds all 118 elements, in order, each backed by a real reagent of the same name.
/datum/unit_test/periodic_table

/datum/unit_test/periodic_table/Run()
	TEST_ASSERT_EQUAL(length(GLOB.periodic_table), 118, "The periodic table should have 118 elements")

	var/list/seen_symbols = list()
	var/list/seen_reagents = list()
	for(var/index in 1 to length(GLOB.periodic_table))
		var/datum/periodic_element/element = GLOB.periodic_table[index]
		if(element.number != index)
			TEST_FAIL("[element.name] has atomic number [element.number] but sits at index [index]")

		if(seen_symbols[element.symbol])
			TEST_FAIL("[element.name] reuses the symbol [element.symbol]")
		seen_symbols[element.symbol] = TRUE

		if(seen_reagents[element.reagent_type])
			TEST_FAIL("[element.name] reuses the reagent [element.reagent_type]")
		seen_reagents[element.reagent_type] = TRUE

		var/datum/reagent/reagent = GLOB.chemical_reagents_list[element.reagent_type]
		if(isnull(reagent))
			TEST_FAIL("[element.name] points at [element.reagent_type], which isn't a usable reagent")
			continue
		if(reagent.name != element.name)
			TEST_FAIL("[element.name] points at [element.reagent_type], which is named [reagent.name]")
		if(get_periodic_element(element.reagent_type) != element)
			TEST_FAIL("Looking up [element.reagent_type] didn't return [element.name]")

	// The standard chem dispenser gets the natural new elements and nothing synthetic
	var/obj/machinery/chem_dispenser/dispenser = allocate(/obj/machinery/chem_dispenser)
	for(var/datum/periodic_element/element as anything in GLOB.periodic_table)
		if(!element.is_new_element())
			continue
		var/dispensed = !!(element.reagent_type in dispenser.dispensable_reagents)
		if(element.is_synthetic() && dispensed)
			TEST_FAIL("The chem dispenser offers synthetic element [element.name]")
		else if(!element.is_synthetic() && !dispensed)
			TEST_FAIL("The chem dispenser is missing natural element [element.name]")
