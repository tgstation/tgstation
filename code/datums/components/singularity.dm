/// The range at which a singularity is considered "contained" to admins
#define FIELD_CONTAINMENT_DISTANCE 30

/// What's the chance that, when a normal singularity moves, it'll go to its target?
#define CHANCE_TO_MOVE_TO_TARGET 60

/// What's the /bloodthirsty subtype chance it'll go to its target?
#define CHANCE_TO_MOVE_TO_TARGET_BLOODTHIRSTY 80
/// what's the /bloodthirsty subtype chance it'll change targets to a closer one?
#define CHANCE_TO_CHANGE_TARGET_BLOODTHIRSTY 20

/// Things that maybe move around and does stuff to things around them
/// Used for the singularity (duh) and Nar'Sie
/datum/component/singularity
	/// Callback for consuming objects (for example, Nar'Sie replaces this to call narsie_act)
	var/datum/callback/consume_callback

	/// The range to pull in stuff around it
	var/consume_range

	/// Does this singularity move?
	var/roaming

	/// The chosen direction to drift in
	var/drifting_dir

	/// How many tiles out to pull in
	var/grav_pull

	/// The last direction we failed to move in (for example: if we are contained)
	var/last_failed_movement

	/// How big is the singularity?
	var/singularity_size

	/// Should we disregard the possibility of failed movements? Used by stage five singularities
	var/disregard_failed_movements

	/// Can this singularity be BSA'd?
	var/bsa_targetable

	/// Should the admins be alerted when this is created?
	var/notify_admins

	/// If specified, the singularity will slowly move to this target
	var/atom/target

	/// List of turfs we have yet to consume, but need to
	var/list/turf/turfs_to_consume = list()

	/// The time that has elapsed since our last move/eat call
	var/time_since_last_eat

	/// What's the chance that, when a singularity moves, it'll go to its target?
	var/chance_to_move_to_target = CHANCE_TO_MOVE_TO_TARGET

/datum/component/singularity/Initialize(
	bsa_targetable = TRUE,
	consume_range = 0,
	consume_callback = CALLBACK(src, PROC_REF(default_singularity_act)),
	disregard_failed_movements = FALSE,
	grav_pull = 4,
	notify_admins = TRUE,
	singularity_size = STAGE_ONE,
	roaming = TRUE,
)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.bsa_targetable = bsa_targetable
	src.consume_callback = consume_callback
	src.consume_range = consume_range
	src.disregard_failed_movements = disregard_failed_movements
	src.grav_pull = grav_pull
	src.notify_admins = notify_admins
	src.roaming = roaming
	src.singularity_size = singularity_size

/datum/component/singularity/RegisterWithParent()
	START_PROCESSING(SSsinguloprocess, src)

	// The singularity stops drifting for no man!
	parent.AddElement(/datum/element/forced_gravity, FALSE)

	parent.AddElement(/datum/element/bsa_blocker)
	RegisterSignal(parent, COMSIG_ATOM_BSA_BEAM, PROC_REF(bluespace_reaction))

	RegisterSignal(parent, COMSIG_ATOM_BLOB_ACT, PROC_REF(block_blob))

	RegisterSignals(parent, list(
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_PAW,
	), PROC_REF(consume_attack))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(consume_attackby))

	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(moved))
	RegisterSignal(parent, COMSIG_ATOM_BUMPED, PROC_REF(consume))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

	RegisterSignal(parent, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(consume_bullets))

	if (notify_admins)
		admin_investigate_setup()

	GLOB.singularities |= src

/datum/component/singularity/Destroy(force)
	GLOB.singularities -= src
	consume_callback = null
	target = null

	return ..()

/datum/component/singularity/UnregisterFromParent()
	STOP_PROCESSING(SSsinguloprocess, src)

	parent.RemoveElement(/datum/element/bsa_blocker)
	parent.RemoveElement(/datum/element/forced_gravity)

	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_BLOB_ACT,
		COMSIG_ATOM_BSA_BEAM,
		COMSIG_ATOM_PRE_BULLET_ACT,
		COMSIG_ATOM_BUMPED,
		COMSIG_MOVABLE_PRE_MOVE,
		COMSIG_ATOM_ATTACKBY,
	))

/datum/component/singularity/process(seconds_per_tick)
	// We want to move and eat once a second, but want to process our turf consume queue the rest of the time
	time_since_last_eat += seconds_per_tick
	digest()
	if(TICK_CHECK)
		return
	if(time_since_last_eat > 1) // Delta time is in seconds for "reasons"
		time_since_last_eat = 0
		if (roaming)
			move()
		eat()
		digest() // Try and process as much as you can with the time we have left

/datum/component/singularity/proc/block_blob()
	SIGNAL_HANDLER

	return COMPONENT_CANCEL_BLOB_ACT

/// Triggered when something enters the component's parent.
/datum/component/singularity/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	consume(source, arrived)

/datum/component/singularity/proc/consume(datum/source, atom/thing)
	SIGNAL_HANDLER
	if (thing == parent)
		stack_trace("Singularity tried to consume itself.")
		return

	consume_callback?.Invoke(thing, src)

/datum/component/singularity/proc/consume_attack(datum/source, mob/user)
	SIGNAL_HANDLER

	consume(source, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/singularity/proc/consume_attackby(datum/source, obj/item/item, mob/user)
	SIGNAL_HANDLER

	consume(source, user)

// Will there be an impact? Who knows.  Will we see it? No.
/datum/component/singularity/proc/consume_bullets(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	qdel(projectile)
	return COMPONENT_BULLET_BLOCKED

/// Calls singularity_act on the thing passed, usually destroying the object
/datum/component/singularity/proc/default_singularity_act(atom/thing)
	thing.singularity_act(singularity_size, parent)

/datum/component/singularity/proc/eat()
	turfs_to_consume |= spiral_range_turfs(grav_pull, parent)

/datum/component/singularity/proc/digest()
	var/atom/atom_parent = parent

	if(!isturf(atom_parent.loc))
		return

	// We use a static index for this to prevent infinite runtimes.
	// Maybe a might overengineered, but let's be safe yes?
	var/static/cached_index = 0
	if(cached_index)
		var/old_index = cached_index
		cached_index = 0 // Prevents infinite Cut() runtimes. Sorry MSO
		turfs_to_consume.Cut(1, old_index + 1)

	for (cached_index in 1 to length(turfs_to_consume))
		var/turf/tile = turfs_to_consume[cached_index]
		var/dist_to_tile = get_dist(tile, parent)

		if(grav_pull < dist_to_tile) //If we've exited the singulo's range already, just skip us
			continue

		var/in_consume_range = (dist_to_tile <= consume_range)
		if (in_consume_range)
			consume(src, tile)
		else
			tile.singularity_pull(parent, singularity_size)

		for (var/atom/movable/thing as anything in tile)
			if(thing == parent)
				continue
			if (in_consume_range)
				consume(src, thing)
			else
				thing.singularity_pull(parent, singularity_size)

		if(TICK_CHECK) //Yes this means the singulo can eat all of its host subsystem's cpu, but like it's the singulo, and it was gonna do that anyway
			turfs_to_consume.Cut(1, cached_index + 1)
			cached_index = 0
			return

	turfs_to_consume.Cut()
	cached_index = 0

/datum/component/singularity/proc/move()
	var/drifting_dir = pick(GLOB.alldirs - last_failed_movement)

	if (!QDELETED(target) && prob(chance_to_move_to_target))
		drifting_dir = get_dir(parent, target)

	step(parent, drifting_dir)

/datum/component/singularity/proc/moved(datum/source, atom/new_location)
	SIGNAL_HANDLER

	var/atom/atom_parent = parent
	var/current_direction = atom_parent.dir
	var/turf/current_turf = get_turf(parent)

	for(var/dir in GLOB.cardinals)
		if(current_direction & dir)
			current_turf = get_step(current_turf, dir)
			if(!current_turf)
				break
			// eat the stuff if we're going to move into it so it doesn't mess up our movement
			for(var/atom/thing_on_turf in current_turf.contents)
				consume(src, thing_on_turf)
			consume(src, current_turf)

	if(disregard_failed_movements || check_turfs_in(current_direction))
		last_failed_movement = null
	else
		last_failed_movement = current_direction
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/singularity/proc/can_move(turf/to_move)
	if (!to_move)
		return FALSE

	for (var/_thing in to_move)
		var/atom/thing = _thing
		if (SEND_SIGNAL(thing, COMSIG_ATOM_SINGULARITY_TRY_MOVE) & SINGULARITY_TRY_MOVE_BLOCK)
			return FALSE

	return TRUE

/// Makes sure we don't move out of the z-level by checking the turfs around us.
/// Takes in the direction we're going, and optionally how many steps forward to look.
/// If steps are not provided, it will be inferred by singularity_size.
/datum/component/singularity/proc/check_turfs_in(direction, steps)
	if (!direction)
		return FALSE
	var/atom/atom_parent = parent
	if (!steps)
		switch (singularity_size)
			if (STAGE_ONE)
				steps = 1
			if (STAGE_TWO)
				steps = 2
			if (STAGE_THREE)
				steps = 3
			if (STAGE_FOUR)
				steps = 4
			if (STAGE_FIVE)
				steps = 5
	var/list/turfs = list()
	var/turf/farthest_turf = atom_parent.loc
	for (var/_ = 1 to steps)
		farthest_turf = get_step(farthest_turf, direction)
	if (!isturf(farthest_turf))
		return FALSE
	turfs.Add(farthest_turf)
	var/dir2
	var/dir3
	switch (direction)
		if (NORTH, SOUTH)
			dir2 = EAST
			dir3 = WEST
		if (EAST, WEST)
			dir2 = NORTH
			dir3 = SOUTH
	var/turf/farthest_perpendicular_turf = farthest_turf
	for (var/_ = 1 to steps - 1)
		farthest_perpendicular_turf = get_step(farthest_perpendicular_turf, dir2)
		if (!isturf(farthest_perpendicular_turf))
			return FALSE
		turfs.Add(farthest_perpendicular_turf)
	for (var/_ = 1 to steps - 1)
		farthest_turf = get_step(farthest_turf, dir3)
		if (!isturf(farthest_turf))
			return FALSE
		turfs.Add(farthest_turf)
	for (var/turf_in_range in turfs)
		if (isnull(turf_in_range))
			continue
		if (!can_move(turf_in_range))
			return FALSE
	return TRUE

/// Logs to admins that a singularity was created
/datum/component/singularity/proc/admin_investigate_setup()
	var/turf/spawned_turf = get_turf(parent)
	message_admins("A singulo has been created at [ADMIN_VERBOSEJMP(spawned_turf)].")
	var/atom/atom_parent = parent
	atom_parent.investigate_log("was made into a singularity at [AREACOORD(spawned_turf)].", INVESTIGATE_ENGINE)

/// Fired when the singularity is fired at with the BSA and deletes it
/datum/component/singularity/proc/bluespace_reaction()
	SIGNAL_HANDLER
	if (!bsa_targetable)
		return

	var/atom/atom_parent = parent
	atom_parent.investigate_log("has been shot by bluespace artillery and destroyed.", INVESTIGATE_ENGINE)
	qdel(parent)

/datum/component/singularity/bloodthirsty
	chance_to_move_to_target = CHANCE_TO_MOVE_TO_TARGET_BLOODTHIRSTY

/datum/component/singularity/bloodthirsty/move()
	var/atom/atom_parent = parent
	//handle current target
	if(target && !QDELETED(target))
		if(istype(target, /obj/machinery/power/singularity_beacon))
			return ..() //don't switch targets from a singulo beacon
		if(target.z != atom_parent.z)
			target = null
		var/mob/living/potentially_closer = find_new_target()
		if(potentially_closer != target && prob(20))
			target = potentially_closer
	//if we lost that target get a new one
	if(!target || QDELETED(target))
		var/mob/living/new_target = find_new_target()
		new_target?.ominous_nosebleed()
		target = new_target
	return ..()

///Searches the living list for the closest target, and begins chasing them down.
/datum/component/singularity/bloodthirsty/proc/find_new_target()
	var/atom/atom_parent = parent
	var/closest_distance = INFINITY
	var/mob/living/closest_target
	for(var/mob/living/target as anything in GLOB.mob_living_list)
		if(target.z != atom_parent.z)
			continue
		if(HAS_TRAIT(target, TRAIT_GODMODE))
			continue
		var/distance_from_target = get_dist(target, atom_parent)
		if(distance_from_target < closest_distance)
			closest_distance = distance_from_target
			closest_target = target
	return closest_target

#undef CHANCE_TO_MOVE_TO_TARGET
#undef CHANCE_TO_MOVE_TO_TARGET_BLOODTHIRSTY
#undef CHANCE_TO_CHANGE_TARGET_BLOODTHIRSTY
#undef FIELD_CONTAINMENT_DISTANCE
