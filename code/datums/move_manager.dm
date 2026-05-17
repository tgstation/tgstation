/**
 * Acts as a namespace for movement packet/type related procs
 *
 * Exists to provide an in code implementation of movement looping
 * Replaces things like walk() or walk_to(), among others
 *
 * Because we're doing things in engine, we have a lot more control over how different operations are performed
 * We also get more say in when things happen, so we can subject movements to the whims of the master controller
 * Rather then using a fuck ton of cpu just moving mobs or meteors
 *
 * The goal is to keep the loops themselves reasonably barebone, and implement more advanced behavior and control via the signals
 *
 * This may be bypassed in cases where snowflakes are nessesary, or where performance is important. S not a hard and fast thing
 *
 * Every atom can have a movement packet, which contains information and behavior about currently active loops, and queuing info
 * Loops control how movement actually happens. So there's a "move in this direction" loop, a "move randomly" loop
 *
 * You can find the logic for this control in this file
 *
 * Specifics of how different loops operate can be found in the movement_types.dm file, alongside the [add to loop][/datum/move_manager/proc/add_to_loop] helper procs that use them
 *
**/
/datum/move_manager

GLOBAL_DATUM_INIT(move_manager, /datum/move_manager, new)

///Adds a movable thing to a movement subsystem. Returns TRUE if it all worked, FALSE if it failed somehow
/datum/move_manager/proc/add_to_loop(atom/movable/thing_to_add, datum/controller/subsystem/movement/subsystem = SSmovement, datum/move_loop/loop_type, priority = MOVEMENT_DEFAULT_PRIORITY, flags, datum/extra_info)
	var/datum/movement_packet/our_data = thing_to_add.move_packet
	if(!our_data)
		our_data = new(thing_to_add)

	var/list/arguments = args.Copy(2) //Drop the atom, since the movement packet already knows about it
	return our_data.add_loop(arglist(arguments))

///Returns the subsystem's loop if we're processing on it, null otherwise
/datum/move_manager/proc/processing_on(atom/movable/packet_owner, datum/controller/subsystem/movement/subsystem)
	var/datum/movement_packet/packet = packet_owner.move_packet
	if(!packet)
		return
	var/datum/move_loop/linked_loop = packet.existing_loops[subsystem]
	if(!linked_loop)
		return
	if(linked_loop.flags & MOVEMENT_LOOP_IGNORE_PRIORITY)
		return linked_loop
	if(linked_loop != packet.running_loop)
		return
	return linked_loop

///A packet of information that describes the current state of a moving object
/datum/movement_packet
	///Our parent atom
	var/atom/movable/parent
	///The move loop that's currently running, excluding those that ignore priority.
	var/datum/move_loop/running_loop
	/**
	 * Flags passed from the move loop before it calls move() and unset right after.
	 * Allows for properties of a move loop to be easily checked by mechanics outside of it.
	 * Having this a bitfield rather than a type var means we don't get screwed over
	 * if the move loop gets deleted mid-move, FYI.
	 */
	var/processing_move_loop_flags = NONE
	///Assoc list of subsystems -> loop datum. Only one datum is allowed per subsystem
	var/list/existing_loops = list()

/datum/movement_packet/New(atom/movable/parent)
	src.parent = parent
	parent.move_packet = src

/datum/movement_packet/Destroy(force)
	parent.move_packet = null
	parent = null
	for(var/datum/controller/subsystem/processor as anything in existing_loops)
		var/datum/move_loop/loop = existing_loops[processor]
		if(QDELETED(loop))
			continue
		qdel(loop)
	existing_loops.Cut()
	existing_loops = null //Catch anyone modifying this post del
	return ..()

///Adds a loop to our parent. Returns the created loop if a success, null otherwise
/datum/movement_packet/proc/add_loop(datum/controller/subsystem/movement/subsystem, datum/move_loop/loop_type, priority, flags, datum/extra_info)
	var/datum/move_loop/existing_loop = existing_loops[subsystem]

	if(existing_loop && existing_loop.priority > priority)
		if(!(existing_loop.flags & MOVEMENT_LOOP_IGNORE_PRIORITY) && !(flags & MOVEMENT_LOOP_IGNORE_PRIORITY))
			return //Give up

	if(existing_loop?.compare_loops(arglist(args.Copy(2))))
		return //it already exists stop trying to make the same moveloop

	var/datum/move_loop/new_loop = new loop_type(src, subsystem, parent, priority, flags, extra_info) //Pass the mob to move and ourselves in via new
	var/list/arguments = args.Copy(6) //Just send the args we've not already dealt with

	var/worked_out = new_loop.setup(arglist(arguments)) //Here goes the rest
	if(!worked_out)
		qdel(new_loop)
		return

	existing_loops[subsystem] = new_loop
	if(existing_loop)
		qdel(existing_loop) //We need to do this here because otherwise the packet would think it was empty, and self destruct
	contest_running_loop(new_loop)
	return new_loop

///Attempts to contest the current running move loop. Returns TRUE if the loop is active, FALSE otherwise
/datum/movement_packet/proc/contest_running_loop(datum/move_loop/contestant)
	var/datum/controller/subsystem/movement/contesting_subsystem = contestant.controller

	if(contestant.flags & MOVEMENT_LOOP_IGNORE_PRIORITY)
		contesting_subsystem.add_loop(contestant)
		return TRUE
	if(!running_loop)
		running_loop = contestant
		contesting_subsystem.add_loop(running_loop)
		return TRUE
	if(running_loop.priority > contestant.priority)
		return FALSE

	var/datum/controller/subsystem/movement/current_subsystem = running_loop.controller

	var/current_running_loop = running_loop
	running_loop = contestant
	current_subsystem.remove_loop(current_running_loop)
	if(running_loop != contestant) // A signal registrant could have messed with things
		return FALSE
	contesting_subsystem.add_loop(contestant)
	return TRUE

///Tries to figure out the current favorite loop to run. More complex then just deciding between two different loops, assumes no running loop currently exists
/datum/movement_packet/proc/decide_on_running_loop()
	if(running_loop)
		return
	if(!length(existing_loops)) //Die
		qdel(src)
		return
	var/datum/move_loop/favorite
	for(var/datum/controller/subsystem/movement/owner as anything in existing_loops)
		var/datum/move_loop/checking = existing_loops[owner]
		if(checking.flags & MOVEMENT_LOOP_IGNORE_PRIORITY)
			continue
		if(favorite && favorite.priority > checking.priority)
			continue
		favorite = checking

	if(!favorite) //This isn't an error state, since some loops ignore the concept of a running loop
		return

	var/datum/controller/subsystem/movement/favorite_subsystem = favorite.controller

	running_loop = favorite
	favorite_subsystem.add_loop(running_loop)

/datum/movement_packet/proc/remove_loop(datum/controller/subsystem/movement/remove_from, datum/move_loop/loop_to_remove)
	if(loop_to_remove == running_loop)
		running_loop = null
		remove_from.remove_loop(loop_to_remove)
	if(loop_to_remove.flags & MOVEMENT_LOOP_IGNORE_PRIORITY)
		remove_from.remove_loop(loop_to_remove)
	if(QDELETED(src))
		return
	if(existing_loops[remove_from] == loop_to_remove)
		existing_loops -= remove_from
	decide_on_running_loop()
	return

/datum/movement_packet/proc/remove_subsystem(datum/controller/subsystem/movement/remove)
	var/datum/move_loop/our_loop = existing_loops[remove]
	if(!our_loop)
		return FALSE
	qdel(our_loop)
	return TRUE


/** Astar movement
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * repath_delay - How often we're allowed to recalculate our path
 * max_path_length - The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * miminum_distance - Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example
 * id - An ID card representing what access we have and what doors we can open
 * simulated_only -  Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * avoid - If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * skip_first -  Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break things
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/astar_move(
	moving,
	chasing,
	delay,
	timeout,
	repath_delay,
	max_path_length,
	minimum_distance,
	list/access,
	simulated_only,
	turf/avoid,
	skip_first,
	subsystem,
	priority,
	flags,
	datum/extra_info,
	initial_path,
	use_diagonals,
	datum/callback/heuristic,
)

	return add_to_loop(
		moving,
		subsystem,
		/datum/move_loop/has_target/astar,
		priority,
		flags,
		extra_info,
		delay,
		timeout,
		chasing,
		repath_delay,
		max_path_length,
		minimum_distance,
		access,
		simulated_only,
		avoid,
		skip_first,
		initial_path,
		use_diagonals,
		heuristic,
)
