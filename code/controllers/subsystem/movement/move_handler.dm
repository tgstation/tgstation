SUBSYSTEM_DEF(move_manager)
	name = "Movement Handler"
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	///A list of all the currently running movement packets
	var/list/datum/movement_packet/packets = list()

/datum/controller/subsystem/move_manager/stat_entry(msg)
	msg = "P:[length(packets)]"
	return ..()

///Adds a movable thing to a movement subsystem. Returns TRUE if it all worked, FALSE if it failed somehow
/datum/controller/subsystem/move_manager/proc/add_to_loop(atom/movable/thing_to_add, datum/controller/subsystem/movement/subsystem = SSmovement, datum/move_loop/loop_type, override=TRUE)
	var/datum/movement_packet/our_data = packets[thing_to_add]
	if(!our_data)
		our_data = new(thing_to_add)
		packets[thing_to_add] = our_data

	var/list/arguments = args.Copy(2) //Drop the atom, since the movement packet already knows about it
	our_data.add_loop(arglist(arguments))

/datum/controller/subsystem/move_manager/proc/remove_from_subsystem(atom/movable/thing_to_remove, datum/controller/subsystem/movement/subsystem = SSmovement)
	var/datum/movement_packet/our_info = packets[thing_to_remove]
	if(!our_info)
		return FALSE
	return our_info.remove_subsystem(subsystem)

///A packet of information that describes the current state of a moving object
/datum/movement_packet
	///Our parent atom
	var/atom/movable/parent
	///Assoc list of subsystems -> loop datum. Only one datum is allowed per subsystem
	var/list/existing_loops = list()

/datum/movement_packet/New(atom/movable/parent)
	src.parent = parent

/datum/movement_packet/Destroy(force)
	SSmove_manager.packets -= parent
	parent = null
	QDEL_LIST(existing_loops)
	existing_loops = null //Catch anyone modifying this post del
	return ..()
	
///Checks if the packet should exist still. If it shouldn't, nukes it
/datum/movement_packet/proc/prove_existence()
	if(length(existing_loops))
		return
	qdel(src)

///Adds a loop to our parent. Returns TRUE if a success, FALSE otherwise
/datum/movement_packet/proc/add_loop(datum/controller/subsystem/movement/subsystem, datum/move_loop/loop_type, override)
	var/datum/move_loop/existing_loop = existing_loops[subsystem]
	if(existing_loop && !override)
		return FALSE //Give up

	var/list/arguments = args.Copy(4) //Just send the args we're not dealing with here

	var/datum/move_loop/new_loop = new loop_type(src, subsystem, parent) //Pass the mob to move and ourselves in via new

	var/worked_out = new_loop.setup(arglist(arguments)) //Here goes the rest

	existing_loops[subsystem] = new_loop

	qdel(existing_loop) //We need to do this here because otherwise the packet would think it was empty, and self destruct
	if(!worked_out)
		qdel(new_loop)
		return FALSE

	subsystem.processing += new_loop

	return TRUE

/datum/movement_packet/proc/remove_loop(datum/controller/subsystem/movement/remove_from, datum/move_loop/loop_to_remove)
	remove_from.processing -= loop_to_remove
	remove_from.currentrun -= loop_to_remove
	if(existing_loops[remove_from] == loop_to_remove)
		existing_loops -= remove_from
	loop_to_remove.owner = null
	loop_to_remove.controller = null
	prove_existence()
	return TRUE

/datum/movement_packet/proc/remove_subsystem(datum/controller/subsystem/movement/remove)
	var/datum/move_loop/our_loop = existing_loops[remove]
	if(!our_loop)
		return FALSE
	return qdel(our_loop)
