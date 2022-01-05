/**
 * General proc used to expel a holder's contents through src (for bins holder is also the src).
 */
/obj/proc/pipe_eject(obj/holder, direction, throw_em = TRUE, turf/target, throw_range = 5, throw_speed = 1)
	var/turf/src_T = get_turf(src)
	for(var/atom/movable/movable as anything in holder)
		movable.forceMove(src_T)
		SEND_SIGNAL(movable, COMSIG_MOVABLE_PIPE_EJECTING, direction)
		if(throw_em && !QDELETED(movable))
			var/turf/T = target || get_offset_target_turf(loc, rand(5)-rand(5), rand(5)-rand(5))
			movable.throw_at(T, throw_range, throw_speed)
