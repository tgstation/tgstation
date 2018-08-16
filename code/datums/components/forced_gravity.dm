/datum/component/forced_gravity
	var/gravity = 1
	var/ignore_space = FALSE	//If forced gravity should also work on space turfs

/datum/component/forced_gravity/Initialize(forced_value = 1)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	gravity = forced_value