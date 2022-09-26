///Checks if all cables on the map are connected to a powernet roundstart
/datum/unit_test/cable_powernets

/datum/unit_test/cable_powernets/Run()
	for(var/obj/structure/cable/cables as anything in GLOB.cable_list)
		TEST_ASSERT(!cables.powernet, "CABLE: [cables.name] has no powernet at ([cables.x] [cables.y] [cables.z])")
