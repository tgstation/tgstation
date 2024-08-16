/// Ensures all airlocks have all the icon states they need to function
/datum/unit_test/airlock_icon_states

/datum/unit_test/airlock_icon_states/Run()
	var/list/required_icon_states = list(
		"opening" = FALSE,
		"closing" = FALSE,
		"open_top" = FALSE,
		"open_bottom" = FALSE,
		"closed" = FALSE,
		"construction" = FALSE,
	)
	// Icon states to use for anything without a tall sprite (deprecated to be removed when all are replaced)
	var/list/legacy_required_states = list(
		"opening" = FALSE,
		"closing" = FALSE,
		"open" = FALSE,
		"closed" = FALSE,
		"construction" = FALSE,
	)

	var/short_found = FALSE
	for(var/obj/machinery/door/airlock/airlock_path as anything in typesof(/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/real_lock = allocate(airlock_path)
		var/icon/airlock_icon = icon(real_lock.icon)
		var/list/existing_icon_states = required_icon_states.Copy()
		// Remove this someday
		if(real_lock.short_rendering)
			existing_icon_states = legacy_required_states.Copy()
			short_found = TRUE

		for(var/icon_state in icon_states(airlock_icon))
			if(!(icon_state in existing_icon_states)) // Ignore gags defaults please
				continue
			existing_icon_states[icon_state] = TRUE

			if(real_lock.short_rendering || has_directionals(airlock_icon, icon_state))
				continue
			TEST_FAIL("[airlock_path] was missing directional icon states for \"[icon_state]\"")

		for(var/possible_state in existing_icon_states)
			if(existing_icon_states[possible_state])
				continue
			TEST_FAIL("[airlock_path] was missing the required \"[possible_state]\" icon state")

	if(!short_found)
		TEST_FAIL("No short airlocks were found! Please remove short_rendering and its uses as it is now redundant")

/// Retruns true if the passed in icon has unique sprites for all 4 directions, false otherwise
/datum/unit_test/airlock_icon_states/proc/has_directionals(icon/input, state)
	var/icon/turned_right = icon(input, icon_state = state, dir = EAST)
	var/icon/turned_up = icon(input, icon_state = state, dir = NORTH)
	return icon2base64(turned_right) != icon2base64(turned_up)
