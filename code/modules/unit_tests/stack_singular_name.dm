/**
 * Goes through every subtype of /obj/item/stack to check for a singular name, var/singular_name.
 * Everything within the blacklist does not need to be tested because it exists to be overridden.
 * This test will fail if a subtype of /obj/item/stack is missing a singular name.
 */
/datum/unit_test/stack_singular_name

/datum/unit_test/stack_singular_name/Run()
	for(var/obj/item/stack/stack_check as anything in valid_subtypesof(/obj/item/stack))
		if(!initial(stack_check.singular_name))
			TEST_FAIL("[stack_check] is missing a singular name!")
