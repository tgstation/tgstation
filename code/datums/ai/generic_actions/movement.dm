/datum/ai_behavior/dumb_moveto
	var/atom/current_target

/datum/ai_behavior/dumb_moveto/set_action_state(atom/target)
	current_target = target

/datum/ai_behavior/dumb_moveto/start_execution()
	INVOKE_ASYNC(src, async_move)

/datum/ai_behavior/dumb_moveto/proc/async_move()
	if(!current_target)
		return FALSE

	if(myPath.len <= 0)
		myPath = get_path_to(src, get_turf(target), /turf/proc/Distance, MAX_RANGE_FIND + 1, 250,1)

	if(!myPath?.len)
		return
	for(var/i = 0; i < maxStepsTick; ++i)
		if(IS_DEAD_OR_INCAP(our_controller))
		if(myPath.len >= 1)
			walk_to(src,myPath[1],0,5)
			myPath -= myPath[1]
		finish_execution(TRUE)

	// failed to path correctly so just try to head straight for a bit

	walk_to(src,get_turf(target),0,5)
	sleep(1)
	walk_to(src,0)

	finish_execution(FALSE)
