/datum/component/magnetic_catch/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(ismovableatom(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_UNCROSS, .proc/uncross_react)
	else
		RegisterSignal(parent, COMSIG_ATOM_EXIT, .proc/exit_react)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

/datum/component/magnetic_catch/proc/uncross_react(atom/movable/thing)
	if(!thing.throwing || thing.throwing.thrower)
		return
	qdel(thing.throwing)
	return COMPONENT_MOVABLE_BLOCK_UNCROSS

/datum/component/magnetic_catch/proc/exit_react(atom/movable/thing, atom/newloc)
	if(!thing.throwing || thing.throwing.thrower)
		return
	qdel(thing.throwing)
	return COMPONENT_ATOM_BLOCK_EXIT

/datum/component/magnetic_catch/proc/examine(mob/user)
	to_chat(user, "It has been installed with inertia dampening to prevent coffee spills.")