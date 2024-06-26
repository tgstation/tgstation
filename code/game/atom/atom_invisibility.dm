// Index defines
#define INVISIBILITY_VALUE 1
#define INVISIBILITY_PRIORITY 2

/atom
	VAR_PRIVATE/list/invisibility_sources
	VAR_PRIVATE/current_invisibility_priority = -INFINITY

/atom/proc/RecalculateInvisibility()
	PRIVATE_PROC(TRUE)

	if(!invisibility_sources)
		current_invisibility_priority = -INFINITY
		invisibility = initial(invisibility)
		return

	var/highest_priority
	var/list/highest_priority_invisibility_data
	for(var/entry in invisibility_sources)
		var/list/priority_data
		if(islist(entry))
			priority_data = entry
		else
			priority_data = invisibility_sources[entry]

		var/priority = priority_data[INVISIBILITY_PRIORITY]
		if(highest_priority > priority) // In the case of equal priorities, we use the last thing in the list so that more recent changes apply first
			continue

		highest_priority = priority
		highest_priority_invisibility_data = priority_data

	current_invisibility_priority = highest_priority
	invisibility = highest_priority_invisibility_data[INVISIBILITY_VALUE]

/**
 * Sets invisibility according to priority.
 * If you want to be able to undo the value you set back to what it would be otherwise,
 * you should provide an id here and remove it using RemoveInvisibility(id)
 */
/atom/proc/SetInvisibility(desired_value, id, priority=0)
	if(!invisibility_sources)
		invisibility_sources = list()

	if(id)
		invisibility_sources[id] = list(desired_value, priority)
	else
		invisibility_sources += list(list(desired_value, priority))

	if(current_invisibility_priority > priority)
		return

	RecalculateInvisibility()

/// Removes the specified invisibility source from the tracker
/atom/proc/RemoveInvisibility(id)
	if(!invisibility_sources?[id])
		return

	var/list/priority_data = invisibility_sources[id]
	invisibility_sources -= id

	if(length(invisibility_sources) == 0)
		invisibility_sources = null

	if(current_invisibility_priority > priority_data[INVISIBILITY_PRIORITY])
		return

	RecalculateInvisibility()

#undef INVISIBILITY_VALUE
#undef INVISIBILITY_PRIORITY
