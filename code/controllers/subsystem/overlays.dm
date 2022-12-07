SUBSYSTEM_DEF(overlays)
	name = "Overlay"
	flags = SS_NO_FIRE|SS_NO_INIT
	var/list/stats

/datum/controller/subsystem/overlays/PreInit()
	stats = list()

/datum/controller/subsystem/overlays/Shutdown()
	text2file(render_stats(stats), "[GLOB.log_directory]/overlay.log")

/datum/controller/subsystem/overlays/Recover()
	stats = SSoverlays.stats

/// Converts an overlay list into text for debug printing
/// Of note: overlays aren't actually mutable appearances, they're just appearances
/// Don't have access to that type tho, so this is the best you're gonna get
/proc/overlays2text(list/overlays)
	var/list/unique_overlays = list()
	// As anything because we're basically doing type coerrsion, rather then actually filtering for mutable apperances
	for(var/mutable_appearance/overlay as anything in overlays)
		var/key = "[overlay.icon]-[overlay.icon_state]-[overlay.dir]"
		unique_overlays[key] += 1
	var/list/output_text = list()
	for(var/key in unique_overlays)
		output_text += "([key]) = [unique_overlays[key]]"
	return output_text.Join("\n")

/proc/iconstate2appearance(icon, iconstate)
	var/static/image/stringbro = new()
	stringbro.icon = icon
	stringbro.icon_state = iconstate
	return stringbro.appearance

/proc/icon2appearance(icon)
	var/static/image/iconbro = new()
	iconbro.icon = icon
	return iconbro.appearance

/atom/proc/build_appearance_list(list/build_overlays)
	if (!islist(build_overlays))
		build_overlays = list(build_overlays)
	for (var/overlay in build_overlays)
		if(!overlay)
			build_overlays -= overlay
			continue
		if (istext(overlay))
			// This is too expensive to run normally but running it during CI is a good test
			if (PERFORM_ALL_TESTS(focus_only/invalid_overlays))
				var/list/icon_states_available = icon_states(icon)
				if(!(overlay in icon_states_available))
					var/icon_file = "[icon]" || "Unknown Generated Icon"
					stack_trace("Invalid overlay: Icon object '[icon_file]' [REF(icon)] used in '[src]' [type] is missing icon state [overlay].")
					continue

			var/index = build_overlays.Find(overlay)
			build_overlays[index] = iconstate2appearance(icon, overlay)
		else if(isicon(overlay))
			var/index = build_overlays.Find(overlay)
			build_overlays[index] = icon2appearance(overlay)
	return build_overlays

/atom/proc/cut_overlays()
	STAT_START_STOPWATCH
	overlays = null
	POST_OVERLAY_CHANGE(src)
	STAT_STOP_STOPWATCH
	STAT_LOG_ENTRY(SSoverlays.stats, type)

/atom/proc/cut_overlay(list/remove_overlays)
	if(!overlays)
		return
	STAT_START_STOPWATCH
	overlays -= build_appearance_list(remove_overlays)
	POST_OVERLAY_CHANGE(src)
	STAT_STOP_STOPWATCH
	STAT_LOG_ENTRY(SSoverlays.stats, type)

/atom/proc/add_overlay(list/add_overlays)
	if(!overlays)
		return
	STAT_START_STOPWATCH
	overlays += build_appearance_list(add_overlays)
	POST_OVERLAY_CHANGE(src)
	STAT_STOP_STOPWATCH
	STAT_LOG_ENTRY(SSoverlays.stats, type)

/atom/proc/copy_overlays(atom/other, cut_old) //copys our_overlays from another atom
	if(!other)
		if(cut_old)
			cut_overlays()
		return

	STAT_START_STOPWATCH
	var/list/cached_other = other.overlays.Copy()
	if(cut_old)
		if(cached_other)
			overlays = cached_other
		else
			overlays = null
		POST_OVERLAY_CHANGE(src)
		STAT_STOP_STOPWATCH
		STAT_LOG_ENTRY(SSoverlays.stats, type)
	else if(cached_other)
		overlays += cached_other
		POST_OVERLAY_CHANGE(src)
		STAT_STOP_STOPWATCH
		STAT_LOG_ENTRY(SSoverlays.stats, type)

//TODO: Better solution for these?
/image/proc/add_overlay(x)
	overlays |= x

/image/proc/cut_overlay(x)
	overlays -= x

/image/proc/cut_overlays(x)
	overlays.Cut()

/image/proc/copy_overlays(atom/other, cut_old)
	if(!other)
		if(cut_old)
			cut_overlays()
		return

	var/list/cached_other = other.overlays.Copy()
	if(cached_other)
		if(cut_old || !overlays.len)
			overlays = cached_other
		else
			overlays |= cached_other
	else if(cut_old)
		cut_overlays()

// Debug procs

/atom
	/// List of overlay "keys" (info about the appearance) -> mutable versions of static appearances
	/// Drawn from the overlays list
	var/list/realized_overlays

/image
	/// List of overlay "keys" (info about the appearance) -> mutable versions of static appearances
	/// Drawn from the overlays list
	var/list/realized_overlays

/// Takes the atoms's existing overlays, and makes them mutable so they can be properly vv'd in the realized_overlays list
/atom/proc/realize_overlays()
	realized_overlays = list()
	var/list/queue = overlays.Copy()
	var/queue_index = 0
	while(queue_index < length(queue))
		queue_index++
		// If it's not a command, we assert that it's an appearance
		var/mutable_appearance/appearance = queue[queue_index]
		if(!appearance) // Who fucking adds nulls to their sublists god you people are the worst
			continue

		var/mutable_appearance/new_appearance = new /mutable_appearance()
		new_appearance.appearance = appearance
		var/key = "[appearance.icon]-[appearance.icon_state]-[appearance.plane]-[appearance.layer]-[appearance.dir]-[appearance.color]"
		var/tmp_key = key
		var/overlay_indx = 1
		while(realized_overlays[tmp_key])
			tmp_key = "[key]-[overlay_indx]"
			overlay_indx++

		realized_overlays[tmp_key] = new_appearance
		// Now check its children
		for(var/mutable_appearance/child_appearance as anything in appearance.overlays)
			queue += child_appearance

/// Takes the image's existing overlays, and makes them mutable so they can be properly vv'd in the realized_overlays list
/image/proc/realize_overlays()
	realized_overlays = list()
	var/list/queue = overlays.Copy()
	var/queue_index = 0
	while(queue_index < length(queue))
		queue_index++
		// If it's not a command, we assert that it's an appearance
		var/mutable_appearance/appearance = queue[queue_index]
		if(!appearance) // Who fucking adds nulls to their sublists god you people are the worst
			continue

		var/mutable_appearance/new_appearance = new /mutable_appearance()
		new_appearance.appearance = appearance
		var/key = "[appearance.icon]-[appearance.icon_state]-[appearance.plane]-[appearance.layer]-[appearance.dir]-[appearance.color]"
		var/tmp_key = key
		var/overlay_indx = 1
		while(realized_overlays[tmp_key])
			tmp_key = "[key]-[overlay_indx]"
			overlay_indx++

		realized_overlays[tmp_key] = new_appearance
		// Now check its children
		for(var/mutable_appearance/child_appearance as anything in appearance.overlays)
			queue += child_appearance

/// Takes two appearances as args, prints out, logs, and returns a text representation of their differences
/// Including suboverlays
/proc/diff_appearances(mutable_appearance/first, mutable_appearance/second, iter = 0)
	var/list/diffs = list()
	var/list/firstdeet = first.vars
	var/list/seconddeet = second.vars
	var/diff_found = FALSE
	for(var/name in first.vars)
		var/firstv = firstdeet[name]
		var/secondv = seconddeet[name]
		if(firstv ~= secondv)
			continue
		if((islist(firstv) || islist(secondv)) && length(firstv) == 0 && length(secondv) == 0)
			continue
		if(name == "vars") // Go away
			continue
		if(name == "comp_lookup") // This is just gonna happen with marked datums, don't care
			continue
		if(name == "overlays")
			first.realize_overlays()
			second.realize_overlays()
			var/overlays_differ = FALSE
			for(var/i in 1 to length(first.realized_overlays))
				if(diff_appearances(first.realized_overlays[i], second.realized_overlays[i], iter + 1))
					overlays_differ = TRUE

			if(!overlays_differ)
				continue

		diff_found = TRUE
		diffs += "Diffs detected at [name]: First ([firstv]), Second ([secondv])"

	var/text = "Depth of: [iter]\n\t[diffs.Join("\n\t")]"
	message_admins(text)
	log_world(text)
	return diff_found
