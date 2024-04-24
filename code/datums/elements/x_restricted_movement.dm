///An element that forces the mob to ONLY move on the x axis unless multiple tile movement.
/// like sideway_movement element but for hardline fundamentalist crabs that refuse to move on a y axis at all
/datum/element/x_restricted_movement

/datum/element/x_restricted_movement/Attach(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))

/datum/element/x_restricted_movement/Detach(atom/movable/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_PRE_MOVE)

/datum/element/x_restricted_movement/proc/on_pre_move(atom/movable/target, atom/entering_loc)
	SIGNAL_HANDLER
	if(!isturf(entering_loc))
		return //contents do not really have directions, lets skip this case
	if(get_dist(target, entering_loc) > 1)
		return //multi-tile jumps do not get considered in this
	var/move_dir = get_dir(target, entering_loc)
	if(move_dir != EAST && move_dir != WEST)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
