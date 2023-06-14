/// Checks if reagent container transfer amount defaults match with actual possible values
/datum/unit_test/reagent_container_defaults

/datum/unit_test/reagent_container_defaults/Run()
	for(var/container_type in subtypesof(/obj/item/reagent_containers))
		var/obj/item/reagent_containers/container = allocate(container_type)
		if(!container.has_variable_transfer_amount)
			continue
		var/initial_value = initial(container.amount_per_transfer_from_this)
		var/index_of_initial_value = container.possible_transfer_amounts.Find(initial_value)
		if(index_of_initial_value == 0)
			TEST_FAIL("Reagent container [container_type]: initial value of amount_per_transfer_from_this value ([initial_value]) not found in possible_transfer_amounts list")
