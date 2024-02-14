/// Ensures that when disassembling a machine, all the parts are given back
/datum/unit_test/machine_disassembly

/datum/unit_test/machine_disassembly/Run()
	var/obj/machinery/freezer = allocate(/obj/machinery/atmospherics/components/unary/thermomachine/freezer)

	var/turf/freezer_location = freezer.loc
	freezer.deconstruct()

	// Check that the components are created
	TEST_ASSERT(locate(/obj/item/stock_parts/micro_laser) in freezer_location, "Couldn't find micro-laser when disassembling freezer")

	// Check that the circuit board itself is created
	TEST_ASSERT(locate(/obj/item/circuitboard/machine/thermomachine) in freezer_location, "Couldn't find the circuit board when disassembling freezer")

	// Frame should be spawned as well
	TEST_ASSERT(locate(/obj/structure/frame/machine) in freezer_location, "Couldn't find the frame when disassembling freezer")

/// Test that the computer is disassembled correctly
/datum/unit_test/computer_disassembly

/datum/unit_test/computer_disassembly/Run()
	var/obj/machinery/computer/pc = allocate(/obj/machinery/computer/crew)

	var/turf/pc_location = pc.loc
	pc.deconstruct()

	TEST_ASSERT(locate(/obj/item/circuitboard/computer/crew) in pc_location, "Couldn't find the circuit board when disassembling computer")
	TEST_ASSERT(locate(/obj/structure/frame/computer) in pc_location, "Couldn't find the frame when disassembling computer")
