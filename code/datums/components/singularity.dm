/// The range at which a singularity is considered "contained" to admins
#define FIELD_CONTAINMENT_DISTANCE 30

/// What's the chance that, when a singularity moves, it'll go to its target?
#define CHANCE_TO_MOVE_TO_TARGET 60

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

/datum/component/singularity/Initialize(
	bsa_targetable = TRUE,
	consume_range = 0,
	consume_callback = CALLBACK(src, .proc/default_singularity_act),
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
	START_PROCESSING(SSdcs, src)

	// The singularity stops drifting for no man!
	parent.AddElement(/datum/element/forced_gravity, FALSE)

	parent.AddElement(/datum/element/bsa_blocker)
	RegisterSignal(parent, COMSIG_ATOM_BSA_BEAM, .proc/bluespace_reaction)

	RegisterSignal(parent, COMSIG_ATOM_BLOB_ACT, .proc/block_blob)

	RegisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_PAW,
	), .proc/consume_attack)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/consume_attackby)

	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, .proc/moved)
	RegisterSignal(parent, COMSIG_ATOM_BUMPED, .proc/consume)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/consume,
	)
	AddElement(/datum/element/connect_loc, parent, loc_connections)

	RegisterSignal(parent, COMSIG_ATOM_BULLET_ACT, .proc/consume_bullets)

	if (notify_admins)
		admin_investigate_setup()

	GLOB.singularities |= src

/datum/component/singularity/Destroy(force, silent)
	GLOB.singularities -= src
	QDEL_NULL(consume_callback)
	target = null

	return ..()

/datum/component/singularity/UnregisterFromParent()
	STOP_PROCESSING(SSdcs, src)

	parent.RemoveElement(/datum/element/bsa_blocker)
	parent.RemoveElement(/datum/element/forced_gravity)

	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_BLOB_ACT,
		COMSIG_ATOM_BSA_BEAM,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_BUMPED,
		COMSIG_MOVABLE_PRE_MOVE,
		COMSIG_PARENT_ATTACKBY,
	))

/datum/component/singularity/process(delta_time)
	if (roaming)
		move()
	eat()

/datum/component/singularity/proc/block_blob()
	SIGNAL_HANDLER

	return COMPONENT_CANCEL_BLOB_ACT

/datum/component/singularity/proc/consume(datum/source, atom/thing)
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

/// Calls singularity_act on the thing passed, usually destroying the object
/datum/component/singularity/proc/default_singularity_act(atom/thing)
	thing.singularity_act(singularity_size, parent)

/datum/component/singularity/proc/eat()
	var/atom/atom_parent = parent

	for (var/_tile in spiral_range_turfs(grav_pull, parent))
		var/turf/tile = _tile
		if (!tile || !isturf(atom_parent.loc))
			continue
		if (get_dist(tile, parent) > consume_range)
			tile.singularity_pull(src, singularity_size)
		else
			consume(src, tile)

		for (var/_thing in tile)
			var/atom/thing = _thing

			// Because we can possibly yield in the middle of iteration, let's make sure what were looking at is still there
			// Without this, you get "Qdeleted thing being thrown around"
			if (QDELETED(thing))
				continue

			if (isturf(atom_parent.loc) && thing != parent)
				var/atom/movable/movable_thing = thing
				if (get_dist(movable_thing, parent) > consume_range)
					movable_thing.singularity_pull(parent, singularity_size)
				else
					consume(src, movable_thing)

			CHECK_TICK

/datum/component/singularity/proc/move()
	var/drifting_dir = pick(GLOB.alldirs - last_failed_movement)

	if (!QDELETED(target) && prob(CHANCE_TO_MOVE_TO_TARGET))
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
				steps = 3//Yes this is right
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
		if (NORTH || SOUTH)
			dir2 = EAST
			dir3 = WEST
		if (EAST || WEST)
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
	atom_parent.investigate_log("was made a singularity at [AREACOORD(spawned_turf)].", INVESTIGATE_SINGULO)

/// Fired when the singularity is fired at with the BSA and deletes it
/datum/component/singularity/proc/bluespace_reaction()
	SIGNAL_HANDLER
	if (!bsa_targetable)
		return

	var/atom/atom_parent = parent
	atom_parent.investigate_log("has been shot by bluespace artillery and destroyed.", INVESTIGATE_SINGULO)
	qdel(parent)

#undef CHANCE_TO_MOVE_TO_TARGET
#undef FIELD_CONTAINMENT_DISTANCE
