/**
 * General proc used to expel a holder's contents through src (for bins holder is also the src).
 */
/obj/proc/pipe_eject(obj/holder, direction, throw_em = TRUE, turf/target, throw_range = 5, throw_speed = 1)
	var/turf/origin_turf = get_turf(src)
	var/turf/target_turf
	if(isnull(target)) // done up here as a safety
		target_turf = get_offset_target_turf(loc, rand(5) - rand(5), rand(5) - rand(5))
	else
		target_turf = target

	if(QDELETED(origin_turf))
		stack_trace("pipe_eject() attempted to operate on a qdeleted turf! In order to avoid sending things to nullspace, we are going to send everything directly to the target turf instead.")
		origin_turf = target_turf

	var/list/contents_to_eject = holder.contents
	var/list/contents_to_throw = list()

	for(var/atom/movable/thing in contents_to_eject)
		thing.forceMove(origin_turf)
		SEND_SIGNAL(thing, COMSIG_MOVABLE_PIPE_EJECTING, direction)
		if(QDELETED(thing))
			continue

		contents_to_throw += thing

	if(!throw_em)
		return

	for(var/atom/movable/throwable as anything in contents_to_throw)
		if(isnull(target)) // we want the thrown things to be spread out a bit if we weren't given a target
			target_turf = get_offset_target_turf(loc, rand(5) - rand(5), rand(5) - rand(5))

		throwable.throw_at(target_turf, throw_range, throw_speed)
