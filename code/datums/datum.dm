/**
 * The absolute base class for everything
 *
 * A datum instantiated has no physical world presence, use an atom if you want something
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
	/// An accursed beast of a list that contains our filters. Why? Because var/list/filters on atoms/images isn't actually a list
	/// but a snowflaked skinwalker pretending to be one, which doesn't support half the list procs/operations and the other half behaves weirdly
	/// so we cut down on filter creation and appearance update costs by editing *this* list, and then assigning ours to it
	var/list/filter_cache

#ifdef REFERENCE_TRACKING
	/// When was this datum last touched by a reftracker?
	/// If this value doesn't match with the start of the search
	/// We know this datum has never been seen before, and we should check it
	var/last_find_references = 0
	/// How many references we're trying to find when searching
	var/references_to_clear = 0
	#ifdef REFERENCE_TRACKING_DEBUG
	///Stores info about where refs are found, used for sanity checks and testing
	var/list/found_refs
	#endif
#endif

	// If we have called dump_harddel_info already. Used to avoid duped calls (since we call it immediately in some cases on failure to process)
	// Create and destroy is weird and I wanna cover my bases
	var/harddel_deets_dumped = FALSE

#ifdef DATUMVAR_DEBUGGING_MODE
	var/list/cached_vars
#endif
	///The layout pref we take from the player looking at this datum's UI to know what layout to give.
	var/datum/preference/choiced/layout_prefs_used = /datum/preference/choiced/tgui_layout

	/**
	 * Parent types.
	 *
	 * Use path Ex:(abstract_type = /obj/item). Generally for abstract code objects, atoms with a set abstract_type can never be selected by spawner.
	 * These should be things that should never show up in a round, this does not include things that require init behavoir to function.
	 */
	var/abstract_type = /datum

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
 * you do override it, make sure to call the parent and return its return value by default
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
/datum/proc/Destroy(force = FALSE)
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
					qdel(component, FALSE)
			else
				var/datum/component/C = component_or_list
				qdel(C, FALSE)
		dc.Cut()

	_clear_signal_refs()
	//END: ECS SHIT

#ifndef DISABLE_DREAMLUAU
	if(!(datum_flags & DF_STATIC_OBJECT))
		DREAMLUAU_CLEAR_REF_USERDATA(vars) // vars ceases existing when src does, so we need to clear any lua refs to it that exist.
		DREAMLUAU_CLEAR_REF_USERDATA(src)
#endif

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
	. = serialize_list(options, list())
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
 * * update - If we should update our actual filters list, or wait until something updates it later
 */
/datum/proc/add_filter(name, priority, list/params, update = TRUE)
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	LAZYINITLIST(filter_data)
	LAZYINITLIST(filter_cache)
	var/list/copied_parameters = params.Copy()
	copied_parameters["name"] = name
	copied_parameters["priority"] = priority
	for (var/list/filter_info as anything in filter_data)
		if (filter_info["name"] == name)
			filter_data -= filter_info
			filter_cache -= name
			break

	BINARY_INSERT_DEFINE(list(copied_parameters), filter_data, SORT_VAR_NO_TYPE, copied_parameters, SORT_PRIORITY_INDEX, COMPARE_KEY)

	for (var/index in 1 to length(filter_data))
		var/list/filter_info = filter_data[index]
		if (filter_info["name"] != name)
			continue
		var/list/arguments = filter_info.Copy()
		arguments -= "priority"
		filter_cache.Insert(index, filter(arglist(arguments)))
		break

	if (update)
		atom_cast.filters = filter_cache

/// A version of add_filter that takes a list of filters to add rather than being individual, to limit appearance updates
/datum/proc/add_filters(list/list/filters, update = TRUE)
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	for (var/list/individual_filter as anything in filters)
		add_filter(individual_filter["name"], individual_filter["priority"], individual_filter["params"], update = FALSE)
	if (update)
		atom_cast.filters = filter_cache

/// Reapplies all the filters. If start_index is passed, only a portion of all filters are reapplied starting from said index
/datum/proc/update_filters(start_index = null)
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	if (start_index)
		filter_cache.Cut(start_index)
	else
		atom_cast.filters = null
		filter_cache.Cut()

	for (var/index in start_index || 1 to length(filter_data))
		var/list/filter_info = filter_data[index]
		var/list/arguments = filter_info.Copy()
		arguments -= "priority"
		if (start_index) // See https://www.byond.com/forum/post/2980598 as to why we cannot just override the existing filter
			atom_cast.filters -= filter_info["name"] // We're trapped in the belly of this horrible machine
		filter_cache += filter(arglist(arguments)) // And the machine is bleeding to death

	atom_cast.filters = filter_cache
	UNSETEMPTY(filter_data)

/obj/item/update_filters(start_index = null)
	. = ..()
	update_item_action_buttons()

/** Update a filter's parameter to the new one. If the filter doesn't exist we won't do anything.
 *
 * Arguments:
 * * name - Filter name
 * * new_params - New parameters of the filter
 * * overwrite - TRUE means we replace the parameter list completely. FALSE means we only replace the things on new_params.
 * * update - If we should apply our filter cache to our actual filters
 */
/datum/proc/modify_filter(name, list/new_params, overwrite = FALSE, update = TRUE)
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	for (var/index in 1 to length(filter_data))
		var/list/filter_info = filter_data[index]
		if (filter_info["name"] != name)
			continue

		if (overwrite)
			filter_data[index] = new_params
		else
			for (var/thing in new_params)
				filter_info[thing] = new_params[thing]

		var/list/arguments = filter_info.Copy()
		arguments -= "priority"
		filter_cache[index] = filter(arglist(arguments))

		if (update)
			atom_cast.filters = filter_cache
		return

/** Update a filter's parameter and animate this change. If the filter doesn't exist we won't do anything.
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
	if (!filter)
		return
	// This can get injected by the filter procs, we want to support them so bye byeeeee
	new_params -= "type"
	animate(filter, new_params, time = time, easing = easing, loop = loop)
	modify_filter(name, new_params)

/** Keeps the steps in the correct order.
* Arguments:
* * params - the parameters you want this step to animate to
* * duration - the time it takes to animate this step
* * easing - the type of easing this step has
*/
/proc/filter_chain_step(params, duration, easing, flags)
	params -= "type"
	return list("params" = params, "duration" = duration, "easing" = easing, "flags" = flags)

/** Similar to transition_filter(), except it creates an animation chain that moves between a list of states.
 * Arguments:
 * * name - Filter name
 * * num_loops - Amount of times the chain loops. INDEFINITE = Infinite
 * * ... - a list of each link in the animation chain. Use filter_chain_step(params, duration, easing) for each link
 * Example use:
 * * add_filter("blue_pulse", 1, color_matrix_filter(COLOR_WHITE))
 * * transition_filter_chain(src, "blue_pulse", INDEFINITE,\
 * *	filter_chain_step(color_matrix_filter(COLOR_BLUE), 10 SECONDS, CUBIC_EASING),\
 * *	filter_chain_step(color_matrix_filter(COLOR_WHITE), 10 SECONDS, CUBIC_EASING))
 * The above code would edit a color_matrix_filter() to slowly turn blue over 10 seconds before returning back to white 10 seconds after, repeating this chain forever.
 */
/datum/proc/transition_filter_chain(name, num_loops, ...)
	var/list/transition_steps = args.Copy(3)
	var/filter = get_filter(name)
	if (!filter)
		return
	var/list/first_step = transition_steps[1]
	animate(filter, first_step["params"], time = first_step["duration"], easing = first_step["easing"], flags = first_step["flags"], loop = num_loops)
	for (var/transition_step in 2 to length(transition_steps))
		var/list/this_step = transition_steps[transition_step]
		animate(this_step["params"], time = this_step["duration"], easing = this_step["easing"], flags = this_step["flags"])

/// Updates the priority of the passed filter key
/datum/proc/change_filter_priority(name, new_priority)
	for (var/list/filter_info as anything in filter_data)
		if (filter_info["name"] != name)
			continue

		remove_filter(name, update = FALSE)
		add_filter(name, new_priority, filter_info)
		return

/// Returns the filter associated with the passed key
/datum/proc/get_filter(name)
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	return atom_cast.filters[name]

/// Removes the passed filter, or multiple filters, if supplied with a list.
/datum/proc/remove_filter(name_or_names, update = TRUE)
	ASSERT(isatom(src) || isimage(src))
	if(!filter_data)
		return
	var/atom/atom_cast = src // filters only work with images or atoms.
	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)
	. = FALSE
	var/list/new_data = list()
	var/list/new_cache = list()
	for (var/index in 1 to length(filter_data))
		var/list/filter_info = filter_data[index]
		if (!(filter_info["name"] in names))
			new_data += list(filter_info)
			new_cache += filter_cache[index]
	filter_data = new_data
	filter_cache = new_cache
	if (update)
		atom_cast.filters = filter_cache
	return .

/datum/proc/clear_filters()
	ASSERT(isatom(src) || isimage(src))
	var/atom/atom_cast = src // filters only work with images or atoms.
	filter_data = null
	filter_cache = null
	atom_cast.filters = null

/// Calls qdel on itself, because signals dont allow callbacks
/datum/proc/selfdelete()
	SIGNAL_HANDLER
	qdel(src)

/// Return text from this proc to provide extra context to hard deletes that happen to it
/// Optional, you should use this for cases where replication is difficult and extra context is required
/// Can be called more then once per object, use harddel_deets_dumped to avoid duplicate calls (I am so sorry)
/datum/proc/dump_harddel_info()
	return

///images are pretty generic, this should help a bit with tracking harddels related to them
/image/dump_harddel_info()
	if(harddel_deets_dumped)
		return
	harddel_deets_dumped = TRUE
	return "Image icon: [icon] - icon_state: [icon_state] [loc ? "loc: [loc] ([loc.x],[loc.y],[loc.z])" : ""]"
