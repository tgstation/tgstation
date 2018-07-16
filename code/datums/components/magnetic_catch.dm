/datum/component/magnetic_catch/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	if(ismovableatom(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/crossed_react)
		RegisterSignal(parent, COMSIG_MOVABLE_UNCROSSED, .proc/uncrossed_react)
		for(var/i in get_turf(parent))
			if(i == parent)
				continue
			RegisterSignal(i, COMSIG_MOVABLE_PRE_THROW, .proc/throw_react)
	else
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/entered_react)
		RegisterSignal(parent, COMSIG_ATOM_EXITED, .proc/exited_react)
		for(var/i in parent)
			RegisterSignal(i, COMSIG_MOVABLE_PRE_THROW, .proc/throw_react)

/datum/component/magnetic_catch/proc/examine(mob/user)
	to_chat(user, "It has been installed with inertia dampening to prevent coffee spills.")

/datum/component/magnetic_catch/proc/crossed_react(atom/movable/thing)
	RegisterSignal(thing, COMSIG_MOVABLE_PRE_THROW, .proc/throw_react, TRUE)

/datum/component/magnetic_catch/proc/uncrossed_react(atom/movable/thing)
	UnregisterSignal(thing, COMSIG_MOVABLE_PRE_THROW)

/datum/component/magnetic_catch/proc/entered_react(atom/movable/thing, atom/oldloc)
	RegisterSignal(thing, COMSIG_MOVABLE_PRE_THROW, .proc/throw_react, TRUE)

/datum/component/magnetic_catch/proc/exited_react(atom/movable/thing, atom/newloc)
	UnregisterSignal(thing, COMSIG_MOVABLE_PRE_THROW)

/datum/component/magnetic_catch/proc/throw_react(list/arguments)
	return COMPONENT_CANCEL_THROW