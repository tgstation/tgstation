/// This element hooks a signal onto the loc the current object is on.
/// When the object moves, it will unhook the signal and rehook it to the new object.
/datum/element/connect_loc
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections

/datum/element/connect_loc/Attach(atom/movable/listener, list/connections)
	. = ..()
	if (!istype(listener))
		return ELEMENT_INCOMPATIBLE

	src.connections = connections

	RegisterSignal(listener, COMSIG_MOVABLE_MOVED, .proc/on_moved, override = TRUE)
	update_signals(listener)

/datum/element/connect_loc/Detach(atom/movable/listener)
	. = ..()
	unregister_signals(listener, listener.loc)
	UnregisterSignal(listener, COMSIG_MOVABLE_MOVED)

/datum/element/connect_loc/proc/update_signals(atom/movable/listener)
	var/atom/listener_loc = listener.loc
	if(isnull(listener_loc))
		return

	for (var/signal in connections)
		//override=TRUE because more than one connect_loc element instance tracked object can be on the same loc
		listener.RegisterSignal(listener_loc, signal, connections[signal], override=TRUE)

/datum/element/connect_loc/proc/unregister_signals(datum/listener, atom/old_loc)
	if(isnull(old_loc))
		return

	for (var/signal in connections)
		listener.UnregisterSignal(old_loc, signal)

/datum/element/connect_loc/proc/on_moved(atom/movable/listener, atom/old_loc)
	SIGNAL_HANDLER
	unregister_signals(listener, old_loc)
	update_signals(listener)

/// This element behaves the same as connect_loc, hooking into a signal on a tracked object's turf
/// It has the ability to react to that signal on behalf of a seperate listener however
/// This has great use, primarially for components, but it carries with it some overhead
/// So we do it seperately rather then intigrating the behavior with the main element
/datum/element/connect_loc_behalf
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH | ELEMENT_COMPLEX_DETACH
	id_arg_index = 3

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections

	/// An assoc list of locs that are being occupied and a list of targets that occupy them.
	var/list/targets = list()

/datum/element/connect_loc_behalf/Attach(datum/listener, atom/movable/tracked, list/connections)
	. = ..()
	if (!istype(tracked))
		return ELEMENT_INCOMPATIBLE

	src.connections = connections

	RegisterSignal(tracked, COMSIG_MOVABLE_MOVED, .proc/on_moved, override = TRUE)
	update_signals(listener, tracked)

/datum/element/connect_loc_behalf/Detach(datum/listener, atom/movable/tracked, list/connections)
	. = ..()

	if(!tracked)
		unregister_all(listener)
	else if(targets[tracked.loc]) // Detach can happen multiple times due to qdel
		unregister_signals(listener, tracked, tracked.loc)
		UnregisterSignal(tracked, COMSIG_MOVABLE_MOVED)

/datum/element/connect_loc_behalf/proc/update_signals(datum/listener, atom/movable/tracked)
	var/existing = length(targets[tracked.loc])
	if(!existing)
		targets[tracked.loc] = list()
	targets[tracked.loc][tracked] = listener

	if(isnull(tracked.loc))
		return

	for (var/signal in connections)
		listener.RegisterSignal(tracked.loc, signal, connections[signal], override=TRUE)
		//override=TRUE because more than one connect_loc element instance tracked object can be on the same loc

/datum/element/connect_loc_behalf/proc/unregister_all(datum/listener)
	for(var/atom/location as anything in targets)
		var/list/loc_targets = targets[location]
		for(var/atom/movable/tracked as anything in loc_targets)
			if(tracked == listener)
				unregister_signals(loc_targets[tracked], tracked, location)
			else if(loc_targets[tracked] == listener)
				unregister_signals(listener, tracked, location)
			else
				continue
			UnregisterSignal(tracked, COMSIG_MOVABLE_MOVED)

/datum/element/connect_loc_behalf/proc/unregister_signals(datum/listener, atom/movable/tracked, atom/old_loc)
	if (length(targets[old_loc]) <= 1)
		targets -= old_loc
	else
		targets[old_loc] -= tracked

	// Yes this is after the above because we use null as a key when objects are in nullspace
	if(isnull(old_loc))
		return

	for (var/signal in connections)
		listener.UnregisterSignal(old_loc, signal)

/datum/element/connect_loc_behalf/proc/on_moved(atom/movable/tracked, atom/old_loc)
	SIGNAL_HANDLER
	var/list/objects_in_old_loc = targets[old_loc]
	//You may ask yourself, isn't this just silencing an error?
	//The answer is yes, but there's no good cheap way to fix it
	//What happens is the tracked object or hell the listener gets say, deleted, which makes targets[old_loc] return a null
	//The null results in a bad index, because of course it does
	//It's not a solvable problem though, since both actions, the destroy and the move, are sourced from the same signal send
	//And sending a signal should be agnostic of the order of listeners
	//So we need to either pick the order agnositic, or destroy safe
	//And I picked destroy safe. Let's hope this is the right path!
	if(!objects_in_old_loc)
		return
	var/datum/listener = objects_in_old_loc[tracked]
	if(!listener) //See above
		return
	unregister_signals(listener, tracked, old_loc)
	update_signals(listener, tracked)

