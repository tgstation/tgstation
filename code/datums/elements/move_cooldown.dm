/**
 * Allows something to move only every x interval
 * For instances where they'd otherwise need to move so slowly that the glide would look stupid
 * Does not differentiate between voluntary and involuntary movement so this is beneficial in some niche circumstances
 */
/datum/element/move_cooldown
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Time to wait between moves
	var/move_delay
	/// List of refs to atoms vs when they can next move
	var/list/next_move_cache = list()

/datum/element/move_cooldown/Attach(datum/target, move_delay = 1 SECONDS)
	. = ..()
	if (!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	src.move_delay = move_delay
	next_move_cache[REF(target)] = 0
	RegisterSignal(target, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(tried_move))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/element/move_cooldown/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED))
	next_move_cache -= REF(source)
	return ..()

/// Called when something we're tracking tries to move, check if it's allowed
/datum/element/move_cooldown/proc/tried_move(atom/movable/source, new_loc)
	SIGNAL_HANDLER
	if (source.pulledby || source.throwing || !isturf(new_loc) || !isturf(source.loc))
		return
	if (world.time <= next_move_cache[REF(source)])
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// Called when we moved successfully, start the cooldown
/datum/element/move_cooldown/proc/on_moved(atom/movable/source, old_loc, direction, forced)
	SIGNAL_HANDLER
	if (forced || source.pulledby || source.throwing || !isturf(old_loc) || !isturf(source.loc))
		return // Can't really eliminate involuntary movement but we'll try
	if (!(source.movement_type & FLYING) && !source.has_gravity())
		return // Skip newtonian movement if it's not under control
	next_move_cache[REF(source)] = world.time + move_delay
