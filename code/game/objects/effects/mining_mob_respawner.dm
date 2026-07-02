/// Respawns a mob if it's died and there's a storm
/obj/effect/mining_mob_respawner
	icon = 'icons/turf/overlays.dmi'
	icon_state = "explodable"
	invisibility = INVISIBILITY_ABSTRACT
	/// Do we check the outdoorsness of our spawn tile?
	var/outdoor_only = TRUE
	// Spawn somewhere in an area around the spawner rather than dead on it
	var/respawn_range = 3
	/// Min time from storm to spawn a mob
	var/min_delay = 1 SECONDS
	/// Max time from storm to spawn a mob
	var/max_delay = 10 SECONDS
	/// Our currently spawned mob
	var/datum/weakref/our_mob
	/// Weighted list of things we can spawn
	var/list/valid_mobs = list()
	/// List of things we want to remove from our spawner list before using it
	var/list/invalid_mobs = list(
		SPAWN_MEGAFAUNA,
		/obj/effect/spawner/random/lavaland_mob/raptor,
		/mob/living/basic/mining/tendril,
	)
	/// Types of storm that respawn mobs, we might as well make it static because it's only used on init so there's no point in it supporting VV edits
	var/static/list/valid_weather = list(
		/datum/weather/particle/ash_storm,
		/datum/weather/sand_storm, // We don't have any mining areas with sand but someone might start one there with an anomaly
		/datum/weather/snow_storm,
	)

/obj/effect/mining_mob_respawner/Initialize(mapload)
	. = ..()

	if (mapload && length(valid_mobs))
		var/list/filtered_mobs = list()
		for (var/path in valid_mobs)
			if (!(path in invalid_mobs))
				filtered_mobs += path
		valid_mobs = filtered_mobs

	if (!our_mob?.resolve())
		make_mob()

	// We're just going to go ahead and assume these won't move after being spawned
	for (var/weather in valid_weather)
		RegisterSignal(get_area(src), COMSIG_WEATHER_BEGAN_IN_AREA(weather), PROC_REF(on_storm_event))

/// Let the map generator system pass us a list of mobs
/obj/effect/mining_mob_respawner/proc/setup(list/valid_mobs, atom/initial_spawn)
	src.valid_mobs = valid_mobs

	if (istype(initial_spawn, /obj/effect/spawner/random))
		RegisterSignal(get_turf(src), COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(get_spawned_mob))
	else
		register_spawn(src, initial_spawn)

/// Record something as our spawn, so we don't need to spawn something else
/obj/effect/mining_mob_respawner/proc/register_spawn(atom/source, atom/new_spawn)
	SIGNAL_HANDLER
	if (!new_spawn)
		return
	if (isliving(new_spawn))
		our_mob = WEAKREF(new_spawn)

/// Make a guy and subscribe to see if they die
/obj/effect/mining_mob_respawner/proc/make_mob()
	if (!length(valid_mobs))
		return
	var/spawn_path = pick(valid_mobs)

	var/list/valid_locations = list()

	for(var/turf/turf_in_view in view(respawn_range, get_turf(src)))
		if (isclosedturf(turf_in_view) || (isgroundlessturf(turf_in_view)))
			continue
		if (outdoor_only)
			var/area/turf_area = get_area(turf_in_view)
			if (!turf_area.outdoors) // Don't spawn inside a miner's little pod house
				continue
		valid_locations += turf_in_view

	if (!length(valid_locations))
		return

	var/turf/spawn_turf = pick(valid_locations)
	// Bit roundabout but it's the only way of intercepting mob spawners
	RegisterSignal(spawn_turf, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(get_spawned_mob))
	new spawn_path(spawn_turf)

/// Intercept the next mob spawned on the turf, because we might have spawned an object which spawns a mob instead
/obj/effect/mining_mob_respawner/proc/get_spawned_mob(datum/source, atom/new_spawn)
	SIGNAL_HANDLER
	if (!isliving(new_spawn))
		return

	UnregisterSignal(source, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	register_spawn(source, new_spawn)
	play_spawn_animation(new_spawn, source)

/// When a storm hits & if our mob is dead, make a new one
/obj/effect/mining_mob_respawner/proc/on_storm_event()
	SIGNAL_HANDLER
	var/mob/living/resolved = our_mob?.resolve()
	if (!resolved || resolved.stat == DEAD)
		addtimer(CALLBACK(src, PROC_REF(make_mob)), rand(min_delay, max_delay), TIMER_DELETE_ME)

/// Play an awesome animation
/obj/effect/mining_mob_respawner/proc/play_spawn_animation(mob/living/spawned, turf/spawned_turf)
	if (HAS_TRAIT(spawned, TRAIT_MOVE_FLYING))
		new /obj/effect/fly_down(spawned_turf, spawned)
	else
		new /obj/effect/unburrow(spawned_turf, spawned)
		spawned_turf.Shake(pixelshiftx = 0.5, pixelshifty = 0.5, duration = 2 SECONDS)

/// A "good enough" alpha mask effect that looks like something is coming out of the ground
/// Not guaranteed to look right on things taller than 32 pixels because i didnt want to make a really massive alpha mask
/obj/effect/unburrow
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER
	/// Time in which to animate emerging from the ground
	var/animate_time = 2 SECONDS

/obj/effect/unburrow/Initialize(mapload, atom/movable/thing)
	. = ..()
	if (QDELETED(thing))
		return INITIALIZE_HINT_QDEL
	thing.forceMove(src)
	setup(thing)

/obj/effect/unburrow/proc/setup(atom/movable/thing)
	vis_contents += thing
	thing.pixel_y -= 32
	animate(thing, pixel_y = 32, time = animate_time, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
	thing.Shake(pixelshiftx = 1, pixelshifty = 0.5, duration = animate_time)
	thing.dir = pick(GLOB.cardinals)

	add_filter("alpha_mask", 2, alpha_mask_filter(icon = icon('icons/effects/64x64.dmi', "alpha_unburrow"), y = 16))
	var/filter = get_filter("alpha_mask")
	animate(filter, y = -16, delay = animate_time, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
	addtimer(CALLBACK(src, PROC_REF(release), thing), animate_time + 0.5 SECONDS, TIMER_DELETE_ME)

/obj/effect/unburrow/proc/release(atom/movable/thing)
	if (!QDELETED(thing))
		thing.forceMove(drop_location())
	qdel(src)

/// An effect that shows an object swooping to the ground from above
/obj/effect/fly_down
	alpha = 0
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER
	/// Time in which to animate appearing
	var/animate_time = 0.6 SECONDS

/obj/effect/fly_down/Initialize(mapload, atom/movable/thing)
	. = ..()
	if (!thing)
		thing = new /mob/living/basic/mining/watcher(loc)
	if (QDELETED(thing))
		return INITIALIZE_HINT_QDEL
	thing.forceMove(src)
	setup(thing)

/obj/effect/fly_down/proc/setup(atom/movable/thing)
	vis_contents += thing
	thing.pixel_y += 64
	var/direction = pick(list(1, -1))
	var/anim_offset = 32 * direction
	thing.pixel_x += anim_offset
	thing.dir = direction < 0 ? EAST : WEST

	animate(src, alpha = 255, time = 0.4 SECONDS, flags = ANIMATION_PARALLEL)
	animate(thing, pixel_y = -64, time = animate_time, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
	animate(thing, pixel_x = -anim_offset, time = animate_time, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE, easing = QUAD_EASING | EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(release), thing), animate_time, TIMER_DELETE_ME)

/obj/effect/fly_down/proc/release(atom/movable/thing)
	if (!QDELETED(thing))
		thing.forceMove(drop_location())
	qdel(src)
