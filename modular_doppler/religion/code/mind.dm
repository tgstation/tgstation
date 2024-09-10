// Free chaplain highpriest role if the chaplain's mind gets deleted for some reason
/datum/mind/Destroy()
	var/list/holy_successors = list_holy_successors()
	if(current && (current in holy_successors)) // if this mob was a holy successor then remove them from the pool
		GLOB.holy_successors -= WEAKREF(src)

	// Handle freeing the high priest role for the next chaplain in line
	if(holy_role == HOLY_ROLE_HIGHPRIEST)
		reset_religion()
			
	return ..()
