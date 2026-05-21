/// Global event logger datum, accessible anywhere for debug logging.
GLOBAL_DATUM_INIT(event_logger, /datum/event_logger, new())

/// Enables event logging for a datum. If display_on is supplied then it will report the events as if theyre happening on that datum
/datum/proc/enable_evlogging(datum/display_on = null)
	if(display_on)
		GLOB.event_logger.display_map[REF(src)] = REF(display_on)
	if(datum_flags & DF_EVLOGGING)
		return
	datum_flags |= DF_EVLOGGING
	SEND_SIGNAL(src, COMSIG_EVLOGGING_ENABLED)

/// Disables event logging for a datum. If display_on was supplied during enable_evlogging, it will also remove the display mapping.
/datum/proc/disable_evlogging()
	GLOB.event_logger.display_map -= REF(src)
	if(!(datum_flags & DF_EVLOGGING))
		return
	datum_flags &= ~DF_EVLOGGING
	SEND_SIGNAL(src, COMSIG_EVLOGGING_DISABLED)


///Datum that holds info for a single track of events in the logger. Each track represents a datum that is being tracked. This track is shown in the timeline and when selected shows information on the track.
/datum/event_logger_track
	/// Display name for this track row.
	var/name
	/// String ref key used to identify this track.
	var/ref
	/// List of event assoc lists: id, tick, category, kind, info, + kind-specific fields.
	var/list/events = list()
	/// Assoc list of string (Title) -> string (Info) displayed in the info panel when this track is selected.
	var/list/info = list()

/datum/event_logger_track/New(track_ref, track_name, list/info_data = list())
	ref = track_ref
	name = track_name
	info = info_data

/datum/event_logger_track/Destroy()
	events = null
	info = null
	return ..()

///Datum for the event logger. One of these is made, and everyone shares it. So be nice. This keeps tracks of everything related to the logger
/datum/event_logger
	/// Whether the logger is actively recording.
	var/running = FALSE
	/// world.time at which logging first started (null until first start).
	var/time_start = null
	/// Assoc list: category name -> enabled (TRUE/FALSE).
	var/list/categories = list()
	/// Assoc list: category name -> hex color, assigned when a category is first seen.
	var/list/category_colors = list()

		/// List of colors we use for categories. We loop around once we run out
	var/list/category_palette = list(
			"#4fc3f7", "#81c784", "#ffb74d", "#e57373", "#ba68c8",
			"#4dd0e1", "#fff176", "#f06292", "#a1887f", "#90a4ae",
		)
	/// Assoc list: ref string -> /datum/event_logger_track
	var/list/tracks = list()
	/// Assoc list: string event id -> event assoc list, for quick look-up when selecting events
	var/list/events_by_id = list()
	/// Incrementing id assigned to each logged event.
	var/next_event_id = 0
	/// Ref string of the currently selected track (for the info panel).
	var/selected_ref = null
	/// Assoc list: mob -> list of /image, for overlay cleanup.
	var/list/user_overlays = list()
	/// The mob currently waiting to click a target for pick-target mode, or null.
	var/mob/awaiting_pick_user = null
	/// Assoc list: REF(source datum) -> REF(display datum). Events from the source appear under the display datum's track.
	var/list/display_map = list()

/datum/event_logger/Destroy()
	_clear_all_overlays()
	QDEL_LIST_ASSOC_VAL(tracks)
	tracks = null
	categories = null
	user_overlays = null
	display_map = null
	return ..()

/datum/event_logger/proc/start()
	if(running)
		return
	running = TRUE
	if(isnull(time_start))
		time_start = world.time

/datum/event_logger/proc/stop()
	running = FALSE

/// Enter pick-target mode: the next atom the user clicks gets DF_EVLOGGING set.
/datum/event_logger/proc/toggle_pick_target(mob/user)
	if(awaiting_pick_user)
		_end_pick_target()
	else
		awaiting_pick_user = user
		RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(on_pick_target_click))

/// Signal handler: fired when the user clicks something while in pick-target mode.
/datum/event_logger/proc/on_pick_target_click(mob/source, atom/clicked, list/modifiers)
	SIGNAL_HANDLER
	clicked.enable_evlogging()
	_end_pick_target()
	return NONE

/// Ends pick-target mode, unregistering the click signal and clearing the awaiting_pick_user var.
/datum/event_logger/proc/_end_pick_target()
	if(isnull(awaiting_pick_user))
		return
	UnregisterSignal(awaiting_pick_user, COMSIG_MOB_CLICKON)
	awaiting_pick_user = null

/// Ensures a track exists for ref_string. Safe to call multiple times.
/datum/event_logger/proc/add_track(ref_string, track_name, list/info_data)
	if(tracks[ref_string])
		return
	tracks[ref_string] = new /datum/event_logger_track(ref_string, track_name, info_data)

/// Internal: Sets the event up, making a track if necesary. Also turns the instance into a REF() at this point
/datum/event_logger/proc/_add_event(datum/source, list/event_data)
	if(!running)
		return
	// Resolve display routing: if source has a display_on target, log under that datum's track instead
	var/datum/display_target
	var/display_ref = display_map[REF(source)]
	if(display_ref)
		display_target = locate(display_ref)
		if(!display_target) // display_on was deleted, remove the stale entry. Yeah this is a bit lame, but I felt like registering QDEL might be more of a hassle if we're using REF() anyway. Feel free to @ me over it
			display_map -= REF(source)

	var/datum/track_datum = display_target || source
	var/ref_string = REF(track_datum)
	if(!tracks[ref_string])
		var/track_name
		if(isatom(track_datum))
			var/atom/resolved_atom = track_datum
			track_name = "[ref_string] [resolved_atom] [track_datum.type]"
		else
			track_name = "[ref_string] [track_datum.type]"
		add_track(ref_string, track_name, null)
	var/datum/event_logger_track/track = tracks[ref_string]
	event_data["id"] = ++next_event_id
	event_data["tick"] = world.time
	var/category = event_data["category"]
	if(!isnull(category) && isnull(categories[category]))
		categories[category] = TRUE

		var/selected_index = (length(category_colors) + 1) % (length(category_palette) + 1)

		category_colors[category] = category_palette[selected_index]
	track.events += list(event_data)
	events_by_id["[event_data["id"]]"] = event_data
	SEND_SIGNAL(source, COMSIG_EVLOG_EVENT_ADDED, track, event_data)
	if(display_target)
		SEND_SIGNAL(display_target, COMSIG_EVLOG_EVENT_ADDED, track, event_data)

/// Log a plain text event. Has no world-visuals, just puts text into the menu
/datum/event_logger/proc/log_event_text(datum/source, category, info_string)
	_add_event(source, list(
		"log_type" = EVLOG_TYPE_TEXT,
		"category" = category,
		"info" = info_string,
	))

/// Log a location event (highlights a single tile). I should remove this one as turfs does the same thing essentially
/datum/event_logger/proc/log_event_location(datum/source, category, info_string, turf/T)
	_add_event(source, list(
		"log_type" = EVLOG_TYPE_LOCATION,
		"category" = category,
		"info" = info_string,
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
	))

/// Log a turfs event (highlights a set of tiles).
/datum/event_logger/proc/log_event_turfs(datum/source, category, info_string, list/turfs)
	var/list/coords = list()
	for(var/turf/T as anything in turfs)
		coords += list(list("x" = T.x, "y" = T.y, "z" = T.z))
	_add_event(source, list(
		"log_type" = EVLOG_TYPE_TURFS,
		"category" = category,
		"info" = info_string,
		"coords" = coords,
	))

/// Log a line event (draws a line between 2 turfs).
/datum/event_logger/proc/log_event_lines(datum/source, category, info_string, turf/A, turf/B)
	_add_event(source, list(
		"log_type" = EVLOG_TYPE_LINES,
		"category" = category,
		"info" = info_string,
		"x1" = A.x,
		"y1" = A.y,
		"z1" = A.z,
		"x2" = B.x,
		"y2" = B.y,
		"z2" = B.z,
	))

/// Log a path event (renders directional arrows + start/end markers for a list of turfs in order from start to finish).
/datum/event_logger/proc/log_event_path(datum/source, category, info_string, list/turfs)
	var/list/coords = list()
	for(var/turf/T as anything in turfs)
		coords += list(list("x" = T.x, "y" = T.y, "z" = T.z))
	_add_event(source, list(
		"log_type" = EVLOG_TYPE_PATH,
		"category" = category,
		"info" = info_string,
		"coords" = coords,
	))

/// Log a maptext event (renders a floating text label at the turf when selected). text_string is the string to display at the turf.
/datum/event_logger/proc/log_event_maptext(datum/source, category, info_string, turf/T, text_string)
	_add_event(source, list(
		"log_type" = EVLOG_TYPE_MAPTEXT,
		"category" = category,
		"info" = info_string,
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"text" = text_string,
	))

/// Remove all overlays for a specific user.
/datum/event_logger/proc/_clear_user_overlays(mob/user)
	if(!user_overlays[user])
		return
	if(user.client)
		user.client.images -= user_overlays[user]
	user_overlays -= user

/// Remove all overlays for all users.
/datum/event_logger/proc/_clear_all_overlays()
	for(var/mob/user as anything in user_overlays)
		_clear_user_overlays(user)

/// Push world-space highlight overlays to the user's client for the given events.
/datum/event_logger/proc/_apply_event_overlays(mob/user, list/events_to_show)
	_clear_user_overlays(user)
	if(!user.client || !length(events_to_show))
		return

	var/list/images = list()

	for(var/list/evt as anything in events_to_show)
		var/color = get_category_color(evt["category"])
		var/log_type = evt["log_type"]

		if(log_type == EVLOG_TYPE_LOCATION)
			var/turf/found_turf = locate(evt["x"], evt["y"], evt["z"])
			if(found_turf)
				images += _make_tile_image(found_turf, "box_overlay", color, 0.3)

		else if(log_type == EVLOG_TYPE_TURFS)
			var/list/coords = evt["coords"]
			for(var/list/coord as anything in coords)
				var/turf/found_turf = locate(coord["x"], coord["y"], coord["z"])
				if(found_turf)
					images += _make_tile_image(found_turf, "box_overlay", color, 0.3)

		else if(log_type == EVLOG_TYPE_LINES)
			var/turf/turf_A = locate(evt["x1"], evt["y1"], evt["z1"])
			var/turf/turf_B = locate(evt["x2"], evt["y2"], evt["z2"])
			if(turf_A && turf_B && turf_A != turf_B)
				images += _make_line_images(turf_A, turf_B, color)

		//Use SSPathfinder to render the full path
		else if(log_type == EVLOG_TYPE_PATH)
			var/list/path_turfs = list()
			var/list/coords = evt["coords"]
			for(var/list/coord as anything in coords)
				var/turf/found_turf = locate(coord["x"], coord["y"], coord["z"])
				if(found_turf)
					path_turfs += found_turf
			images += SSpathfinder.render_path_images_full(path_turfs)

		//Draw maptext on a turf which lets us show important events in-world
		else if(log_type == EVLOG_TYPE_MAPTEXT)
			var/turf/found_turf = locate(evt["x"], evt["y"], evt["z"])
			if(found_turf)
				var/image/img = image('icons/turf/debug.dmi', found_turf, "circle", PATH_DEBUG_LAYER)
				SET_PLANE_EXPLICIT(img, BALLOON_CHAT_PLANE, found_turf)
				img.color = color
				img.maptext = MAPTEXT(evt["text"])
				img.maptext_width = 200
				img.maptext_height = 64
				img.maptext_x = 0
				img.maptext_y = 32
				images += img

	if(length(images))
		user_overlays[user] = images
		user.client.images += images

///Draw a line of images similar to beams but client-side. I couldn't find anything like this yet so here we are. Maybe making this a global is a good idea.
/datum/event_logger/proc/_make_line_images(turf/turf_A, turf/turf_B, color)
	var/list/images = list()
	var/beam_icon = 'icons/turf/debug.dmi'
	var/beam_icon_state = "beam"

	var/origin_px = turf_A.pixel_x + turf_A.pixel_w
	var/origin_py = turf_A.pixel_y + turf_A.pixel_z
	var/target_px = turf_B.pixel_x + turf_B.pixel_w
	var/target_py = turf_B.pixel_y + turf_B.pixel_z

	var/Angle = get_angle_raw(turf_A.x, turf_A.y, origin_px, origin_py, turf_B.x, turf_B.y, target_px, target_py)
	var/matrix/rot_matrix = matrix()
	rot_matrix.Turn(Angle)

	var/DX = (ICON_SIZE_X * turf_B.x + target_px) - (ICON_SIZE_X * turf_A.x + origin_px)
	var/DY = (ICON_SIZE_Y * turf_B.y + target_py) - (ICON_SIZE_Y * turf_A.y + origin_py)
	var/line_length = round(sqrt(DX ** 2 + DY ** 2))

	for(var/N in 0 to line_length - 1 step 32)
		var/Pixel_x
		var/Pixel_y
		if(DX == 0)
			Pixel_x = 0
		else
			Pixel_x = round(sin(Angle) + ICON_SIZE_X * sin(Angle) * (N + 16) / 32)
		if(DY == 0)
			Pixel_y = 0
		else
			Pixel_y = round(cos(Angle) + ICON_SIZE_Y * cos(Angle) * (N + 16) / 32)

		var/final_x = turf_A.x
		var/final_y = turf_A.y
		if(abs(Pixel_x) > ICON_SIZE_X)
			final_x += Pixel_x > 0 ? round(Pixel_x / ICON_SIZE_X) : ceil(Pixel_x / ICON_SIZE_X)
			Pixel_x %= ICON_SIZE_X
		if(abs(Pixel_y) > ICON_SIZE_Y)
			final_y += Pixel_y > 0 ? round(Pixel_y / ICON_SIZE_Y) : ceil(Pixel_y / ICON_SIZE_Y)
			Pixel_y %= ICON_SIZE_Y

		var/turf/seg_turf = locate(final_x, final_y, turf_A.z)
		if(!seg_turf)
			continue

		var/image/img = image(beam_icon, seg_turf, beam_icon_state, PATH_DEBUG_LAYER)
		SET_PLANE_EXPLICIT(img, BALLOON_CHAT_PLANE, seg_turf)
		if(N + 32 > line_length)
			// Terminal segment: crop the icon to avoid overshooting the target
			var/icon/clipped = new(beam_icon, beam_icon_state)
			clipped.DrawBox(null, 1, (line_length - N), 32, 32)
			img.icon = clipped
		img.color = color
		img.transform = rot_matrix
		img.pixel_x = origin_px + Pixel_x
		img.pixel_y = origin_py + Pixel_y
		images += img

	return images


/// Creates a single coloured tile overlay image.
/datum/event_logger/proc/_make_tile_image(turf/selected_turf, icon_state, color, alpha_fraction)
	var/image/img = image('icons/turf/debug.dmi', selected_turf, icon_state, PATH_DEBUG_LAYER)
	SET_PLANE_EXPLICIT(img, BALLOON_CHAT_PLANE, selected_turf)
	img.color = color
	img.alpha = round(alpha_fraction * 255)
	return img

/// Returns the hex color string for a category, or white if unknown.
/datum/event_logger/proc/get_category_color(category)
	return category_colors[category] || "#ffffff"

/// Clears all tracks, categories and overlays.
/datum/event_logger/proc/clear()
	_clear_all_overlays()
	QDEL_LIST_ASSOC_VAL(tracks)
	tracks = list()
	events_by_id = list()
	categories = list()
	category_colors = list()
	next_event_id = 0
	selected_ref = null
	time_start = null
	running = FALSE

///Tgui stuff below!!


/datum/event_logger/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/chat_dark),
	)

/datum/event_logger/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EventLogger", "Event Logger")
		ui.open()

/datum/event_logger/ui_close(mob/user)
	. = ..()
	_clear_user_overlays(user)
	if(awaiting_pick_user == user)
		_end_pick_target()

/datum/event_logger/ui_state(mob/user)
	return ADMIN_STATE(R_DEBUG)

/datum/event_logger/ui_data(mob/user)
	var/list/data = list()

	data["running"] = running
	data["time_start"] = time_start
	data["time_current"] = world.time
	data["selected_ref"] = selected_ref
	data["awaiting_pick"] = !isnull(awaiting_pick_user)

	// Categories
	var/list/cats = list() //meow
	for(var/cat, enabled in categories)
		cats += list(list("name" = cat, "enabled" = enabled))
	data["categories"] = cats

	// Tracks
	var/list/track_list = list()
	for(var/ref, track_val in tracks)
		var/datum/event_logger_track/track = track_val

		// Converts track info to a list for tgui
		var/list/info_pairs = list()
		for(var/title, entry in track.info)
			info_pairs += list(list("title" = title, "entry" = entry))

		track_list += list(list(
			"name" = track.name,
			"ref" = track.ref,
			"events" = track.events,
			"info" = info_pairs,
		))
	data["tracks"] = track_list

	return data

/datum/event_logger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	switch(action)
		if("toggle_running") //Start or stop the logger
			if(running)
				stop()
			else
				start()
			return TRUE

		if("toggle_category") //Enable categories
			var/cat = params["name"]
			if(!isnull(categories[cat]))
				categories[cat] = !categories[cat]
			return TRUE

		if("select_track") //Select a track on the timeline
			selected_ref = params["ref"]
			return TRUE

		if("select_events") ///We selected events on the timeline, clear old overlays, add new ones.
			var/list/ids = params["ids"]
			if(!islist(ids) || !length(ids))
				_clear_user_overlays(user)
				return TRUE

			var/list/matched = list()
			for(var/id in ids)
				var/list/evt = events_by_id["[id]"]
				if(evt)
					matched += list(evt)

			_apply_event_overlays(user, matched)
			return TRUE

		if("clear")
			clear()
			return TRUE

		if("start_pick_target")
			toggle_pick_target(user)
			return TRUE

		if("disable_evlogging")
			var/track_ref = params["ref"]
			var/datum/target = locate(track_ref)
			if(!target)
				return FALSE
			if(tgui_alert(user, "Stop tracking [target]?", "Confirm", list("Stop Tracking", "Cancel")) != "Stop Tracking")
				return FALSE
			target.disable_evlogging()
			return TRUE

		if("remove_track") // Removes a track and all its events from the logger entirely, and stops tracking the datum
			var/track_ref = params["ref"]
			var/datum/event_logger_track/track = tracks[track_ref]
			if(!track)
				return FALSE
			// Remove all events from events_by_id
			for(var/list/evt as anything in track.events)
				events_by_id -= "[evt["id"]]"
			// Disable evlogging on the datum if it still exists
			var/datum/target = locate(track_ref)
			if(target)
				target.disable_evlogging()
			// Clear overlays and deselect if this was the selected track
			_clear_user_overlays(user)
			if(selected_ref == track_ref)
				selected_ref = null
			qdel(track)
			tracks -= track_ref
			return TRUE

		if("teleport_to_event")
			var/target_id = params["id"]
			var/list/found_evt = events_by_id["[target_id]"]
			if(!found_evt)
				return FALSE
			var/dest_x
			var/dest_y
			var/dest_z
			switch(found_evt["log_type"])
				if(EVLOG_TYPE_LOCATION, EVLOG_TYPE_MAPTEXT)
					dest_x = found_evt["x"]
					dest_y = found_evt["y"]
					dest_z = found_evt["z"]
				if(EVLOG_TYPE_TURFS, EVLOG_TYPE_PATH)
					var/list/coords = found_evt["coords"]
					if(!length(coords))
						return FALSE
					var/list/first = coords[1]
					dest_x = first["x"]
					dest_y = first["y"]
					dest_z = first["z"]
				if(EVLOG_TYPE_LINES)
					dest_x = found_evt["x1"]
					dest_y = found_evt["y1"]
					dest_z = found_evt["z1"]
				else
					return FALSE
			var/turf/dest = locate(dest_x, dest_y, dest_z)
			if(!dest)
				return FALSE
			user.forceMove(dest)
			return TRUE
