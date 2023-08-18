/*
voidcrew TODO:
	SSovermap originally fired to apply the planet effects but these would be way better off just using signals



*/

#define MAX_OVERMAP_EVENT_CLUSTERS 8
#define MAX_OVERMAP_EVENTS 70
#define MAX_OVERMAP_PLACEMENT_ATTEMPTS 20
#define MAX_OVERMAP_PLANETS_TO_SPAWN 5

SUBSYSTEM_DEF(overmap)
	name = "Overmap"
	wait = 10
	init_order = INIT_ORDER_OVERMAP
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME

	/// Centre of the overmap
	var/turf/overmap_centre
	/// Map of tiles at each radius around the sun
	var/list/turf/radius_tiles = list()
	/// List of all events
	var/list/events = list()

	var/size = OVERMAP_SIZE
	//List of all mapzones
	var/list/map_zones = list()
	///List of all simulated ships
	var/list/simulated_ships = list()
	/// Timer ID of the timer used for telling which stage of an endround "jump" the ships are in
	var/jump_timer
	/// Current state of the jump
	var/jump_mode = BS_JUMP_IDLE
	/// Time taken for bluespace jump to begin after it is requested (in deciseconds)
	var/jump_request_time = 6000
	/// Time taken for a bluespace jump to complete after it initiates (in deciseconds)
	var/jump_completion_time = 1200

	var/datum/map_template/shuttle/voidcrew/initial_ship_template
	var/obj/structure/overmap/ship/initial_ship

/datum/controller/subsystem/overmap/Initialize(start_timeofday)
	create_map()
	setup_sun()
	setup_dangers()
	setup_planets()
	spawn_initial_ship()

	return SS_INIT_SUCCESS
/*
 * Bluespace jump procs
 */

/**
 * ## request_jump
 *
 * Requests a bluespace jump, which, after jump_request_time deciseconds, will initiate a bluespace jump.
 *
 * Arguments:
 * * modifiers - (Optional) Modifies the length of the jump request time (defaults to 1)
 */
/datum/controller/subsystem/overmap/proc/request_jump(modifier = 1)
	jump_mode = BS_JUMP_CALLED
	jump_timer = addtimer(CALLBACK(src, PROC_REF(initiate_jump)), jump_request_time * modifier, TIMER_STOPPABLE)
	priority_announce("Preparing for jump. ETD: [jump_request_time * modifier / 600] minutes.", null, null, "Priority")

/**
 * ##cancel_jump
 *
 * Cancels a currently requested bluespace jump.
 * Can only be done after the jump has been requested, but before the jump has actually begun.
 */
/datum/controller/subsystem/overmap/proc/cancel_jump()
	if(jump_mode != BS_JUMP_CALLED)
		return
	deltimer(jump_timer)
	jump_mode = BS_JUMP_IDLE
	priority_announce("Bluespace jump cancelled.", null, null, "Priority")

/**
 * ##initiate_jump
 *
 * Initiates a bluespace jump, ending the round after a delay of jump_completion_time deciseconds.
 * This cannot be interrupted by conventional means.
 */
/datum/controller/subsystem/overmap/proc/initiate_jump()
	jump_mode = BS_JUMP_INITIATED
	for(var/obj/docking_port/mobile/voidcrew/mobile_port as anything in SSshuttle.mobile_docking_ports)
		mobile_port.hyperspace_sound(HYPERSPACE_WARMUP, mobile_port.shuttle_areas)
		mobile_port.on_emergency_launch()

	priority_announce("Jump initiated. ETA: [jump_completion_time / 600] minutes.", null, null, "Priority")
	jump_timer = addtimer(VARSET_CALLBACK(src, jump_mode, BS_JUMP_COMPLETED), jump_completion_time)

/datum/controller/subsystem/overmap/proc/create_map()
	// creates the overmap area and sets it up
	var/area/overmap/overmap_area = new
	overmap_area.setup("Overmap")

	// locates the area we want the overmap to be
	var/turf/top_left = locate(OVERMAP_LEFT_SIDE_COORD, OVERMAP_NORTH_SIDE_COORD, OVERMAP_Z_LEVEL)
	var/turf/bottom_right = locate(OVERMAP_RIGHT_SIDE_COORD, OVERMAP_SOUTH_SIDE_COORD, OVERMAP_Z_LEVEL)
	var/list/overmap_turfs = block(top_left, bottom_right)
	for (var/turf/overmap_turf as anything in overmap_turfs)
		if (overmap_turf.x == OVERMAP_LEFT_SIDE_COORD || overmap_turf.x == OVERMAP_RIGHT_SIDE_COORD || overmap_turf.y == OVERMAP_NORTH_SIDE_COORD || overmap_turf.y == OVERMAP_SOUTH_SIDE_COORD)
			overmap_turf.ChangeTurf(/turf/closed/overmap_edge)
		else
			overmap_turf.ChangeTurf(/turf/open/overmap)
		var/area/old_area = get_area(overmap_turf)
		old_area.turfs_to_uncontain += overmap_turf
		overmap_area.contents += overmap_turf
		overmap_area.contained_turfs += overmap_turf
	overmap_area.reg_in_areas_in_z()
	// not actually the centre but close enough
	overmap_centre = get_turf(locate((OVERMAP_LEFT_SIDE_COORD + ((OVERMAP_SIZE - 1) / 2)) - 1, (OVERMAP_SOUTH_SIDE_COORD + ((OVERMAP_SIZE - 1) / 2)) - 1, OVERMAP_Z_LEVEL))

/datum/controller/subsystem/overmap/proc/setup_sun()
	var/turf/open/overmap/centre_tile = overmap_centre
	if(!istype(centre_tile))
		can_fire = FALSE
		message_admins("Overmap failed to generate the map, this is a critical error.")
		CRASH("Overmap did not generate correctly!")

	var/obj/structure/overmap/star/big/star_to_spawn = pick(/obj/structure/overmap/star/big, /obj/structure/overmap/star/big/binary)
	star_to_spawn = new
	star_to_spawn.forceMove(centre_tile)

	var/list/unsorted_turfs = get_area_turfs(/area/overmap, target_z = OVERMAP_Z_LEVEL)
	var/max_ring = 0
	for (var/turf/turf as anything in unsorted_turfs)
		if (istype(turf, /turf/closed/overmap_edge))
			continue
		// the overmap is a square, so we can just use the x and y values to determine the actual ring
		// 2 2 2 2 2
		// 2 1 1 1 2
		// 2 1 X 1 2
		// 2 1 1 1 2
		// 2 2 2 2 2
		var/ring_x = turf.x - (overmap_centre.x + 1)
		var/ring_y = turf.y - (overmap_centre.y + 1)
		var/ring = max(abs(ring_x), abs(ring_y))
		if (!ring)
			continue
		if (ring > max_ring)
			for (var/i in 1 to ring - max_ring)
				radius_tiles += list(list())
			max_ring = ring
		LAZYADDASSOC(radius_tiles, ring, turf)

/datum/controller/subsystem/overmap/proc/get_unused_overmap_square(thing_not_to_have = /obj/structure/overmap, tries = MAX_OVERMAP_PLACEMENT_ATTEMPTS, force = FALSE)
	var/turf/turf_to_return
	for (var/_ in 1 to tries)
		turf_to_return = pick(block(locate(OVERMAP_LEFT_SIDE_COORD + 1, OVERMAP_SOUTH_SIDE_COORD + 1, OVERMAP_Z_LEVEL), locate(OVERMAP_RIGHT_SIDE_COORD - 1, OVERMAP_NORTH_SIDE_COORD - 1, OVERMAP_Z_LEVEL))) // todo : see if this is expensive
		if (locate(thing_not_to_have) in turf_to_return)
			continue
		return turf_to_return
	if (!force)
		turf_to_return = null
	return turf_to_return

/datum/controller/subsystem/overmap/proc/get_unused_overmap_square_in_radius(radius, thing_not_to_have = /obj/structure/overmap, tries = MAX_OVERMAP_PLACEMENT_ATTEMPTS, force = FALSE)
	if (!radius)
		radius = rand(2, length(radius_tiles) / 2)

	var/turf/turf_to_return
	for (var/_ in 1 to tries)
		turf_to_return = pick(radius_tiles[radius])
		if (locate(thing_not_to_have) in turf_to_return)
			continue
		return turf_to_return

	if (!force)
		turf_to_return = null
	return turf_to_return


/datum/controller/subsystem/overmap/proc/setup_dangers()
	var/list/orbits = list()
	for (var/i in 2 to LAZYLEN(radius_tiles))
		orbits += "[i]"

	for (var/_ in 1 to MAX_OVERMAP_EVENT_CLUSTERS)
		if (MAX_OVERMAP_EVENTS <= LAZYLEN(events))
			return
		if (LAZYLEN(orbits) == 0 || !orbits)
			break // can't fit anymore in
		var/selected_orbit = text2num(pick(orbits))

		var/turf/turf_for_event = get_unused_overmap_square_in_radius(selected_orbit)
		if (!turf_for_event || !istype(turf_for_event))
			orbits -= "[selected_orbit]" // this one is full
			continue
		var/event_type = pick_weight(GLOB.overmap_event_pick_list)
		var/obj/structure/overmap/event/event_to_spawn = new event_type(turf_for_event)
		for (var/turf/turf_to_spawn as anything in radius_tiles[selected_orbit])
			if (locate(/obj/structure/overmap) in turf_to_spawn)
				continue
			if (!prob(event_to_spawn.spread_chance))
				continue
			new event_type(turf_to_spawn)

/datum/controller/subsystem/overmap/proc/setup_planets()
	var/list/planets = list()
	for(var/datum/overmap/planet/planet_type as anything in subtypesof(/datum/overmap/planet))
		if(initial(planet_type.spawn_rate) > 0)
			planets += planet_type


	var/list/orbits = list()
	for (var/i in 2 to LAZYLEN(radius_tiles))
		orbits += "[i]"

	for (var/_ in 1 to MAX_OVERMAP_PLANETS_TO_SPAWN)
		if (LAZYLEN(orbits) == 0 || !orbits)
			break // can't fit anymore in
		var/selected_orbit = text2num(pick(orbits))

		var/turf/turf_for_planet = get_unused_overmap_square_in_radius(selected_orbit)
		if (!turf_for_planet || !istype(turf_for_planet))
			orbits -= "[selected_orbit]" // this one is full
			continue

		var/planet_type = pick(planets)
		var/obj/structure/overmap/planet/planet_to_spawn = new
		planet_to_spawn.planet = planet_type
		planet_to_spawn.forceMove(turf_for_planet)

		// Transfer all of the data from the planet datum onto the planet object
		var/datum/overmap/planet/planet_info = new planet_to_spawn.planet
		planet_to_spawn.name = planet_info.name
		planet_to_spawn.desc = planet_info.desc
		planet_to_spawn.icon_state = planet_info.icon_state
		planet_to_spawn.color = planet_info.color
		qdel(planet_info)

// TODO - MULTI-Z VLEVELS
/datum/controller/subsystem/overmap/proc/calculate_turf_above(turf/T)
	return

// TODO - MULTI-Z VLEVELS
/datum/controller/subsystem/overmap/proc/calculate_turf_below(turf/T)
	return

/**
 * At the start of the game, we want to make sure there is a ship on the overmap for people to join.
 * If there is no default template, we iterate through subtypes and run various checks to see if its a valid ship.
 * When we find a valid template we use it to spawn a ship.
 */
/datum/controller/subsystem/overmap/proc/spawn_initial_ship()
#ifdef UNIT_TESTS
	var/list/remaining_templates = subtypesof(/datum/map_template/shuttle/voidcrew)
	for(var/templates in remaining_templates)
		var/datum/map_template/shuttle/voidcrew/loaded_template = SSshuttle.create_ship(templates)
		if(!initial_ship_template)
			initial_ship_template = loaded_template
		if(!loaded_template)
			log_mapping("[src] failed to load ship [templates].")
#else
	if(!set_initial_ship())
		return
	initial_ship = SSshuttle.create_ship(initial_ship_template)
	if(!initial_ship)
		CRASH("Failed to spawn initial ship.")

	RegisterSignal(initial_ship, COMSIG_PARENT_QDELETING, PROC_REF(handle_initial_ship_deletion))
#endif

/**
 * Attempts to set an initial ship template.
 * If one is already set, this will return out.
 * If a ship is set, initial_ship_template will be set to it, and it will return TRUE, otherwise FALSE.
 */
/datum/controller/subsystem/overmap/proc/set_initial_ship()
	if(initial_ship_template)
		return TRUE

	var/list/remaining_templates = subtypesof(/datum/map_template/shuttle/voidcrew)
	while(!initial_ship_template && LAZYLEN(remaining_templates))
		var/datum/map_template/shuttle/voidcrew/random_template = pick_n_take(remaining_templates)
		if(initial(random_template.abstract) == random_template)
			continue
		// the first ship will always be an NT or Syndicate one.
		if(initial(random_template.faction_prefix) == NEUTRAL_SHIP)
			continue
		initial_ship_template = random_template
		return TRUE

	stack_trace("Failed to find a valid initial ship template to spawn.")
	return FALSE

/datum/controller/subsystem/overmap/proc/handle_initial_ship_deletion(datum/source)
	SIGNAL_HANDLER

	initial_ship = null
	message_admins("Overmap Starter Ship was deleted. You may want to investigate or spawn a new one!")



	/**
  * Reserves a square dynamic encounter area, and spawns a ruin in it if one is supplied.
  * * on_planet - If the encounter should be on a generated planet. Required, as it will be otherwise inaccessible.
  * * target - The ruin to spawn, if any
  * * ruin_type - The ruin to spawn. Don't pass this argument if you want it to randomly select based on planet type.
  */

  /**
 * ##get_ruin_list
 *
 * Returns the SSmapping list of ruins, according to the given desired ruin type
 *
 * Arguments:
 * * ruin_type - a string, depicting the desired ruin type
 */
/datum/controller/subsystem/overmap/proc/get_ruin_list(ruin_type)
	switch(ruin_type) // temporary because SSmapping needs a refactor to make this any better
		if (ZTRAIT_LAVA_RUINS)
			return SSmapping.lava_ruins_templates
		if (ZTRAIT_ICE_RUINS)
			return SSmapping.ice_ruins_templates
		if (ZTRAIT_JUNGLE_RUINS)
			return SSmapping.jungle_ruins_templates
		if (ZTRAIT_REEBE_RUINS)
			return SSmapping.yellow_ruins_templates
		if (ZTRAIT_SPACE_RUINS)
			return SSmapping.space_ruins_templates
		if (ZTRAIT_BEACH_RUINS)
			return SSmapping.beach_ruins_templates
		if (ZTRAIT_WASTELAND_RUINS)
			return SSmapping.wasteland_ruins_templates

/datum/controller/subsystem/overmap/proc/spawn_dynamic_encounter(datum/overmap/planet/planet_type, ruin = TRUE, ignore_cooldown = FALSE, datum/map_template/ruin/ruin_type)
	log_shuttle("SSOVERMAP: SPAWNING DYNAMIC ENCOUNTER STARTED")
	var/list/ruin_list
	var/datum/map_generator/mapgen
	var/area/target_area
	var/datum/weather/weather_controller_type
	var/datum/planet/planet_template
	if(!isnull(planet_type))
		planet_type = new planet_type
		ruin_list = get_ruin_list(planet_type.ruin_type)
		if(!isnull(planet_type.mapgen))
			mapgen = new planet_type.mapgen
		target_area = planet_type.target_area
		weather_controller_type = planet_type.weather_controller_type
		if(!(isnull(planet_type.planet_template)))
			planet_template = new planet_type.planet_template
		qdel(planet_type)

	if(ruin && ruin_list && !ruin_type)
		ruin_type = ruin_list[pick(ruin_list)]
		if(ispath(ruin_type))
			ruin_type = new ruin_type

	var/encounter_name = "Dynamic Overmap Encounter"
	var/datum/map_zone/mapzone = find_free_mapzone()
	var/datum/space_level/zlevel
	if(isnull(mapzone))
		mapzone = create_map_zone(encounter_name)
		zlevel = SSmapping.add_new_zlevel(encounter_name, list(ZTRAIT_MINING = TRUE))
		mapzone.add_space_level(zlevel)
	else
		if(mapzone.z_levels[1])
			zlevel = mapzone.z_levels[1]
		else
			zlevel = SSmapping.add_new_zlevel(encounter_name, list(ZTRAIT_MINING = TRUE))
			mapzone.add_space_level(zlevel)

	mapzone.taken = TRUE

	zlevel.fill_in(area_override = target_area)

	if(ruin_type)
		var/turf/ruin_turf = locate(rand(
			zlevel.low_x+6,
			zlevel.high_x-ruin_type.width-6),
			zlevel.high_y-ruin_type.height-6,
			zlevel.z_value
			)
		ruin_type.load(ruin_turf)

	if (!isnull(mapgen) && istype(mapgen, /datum/map_generator/planet_generator) && !isnull(planet_template))
		mapgen.generate_terrain(zlevel.get_block(), planet_template)
	else
		if (!isnull(mapgen))
			mapgen.generate_terrain(zlevel.get_block())
	if(weather_controller_type)
		new weather_controller_type(mapzone)


	// locates the first dock in the bottom left, accounting for padding and the border
	var/turf/primary_docking_turf = locate(
		zlevel.low_x+RESERVE_DOCK_DEFAULT_PADDING+1,
		zlevel.low_y+RESERVE_DOCK_DEFAULT_PADDING+1,
		zlevel.z_value
		)
	// now we need to offset to account for the first dock
	var/turf/secondary_docking_turf = locate(
		primary_docking_turf.x+RESERVE_DOCK_MAX_SIZE_LONG+RESERVE_DOCK_DEFAULT_PADDING,
		primary_docking_turf.y,
		primary_docking_turf.z
		)

	//This check exists because docking ports don't like to be deleted.
	var/obj/docking_port/stationary/primary_dock = new(primary_docking_turf)
	primary_dock.dir = NORTH
	primary_dock.name = "\improper Uncharted Space"
	primary_dock.height = RESERVE_DOCK_MAX_SIZE_SHORT
	primary_dock.width = RESERVE_DOCK_MAX_SIZE_LONG
	primary_dock.dheight = 0
	primary_dock.dwidth = 0

	var/obj/docking_port/stationary/secondary_dock = new(secondary_docking_turf)
	secondary_dock.dir = NORTH
	secondary_dock.name = "\improper Uncharted Space"
	secondary_dock.height = RESERVE_DOCK_MAX_SIZE_SHORT
	secondary_dock.width = RESERVE_DOCK_MAX_SIZE_LONG
	secondary_dock.dheight = 0
	secondary_dock.dwidth = 0

	return list(mapzone, primary_dock, secondary_dock)


/datum/controller/subsystem/overmap/proc/create_map_zone(new_name)
	return new /datum/map_zone(new_name)

/datum/controller/subsystem/overmap/proc/find_free_mapzone()
	. = null
	for(var/datum/map_zone/mapzone as anything in map_zones)
		if(!mapzone.taken)
			return(mapzone)




