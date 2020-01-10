/**
  * Movespeed modification datums.
  */

/datum/movespeed_modifier
	/// Unique ID. You can never have different modifications with the same ID
	var/id = "ERROR"

	/// Higher ones override lower priorities. This is NOT used for ID, ID must be unique, if it isn't unique the newer one overwrites automatically if overriding.
	var/priority = 0
	var/flags = NONE

	/// Multiplicative slowdown
	var/multiplicative_slowdown = 0

	/// Movetypes this applies to
	var/movetypes = ALL

	/// Movetypes this never applies to
	var/blacklisted_movetypes = NONE

	/// Other modification datums this conflicts with.
	var/conflicts_with

/*! How move speed for mobs works

Move speed is now calculated by using a list of movespeed modifiers, which is a list itself (to avoid datum overhead)

This gives us the ability to have multiple sources of movespeed, reliabily keep them applied and remove them when they should be

THey can have unique sources and a bunch of extra fancy flags that control behaviour

Previously trying to update move speed was a shot in the dark that usually meant mobs got stuck going faster or slower

This list takes the following format

```Current movespeed modification list format:
		list(
			id = list(
				priority,
				flags,
				legacy slowdown/speedup amount,
				movetype_flags
			)
		)
```

WHen update movespeed is called, the list of items is iterated, according to flags priority and a bunch of conditions
this spits out a final calculated value which is used as a modifer to last_move + modifier for calculating when a mob
can next move

Key procs
* [add_movespeed_modifier](mob.html#proc/add_movespeed_modifier)
* [remove_movespeed_modifier](mob.html#proc/remove_movespeed_modifier)
* [has_movespeed_modifier](mob.html#proc/has_movespeed_modifier)
* [update_movespeed](mob.html#proc/update_movespeed)
*/

//ANY ADD/REMOVE DONE IN UPDATE_MOVESPEED MUST HAVE THE UPDATE ARGUMENT SET AS FALSE!

GLOBAL_LIST_EMPTY(movespeed_modification_cache)

/// Grabs a STATIC MODIFIER datum from cache. YOU MUST NEVER EDIT THESE DATUMS, OR IT WILL AFFECT ANYTHING ELSE USING IT TOO!
/proc/get_cached_movespeed_modification(modtype)
	if(!ispath(modtype, /datum/movespeed_modifier))
		CRASH("[modtype] is not a movespeed modification type.")
	var/datum/movespeed_modifier/M = GLOB.movespeed_modification_cache[modtype] || ((GLOB.movespeed_modification_cache[modtype] = new modtype))
	return M

///Add a move speed modifier to a mob
/mob/proc/_REFACTORING_add_movespeed_modifier(datum/movespeed_modifier/type_or_datum, update = TRUE, override = FALSE)
	if(ispath(type_or_datum))
		type_or_datum = get_cached_movespeed_modification(type_or_datum)
	if(!istype(type_or_datum))
		CRASH("Invalid modification datum")
	var/oldpriority
	var/datum/movespeed_modifier/existing = LAZYACCESS(movespeed_modification, type_or_datum.id)
	if(existing)
		if(existing == type_or_datum)		//same thing don't need to touch
			return TRUE
		if(!override)						//not overriding, do not overwrite same ID.
			return FALSE
		oldpriority = existing.priority
		remove_movespeed_modifier(existing, FLASE)
	LAZYSET(movespeed_modification, type_or_datum.id, type_or_datum)
	var/resort = type_or_datum.priority == oldpriority
	if(update)
		update_movespeed(resort)
	return TRUE

///Remove a move speed modifier from a mob
/mob/proc/_REFACTORING_remove_movespeed_modifier(datum/movespeed_modifier/type_id_datum, update = TRUE)
	if(ispath(type_id_datum))
		type_id_datum = get_cached_movespeed_modification(type_id_datum)
	if(istype(type_id_datum))
		type_id_datum = type_id_datum.id
	if(!LAZYACCESS(movespeed_modification, type_id_datum))
		return FALSE
	LAZYREMOVE(movespeed_modification, type_id_datum)
	UNSETEMPTY(movespeed_modification)
	if(update)
		update_movespeed(FALSE)
	return TRUE

///Handles the special case of editing the movement var
/mob/vv_edit_var(var_name, var_value)
	var/slowdown_edit = (var_name == NAMEOF(src, cached_multiplicative_slowdown))
	var/diff
	if(slowdown_edit && isnum(cached_multiplicative_slowdown) && isnum(var_value))
		remove_movespeed_modifier(MOVESPEED_ID_ADMIN_VAREDIT)
		diff = var_value - cached_multiplicative_slowdown
	. = ..()
	if(. && slowdown_edit && isnum(diff))
		add_movespeed_modifier(MOVESPEED_ID_ADMIN_VAREDIT, TRUE, 100, override = TRUE, multiplicative_slowdown = diff)

///Is there a movespeed modifier for this mob
/mob/proc/has_movespeed_modifier(datum/movespeed_modifier/datum_type_id)
	if(ispath(datum_type_id))
		datum_type_id = get_cached_movespeed_modification(datum_type_id)
	if(istype(datum_type_id))
		datum_type_id = datum_type_id.id
	return LAZYACCESS(movespeed_modification, datum_type_id)

///Set or update the global movespeed config on a mob
/mob/proc/update_config_movespeed()
	add_movespeed_modifier(MOVESPEED_ID_CONFIG_SPEEDMOD, FALSE, 100, override = TRUE, multiplicative_slowdown = get_config_multiplicative_speed())

///Get the global config movespeed of a mob by type
/mob/proc/get_config_multiplicative_speed()
	if(!islist(GLOB.mob_config_movespeed_type_lookup) || !GLOB.mob_config_movespeed_type_lookup[type])
		return 0
	else
		return GLOB.mob_config_movespeed_type_lookup[type]

///Go through the list of movespeed modifiers and calculate a final movespeed
/mob/proc/update_movespeed(resort = TRUE)
	if(resort)
		sort_movespeed_modlist()
	. = 0
	var/list/conflict_tracker = list()
	for(var/id in get_movespeed_modifiers())
		var/datum/movespeed_modifier/M = movespeed_modification[id]
		if(!(M.movetypes & movement_type)) // We don't affect any of these move types, skip
			continue
		if(M.blacklisted_movetypes & movement_type) // There's a movetype here that disables this modifier, skip
			continue
		var/conflict = M.conflict
		var/amt = M.multiplicative_slowdown
		if(conflict)
			// Conflicting modifiers prioritize the larger slowdown or the larger speedup
			// We purposefuly don't handle mixing speedups and slowdowns on the same id
			if(abs(conflict_tracker[conflict]) < abs(amt))
				conflict_tracker[conflict] = amt
			else
				continue
		. += amt
	cached_multiplicative_slowdown = .

///Get the move speed modifiers list of the mob
/mob/proc/get_movespeed_modifiers()
	return movespeed_modification

///Calculate the total slowdown of all movespeed modifiers
/mob/proc/total_multiplicative_slowdown()
	. = 0
	for(var/id in get_movespeed_modifiers())
		var/list/data = movespeed_modification[id]
		. += data[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN]

///Checks if a move speed modifier is valid and not missing any data
/proc/movespeed_data_null_check(list/data)		//Determines if a data list is not meaningful and should be discarded.
	. = TRUE
	if(data[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN])
		. = FALSE

/**
  * Sort the list of move speed modifiers
  *
  * Verifies it too. Sorts highest priority (first applied) to lowest priority (last applied)
  */
/mob/proc/sort_movespeed_modlist()
	if(!movespeed_modification)
		return
	var/list/assembled = list()
	for(var/our_id in movespeed_modification)
		var/datum/movespeed_modifier/M = movespeed_modification[our_id]
		if(!istype(M) || movespeed_data_null_check(M))
			movespeed_modification -= our_id
			continue
		var/our_priority = M.priority
		var/resolved = FALSE
		for(var/their_id in assembled)
			var/datum/movespeed_modifier/other = assembled[their_id]
			if(other.priority < our_priority)
				assembled.Insert(assembled.Find(their_id), our_id)
				assembled[our_id] = M
				resolved = TRUE
				break
		if(!resolved)
			assembled[our_id] = M
	movespeed_modification = assembled
	UNSETEMPTY(movespeed_modification)
