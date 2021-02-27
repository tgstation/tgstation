#ifdef REFERENCE_TRACKING

/datum/verb/find_refs()
	set category = "Debug"
	set name = "Find References"
	set src in world

	find_references(FALSE)


/datum/proc/find_references(skip_alert)
	running_find_references = type
	if(usr?.client)
		if(usr.client.running_find_references)
			testing("CANCELLED search for references to a [usr.client.running_find_references].")
			usr.client.running_find_references = null
			running_find_references = null
			//restart the garbage collector
			SSgarbage.can_fire = TRUE
			SSgarbage.next_fire = world.time + world.tick_lag
			return

		if(!skip_alert && alert("Running this will lock everything up for about 5 minutes.  Would you like to begin the search?", "Find References", "Yes", "No") != "Yes")
			running_find_references = null
			return

	//this keeps the garbage collector from failing to collect objects being searched for in here
	SSgarbage.can_fire = FALSE

	if(usr?.client)
		usr.client.running_find_references = type

	testing("Beginning search for references to a [type].")
	last_find_references = world.time

	DoSearchVar(GLOB) //globals
	for(var/datum/thing in world) //atoms (don't beleive its lies)
		DoSearchVar(thing, "World -> [thing]")

	for(var/datum/thing) //datums
		DoSearchVar(thing, "World -> [thing]")

	for(var/client/thing) //clients
		DoSearchVar(thing, "World -> [thing]")

	testing("Completed search for references to a [type].")
	if(usr?.client)
		usr.client.running_find_references = null
	running_find_references = null

	//restart the garbage collector
	SSgarbage.can_fire = TRUE
	SSgarbage.next_fire = world.time + world.tick_lag


/datum/verb/qdel_then_find_references()
	set category = "Debug"
	set name = "qdel() then Find References"
	set src in world

	qdel(src, TRUE) //force a qdel
	if(!running_find_references)
		find_references(TRUE)


/datum/verb/qdel_then_if_fail_find_references()
	set category = "Debug"
	set name = "qdel() then Find References if GC failure"
	set src in world

	qdel_and_find_ref_if_fail(src, TRUE)


/datum/proc/DoSearchVar(potential_container, container_name, recursive_limit = 64)
	if(usr?.client && !usr.client.running_find_references)
		return

	if(!recursive_limit)
		return

	if(istype(potential_container, /datum))
		var/datum/datum_container = potential_container
		if(datum_container.last_find_references == last_find_references)
			return

		datum_container.last_find_references = last_find_references
		var/list/vars_list = datum_container.vars

		for(var/varname in vars_list)
			if (varname == "vars")
				continue
			var/variable = vars_list[varname]

			if(variable == src)
				testing("Found [type] \ref[src] in [datum_container.type]'s [varname] var. [container_name]")

			else if(islist(variable))
				DoSearchVar(variable, "[container_name] -> list", recursive_limit - 1)

	else if(islist(potential_container))
		var/normal = IS_NORMAL_LIST(potential_container)
		for(var/element_in_list in potential_container)
			if(element_in_list == src)
				testing("Found [type] \ref[src] in list [container_name].")

			else if(element_in_list && !isnum(element_in_list) && normal && potential_container[element_in_list] == src)
				testing("Found [type] \ref[src] in list [container_name]\[[element_in_list]\]")

			else if(islist(element_in_list))
				DoSearchVar(element_in_list, "[container_name] -> list", recursive_limit - 1)

	#ifndef FIND_REF_NO_CHECK_TICK
	CHECK_TICK
	#endif


/proc/qdel_and_find_ref_if_fail(datum/thing_to_del, force = FALSE)
	SSgarbage.reference_find_on_fail[REF(thing_to_del)] = TRUE
	qdel(thing_to_del, force)

#endif
