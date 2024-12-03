/atom
	///overlays managed by [update_overlays][/atom/proc/update_overlays] to prevent removing overlays that weren't added by the same proc. Single items are stored on their own, not in a list.
	var/list/managed_overlays

/**
 * Updates the appearence of the icon
 *
 * Mostly delegates to update_name, update_desc, and update_icon
 *
 * Arguments:
 * - updates: A set of bitflags dictating what should be updated. Defaults to [ALL]
 */
/atom/proc/update_appearance(updates=ALL)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_APPEARANCE, updates)
	if(updates & UPDATE_NAME)
		. |= update_name(updates)
	if(updates & UPDATE_DESC)
		. |= update_desc(updates)
	if(updates & UPDATE_ICON)
		. |= update_icon(updates)

/// Updates the name of the atom
/atom/proc/update_name(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_NAME, updates)

/// Updates the description of the atom
/atom/proc/update_desc(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_DESC, updates)

/// Updates the icon of the atom
/atom/proc/update_icon(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON, updates)
	if(updates & UPDATE_ICON_STATE)
		update_icon_state()
		. |= UPDATE_ICON_STATE

	if(updates & UPDATE_OVERLAYS)
		if(LAZYLEN(managed_vis_overlays))
			SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

		var/list/new_overlays = update_overlays(updates)
		var/nulls = 0
		for(var/i in 1 to length(new_overlays))
			var/atom/maybe_not_an_atom = new_overlays[i]
			if(isnull(maybe_not_an_atom))
				nulls++
				continue
			if(istext(maybe_not_an_atom) || isicon(maybe_not_an_atom))
				continue
			new_overlays[i] = maybe_not_an_atom.appearance
		if(nulls)
			for(var/i in 1 to nulls)
				new_overlays -= null

		var/identical = FALSE
		var/new_length = length(new_overlays)
		if(!managed_overlays && !new_length)
			identical = TRUE
		else if(!islist(managed_overlays))
			if(new_length == 1 && managed_overlays == new_overlays[1])
				identical = TRUE
		else if(length(managed_overlays) == new_length)
			identical = TRUE
			for(var/i in 1 to length(managed_overlays))
				if(managed_overlays[i] != new_overlays[i])
					identical = FALSE
					break

		if(!identical)
			var/full_control = FALSE
			if(managed_overlays)
				full_control = length(overlays) == (islist(managed_overlays) ? length(managed_overlays) : 1)
				if(full_control)
					overlays = null
				else
					cut_overlay(managed_overlays)

			switch(length(new_overlays))
				if(0)
					if(full_control)
						POST_OVERLAY_CHANGE(src)
					managed_overlays = null
				if(1)
					add_overlay(new_overlays)
					managed_overlays = new_overlays[1]
				else
					add_overlay(new_overlays)
					managed_overlays = new_overlays

		. |= UPDATE_OVERLAYS

	. |= SEND_SIGNAL(src, COMSIG_ATOM_UPDATED_ICON, updates, .)

/// Updates the icon state of the atom
/atom/proc/update_icon_state()
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)

/// Updates the overlays of the atom
/atom/proc/update_overlays()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, .)
