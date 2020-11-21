/* TODO:
- Make an element that adds/removes things from poi_list
- SIGNAL_HANDLER
- Change singularity_pull to no longer provide the singularity itself, nothing uses it
- Make this component handle /obj/machinery/field/generator/proc/notify_admins(), it never made sense that generators did that in the first place
*/

/// The range at which a singularity is considered "contained" to admins
#define FIELD_CONTAINMENT_DISTANCE 30

/// Things that maybe move around and does stuff to things around them
/// Used for the singularity (duh) and Nar'Sie
/datum/component/singularity
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

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

/datum/component/singularity/Initialize(
	consume_range = 0,
	consume_callback = CALLBACK(src, .proc/default_singularity_act),
	grav_pull = 4,
	singularity_size = STAGE_ONE,
	disregard_failed_movements = FALSE,
	roaming = TRUE,
)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.consume_callback = consume_callback
	src.consume_range = consume_range
	src.disregard_failed_movements = disregard_failed_movements
	src.grav_pull = grav_pull
	src.singularity_size = singularity_size
	src.roaming = roaming

/datum/component/singularity/RegisterWithParent()
	START_PROCESSING(SSdcs, src)

	// The singularity stops drifting for no man!
	parent.AddElement(/datum/element/forced_gravity, FALSE)

	parent.AddElement(/datum/element/bsa_blocker)
	RegisterSignal(parent, COMSIG_ATOM_BSA_BEAM, .proc/bluespace_reaction)

	RegisterSignal(parent, COMSIG_ATOM_BLOB_ACT, .proc/block_blob)

	RegisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_MOB_ATTACK_HAND,
	), .proc/consume_attack)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/consume_attackby)

	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, .proc/moved)
	RegisterSignal(parent, list(COMSIG_ATOM_BUMPED, COMSIG_MOVABLE_CROSSED), .proc/consume)

	admin_investigate_setup()

/datum/component/singularity/UnregisterFromParent()
	STOP_PROCESSING(SSdcs, src)

	parent.RemoveElement(/datum/element/bsa_blocker)
	parent.RemoveElement(/datum/element/forced_gravity)

	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_BLOB_ACT,
		COMSIG_ATOM_BSA_BEAM,
		COMSIG_ATOM_BUMPED,
		COMSIG_MOB_ATTACK_HAND,
		COMSIG_MOVABLE_CROSSED,
		COMSIG_MOVABLE_PRE_MOVE,
		COMSIG_PARENT_ATTACKBY,
	))

/datum/component/singularity/InheritComponent(datum/component/singularity/old_singularity)
	consume_callback = old_singularity.consume_callback
	consume_range = old_singularity.consume_range
	disregard_failed_movements = old_singularity.disregard_failed_movements
	grav_pull = old_singularity.grav_pull
	roaming = old_singularity.roaming
	singularity_size = old_singularity.singularity_size

/datum/component/singularity/process(delta_time)
	if (roaming)
		move()
	eat()

/datum/component/singularity/proc/block_blob()
	return COMPONENT_CANCEL_BLOB_ACT

/datum/component/singularity/proc/consume(datum/source, atom/thing)
	consume_callback.Invoke(thing, src)

/datum/component/singularity/proc/consume_attack(datum/source, mob/user)
	consume(source, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/singularity/proc/consume_attackby(datum/source, obj/item/item, mob/user)
	consume(source, user)

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
			tile.singularity_pull(parent, singularity_size)
		else
			consume(src, tile)

		for (var/thing in tile)
			if(isturf(atom_parent.loc) && thing != parent)
				var/atom/movable/movable_thing = thing
				if(get_dist(movable_thing, parent) > consume_range)
					movable_thing.singularity_pull(parent, singularity_size)
				else
					consume(src, movable_thing)
			CHECK_TICK

/datum/component/singularity/proc/move()
	var/drifting_dir = pick(GLOB.alldirs - last_failed_movement)
	step(parent, drifting_dir)

/datum/component/singularity/proc/moved(datum/source, atom/new_location)
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

// TODO: Replace this whole thing with signals these types can check for
/datum/component/singularity/proc/can_move(turf/to_move)
	if (!to_move)
		return FALSE

	// TODO: Trait for blocking singularities
	if ((locate(/obj/machinery/field/containment) in to_move) || (locate(/obj/machinery/shieldwall) in to_move))
		return FALSE
	else if (locate(/obj/machinery/field/generator) in to_move)
		var/obj/machinery/field/generator/generator = locate(/obj/machinery/field/generator) in to_move
		if (generator?.active)
			return FALSE
	else if (locate(/obj/machinery/power/shieldwallgen) in to_move)
		var/obj/machinery/power/shieldwallgen/shieldwallgen = locate(/obj/machinery/power/shieldwallgen) in to_move
		if (shieldwallgen?.active)
			return FALSE
	return TRUE

// TODO: Figure out what the hell this does, and fix the names
/datum/component/singularity/proc/check_turfs_in(direction = 0, step = 0)
	if(!direction)
		return FALSE
	var/atom/atom_parent = parent
	var/steps = 0
	if(!step)
		switch(singularity_size)
			if(STAGE_ONE)
				steps = 1
			if(STAGE_TWO)
				steps = 3//Yes this is right
			if(STAGE_THREE)
				steps = 3
			if(STAGE_FOUR)
				steps = 4
			if(STAGE_FIVE)
				steps = 5
	else
		steps = step
	var/list/turfs = list()
	var/turf/T = atom_parent.loc
	for(var/i = 1 to steps)
		T = get_step(T,direction)
	if(!isturf(T))
		return FALSE
	turfs.Add(T)
	var/dir2 = 0
	var/dir3 = 0
	switch(direction)
		if(NORTH||SOUTH)
			dir2 = 4
			dir3 = 8
		if(EAST||WEST)
			dir2 = 1
			dir3 = 2
	var/turf/T2 = T
	for(var/j = 1 to steps-1)
		T2 = get_step(T2,dir2)
		if(!isturf(T2))
			return FALSE
		turfs.Add(T2)
	for(var/k = 1 to steps-1)
		T = get_step(T,dir3)
		if(!isturf(T))
			return FALSE
		turfs.Add(T)
	for(var/turf/T3 in turfs)
		if(isnull(T3))
			continue
		if(!can_move(T3))
			return FALSE
	return TRUE

/// Logs to admins that a singularity was created
/datum/component/singularity/proc/admin_investigate_setup()
	var/turf/spawned_turf = get_turf(parent)
	var/count = locate(/obj/machinery/field/containment) in urange(FIELD_CONTAINMENT_DISTANCE, parent, TRUE)
	if(!count)
		message_admins("A singulo has been created without containment fields active at [ADMIN_VERBOSEJMP(spawned_turf)].")
	var/atom/atom_parent = parent
	atom_parent.investigate_log("was made a singularity at [AREACOORD(spawned_turf)]. [count?"":"<font color='red'>No containment fields were active</font>"]", INVESTIGATE_SINGULO)

/// Fired when the singularity is fired at with the BSA and deletes it
/datum/component/singularity/proc/bluespace_reaction()
	var/atom/atom_parent = parent
	atom_parent.investigate_log("has been shot by bluespace artillery and destroyed.", INVESTIGATE_SINGULO)
	qdel(parent)

#undef FIELD_CONTAINMENT_DISTANCE
