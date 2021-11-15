/datum/component/slipping

/datum/component/slipping/Initialize(atom/target, spin)
	if(!target && ismob(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/mob_parent = parent
	var/dist = get_dist(mob_parent, target)
	var/datum/move_loop/loop = SSmove_manager.move_towards(mob_parent, target, delay = 1, timeout = dist)
	RegisterSignal(mob_parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, .proc/stop_move)
	RegisterSignal(mob_parent, COMSIG_ATOM_PRE_PRESSURE_PUSH, .proc/stop_pressure)
	if(spin)
		RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/slip_spin)
	RegisterSignal(loop, COMSIG_PARENT_QDELETING, .proc/loop_ended)

/datum/component/slipping/proc/stop_move(datum/source)
	SIGNAL_HANDLER
	return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/datum/component/slipping/proc/stop_pressure(datum/source)
	SIGNAL_HANDLER
	return COMSIG_ATOM_BLOCKS_PRESSURE

/datum/component/slipping/proc/slip_spin(datum/source)
	SIGNAL_HANDLER
	var/mob/mob_parent = parent
	mob_parent.spin(1, 1)

/datum/component/slipping/proc/loop_ended(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)
