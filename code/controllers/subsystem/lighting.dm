SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	dependencies = list(
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/mapping,
	)
	wait = 2
	flags = SS_TICKER
	var/static/list/sources_queue = list() // List of lighting sources queued for update.
	var/static/list/corners_queue = list() // List of lighting corners queued for update.
	var/static/list/objects_queue = list() // List of lighting objects queued for update.
	var/static/list/current_sources = list()
#ifdef VISUALIZE_LIGHT_UPDATES
	var/allow_duped_values = FALSE
	var/allow_duped_corners = FALSE
#endif

/datum/controller/subsystem/lighting/stat_entry(msg)
	msg = "\n  Sources:[length(sources_queue)]|Corners:[length(corners_queue)]|Objects:[length(objects_queue)]"
	return ..()


/datum/controller/subsystem/lighting/Initialize()
	if(!initialized)
		create_all_lighting_objects()
		initialized = TRUE

	fire(FALSE, TRUE)

	return SS_INIT_SUCCESS


/datum/controller/subsystem/lighting/proc/create_all_lighting_objects()
	for(var/area/area as anything in GLOB.areas)
		if(!area.static_lighting)
			continue
		for (var/list/zlevel_turfs as anything in area.get_zlevel_turf_lists())
			for(var/turf/area_turf as anything in zlevel_turfs)
				if(area_turf.space_lit)
					continue
				new /datum/lighting_object(area_turf)
			CHECK_TICK
		CHECK_TICK

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK

	if(!resumed)
		current_sources = sources_queue
		sources_queue = list()

	// UPDATE SOURCE QUEUE
	var/i = 0
	var/list/queue = current_sources
	while(i < length(queue)) //we don't use for loop here because i cannot be changed during an iteration
		i += 1

		var/datum/light_source/L = queue[i]
		L.update_corners()
		if(!QDELETED(L))
			L.needs_update = LIGHTING_NO_UPDATE
		else
			i -= 1 // update_corners() has removed L from the list, move back so we don't overflow or skip the next element

		// We unroll TICK_CHECK here so we can clear out the queue to ensure any removals/additions when sleeping don't fuck us
		if(init_tick_checks)
			if(!TICK_CHECK)
				continue
			queue.Cut(1, i + 1)
			i = 0
			stoplag()
		else if(MC_TICK_CHECK)
			break
	if(i)
		queue.Cut(1, i + 1)
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	// UPDATE CORNERS QUEUE
	queue = corners_queue
	while(i < length(queue)) //we don't use for loop here because i cannot be changed during an iteration
		i += 1

		var/datum/lighting_corner/C = queue[i]
		C.needs_update = FALSE //update_objects() can call qdel if the corner is storing no data
		C.update_objects()

		// We unroll TICK_CHECK here so we can clear out the queue to ensure any removals/additions when sleeping don't fuck us
		if(init_tick_checks)
			if(!TICK_CHECK)
				continue
			queue.Cut(1, i + 1)
			i = 0
			stoplag()
		else if(MC_TICK_CHECK)
			break
	if(i)
		queue.Cut(1, i+1)
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	// UPDATE OBJECTS QUEUE
	queue = objects_queue
	while(i < length(queue)) //we don't use for loop here because i cannot be changed during an iteration
		i += 1

		var/datum/lighting_object/O = queue[i]
		if(QDELETED(O))
			continue
		O.update()
		O.needs_update = FALSE

		// We unroll TICK_CHECK here so we can clear out the queue to ensure any removals/additions when sleeping don't fuck us
		if(init_tick_checks)
			if(!TICK_CHECK)
				continue
			queue.Cut(1, i + 1)
			i = 0
			stoplag()
		else if(MC_TICK_CHECK)
			break
	if(i)
		queue.Cut(1, i + 1)


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
