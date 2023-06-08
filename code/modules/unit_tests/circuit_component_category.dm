/// Tests to make sure each circuit component that could potentially be available to a player has a category
/datum/unit_test/circuit_component_category

/datum/unit_test/circuit_component_category/Run()
	for(var/datum/design/design in subtypesof(/datum/design/component))
		var/obj/item/circuit_component/path = initial(design.build_path)
		if(!path)
			continue

		if(initial(path.category) == COMPONENT_DEFAULT_CATEGORY)
			TEST_FAIL("[path] has a category of '[COMPONENT_DEFAULT_CATEGORY]' when it has a research design that players can potentially access!")
