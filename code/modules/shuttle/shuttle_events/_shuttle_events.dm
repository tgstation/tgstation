///spawned stuff should float by the window and not hit the shuttle
#define SHUTTLE_EVENT_MISS_SHUTTLE 1 << 0
///spawned stuff should hit the shuttle
#define SHUTTLE_EVENT_HIT_SHUTTLE 1 << 1
///we should process with the shuttle subsystem
#define SHUTTLE_EVENT_CLEAR 2

///An event that can run during shuttle flight
/datum/shuttle_event
	///probability of this event to run from 0 to 100
	var/probability
	///behaviour of spawning objects, if we spawn
	var/spawning_flags = SHUTTLE_EVENT_MISS_SHUTTLE | SHUTTLE_EVENT_HIT_SHUTTLE
	///Track if we're allowed to run, gets turned to TRUE when the activation timer hits
	var/active = FALSE
	///fraction of the escape timer at which we activate, 0 means we start running immediately
	///(so if activation timer is 0.2 and shuttle takes 3 minutes to get going, it will activate in 36 seconds)
	///We only care about the timer from the moment of launch, any speed changed afterwards are not worth dealing with
	var/activation_fraction = 0
	///when do we activate?
	var/activate_at
	///Our reference to the docking port and thus the shuttle
	var/obj/docking_port/mobile/port
	///List of valid spawning turfs, generated from generate_spawning_turfs()
	var/list/turf/spawning_turfs

/datum/shuttle_event/New(obj/docking_port/mobile/port)
	. = ..()

	src.port = port

/datum/shuttle_event/proc/start_up_event(evacuation_duration)
	activate_at = world.time + evacuation_duration * activation_fraction

	generate_spawning_turfs(port.return_coords(), spawning_flags, port.preferred_direction)

///We got activated
/datum/shuttle_event/proc/activate()
	return

///Process with the SShutle subsystem
/datum/shuttle_event/proc/event_process()
	. = TRUE

	if(!active)
		if(world.time < activate_at)
			return
		active = TRUE
		. = activate()

///Bounding coords are list(x0, y0, x1, y1) where x0 and y0 are top-left
/datum/shuttle_event/proc/generate_spawning_turfs(list/bounding_coords, spawning_behaviour, direction)
	spawning_turfs = list()
	var/list/step_dir
	var/list/target_corner
	var/list/spawn_offset

	switch(direction)
		if(NORTH)
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
			spawning_turfs.Add(locate(target_coords[1], target_coords[2], port.z))
	if(spawning_behaviour & SHUTTLE_EVENT_MISS_SHUTTLE)
		for(var/i in 0 to SHUTTLE_TRANSIT_BORDER)
			spawning_turfs.Add(locate(target_corner[1] - step_dir[1] * i + spawn_offset[1], target_corner[2] - step_dir[2] * i + spawn_offset[2], port.z))
		for(var/i in 0 to SHUTTLE_TRANSIT_BORDER)
			var/corner_delta = list(bounding_coords[3] - bounding_coords[1], bounding_coords[2] - bounding_coords[4])
			spawning_turfs.Add(locate(target_corner[1] + corner_delta[1] * step_dir[1] + step_dir[1] * i + spawn_offset[1], target_corner[2] + corner_delta[2] * step_dir[2] + step_dir[2] * i + spawn_offset[2], port.z))

/datum/shuttle_event/simple_spawner
	///Change, from 0 to 100, for something to spawn
	var/spawn_probability_per_process = 0
	///Increment if you want more stuff to spawn at once
	var/spawns_per_spawn = 1
	///weighted list with spawnable movables
	var/list/spawning_list = list()

/datum/shuttle_event/simple_spawner/event_process()
	. = ..()

	if(!.)
		return FALSE

	if(prob(spawn_probability_per_process))
		for(var/i in 0 to spawns_per_spawn)
			spawn_stuff()

///Spawn stuff! Draws from spawning_list. It's fine if your event doesnt use this, most just do
/datum/shuttle_event/simple_spawner/proc/spawn_stuff()
	var/spawn_type = pick_weight(spawning_list)
	post_spawn(new spawn_type (pick(spawning_turfs)))

///Do any post-spawn edits you need to do
/datum/shuttle_event/simple_spawner/proc/post_spawn(atom/movable/spawnee)
	ADD_TRAIT(spawnee, TRAIT_FREE_HYPERSPACE_SOFTCORDON_MOVEMENT, src)
	var/turf/target = spawnee.loc
	target.Entered(spawnee) //tell the transit turf we have arrived!

uhh doe dat waar de border ALTIJD dingen weg teleporteerd want ja fuck
/datum/shuttle_event/simple_spawner/italian
	probability = 100
	spawns_per_spawn = 5
	spawning_flags = SHUTTLE_EVENT_MISS_SHUTTLE | SHUTTLE_EVENT_HIT_SHUTTLE
	spawn_probability_per_process = 100
	spawning_list = list(/obj/item/food/spaghetti/boiledspaghetti = 5, /obj/item/food/meatball = 1, /obj/item/food/spaghetti/pastatomato = 2, /obj/item/food/spaghetti/meatballspaghetti = 2)
