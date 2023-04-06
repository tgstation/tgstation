/**
 * This test checks that all areas on the station are connected to the atmospherics network.
 * It does this by crawling all connected devices from designated starting areas.
 */
/datum/unit_test/atmospherics_sanity
	// we literally iterate over all atmospherics devices on the station
	priority = TEST_LONGER

	/// List of areas remaining to be checked
	var/list/station_areas_remaining

/datum/unit_test/atmospherics_sanity/Run()
	station_areas_remaining = GLOB.the_station_areas.Copy()

	var/list/ignored_areas = list(
		// external
		/area/station/solars,
		// SPAAACE
		/area/station/maintenance/space_hut,
		// where the bombs get sent for ordance
		/area/station/science/ordnance/bomb,
		// holodeck
		/area/station/holodeck/rec_center,
		// pretty obvious
		/area/station/engineering/supermatter,
		// self contained
		/area/station/tcommsat/server,
		// not really sure why this is a station area
		/area/station/asteroid,
		// in the middle of space, for some reason
		/area/station/commons/vacant_room,
		/area/station/science/ordnance/freezerchamber,
		// on kilo station in specific this is off in space
		/area/station/cargo/warehouse,
		// maintenence areas are not required to be connected
		/area/station/maintenance,
	)
	for(var/ignored_type in ignored_areas)
		station_areas_remaining -= typesof(ignored_type)

	var/list/start_areas = list(
		// arrivals
		/area/station/hallway/secondary/entry,
		// xenobio
		/area/station/science/xenobiology,
		// viro
		/area/station/medical/virology,
		// ai satt
		/area/station/ai_monitored/turret_protected/ai,
	)
	for(var/area/start_area as anything in start_areas)
		var/area/area_instance = GLOB.areas_by_type[start_area]
		if(isnull(area_instance))
			continue
		crawl_area(GLOB.areas_by_type[start_area])

	for(var/area/missed as anything in station_areas_remaining)
		TEST_FAIL("Area Type [missed] was not connected to the atmospherics network")

/// Crawls through an area, iterating over all vents/scrubbers and their connected pipelines
/datum/unit_test/atmospherics_sanity/proc/crawl_area(area/the_area)
	if(!(the_area.type in station_areas_remaining))
		return
	station_areas_remaining -= the_area.type

	var/list/area_scrubbers = the_area.air_scrubbers
	var/list/area_vents = the_area.air_vents
	var/list/datum/pipeline/pipelines = list()

	for(var/obj/machinery/atmospherics/components/component as anything in (area_vents + area_scrubbers))
		for(var/datum/pipeline/vent_node as anything in component.return_pipenets())
			if(!length(vent_node.other_airs))
				TEST_FAIL("Area Type [the_area.type] has an unconnected atmospherics device [component.type]")
				continue
			pipelines |= vent_node

	for(var/datum/pipeline/to_explore as anything in pipelines)
		for(var/obj/machinery/atmospherics/components/other_component as anything in to_explore.other_atmos_machines)
			crawl_area(get_area(other_component))
