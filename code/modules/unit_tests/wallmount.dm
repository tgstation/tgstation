/// Ensures wallmouted objects prioritize walls over other mountable objects like tables
/datum/unit_test/wallmount

/datum/unit_test/wallmount/Run()
	//Test 1 light must priotize wall and not table
	var/obj/structure/table/test_table = EASY_ALLOCATE()
	var/obj/machinery/light/directional/south/test_light = EASY_ALLOCATE()
	test_light.find_and_mount_on_atom()

	var/datum/component/atom_mounted/wallmount_component = test_light.GetComponent(/datum/component/atom_mounted)
	TEST_ASSERT_NOTNULL(wallmount_component, "Atom mount component was not added to the light!")
	TEST_ASSERT_NOTEQUAL(wallmount_component.hanging_support_atom, test_table, "Atom mount component was mounted on the table rather than the wall for the directional light!")

	//Test 2 button must mount on table not wall
	var/obj/machinery/button/test_button = EASY_ALLOCATE()
	test_button.find_and_mount_on_atom()

	wallmount_component = test_button.GetComponent(/datum/component/atom_mounted)
	TEST_ASSERT_NOTNULL(wallmount_component, "Atom mount component was not added to the button with 0 offsets!")
	TEST_ASSERT_EQUAL(wallmount_component.hanging_support_atom, test_table, "Atom mount component was mounted on the wall and not the table for the button with 0 offsets!")

	//Test 3 button must mount on wall not table because it now uses offsets
	test_button = allocate(/obj/machinery/button, run_loc_floor_top_right)
	test_button.pixel_y = 24
	test_button.find_and_mount_on_atom()

	wallmount_component = test_button.GetComponent(/datum/component/atom_mounted)
	TEST_ASSERT_NOTNULL(wallmount_component, "Atom mount component was not added to the button with 24 y offset!")
	TEST_ASSERT(isindestructiblewall(wallmount_component.hanging_support_atom), "Button with 24y offset failed to mount on wall!")
