SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING
	flags = SS_TICKER
	var/static/list/sources_queue = list() // List of lighting sources queued for update.
	var/static/list/corners_queue = list() // List of lighting corners queued for update.
	var/static/list/objects_queue = list() // List of lighting objects queued for update.
#ifdef VISUALIZE_LIGHT_UPDATES
	var/allow_duped_values = FALSE
	var/allow_duped_corners = FALSE
#endif

/datum/controller/subsystem/lighting/stat_entry(msg)
	msg = "L:[length(sources_queue)]|C:[length(corners_queue)]|O:[length(objects_queue)]"
	return ..()


/datum/controller/subsystem/lighting/Initialize()
	if(!initialized)
		create_all_lighting_objects()
		initialized = TRUE

	fire(FALSE, TRUE)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK

	var/list/queue = sources_queue
	// This can change when sleeping. I hate sleep()
	var/queue_length = length(queue)
	var/i = 0
	for(i = 1; i <= queue_length; i++)
		var/datum/light_source/L = queue[i]

		L.update_corners()
		L.needs_update = LIGHTING_NO_UPDATE

		// We unroll TICK_CHECK here so we can clear out the queue to ensure any removals/additions when sleeping don't fuck us
		if(init_tick_checks)
			if(!TICK_CHECK)
				continue
			queue.Cut(1, i+1)
			i = 0
			stoplag()
			queue_length = length(queue)
		else if (MC_TICK_CHECK)
			break
	if (i && queue_length)
		queue.Cut(1, i) // we get a postincrement from the final loop, so we don't want +1 here
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	queue = corners_queue
	queue_length = length(queue)
	for(i = 1; i <= queue_length; i++)
		var/datum/lighting_corner/C = queue[i]

		C.needs_update = FALSE //update_objects() can call qdel if the corner is storing no data
		C.update_objects()

		if(init_tick_checks)
			if(!TICK_CHECK)
				continue 
			queue.Cut(1, i+1)
			i = 0
			stoplag()
			queue_length = length(queue)
		else if (MC_TICK_CHECK)
			break
	if (i && queue_length)
		queue.Cut(1, i)
		i = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	queue = objects_queue
	queue_length = length(queue)
	for(i = 1; i <= queue_length; i++)
		var/datum/lighting_object/O = queue[i]

		if (QDELETED(O))
			continue

		O.update()
		O.needs_update = FALSE

		if(init_tick_checks)
			if(!TICK_CHECK)
				continue
			queue.Cut(1, i+1)
			i = 0
			stoplag()
			queue_length = length(queue)
		else if (MC_TICK_CHECK)
			break
	if (i && queue_length)
		queue.Cut(1, i)


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
