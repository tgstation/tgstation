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

///Temporary proc for use while packets live on the subsystem. I'm going to move them to the objects later, but it makes debugging harder
/datum/controller/subsystem/move_manager/proc/get_packet(atom/movable/packet_holder)
	return packets[packet_holder]
	
///A packet of information that describes the current state of a moving object
/datum/movement_packet
	///Our parent atom
	var/atom/movable/parent
	///The move loop that's currently running
	var/datum/move_loop/running_loop
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

///Adds a loop to our parent. Returns TRUE if a success, FALSE otherwise
/datum/movement_packet/proc/add_loop(datum/controller/subsystem/movement/subsystem, datum/move_loop/loop_type, override)
	var/datum/move_loop/existing_loop = existing_loops[subsystem]
	if(existing_loop && !override)
		return FALSE //Give up

	var/list/arguments = args.Copy(4) //Just send the args we're not dealing with here

	var/datum/move_loop/new_loop = new loop_type(src, subsystem, parent) //Pass the mob to move and ourselves in via new

	var/worked_out = new_loop.setup(arglist(arguments)) //Here goes the rest
	if(!worked_out)
		qdel(new_loop)
		return FALSE

	existing_loops[subsystem] = new_loop
	if(existing_loop)
		qdel(existing_loop) //We need to do this here because otherwise the packet would think it was empty, and self destruct
	contest_running_loop(new_loop)
	return TRUE

///Attempts to contest the current running move loop. Returns TRUE if it succeeds, FALSE otherwise
/datum/movement_packet/proc/contest_running_loop(datum/move_loop/contestant)
	if(!running_loop)
		var/datum/controller/subsystem/movement/contesting_subsystem = contestant.controller
		running_loop = contestant
		contesting_subsystem.add_loop(running_loop)
		return TRUE

	var/datum/controller/subsystem/movement/current_subsystem = running_loop.controller
	var/datum/controller/subsystem/movement/contesting_subsystem = contestant.controller

	if(contesting_subsystem.precedence > current_subsystem.precedence)
		return FALSE

	current_subsystem.remove_loop(running_loop)
	contesting_subsystem.add_loop(contestant)
	return TRUE

///Tries to figure out the current favorite loop to run. More complex then just deciding between two different loops, assumes no running loop currently exists
/datum/movement_packet/proc/decide_on_running_loop()
	if(running_loop)
		return
	if(!length(existing_loops)) //Die
		qdel(src)
		return
	var/datum/controller/subsystem/movement/favorite = existing_loops[1] //Take the first index
	for(var/i in 2 to length(existing_loops))
		var/datum/controller/subsystem/movement/checking = existing_loops[i]
		if(favorite.precedence < checking.precedence)
			continue
		favorite = checking

	var/datum/move_loop/favorite_loop = existing_loops[favorite]
	running_loop = favorite_loop
	favorite.add_loop(running_loop)

/datum/movement_packet/proc/remove_loop(datum/controller/subsystem/movement/remove_from, datum/move_loop/loop_to_remove)
	if(loop_to_remove == running_loop)
		remove_from.remove_loop(loop_to_remove)
		running_loop = null
	if(existing_loops[remove_from] == loop_to_remove)
		existing_loops -= remove_from
	decide_on_running_loop()
	return TRUE

/datum/movement_packet/proc/remove_subsystem(datum/controller/subsystem/movement/remove)
	var/datum/move_loop/our_loop = existing_loops[remove]
	if(!our_loop)
		return FALSE
	qdel(our_loop)
	return TRUE
