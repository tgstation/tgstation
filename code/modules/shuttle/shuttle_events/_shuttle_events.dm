///An event that can run during shuttle flight, and will run for the duration of it (configurable)
/datum/shuttle_event
	///How we're announced to ghosts and stuff
	var/name = "The concept of a shuttle event"
	///probability of this event to run from 0 to 100
	var/event_probability = 0
	///Track if we're allowed to run, gets turned to TRUE when the activation timer hits
	VAR_PRIVATE/active = FALSE
	///fraction of the escape timer at which we activate, 0 means we start running immediately
	///(so if activation timer is 0.2 and shuttle takes 3 minutes to get going, it will activate in 36 seconds)
	///We only care about the timer from the moment of launch, any speed changed afterwards are not worth dealing with
	var/activation_fraction = 0
	///when do we activate?
	VAR_PRIVATE/activate_at
	///Our reference to the docking port and thus the shuttle
	var/obj/docking_port/mobile/port

/datum/shuttle_event/New(obj/docking_port/mobile/port)
	. = ..()

	src.port = port

/datum/shuttle_event/proc/start_up_event(evacuation_duration)
	activate_at = world.time + evacuation_duration * activation_fraction

///We got activated
/datum/shuttle_event/proc/activate()
	return

///Process with the SShutle subsystem. Return SHUTTLE_EVENT_CLEAR to self-destruct
/datum/shuttle_event/proc/event_process()
	. = TRUE

	if(!active)
		if(world.time < activate_at)
			return FALSE
		active = TRUE
		. = activate()

///Spawns objects, mobs, whatever with all the necessary code to make it hit and/or miss the shuttle
/datum/shuttle_event/simple_spawner
	///behaviour of spawning objects, if we spawn
	var/spawning_flags = SHUTTLE_EVENT_MISS_SHUTTLE | SHUTTLE_EVENT_HIT_SHUTTLE
	///List of valid spawning turfs, generated from generate_spawning_turfs(), that will HIT the shuttle
	var/list/turf/spawning_turfs_hit
	///List of valid spawning turfs, generated from generate_spawning_turfs(), that will MISS the shuttle
	var/list/turf/spawning_turfs_miss
	///Chance, from 0 to 100, for something to spawn
	var/spawn_probability_per_process = 0
	///Increment if you want more stuff to spawn at once
	var/spawns_per_spawn = 1
	///weighted list with spawnable movables
	var/list/spawning_list = list()
	///If set to TRUE, every time an object is spawned their weight is decreased untill they are removed
	var/remove_from_list_when_spawned = FALSE
	///If set to true, we'll delete ourselves if we cant spawn anything anymore. Useful in conjunction with remove_from_list_when_spawned
	var/self_destruct_when_empty = FALSE

/datum/shuttle_event/simple_spawner/start_up_event(evacuation_duration)
	..()

	generate_spawning_turfs(port.return_coords(), spawning_flags, port.preferred_direction)

///Bounding coords are list(x0, y0, x1, y1) where x0 and y0 are top-left
/datum/shuttle_event/simple_spawner/proc/generate_spawning_turfs(list/bounding_coords, spawning_behaviour, direction)
	spawning_turfs_hit = list() //turfs that will drift its contents to miss the shuttle
	spawning_turfs_miss = list() //turfs that will drift its contents to hit the shuttle
	var/list/step_dir //vector, either -1, 0 or 1. once we get a corner (lets say top right), in which direction do we 'walk' to get the full side? (this case to the right, so (1, 0)
	var/list/target_corner //Top left or bottom right corner
	var/list/spawn_offset //bounding_coords is ONLY the shuttle, not the space around it, so offset spawn_tiles or stuff spawns on the walls of the shuttle

	// Bounding coords sticky to either the top right or bottom left corner of the template, depending on proximity to docking port
	// If we sticky to the bottom right corner, then [1] and [2] will be the bottom right corner, so we need to invert it
	if(bounding_coords[1] > bounding_coords[3])
		bounding_coords = list(bounding_coords[3], bounding_coords[4], bounding_coords[1], bounding_coords[2])

	switch(direction)
		if(NORTH) //we're travelling north (so people get pushed south)
			step_dir = list(1, 0)
			target_corner = list(bounding_coords[1], bounding_coords[2])
			spawn_offset = list(0, SHUTTLE_TRANSIT_BORDER)
		if(SOUTH)
			step_dir = list(-1, 0)
			target_corner = list(bounding_coords[3], bounding_coords[4])
			spawn_offset = list(0, -SHUTTLE_TRANSIT_BORDER)
		if(EAST)
			step_dir = list(0, 1)
			target_corner = list(bounding_coords[3], bounding_coords[4])
			spawn_offset = list(SHUTTLE_TRANSIT_BORDER, 0)
		if(WEST)
			step_dir = list(0, -1)
			target_corner = list(bounding_coords[1], bounding_coords[2])
			spawn_offset = list(-SHUTTLE_TRANSIT_BORDER, 0)

	if(spawning_behaviour & SHUTTLE_EVENT_HIT_SHUTTLE)
		///so we get either the horizontal width or vertical width, which would both equal the amount of spawn tiles
		var/tile_amount = abs((direction == NORTH || SOUTH) ? bounding_coords[1] - bounding_coords[3] :  bounding_coords[2] - bounding_coords[4])
		for(var/i in 0 to tile_amount)
			var/list/target_coords = list(target_corner[1] + step_dir[1] * i + spawn_offset[1], target_corner[2] + step_dir[2] * i + spawn_offset[2])
			spawning_turfs_hit.Add(locate(target_coords[1], target_coords[2], port.z))
	if(spawning_behaviour & SHUTTLE_EVENT_MISS_SHUTTLE)
		for(var/i in 1 to SHUTTLE_TRANSIT_BORDER)
			//Get the corner tile, and move away from the shuttle and towards the cordon
			spawning_turfs_miss.Add(locate(target_corner[1] - step_dir[1] * i + spawn_offset[1], target_corner[2] - step_dir[2] * i + spawn_offset[2], port.z))
			var/corner_delta = list(bounding_coords[3] - bounding_coords[1], bounding_coords[2] - bounding_coords[4])
			//Get the corner tile, but jump over the shuttle and then continue unto the cordon
			spawning_turfs_miss.Add(locate(target_corner[1] + corner_delta[1] * step_dir[1] + step_dir[1] * i + spawn_offset[1], target_corner[2] + corner_delta[2] * step_dir[2] + step_dir[2] * i + spawn_offset[2], port.z))

/datum/shuttle_event/simple_spawner/event_process()
	. = ..()

	if(!.)
		return

	if(!LAZYLEN(spawning_list))
		if(self_destruct_when_empty)
			return SHUTTLE_EVENT_CLEAR
		return

	if(prob(spawn_probability_per_process))
		for(var/i in 1 to spawns_per_spawn)
			spawn_movable(get_type_to_spawn())

///Pick a random turf from the valid turfs we got. Overwrite if you need some custom picking
/datum/shuttle_event/simple_spawner/proc/get_spawn_turf()
	RETURN_TYPE(/turf)
	return pick(spawning_turfs_hit + spawning_turfs_miss)

///Spawn stuff! if you're not using this, don't use the simple_spawner subtype
/datum/shuttle_event/simple_spawner/proc/spawn_movable(spawn_type)
	post_spawn(new spawn_type (get_spawn_turf()))

///Not technically a getter if remove_from_list_when_spawned=TRUE. Otherwise, this returns the type we're going to spawn and throw at the shuttle
/datum/shuttle_event/simple_spawner/proc/get_type_to_spawn()
	. = pick_weight(spawning_list)
	if(remove_from_list_when_spawned) //if we have this enabled, we decrease the pickweight by 1 till it runs out
		spawning_list[.] -= 1
		if(spawning_list[.] < 1)
			spawning_list.Remove(.)

///Do any post-spawn edits you need to do
/datum/shuttle_event/simple_spawner/proc/post_spawn(atom/movable/spawnee)
	ADD_TRAIT(spawnee, TRAIT_FREE_HYPERSPACE_SOFTCORDON_MOVEMENT, INNATE_TRAIT) //Lets us spawn and move further away from the shuttle without being teleported into space
	ADD_TRAIT(spawnee, TRAIT_DEL_ON_SPACE_DUMP, INNATE_TRAIT) //if we hit the cordon, we get deleted. If the shuttle can make you, it can qdel you
