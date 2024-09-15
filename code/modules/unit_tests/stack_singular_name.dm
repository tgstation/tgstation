/**
 * Goes through every subtype of /obj/item/stack to check for a singular name, var/singular_name.
 * Everything within the blacklist does not need to be tested because it exists to be overridden.
 * This test will fail if a subtype of /obj/item/stack is missing a singular name.
 */
/datum/unit_test/stack_singular_name

/datum/unit_test/stack_singular_name/Run()
	var/list/blacklist = list( // all of these are generally parents that exist to be overridden; ex. /obj/item/stack/license_plates exists to branch into /filled and /empty
		/obj/item/stack/sheet,
		/obj/item/stack/sheet/mineral,
		/obj/item/stack/license_plates,
		/obj/item/stack/sheet/animalhide,
	)

	for(var/obj/item/stack/stack_check as anything in subtypesof(/obj/item/stack) - blacklist)
		if(!initial(stack_check.singular_name))
			TEST_FAIL("[stack_check] is missing a singular name!")
