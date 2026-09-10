/// Base transition contract. Concrete stairs/ladders provide their own execution behavior.
/datum/nav_link
	var/id
	var/turf/source
	var/turf/destination
	var/cost = 10

/datum/nav_link/New(turf/source, turf/destination, cost = 10)
	src.source = source
	src.destination = destination
	src.cost = max(1, cost)
	SSnavmap.register_nav_link(src)

/datum/nav_link/Destroy(force)
	SSnavmap.unregister_nav_link(src)
	source = null
	destination = null
	return ..()

/datum/nav_link/proc/can_plan(datum/can_pass_info/pass_info)
	return !QDELETED(src) && source && destination

/datum/nav_link/proc/begin_traversal(atom/movable/mover, datum/callback/completion)
	if(!can_plan(new /datum/can_pass_info(mover)))
		completion?.Invoke(FALSE)
		return FALSE
	var/success = mover.zMove(target = destination, z_move_flags = ZMOVE_ALLOW_BUCKLED|ZMOVE_CHECK_PULLS)
	completion?.Invoke(success)
	return success

/datum/nav_link/proc/cancel_traversal(atom/movable/mover)
	return

/datum/nav_link/stairs
	var/obj/structure/stairs/stair
	var/going_up

/datum/nav_link/stairs/New(obj/structure/stairs/stair, turf/source, turf/destination)
	src.stair = stair
	going_up = destination.z > source.z
	..(source, destination, 10)

/datum/nav_link/stairs/can_plan(datum/can_pass_info/pass_info)
	return ..() && stair && stair.isTerminator()

/datum/nav_link/stairs/begin_traversal(atom/movable/mover, datum/callback/completion)
	if(!can_plan(new /datum/can_pass_info(mover)))
		completion?.Invoke(FALSE)
		return FALSE
	if(going_up)
		return stair.stair_ascend(mover, completion)
	return stair.stair_descend(mover, completion)

/datum/nav_link/ladder
	var/obj/structure/ladder/ladder
	var/going_up

/datum/nav_link/ladder/New(obj/structure/ladder/ladder, turf/source, turf/destination, going_up)
	src.ladder = ladder
	src.going_up = going_up
	..(source, destination, max(10, round(ladder.travel_time / (0.2 SECONDS)) * 10))

/datum/nav_link/ladder/can_plan(datum/can_pass_info/pass_info)
	if(!..() || !ladder || !(going_up ? ladder.up : ladder.down))
		return FALSE
	return !pass_info?.buckled_info?.anchored

/datum/nav_link/ladder/begin_traversal(atom/movable/mover, datum/callback/completion)
	if(!can_plan(new /datum/can_pass_info(mover)))
		completion?.Invoke(FALSE)
		return FALSE
	if(ladder.travel_time)
		INVOKE_ASYNC(ladder, TYPE_PROC_REF(/obj/structure/ladder, start_travelling), mover, going_up, completion)
		return TRUE
	var/success = ladder.travel(mover, going_up)
	completion?.Invoke(success)
	return success
