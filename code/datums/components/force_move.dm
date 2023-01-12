///Forced directional movement, but with a twist
///Let's block pressure and client movements while doing it so we can't be interrupted
///Supports spinning on each move, for lube related reasons
/datum/component/force_move

/datum/component/force_move/Initialize(atom/target, spin)
	if(!target || !ismob(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/mob_parent = parent
	var/dist = get_dist(mob_parent, target)
	var/datum/move_loop/loop = SSmove_manager.move_towards(mob_parent, target, delay = 1, timeout = dist)
	RegisterSignal(mob_parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(stop_move))
	RegisterSignal(mob_parent, COMSIG_ATOM_PRE_PRESSURE_PUSH, PROC_REF(stop_pressure))
	if(spin)
		RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(slip_spin))
	RegisterSignal(loop, COMSIG_PARENT_QDELETING, PROC_REF(loop_ended))

/datum/component/force_move/proc/stop_move(datum/source)
	SIGNAL_HANDLER
	return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/datum/component/force_move/proc/stop_pressure(datum/source)
	SIGNAL_HANDLER
	return COMSIG_ATOM_BLOCKS_PRESSURE

/datum/component/force_move/proc/slip_spin(datum/source)
	SIGNAL_HANDLER
	var/mob/mob_parent = parent
	mob_parent.spin(1, 1)

/datum/component/force_move/proc/loop_ended(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)


