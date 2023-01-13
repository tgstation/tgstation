/// Apply this element to a movable atom when you want it to block explosions
/// It will mirror the blocking down to that movable's turf, keeping explosion work cheap
/datum/element/blocks_explosives

/datum/element/blocks_explosives/Attach(datum/target)
	if(!ismovable(target))
		return
	. = ..()
	ADD_TRAIT(target, TRAIT_BLOCKING_EXPLOSIVES, TRAIT_GENERIC)
	var/atom/movable/moving_target = target
	RegisterSignal(moving_target, COMSIG_MOVABLE_MOVED, PROC_REF(blocker_moved))
	RegisterSignal(moving_target, COMSIG_MOVABLE_EXPLOSION_BLOCK_CHANGED, PROC_REF(blocking_changed))
	moving_target.explosive_resistance = moving_target.explosion_block

	if(length(moving_target.locs) > 1)
		for(var/atom/location as anything in moving_target.locs)
			block_loc(location, moving_target.explosion_block)
	else if(moving_target.loc)
		block_loc(moving_target.loc, moving_target.explosion_block)

/datum/element/blocks_explosives/Detach(datum/source)
	. = ..()
	REMOVE_TRAIT(source, TRAIT_BLOCKING_EXPLOSIVES, TRAIT_GENERIC)

/// Call this when our blocking well, changes. we'll update our turf(s) with the details
/datum/element/blocks_explosives/proc/blocking_changed(atom/movable/target, old_block, new_block)
	if(length(target.locs) > 1)
		for(var/atom/location as anything in target.locs)
			unblock_loc(location, old_block)
			block_loc(location, new_block)
	else if(target.loc)
		unblock_loc(target.loc, old_block)
		block_loc(target.loc, new_block)

/// Applies a block amount to a turf. proc for convenince
/datum/element/blocks_explosives/proc/block_loc(atom/location, block_amount)
	location.explosive_resistance += block_amount

/// Removes a block amount from a turf. proc for convenince
/datum/element/blocks_explosives/proc/unblock_loc(atom/location, block_amount)
	location.explosive_resistance -= block_amount

/// Essentially just blocking_changed except we remove from the old loc, and add to the new one
/datum/element/blocks_explosives/proc/blocker_moved(atom/movable/target, atom/old_loc, dir, forced, list/old_locs)
	if(length(old_locs) > 1)
		for(var/atom/location as anything in old_locs)
			unblock_loc(location, target.explosion_block)
	else if(old_loc)
		unblock_loc(old_loc, target.explosion_block)

	if(length(target.locs) > 1)
		for(var/atom/location as anything in target.locs)
			block_loc(location, target.explosion_block)
	else if(target.loc)
		block_loc(target.loc, target.explosion_block)

