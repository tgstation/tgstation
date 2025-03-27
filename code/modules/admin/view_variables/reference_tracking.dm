#ifdef REFERENCE_TRACKING
#define REFSEARCH_RECURSE_LIMIT 64

/datum/proc/find_references(references_to_clear = INFINITY)
	if(usr?.client)
		if(tgui_alert(usr,"Running this will lock everything up for about 5 minutes.  Would you like to begin the search?", "Find References", list("Yes", "No")) != "Yes")
			return

	src.references_to_clear = references_to_clear
	//this keeps the garbage collector from failing to collect objects being searched for in here
	SSgarbage.can_fire = FALSE

	_search_references()
	//restart the garbage collector
	SSgarbage.can_fire = TRUE
	SSgarbage.update_nextfire(reset_time = TRUE)

/datum/proc/_search_references()
	log_reftracker("Beginning search for references to a [type], looking for [references_to_clear] refs.")

	var/starting_time = world.time
	//Time to search the whole game for our ref
	DoSearchVar(GLOB, "GLOB", starting_time) //globals
	log_reftracker("Finished searching globals")
	if(src.references_to_clear == 0)
		return

	//Yes we do actually need to do this. The searcher refuses to read weird lists
	//And global.vars is a really weird list
	var/global_vars = list()
	for(var/key in global.vars)
		global_vars[key] = global.vars[key]

	DoSearchVar(global_vars, "Native Global", starting_time)
	log_reftracker("Finished searching native globals")
	if(src.references_to_clear == 0)
		return

	for(var/datum/thing in world) //atoms (don't beleive its lies)
		DoSearchVar(thing, "World -> [thing.type]", starting_time)
		if(src.references_to_clear == 0)
			break
	log_reftracker("Finished searching atoms")
	if(src.references_to_clear == 0)
		return

	for(var/datum/thing) //datums
		DoSearchVar(thing, "Datums -> [thing.type]", starting_time)
		if(src.references_to_clear == 0)
			break
	log_reftracker("Finished searching datums")
	if(src.references_to_clear == 0)
		return

	//Warning, attempting to search clients like this will cause crashes if done on live. Watch yourself
#ifndef REFERENCE_DOING_IT_LIVE
	for(var/client/thing) //clients
		DoSearchVar(thing, "Clients -> [thing.type]", starting_time)
		if(src.references_to_clear == 0)
			break
	log_reftracker("Finished searching clients")
	if(src.references_to_clear == 0)
		return
#endif

	log_reftracker("Completed search for references to a [type].")

/datum/proc/DoSearchVar(potential_container, container_name, search_time, recursion_count, is_special_list)
	if(recursion_count >= REFSEARCH_RECURSE_LIMIT)
		log_reftracker("Recursion limit reached. [container_name]")
		return

	if(references_to_clear == 0)
		return

	//Check each time you go down a layer. This makes it a bit slow, but it won't effect the rest of the game at all
	#ifndef FIND_REF_NO_CHECK_TICK
	CHECK_TICK
	#endif

	if(isdatum(potential_container))
		var/datum/datum_container = potential_container
		if(datum_container.last_find_references == search_time)
			return

		datum_container.last_find_references = search_time
		var/list/vars_list = datum_container.vars

		var/is_atom = FALSE
		var/is_area = FALSE
		if(isatom(datum_container))
			is_atom = TRUE
			if(isarea(datum_container))
				is_area = TRUE
		for(var/varname in vars_list)
			var/variable = vars_list[varname]
			if(islist(variable))
				//Fun fact, vis_locs don't count for references
				if(varname == "vars" || (is_atom && (varname == "vis_locs" || varname == "overlays" || varname == "underlays" || varname == "filters" || varname == "verbs" || (is_area && varname == "contents"))))
					continue
				// We do this after the varname check to avoid area contents (reading it incures a world loop's worth of cost)
				if(!length(variable))
					continue
				DoSearchVar(variable,\
					"[container_name] [datum_container.ref_search_details()] -> [varname] (list)",\
					search_time,\
					recursion_count + 1,\
					/*is_special_list = */ is_atom && (varname == "contents" || varname == "vis_contents" || varname == "locs"))
			else if(variable == src)
				#ifdef REFERENCE_TRACKING_DEBUG
				if(SSgarbage.should_save_refs)
					if(!found_refs)
						found_refs = list()
					found_refs[varname] = TRUE
					continue //End early, don't want these logging
				else
					log_reftracker("Found [type] [text_ref(src)] in [datum_container.type]'s [datum_container.ref_search_details()] [varname] var. [container_name]")
				#else
				log_reftracker("Found [type] [text_ref(src)] in [datum_container.type]'s [datum_container.ref_search_details()] [varname] var. [container_name]")
				#endif
				references_to_clear -= 1
				if(references_to_clear == 0)
					log_reftracker("All references to [type] [text_ref(src)] found, exiting.")
					return
				continue

	else if(islist(potential_container))
		var/list/potential_cache = potential_container
		for(var/element_in_list in potential_cache)
			//Check normal sublists
			if(islist(element_in_list))
				if(length(element_in_list))
					DoSearchVar(element_in_list, "[container_name] -> [element_in_list] (list)", search_time, recursion_count + 1)
			//Check normal entrys
			else if(element_in_list == src)
				#ifdef REFERENCE_TRACKING_DEBUG
				if(SSgarbage.should_save_refs)
					if(!found_refs)
						found_refs = list()
					found_refs[potential_cache] = TRUE
					continue
				else
					log_reftracker("Found [type] [text_ref(src)] in list [container_name].")
				#else
				log_reftracker("Found [type] [text_ref(src)] in list [container_name].")
				#endif

				// This is dumb as hell I'm sorry
				// I don't want the garbage subsystem to count as a ref for the purposes of this number
				// If we find all other refs before it I want to early exit, and if we don't I want to keep searching past it
				var/ignore_ref = FALSE
				var/list/queues = SSgarbage.queues
				for(var/list/queue in queues)
					if(potential_cache in queue)
						ignore_ref = TRUE
						break
				if(ignore_ref)
					log_reftracker("[container_name] does not count as a ref for our count")
				else
					references_to_clear -= 1
				if(references_to_clear == 0)
					log_reftracker("All references to [type] [text_ref(src)] found, exiting.")
					return

			if(!isnum(element_in_list) && !is_special_list)
				// This exists to catch an error that throws when we access a special list
				// is_special_list is a hint, it can be wrong
				try
					var/assoc_val = potential_cache[element_in_list]
					//Check assoc sublists
					if(islist(assoc_val))
						if(length(assoc_val))
							DoSearchVar(potential_container[element_in_list], "[container_name]\[[element_in_list]\] -> [assoc_val] (list)", search_time, recursion_count + 1)
					//Check assoc entry
					else if(assoc_val == src)
						#ifdef REFERENCE_TRACKING_DEBUG
						if(SSgarbage.should_save_refs)
							if(!found_refs)
								found_refs = list()
							found_refs[potential_cache] = TRUE
							continue
						else
							log_reftracker("Found [type] [text_ref(src)] in list [container_name]\[[element_in_list]\]")
						#else
						log_reftracker("Found [type] [text_ref(src)] in list [container_name]\[[element_in_list]\]")
						#endif
						references_to_clear -= 1
						if(references_to_clear == 0)
							log_reftracker("All references to [type] [text_ref(src)] found, exiting.")
							return
				catch
					// So if it goes wrong we kill it
					is_special_list = TRUE
					log_reftracker("Curiosity: [container_name] lead to an error when acessing [element_in_list], what is it?")

#undef REFSEARCH_RECURSE_LIMIT
#endif

// Kept outside the ifdef so overrides are easy to implement

/// Return info about us for reference searching purposes
/// Will be logged as a representation of this datum if it's a part of a search chain
/datum/proc/ref_search_details()
	return text_ref(src)

/datum/callback/ref_search_details()
	return "[text_ref(src)] (obj: [object] proc: [delegate] args: [json_encode(arguments)] user: [user?.resolve() || "null"])"
