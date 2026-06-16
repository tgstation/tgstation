/**
 * This test checks that all areas are connected to their distribution loops
 */
/datum/unit_test/atmospherics_sanity
	test_flags = UNIT_TEST_MAP_TEST
	priority = TEST_LONGER // we iterate over all atmospherics devices on the starting networks

	/// List of areas to start crawling from
	var/list/area/starting_areas

	/// List of areas already crawled, to prevent needless crawling
	var/list/area/crawled_areas

	/// List of areas remaining to be checked
	var/list/area/remaining_areas

	/// List of areas that should absolutely not be encountered
	var/list/area/forbidden_areas

	/// We run this test in parallel, so we need to keep track of how many crawls are running
	/// This is to prevent stack overflow mostly
	var/crawls = 0

/datum/unit_test/atmospherics_sanity/proc/prepare_crawl()
	starting_areas = list()
	forbidden_areas = list()
	crawled_areas = list()
	remaining_areas = list()

	for(var/obj/effect/landmark/atmospheric_sanity/start_area/start_marker in GLOB.landmarks_list)
		var/area/starting_area = get_area(start_marker)
		if(starting_area in starting_areas)
			TEST_FAIL("Duplicate atmospherics sanity starting marker in '[starting_area]'([starting_area.type]) at ([start_marker.x], [start_marker.y], [start_marker.z])")
			continue
		if(starting_area.outdoors)
			TEST_FAIL("Atmospherics sanity starting marker cannot be in outdoors area '[starting_area]'([starting_area.type]) at ([start_marker.x], [start_marker.y], [start_marker.z])")
			continue
		starting_areas |= get_area(start_marker)

	if(!length(starting_areas))
		log_test("No starting areas found, defaulting...")

		var/list/area/default_starting_areas = list(
			// These areas have their own air supply
			/area/station/ai/satellite/chamber,
			/area/station/medical/virology,
			/area/station/science/xenobiology,
			// Otherwise, this should connect to the rest of the station
			/area/station/engineering/atmos,
		)

		for(var/area/starting_area as anything in default_starting_areas)
			var/area/station_area = GLOB.areas_by_type[starting_area]
			if(!isnull(station_area))
				starting_areas += station_area


	var/atom/mark_all_station_areas_marker = locate(/obj/effect/landmark/atmospheric_sanity/mark_all_station_areas_as_goal) in GLOB.landmarks_list
	if(!isnull(mark_all_station_areas_marker))
		log_world("Marking all station areas as goal areas due to marker at ([mark_all_station_areas_marker.x], [mark_all_station_areas_marker.y], [mark_all_station_areas_marker.z])")
		mark_station_areas_as_goals()

	else
		for(var/obj/effect/landmark/atmospheric_sanity/goal_area/goal_marker in GLOB.landmarks_list)
			var/area/goal_area = get_area(goal_marker)
			if(goal_area in remaining_areas)
				TEST_FAIL("Duplicate atmospherics sanity goal marker in '[goal_area]'([goal_area.type]) at ([goal_marker.x], [goal_marker.y], [goal_marker.z])")
				continue
			if(goal_area.outdoors)
				TEST_FAIL("Atmospherics sanity goal marker in outdoors area '[goal_area]'([goal_area.type]) at ([goal_marker.x], [goal_marker.y], [goal_marker.z])")
				continue
			remaining_areas |= get_area(goal_marker)

		if(!length(remaining_areas))
			log_test("No goal areas found, defaulting...")
			mark_station_areas_as_goals()
		else
			for(var/obj/effect/landmark/atmospheric_sanity/forbidden_area/forbidden_marker in GLOB.landmarks_list)
				var/area/forbidden_area = get_area(forbidden_marker)
				if(forbidden_area in remaining_areas)
					var/obj/effect/landmark/atmospheric_sanity/goal_area/goal_marker = locate() in forbidden_area
					TEST_FAIL("Area '[forbidden_area]'([forbidden_area.type]) \
						has a goal marker at ([goal_marker.x], [goal_marker.y], [goal_marker.z]) \
						and a forbidden marker at ([forbidden_marker.x], ([forbidden_marker.y], ([forbidden_marker.z])")
					continue
				if(forbidden_area in forbidden_areas)
					TEST_FAIL("Area '[forbidden_area]'([forbidden_area.type]) is so forbidden it has a duplicate marker at at ([forbidden_marker.x], ([forbidden_marker.y], ([forbidden_marker.z])")
					continue

				forbidden_areas |= forbidden_area

	for(var/obj/effect/landmark/atmospheric_sanity/ignore_area/ignore_marker in GLOB.landmarks_list)
		remaining_areas -= get_area(ignore_marker)

/datum/unit_test/atmospherics_sanity/proc/mark_station_areas_as_goals()
	// We don't care if we find these
	var/list/area/ignored_types = list(
		/area/station/asteroid,
		/area/station/holodeck,
		/area/station/maintenance,
		/area/station/science/ordnance/bomb,
		/area/station/solars,

		// FIXME, burnchamber is usually mapped with a vent in the buffer airlock
		// which causes us to leak into freezer. These two should be forbidden
		/area/station/science/ordnance/burnchamber,
		/area/station/science/ordnance/freezerchamber,
	)

	for(var/area/ignored as anything in ignored_types)
		ignored_types |= subtypesof(ignored)

	// We should never find these
	var/list/area/forbidden_types = list(
		/area/station/engineering/supermatter/engine,
		/area/station/tcommsat/server,
	)

	for(var/area/forbidden as anything in forbidden_types)
		forbidden_types |= subtypesof(forbidden)

	for(var/area/station/station_area_type as anything in subtypesof(/area/station) - ignored_types - forbidden_types)
		var/area/station_area = GLOB.areas_by_type[station_area_type]
		if(!isnull(station_area))
			remaining_areas += station_area

	for(var/area/station/forbidden_area_type as anything in forbidden_types)
		var/area/forbidden_area = GLOB.areas_by_type[forbidden_area_type]
		if(!isnull(forbidden_area))
			forbidden_areas += forbidden_area

/datum/unit_test/atmospherics_sanity/Run()
	prepare_crawl()
	for(var/area/start_area as anything in starting_areas)
		ASYNC
			crawl_area(start_area)
	UNTIL(crawls == 0)

	for(var/area/missed as anything in remaining_areas)
		var/turf/first_turf = missed.get_zlevel_turf_lists()[1][1]
		TEST_FAIL("Goal area '[missed]'([missed.type]) is isolated from any distribution loops ([first_turf.x], [first_turf.y], [first_turf.z])")

/// Crawls through an area, iterating over all vents/scrubbers and their connected pipelines
/datum/unit_test/atmospherics_sanity/proc/crawl_area(area/the_area)
	if(the_area in crawled_areas)
		return

	crawls += 1
	crawled_areas |= the_area

	var/list/datum/pipeline/pipelines = list()
	for(var/obj/machinery/atmospherics/components/component as anything in (the_area.air_vents + the_area.air_scrubbers))
		for(var/datum/pipeline/parent as anything in component.parents)
			if(isnull(parent))
				TEST_NOTICE(src, "[component] at ([component.x], [component.y], [component.z]) isn't attached to a pipenet, is this on purpose?")
				continue
			pipelines |= parent

	if((the_area in forbidden_areas) && length(pipelines)) // we don't care if this area is forbidden if it isn't actually connected to the air
		var/turf/first_turf = the_area.get_zlevel_turf_lists()[1][1]
		TEST_FAIL("Forbidden area '[the_area]'([the_area.type]) is connected to a distribution loop at ([first_turf.x], [first_turf.y], [first_turf.z])")
	else
		for(var/datum/pipeline/pipeline as anything in pipelines)
			crawl_pipeline(pipeline)

	crawls -= 1

/// Crawls through a pipeline, iterating over all connected machines and their connected areas
/datum/unit_test/atmospherics_sanity/proc/crawl_pipeline(datum/pipeline/pipeline)
	for(var/obj/machinery/atmospherics/machinery in pipeline.other_atmos_machines)
		var/area/other_area = get_area(machinery)
		remaining_areas -= other_area
		ASYNC
			crawl_area(other_area)
