
/*Current movespeed modification list format: list(id = list(
	priority,
	flags,
	legacy slowdown/speedup amount,
	movetype_flags
	))
*/

//ANY ADD/REMOVE DONE IN UPDATE_MOVESPEED MUST HAVE THE UPDATE ARGUMENT SET AS FALSE!
/mob/proc/add_movespeed_modifier(id, update=TRUE, priority=0, flags=NONE, override=FALSE, multiplicative_slowdown=0, movetypes=ALL, blacklisted_movetypes=NONE, conflict=FALSE)
	var/list/temp = list(priority, flags, multiplicative_slowdown, movetypes, blacklisted_movetypes, conflict) //build the modification list
	var/resort = TRUE
	if(LAZYACCESS(movespeed_modification, id))
		var/list/existing_data = movespeed_modification[id]
		if(movespeed_modifier_identical_check(existing_data, temp))
			return FALSE
		if(!override)
			return FALSE
		if(priority == existing_data[MOVESPEED_DATA_INDEX_PRIORITY])
			resort = FALSE // We don't need to re-sort if we're replacing something already there and it's the same priority
	LAZYSET(movespeed_modification, id, temp)
	if(update)
		update_movespeed(resort)
	return TRUE

/mob/proc/remove_movespeed_modifier(id, update = TRUE)
	if(!LAZYACCESS(movespeed_modification, id))
		return FALSE
	LAZYREMOVE(movespeed_modification, id)
	UNSETEMPTY(movespeed_modification)
	if(update)
		update_movespeed(FALSE)
	return TRUE

/mob/vv_edit_var(var_name, var_value)
	var/slowdown_edit = (var_name == NAMEOF(src, cached_multiplicative_slowdown))
	var/diff
	if(slowdown_edit && isnum(cached_multiplicative_slowdown) && isnum(var_value))
		remove_movespeed_modifier(MOVESPEED_ID_ADMIN_VAREDIT)
		diff = var_value - cached_multiplicative_slowdown
	. = ..()
	if(. && slowdown_edit && isnum(diff))
		add_movespeed_modifier(MOVESPEED_ID_ADMIN_VAREDIT, TRUE, 100, override = TRUE, multiplicative_slowdown = diff)

/mob/proc/has_movespeed_modifier(id)
	return LAZYACCESS(movespeed_modification, id)

/mob/proc/update_config_movespeed()
	add_movespeed_modifier(MOVESPEED_ID_CONFIG_SPEEDMOD, FALSE, 100, override = TRUE, multiplicative_slowdown = get_config_multiplicative_speed())

/mob/proc/get_config_multiplicative_speed()
	if(!islist(GLOB.mob_config_movespeed_type_lookup) || !GLOB.mob_config_movespeed_type_lookup[type])
		return 0
	else
		return GLOB.mob_config_movespeed_type_lookup[type]

/mob/proc/update_movespeed(resort = TRUE)
	if(resort)
		sort_movespeed_modlist()
	. = 0
	var/list/conflict_tracker = list()
	for(var/id in get_movespeed_modifiers())
		var/list/data = movespeed_modification[id]
		if(!(data[MOVESPEED_DATA_INDEX_MOVETYPE] & movement_type)) // We don't affect any of these move types, skip
			continue
		if(data[MOVESPEED_DATA_INDEX_BL_MOVETYPE] & movement_type) // There's a movetype here that disables this modifier, skip
			continue
		var/conflict = data[MOVESPEED_DATA_INDEX_CONFLICT]
		var/amt = data[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN]
		if(conflict)
			// Conflicting modifiers prioritize the larger slowdown or the larger speedup
			// We purposefuly don't handle mixing speedups and slowdowns on the same id
			if(abs(conflict_tracker[conflict]) < abs(amt))
				conflict_tracker[conflict] = amt
			else
				continue
		. += amt
	cached_multiplicative_slowdown = .
	set_glide_size(DELAY_TO_GLIDE_SIZE(cached_multiplicative_slowdown))

/mob/proc/get_movespeed_modifiers()
	return movespeed_modification

/mob/proc/movespeed_modifier_identical_check(list/mod1, list/mod2)
	if(!islist(mod1) || !islist(mod2) || mod1.len < MOVESPEED_DATA_INDEX_MAX || mod2.len < MOVESPEED_DATA_INDEX_MAX)
		return FALSE
	for(var/i in 1 to MOVESPEED_DATA_INDEX_MAX)
		if(mod1[i] != mod2[i])
			return FALSE
	return TRUE

/mob/proc/total_multiplicative_slowdown()
	. = 0
	for(var/id in get_movespeed_modifiers())
		var/list/data = movespeed_modification[id]
		. += data[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN]

/proc/movespeed_data_null_check(list/data)		//Determines if a data list is not meaningful and should be discarded.
	. = TRUE
	if(data[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN])
		. = FALSE

/mob/proc/sort_movespeed_modlist()			//Verifies it too. Sorts highest priority (first applied) to lowest priority (last applied)
	if(!movespeed_modification)
		return
	var/list/assembled = list()
	for(var/our_id in movespeed_modification)
		var/list/our_data = movespeed_modification[our_id]
		if(!islist(our_data) || (our_data.len < MOVESPEED_DATA_INDEX_PRIORITY) || movespeed_data_null_check(our_data))
			movespeed_modification -= our_id
			continue
		var/our_priority = our_data[MOVESPEED_DATA_INDEX_PRIORITY]
		var/resolved = FALSE
		for(var/their_id in assembled)
			var/list/their_data = assembled[their_id]
			if(their_data[MOVESPEED_DATA_INDEX_PRIORITY] < our_priority)
				assembled.Insert(assembled.Find(their_id), our_id)
				assembled[our_id] = our_data
				resolved = TRUE
				break
		if(!resolved)
			assembled[our_id] = our_data
	movespeed_modification = assembled
	UNSETEMPTY(movespeed_modification)
