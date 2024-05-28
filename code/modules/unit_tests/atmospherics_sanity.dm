/**
 * This test checks that all expected areas are connected to a starting area
 */
/datum/unit_test/atmospherics_sanity
	// we iterate over all atmospherics devices on the starting networks
	priority = TEST_LONGER

	/// List of areas remaining to be checked
	var/list/area/remaining_areas

	/// List of areas already crawled, to prevent needless crawling
	var/list/area/crawled_areas

	/// List of areas to start crawling from
	var/list/area/starting_areas

	/// We run this test in parallel, so we need to keep track of how many crawls are running
	/// This is to prevent stack overflow mostly
	var/crawls = 0

/datum/unit_test/atmospherics_sanity/proc/get_areas()
	starting_areas = list()
	for(var/obj/effect/landmark/atmospheric_sanity/start_area/start_marker in GLOB.landmarks_list)
		var/area/starting_area = get_area(start_marker)
		if(starting_area in starting_areas)
			TEST_FAIL("Duplicate atmospherics sanity starting marker in '[starting_area]'([starting_area.type]) at ([start_marker.x], [start_marker.y], [start_marker.z])")
			continue
		if(starting_area.outdoors)
			TEST_FAIL("Atmospherics sanity starting marker in outdoors area '[starting_area]'([starting_area.type]) at ([start_marker.x], [start_marker.y], [start_marker.z])")
			continue
		starting_areas |= get_area(start_marker)

		// If there are no starting areas, default to these
	var/static/list/area/default_starting_areas = list(
		/area/station/ai_monitored/turret_protected/ai,
		/area/station/engineering/atmos,
		/area/station/medical/virology,
		/area/station/science/xenobiology,
		)

	if(!length(starting_areas))
		log_test("No starting areas found, defaulting...")
		for(var/area/starting_area as anything in default_starting_areas)
			var/area/station_area = GLOB.areas_by_type[starting_area]
			if(!isnull(station_area))
				starting_areas += station_area

	remaining_areas = list()

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
			if(istype(goal_area, /area/space))
				TEST_FAIL("Atmospherics sanity goal marker in space at ([goal_marker.x], [goal_marker.y], [goal_marker.z])")
				continue
			remaining_areas |= get_area(goal_marker)

		if(!length(remaining_areas))
			log_test("No goal areas found, defaulting...")
			mark_station_areas_as_goals()

	for(var/obj/effect/landmark/atmospheric_sanity/ignore_area/ignore_marker in GLOB.landmarks_list)
		remaining_areas -= get_area(ignore_marker)

/datum/unit_test/atmospherics_sanity/proc/mark_station_areas_as_goals()
	// We don't want to check these areas
	var/static/list/area/ignored_types = list(
		/area/station/asteroid,
		/area/station/engineering/supermatter,
		/area/station/holodeck,
		/area/station/maintenance,
		/area/station/science/ordnance/bomb,
		/area/station/science/ordnance/burnchamber,
		/area/station/science/ordnance/freezerchamber,
		/area/station/solars,
		/area/station/tcommsat/server,
	)

	for(var/area/ignored as anything in ignored_types)
		ignored_types |= subtypesof(ignored)

	for(var/area/station/station_area_type as anything in subtypesof(/area/station) - ignored_types)
		var/area/station_area = GLOB.areas_by_type[station_area_type]
		if(!isnull(station_area))
			remaining_areas += station_area

/datum/unit_test/atmospherics_sanity/Run()
	get_areas()
	crawl_areas()
	UNTIL(crawls == 0)
	for(var/area/missed as anything in remaining_areas)
		if(missed.has_contained_turfs())
			var/turf/first_turf = missed.get_zlevel_turf_lists()[1][1]
			TEST_FAIL("Disconnected Area '[missed]'([missed.type]) at ([first_turf.x], [first_turf.y], [first_turf.z])")
		else
			TEST_NOTICE(src, "Disconnected Area '[missed]'([missed.type]) with no turfs?")

/// Iterates over starting_areas and ensures that all goal areas are connected to atleast one start
/datum/unit_test/atmospherics_sanity/proc/crawl_areas()
	crawled_areas = list()
	for(var/area/start_area as anything in starting_areas)
		ASYNC
			crawl_area(start_area)
	starting_areas = null

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
				TEST_NOTICE(src, "Found a null parent for [component] in [the_area] at ([component.x], [component.y], [component.z])")
				continue
			pipelines |= parent

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
