/**
 * The absolute base class for everything
 *
 * A datum instantiated has no physical world prescence, use an atom if you want something
 * that actually lives in the world
 *
 * Be very mindful about adding variables to this class, they are inherited by every single
 * thing in the entire game, and so you can easily cause memory usage to rise a lot with careless
 * use of variables at this level
 */
/datum
	/**
	  * Tick count time when this object was destroyed.
	  *
	  * If this is non zero then the object has been garbage collected and is awaiting either
	  * a hard del by the GC subsystme, or to be autocollected (if it has no references)
	  */
	var/gc_destroyed

	/// Open uis owned by this datum
	/// Lazy, since this case is semi rare
	var/list/open_uis

	/// Active timers with this datum as the target
	var/list/_active_timers
	/// Status traits attached to this datum. associative list of the form: list(trait name (string) = list(source1, source2, source3,...))
	var/list/_status_traits

	/**
	  * Components attached to this datum
	  *
	  * Lazy associated list in the structure of `type -> component/list of components`
	  */
	var/list/_datum_components
	/**
	  * Any datum registered to receive signals from this datum is in this list
	  *
	  * Lazy associated list in the structure of `signal -> registree/list of registrees`
	  */
	var/list/_listen_lookup
	/// Lazy associated list in the structure of `target -> list(signal -> proctype)` that are run when the datum receives that signal
	var/list/list/_signal_procs

	/// Datum level flags
	var/datum_flags = NONE

#ifndef EXPERIMENT_515_DONT_CACHE_REF
	/// A cached version of our \ref
	/// The brunt of \ref costs are in creating entries in the string tree (a tree of immutable strings)
	/// This avoids doing that more then once per datum by ensuring ref strings always have a reference to them after they're first pulled
	var/cached_ref
#endif

	/// A weak reference to another datum
	var/datum/weakref/weak_reference

	/*
	* Lazy associative list of currently active cooldowns.
	*
	* cooldowns [ COOLDOWN_INDEX ] = add_timer()
	* add_timer() returns the truthy value of -1 when not stoppable, and else a truthy numeric index
	*/
	var/list/cooldowns


	/// List for handling persistent filters.
	var/list/filter_data

#ifdef REFERENCE_TRACKING
	var/running_find_references
	var/last_find_references = 0
	#ifdef REFERENCE_TRACKING_DEBUG
	///Stores info about where refs are found, used for sanity checks and testing
	var/list/found_refs
	#endif
#endif

#ifdef DATUMVAR_DEBUGGING_MODE
	var/list/cached_vars
#endif

/**
 * Called when a href for this datum is clicked
 *
 * Sends a [COMSIG_TOPIC] signal
 */
/datum/Topic(href, href_list[])
	..()
	SEND_SIGNAL(src, COMSIG_TOPIC, usr, href_list)

/**
 * Default implementation of clean-up code.
 *
 * This should be overridden to remove all references pointing to the object being destroyed, if
 * you do override it, make sure to call the parent and return it's return value by default
 *
 * Return an appropriate [QDEL_HINT][QDEL_HINT_QUEUE] to modify handling of your deletion;
 * in most cases this is [QDEL_HINT_QUEUE].
 *
 * The base case is responsible for doing the following
 * * Erasing timers pointing to this datum
 * * Erasing compenents on this datum
 * * Notifying datums listening to signals from this datum that we are going away
 *
 * Returns [QDEL_HINT_QUEUE]
 */
/datum/proc/Destroy(force=FALSE, ...)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	tag = null
	datum_flags &= ~DF_USE_TAG //In case something tries to REF us
	weak_reference = null //ensure prompt GCing of weakref.

	if(_active_timers)
		var/list/timers = _active_timers
		_active_timers = null
		for(var/datum/timedevent/timer as anything in timers)
			if (timer.spent && !(timer.flags & TIMER_DELETE_ME))
				continue
			qdel(timer)

	#ifdef REFERENCE_TRACKING
	#ifdef REFERENCE_TRACKING_DEBUG
	found_refs = null
	#endif
	#endif

	//BEGIN: ECS SHIT
	var/list/dc = _datum_components
	if(dc)
		for(var/component_key in dc)
			var/component_or_list = dc[component_key]
			if(islist(component_or_list))
				for(var/datum/component/component as anything in component_or_list)
					qdel(component, FALSE, TRUE)
			else
				var/datum/component/C = component_or_list
				qdel(C, FALSE, TRUE)
		dc.Cut()

	_clear_signal_refs()
	//END: ECS SHIT

	return QDEL_HINT_QUEUE

///Only override this if you know what you're doing. You do not know what you're doing
///This is a threat
/datum/proc/_clear_signal_refs()
	var/list/lookup = _listen_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for(var/datum/component/comp as anything in comps)
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		_listen_lookup = lookup = null

	for(var/target in _signal_procs)
		UnregisterSignal(target, _signal_procs[target])

#ifdef DATUMVAR_DEBUGGING_MODE
/datum/proc/save_vars()
	cached_vars = list()
	for(var/i in vars)
		if(i == "cached_vars")
			continue
		cached_vars[i] = vars[i]

/datum/proc/check_changed_vars()
	. = list()
	for(var/i in vars)
		if(i == "cached_vars")
			continue
		if(cached_vars[i] != vars[i])
			.[i] = list(cached_vars[i], vars[i])

/datum/proc/txt_changed_vars()
	var/list/l = check_changed_vars()
	var/t = "[src]([REF(src)]) changed vars:"
	for(var/i in l)
		t += "\"[i]\" \[[l[i][1]]\] --> \[[l[i][2]]\] "
	t += "."

/datum/proc/to_chat_check_changed_vars(target = world)
	to_chat(target, txt_changed_vars())
#endif

/// Return a list of data which can be used to investigate the datum, also ensure that you set the semver in the options list
/datum/proc/serialize_list(list/options, list/semvers)
	SHOULD_CALL_PARENT(TRUE)

	. = list()
	.["tag"] = tag

	SET_SERIALIZATION_SEMVER(semvers, "1.0.0")
	return .

///Accepts a LIST from deserialize_datum. Should return whether or not the deserialization was successful.
/datum/proc/deserialize_list(json, list/options)
	SHOULD_CALL_PARENT(TRUE)
	return TRUE

///Serializes into JSON. Does not encode type.
/datum/proc/serialize_json(list/options)
	. = serialize_list(options)
	if(!islist(.))
		. = null
	else
		. = json_encode(.)

///Deserializes from JSON. Does not parse type.
/datum/proc/deserialize_json(list/input, list/options)
	var/list/jsonlist = json_decode(input)
	. = deserialize_list(jsonlist)
	if(!istype(., /datum))
		. = null

///Convert a datum into a json blob
/proc/json_serialize_datum(datum/D, list/options)
	if(!istype(D))
		return
	var/list/jsonlist = D.serialize_list(options)
	if(islist(jsonlist))
		jsonlist["DATUM_TYPE"] = D.type
	return json_encode(jsonlist)

/// Convert a list of json to datum
/proc/json_deserialize_datum(list/jsonlist, list/options, target_type, strict_target_type = FALSE)
	if(!islist(jsonlist))
		if(!istext(jsonlist))
			CRASH("Invalid JSON")
		jsonlist = json_decode(jsonlist)
		if(!islist(jsonlist))
			CRASH("Invalid JSON")
	if(!jsonlist["DATUM_TYPE"])
		return
	if(!ispath(jsonlist["DATUM_TYPE"]))
		if(!istext(jsonlist["DATUM_TYPE"]))
			return
		jsonlist["DATUM_TYPE"] = text2path(jsonlist["DATUM_TYPE"])
		if(!ispath(jsonlist["DATUM_TYPE"]))
			return
	if(target_type)
		if(!ispath(target_type))
			return
		if(strict_target_type)
			if(target_type != jsonlist["DATUM_TYPE"])
				return
		else if(!ispath(jsonlist["DATUM_TYPE"], target_type))
			return
	var/typeofdatum = jsonlist["DATUM_TYPE"] //BYOND won't directly read if this is just put in the line below, and will instead runtime because it thinks you're trying to make a new list?
	var/datum/D = new typeofdatum
	if(!D.deserialize_list(jsonlist, options))
		qdel(D)
	else
		return D

/**
 * Callback called by a timer to end an associative-list-indexed cooldown.
 *
 * Arguments:
 * * source - datum storing the cooldown
 * * index - string index storing the cooldown on the cooldowns associative list
 *
 * This sends a signal reporting the cooldown end.
 */
/proc/end_cooldown(datum/source, index)
	if(QDELETED(source))
		return
	SEND_SIGNAL(source, COMSIG_CD_STOP(index))
	TIMER_COOLDOWN_END(source, index)


/**
 * Proc used by stoppable timers to end a cooldown before the time has ran out.
 *
 * Arguments:
 * * source - datum storing the cooldown
 * * index - string index storing the cooldown on the cooldowns associative list
 *
 * This sends a signal reporting the cooldown end, passing the time left as an argument.
 */
/proc/reset_cooldown(datum/source, index)
	if(QDELETED(source))
		return
	SEND_SIGNAL(source, COMSIG_CD_RESET(index), S_TIMER_COOLDOWN_TIMELEFT(source, index))
	TIMER_COOLDOWN_END(source, index)

///Generate a tag for this /datum, if it implements one
///Should be called as early as possible, best would be in New, to avoid weakref mistargets
///Really just don't use this, you don't need it, global lists will do just fine MOST of the time
///We really only use it for mobs to make id'ing people easier
/datum/proc/GenerateTag()
	datum_flags |= DF_USE_TAG

/** Add a filter to the datum.
 * This is on datum level, despite being most commonly / primarily used on atoms, so that filters can be applied to images / mutable appearances.
 * Can also be used to assert a filter's existence. I.E. update a filter regardless if it exists or not.
 *
 * Arguments:
 * * name - Filter name
 * * priority - Priority used when sorting the filter.
 * * params - Parameters of the filter.
 */
/datum/proc/add_filter(name, priority, list/params)
	LAZYINITLIST(filter_data)
	var/list/copied_parameters = params.Copy()
	copied_parameters["priority"] = priority
	filter_data[name] = copied_parameters
	update_filters()

/// Reapplies all the filters.
/datum/proc/update_filters()
	ASSERT(isatom(src) || istype(src, /image))
	var/atom/atom_cast = src // filters only work with images or atoms.
	atom_cast.filters = null
	filter_data = sortTim(filter_data, GLOBAL_PROC_REF(cmp_filter_data_priority), TRUE)
	for(var/filter_raw in filter_data)
		var/list/data = filter_data[filter_raw]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		atom_cast.filters += filter(arglist(arguments))
	UNSETEMPTY(filter_data)

/obj/item/update_filters()
	. = ..()
	update_item_action_buttons()

/** Update a filter's parameter to the new one. If the filter doesnt exist we won't do anything.
 *
 * Arguments:
 * * name - Filter name
 * * new_params - New parameters of the filter
 * * overwrite - TRUE means we replace the parameter list completely. FALSE means we only replace the things on new_params.
 */
/datum/proc/modify_filter(name, list/new_params, overwrite = FALSE)
	var/filter = get_filter(name)
	if(!filter)
		return
	if(overwrite)
		filter_data[name] = new_params
	else
		for(var/thing in new_params)
			filter_data[name][thing] = new_params[thing]
	update_filters()

/** Update a filter's parameter and animate this change. If the filter doesnt exist we won't do anything.
 * Basically a [datum/proc/modify_filter] call but with animations. Unmodified filter parameters are kept.
 *
 * Arguments:
 * * name - Filter name
 * * new_params - New parameters of the filter
 * * time - time arg of the BYOND animate() proc.
 * * easing - easing arg of the BYOND animate() proc.
 * * loop - loop arg of the BYOND animate() proc.
 */
/datum/proc/transition_filter(name, list/new_params, time, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return
	// This can get injected by the filter procs, we want to support them so bye byeeeee
	new_params -= "type"
	animate(filter, new_params, time = time, easing = easing, loop = loop)
	modify_filter(name, new_params)

/// Updates the priority of the passed filter key
/datum/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return

	filter_data[name]["priority"] = new_priority
	update_filters()

/// Returns the filter associated with the passed key
/datum/proc/get_filter(name)
	ASSERT(isatom(src) || istype(src, /image))
	if(filter_data && filter_data[name])
		var/atom/atom_cast = src // filters only work with images or atoms.
		return atom_cast.filters[filter_data.Find(name)]

/// Returns the indice in filters of the given filter name.
/// If it is not found, returns null.
/datum/proc/get_filter_index(name)
	return filter_data?.Find(name)

/// Removes the passed filter, or multiple filters, if supplied with a list.
/datum/proc/remove_filter(name_or_names)
	if(!filter_data)
		return

	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/datum/proc/clear_filters()
	ASSERT(isatom(src) || istype(src, /image))
	var/atom/atom_cast = src // filters only work with images or atoms.
	filter_data = null
	atom_cast.filters = null

/// Return text from this proc to provide extra context to hard deletes that happen to it
/// Optional, you should use this for cases where replication is difficult and extra context is required
/datum/proc/dump_harddel_info()
	return
