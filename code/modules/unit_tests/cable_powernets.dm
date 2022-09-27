///Checking all powernets to see if they are properly connected and powered.
/datum/unit_test/cable_powernets

/datum/unit_test/cable_powernets/Run()
	for(var/datum/powernet/powernets as anything in SSmachines.powernets)

		//nodes (machines, which includes APCs and SMES)
		if(!length(powernets.nodes))
			TEST_ASSERT(!length(powernets.nodes), "CABLE: [powernets] found with no nodes OR cables connected, something has gone horribly wrong.")

			var/obj/structure/cable/found_cable = powernets.cables[1]
			//Check if they're a station area
			var/area/cable_area = get_area(found_cable)
			if(!(cable_area.type in GLOB.the_station_areas) || istype(cable_area, /area/station/solars))
				continue
			TEST_ASSERT(!powernets.nodes, "CABLE: [powernets] found with no nodes connected([found_cable.x], [found_cable.y], [found_cable.z])).")

		//cables
		if(!length(powernets.cables))
			TEST_ASSERT(!length(powernets.cables), "CABLE: [powernets] found with no cables OR nodes connected, something has gone horribly wrong.")

			var/obj/machinery/power/found_machine = powernets.nodes[1]
			//Check if they're a station area
			var/area/cable_area = get_area(found_cable)
			if(!(cable_area.type in GLOB.the_station_areas) || istype(cable_area, /area/station/solars))
				continue
			TEST_ASSERT(!powernets.cables, "CABLE: [powernets] found with no cables connected ([found_machine.x], [found_machine.y], [found_machine.z]).")

		if(!powernets.avail)
			var/obj/structure/cable/random_cable = powernets.cables[1]
			//Check if they're a station area
			var/area/cable_area = get_area(found_cable)
			if(!(cable_area.type in GLOB.the_station_areas) || istype(cable_area, /area/station/solars))
				continue
			TEST_FAIL("CABLE: [powernets] found with no power roundstart, connected to a cable at ([random_cable.x], [random_cable.y], [random_cable.z]).")
