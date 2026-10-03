/// Assoc list of turfs to what radius around them blocks mining mob respawns
GLOBAL_LIST_EMPTY(mining_mob_respawn_blockers)

/// Attach to a movable object to prevent mining mobs within its radius from respawning during storms
/datum/element/block_mining_mob_respawns
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	/// Radius around the movable that blocks respawns
	var/block_range = 7

/datum/element/block_mining_mob_respawns/Attach(datum/target, block_range = 7)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.block_range = block_range

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(movable_moved))
	RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(movable_stat_change))

	var/atom/movable/movable_target = target
	if(isturf(movable_target.loc) && (!ismob(target) || astype(target, /mob).stat != DEAD))
		GLOB.mining_mob_respawn_blockers[movable_target.loc] = block_range

/datum/element/block_mining_mob_respawns/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	GLOB.mining_mob_respawn_blockers -= get_turf(source)
	return ..()

/datum/element/block_mining_mob_respawns/proc/movable_moved(atom/movable/source, atom/old_loc, ...)
	SIGNAL_HANDLER

	GLOB.mining_mob_respawn_blockers -= old_loc
	if(isturf(source.loc) && (!ismob(source) || astype(source, /mob).stat != DEAD))
		GLOB.mining_mob_respawn_blockers[source.loc] = src.block_range

/datum/element/block_mining_mob_respawns/proc/movable_stat_change(mob/source, new_stat, old_stat)
	SIGNAL_HANDLER

	if(new_stat == DEAD)
		GLOB.mining_mob_respawn_blockers -= get_turf(source)
	else if(isturf(source.loc))
		GLOB.mining_mob_respawn_blockers[source.loc] = src.block_range
