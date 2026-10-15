/// A test to ensure that door control assemblies, specifically blast door assembles, work as they should
/datum/unit_test/door_control_assembly

/datum/unit_test/door_control_assembly/Run()
	var/mob/living/carbon/human/consistent/engineer = EASY_ALLOCATE()
	var/obj/item/screwdriver/panel_interaction_device = EASY_ALLOCATE()
	var/obj/item/assembly/control/blast_door/controller_one = EASY_ALLOCATE()
	var/obj/item/assembly/control/blast_door/controller_two = EASY_ALLOCATE()
	var/obj/machinery/door/poddoor/big_door = allocate(/obj/machinery/door/poddoor, get_step(run_loc_floor_bottom_left, NORTH))
	var/obj/machinery/button/bigger_button = EASY_ALLOCATE()

	big_door.set_density(FALSE) // No theres no poddoor/instant, why do you ask

	controller_one.id = 51413

	engineer.put_in_active_hand(panel_interaction_device)

	click_wrapper(engineer, big_door)
	TEST_ASSERT(big_door.panel_open, "Failed to open blast door panel with screwdriver")

	engineer.swap_hand(engineer.get_inactive_hand_index())
	engineer.put_in_active_hand(controller_two)

	click_wrapper(engineer, controller_one)
	TEST_ASSERT_EQUAL(controller_two.id, 51413, "Failed to copy blast door controller ID by clicking")

	click_wrapper(engineer, big_door)
	TEST_ASSERT_EQUAL(big_door.id, 51413, "Failed to give a blast door an ID with a controller")

	click_wrapper(engineer, bigger_button)
	TEST_ASSERT_EQUAL(bigger_button.device, controller_two, "Failed to put an assembly in a button")

	engineer.swap_hand(engineer.get_inactive_hand_index()) // Remember the screwdriver?

	click_wrapper(engineer, bigger_button)
	TEST_ASSERT(!bigger_button.panel_open, "Failed to close a button panel with a screwdriver")

	engineer.swap_hand(engineer.get_inactive_hand_index())

	click_wrapper(engineer, bigger_button)
	TEST_ASSERT(big_door.operating, "Pressing a linked button did not make a blast door begin to close")
