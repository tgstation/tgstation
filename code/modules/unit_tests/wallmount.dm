/// Ensures wallmouted objects prioritize walls over other mountable objects like tables
/datum/unit_test/wallmount

/datum/unit_test/wallmount/Run()
	var/obj/structure/table/test_table = EASY_ALLOCATE()
	var/obj/machinery/light/directional/south/test_light = EASY_ALLOCATE()
	test_light.find_and_hang_on_atom()

	var/datum/component/atom_mounted/wallmount_component = test_light.GetComponent(/datum/component/atom_mounted)
	TEST_ASSERT_NOTNULL(wallmount_component, "Wall mount component was not added to the light!")
	TEST_ASSERT_NOTEQUAL(wallmount_component.hanging_support_atom, test_table, "Wall mount component was mounted on the table rather than the wall!")
